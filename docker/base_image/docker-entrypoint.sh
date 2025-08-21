#!/bin/bash
set -e

mkdir -p /etc/freeswitch /var/log/freeswitch /var/lib/freeswitch /usr/share/freeswitch/sounds

# Populate default configs if missing
if [ ! -f "/etc/freeswitch/freeswitch.xml" ]; then
    SIP_PASSWORD=$(tr -dc _A-Z-a-z-0-9 </dev/urandom | head -c12; echo)
    cp -r /usr/local/freeswitch/conf/vanilla/* /etc/freeswitch/
    sed -i -e "s/default_password=.*\?/default_password=$SIP_PASSWORD\"/" /etc/freeswitch/vars.xml
    echo "New FreeSwitch SIP password set to '$SIP_PASSWORD'"
fi

# Ensure sound directories exist
mkdir -p /usr/share/freeswitch/sounds

# Download sounds if environment variables are set
if [ -n "$SOUND_RATES" ] && [ -n "$SOUND_TYPES" ]; then
    SOUND_RATES=$(echo "$SOUND_RATES" | tr ':' '\n')
    SOUND_TYPES=$(echo "$SOUND_TYPES" | tr ':' '\n')

    BASEURL=http://files.freeswitch.org

    for type in $SOUND_TYPES; do
        version=$(grep "$type" /sounds_version.txt | awk '{print $2}')
        for rate in $SOUND_RATES; do
            f=freeswitch-sounds-$type-$rate-$version.tar.gz
            if [ ! -f "/usr/share/freeswitch/sounds/$f" ]; then
                wget -q $BASEURL/$f -O /usr/share/freeswitch/sounds/$f
                tar xzf /usr/share/freeswitch/sounds/$f -C /usr/share/freeswitch/sounds/
                rm -f /usr/share/freeswitch/sounds/$f
            fi
        done
    done
fi

# Trap SIGTERM to gracefully stop FreeSWITCH
trap "echo 'Stopping FreeSWITCH'; /usr/local/freeswitch/bin/freeswitch -stop" SIGTERM

# Start FreeSWITCH in foreground
exec /usr/local/freeswitch/bin/freeswitch -nc -nf -nonat
