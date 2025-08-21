# -------------------------------------------------------
# Stage 1: Build FreeSWITCH from source
# -------------------------------------------------------
FROM debian:bookworm-slim as builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf automake autotools-dev binutils-dev build-essential cmake curl \
    ca-certificates clang \
    git lsb-release gnupg2 wget unzip \
    libtool libtool-bin pkg-config \
    libncurses5-dev libjpeg-dev libcurl4-openssl-dev \
    libedit-dev libsqlite3-dev libopus-dev libssl-dev libspeexdsp-dev \
    libavformat-dev libswscale-dev libswresample-dev libavcodec-dev libavutil-dev \
    libsndfile1-dev libshout3-dev libmpg123-dev libmp3lame-dev libflac-dev \
    libogg-dev libvorbis-dev libyuv-dev libspandsp-dev libtiff-dev libxml2-dev \
    libpq-dev libgnutls28-dev libonig-dev \
    libfreetype6-dev libpng-dev \
    libvpx-dev libavresample-dev \
    libuuid1 uuid-dev \
    zlib1g-dev libzstd-dev \
    libldns-dev liblua5.2-dev \
    libpcre3-dev libpcre2-dev \
    libedit-dev \
    && rm -rf /var/lib/apt/lists/*

# Build spandsp3 (required for FreeSWITCH)
RUN git clone https://github.com/freeswitch/spandsp.git /usr/src/spandsp \
    && cd /usr/src/spandsp \
    && ./bootstrap.sh -j \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && ldconfig

# Build sofia-sip (required for SIP support)
RUN git clone https://github.com/freeswitch/sofia-sip.git /usr/src/sofia-sip \
    && cd /usr/src/sofia-sip \
    && ./bootstrap.sh -j \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && ldconfig

RUN git clone https://github.com/signalwire/libks.git /usr/src/libks \
    && cd /usr/src/libks \
    && cmake . \
    && make -j$(nproc) \
    && make install \
    && ldconfig

# Clone FreeSWITCH source
WORKDIR /usr/src
RUN git clone https://github.com/signalwire/freeswitch.git --depth=1
WORKDIR /usr/src/freeswitch

# Bootstrap, configure, and build
RUN ./bootstrap.sh -j
RUN ./configure
RUN make -j$(nproc)
RUN make install

# -------------------------------------------------------
# Stage 2: Minimal runtime image
# -------------------------------------------------------
FROM debian:bookworm-slim

# Copy only needed files from builder
COPY --from=builder /usr/local /usr/local

# Add entrypoint + healthcheck scripts
COPY docker-entrypoint.sh healthcheck.sh sounds_version.txt /

# Environment variables (adjust as needed)
ENV PATH="/usr/local/bin:${PATH}"

# Healthcheck (example)
HEALTHCHECK --interval=30s --timeout=5s \
    CMD /healthcheck.sh || exit 1

# Expose SIP & RTP ports
EXPOSE 5060/tcp 5060/udp 5080/tcp 5080/udp 8021/tcp
EXPOSE 16384-32768/udp

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["freeswitch", "-nf"]
