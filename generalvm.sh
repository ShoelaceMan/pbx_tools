#!/bin/sh
#
# Control script to change the status of a custom device state in Asterisk
# Called from Asterisk whenever a voicemail message is left
#
VM_CONTEXT=$1
EXTEN=$2
VM_COUNT=$3

ASTCMD="/usr/sbin/asterisk -rx"

if [ $EXTEN -ne 991 ]; then
    exit 0
fi

if [ $VM_COUNT -eq "0" ]; then
    logger -t generalvm "Switching OFF General mailbox lamp ($VM_COUNT)"
    $ASTCMD "channel originate Local/s@generalvm-off extension 4@default"
else
    logger -t generalvm "Switching ON General mailbox lamp ($VM_COUNT)"
    $ASTCMD "channel originate Local/s@generalvm-on extension 4@default"
fi

exit 0
