# ---------------------------------------------------------
# Stage 1: Build FreeSWITCH from source
# --------------------------------------------------------
FROM debian:bookworm-slim as builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget curl gnupg2 ca-certificates lsb-release apt-transport-https \
    build-essential pkg-config automake autoconf libtool libtool-bin cmake \
    libncurses5-dev libjpeg-dev libcurl4-openssl-dev libpcre2-dev libspeexdsp-dev uuid-dev \
    libldns-dev libedit-dev libsqlite3-dev libopus-dev libavformat-dev \
    libswscale-dev libswresample-dev libavcodec-dev libavutil-dev libssl-dev \
    libsndfile1-dev libshout3-dev libmpg123-dev libmp3lame-dev libflac-dev nasm yasm liblua5.3-dev \
    libogg-dev libvorbis-dev libyuv-dev libspandsp-dev libtiff-dev libxml2-dev \
    libpq-dev libgnutls28-dev libonig-dev unzip \
    && rm -rf /var/lib/apt/lists/*

# Build spandsp3
RUN git clone https://github.com/freeswitch/spandsp.git /usr/src/spandsp \
    && cd /usr/src/spandsp \
    && ./bootstrap.sh \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && ldconfig

# Build sofia-sip
RUN git clone https://github.com/freeswitch/sofia-sip.git /usr/src/sofia-sip \
    && cd /usr/src/sofia-sip \
    && ./bootstrap.sh -j \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && ldconfig

# Build libks
RUN git clone https://github.com/signalwire/libks.git /usr/src/libks \
    && cd /usr/src/libks \
    && cmake . \
    && make -j$(nproc) \
    && make install \
    && ldconfig

# Build signalwire-client-c
RUN git clone https://github.com/signalwire/signalwire-c.git /usr/src/signalwire-c \
    && cd /usr/src/signalwire-c \
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
RUN make
RUN make install

# -------------------------------------------------------
# Stage 2: Minimal runtime image
# -------------------------------------------------------
FROM debian:bookworm-slim

# Copy FreeSWITCH binaries
COPY --from=builder /usr/local /usr/local

# Copy scripts and version file
COPY docker-entrypoint.sh healthcheck.sh sounds_version.txt /

# Make entrypoint executable
RUN chmod +x /docker-entrypoint.sh /healthcheck.sh

# Set environment PATH
ENV PATH="/usr/local/bin:${PATH}"

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s CMD /healthcheck.sh || exit 1

# Expose SIP & RTP ports
EXPOSE 5060/tcp 5060/udp 5080/tcp 5080/udp 8021/tcp
EXPOSE 16384-32768/udp

# Entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
