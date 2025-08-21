

#!/bin/sh
set -e

# Ensure required directories exist
mkdir -p /etc/freeswitch /var/log/freeswitch /var/lib/freeswitch

# Populate default configs if missing
if [ ! -f "/etc/freeswitch/freeswitch.xml" ]; then
    SIP_PASSWORD=$(tr -dc _A-Z-a-z-0-9 </dev/urandom | head -c12; echo)
    cp -r /usr/share/freeswitch/conf/vanilla/* /etc/freeswitch/
    sed -i -e "s/default_password=.*\?/default_password=$SIP_PASSWORD\"/" /etc/freeswitch/vars.xml
    echo "New FreeSwitch SIP password set to '$SIP_PASSWORD'"
fi

# Start FreeSWITCH in foreground
exec /usr/bin/freeswitch -nc -nf -nonat
