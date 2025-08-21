#!/bin/sh
#
# FreeSWITCH Modular Media Switching Software Library / Soft-Switch Application
# Copyright (C) 2005-2016, Anthony Minessale II <anthm@freeswitch.org>
#
# Version: MPL 1.1
#
# The contents of this file are subject to the Mozilla Public License Version
# 1.1 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/F
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
#
# The Original Code is FreeSWITCH Modular Media Switching Software Library / Soft-Switch Application
#
# The Initial Developer of the Original Code is
# Michael Jerris <mike@jerris.com>
# Portions created by the Initial Developer are Copyright (C)
# the Initial Developer. All Rights Reserved.
#
# Contributor(s):
#
#  Sergey Safarov <s.safarov@gmail.com>
#

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
