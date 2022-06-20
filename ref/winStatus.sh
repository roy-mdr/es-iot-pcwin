#!/bin/bash
# Script to check remote windwos status, like Loggedin + Windows Lock/Unlock status
# More functions can be added/removed as required.
# I attached this script to webmin for our Support dept.
# Syed Jahanzaib / aacable.wordpress.com / aacable @ hotmail . com
# Created: 25-JAN-2017
# Revised: 29-JUN-2017
#set -x
QUSER_HOLDER="/tmp/$1.quser"
LOCK_HOLDER="/tmp/$1.lockstatus"
REMOTE_PC="$1"
PING_ATEMPTS="1"
PING_STATUS="/tmp/$1.ping.status"
LOCAL_DNS_IP="101.11.11.5#"
 
# Domain credentials details so that winexe can execute commands on all domain clients
DOMAIN="YOURDOMAINNAME"
DOMAIN_ADMIN="ADMINID"
ADMIN_PASS="PASSWORD"
# Empty All Holders
> $QUSER_HOLDER
> $LOCK_HOLDER
> $PING_STATUS
# Check if remote PC is accessibel or not,
## IF PING FAILS then inform accordingly and EXIT
ping -q -c $PING_ATEMPTS $REMOTE_PC &>/dev/null > $PING_STATUS
PING_RESULT=`cat $PING_STATUS`
if [ "$PING_RESULT" = "" ]; then
echo "ERROR: Unable to resolve hostnname using $LOCAL_DNS_IP DNS Server.
Unknown HOST. Exiting"
exit 1
fi
# Print PC NAME (from $1 variable)
echo "Remote PC : $1"
IPADD=`nslookup $1 | grep Address | sed /$LOCAL_DNS_IP/d`
# Print IP of remote PC via nslookp using local DNS
echo "IP $IPADD"
# If ping failed, then print Error and EXIT
if [[ $(ping -q -c $PING_ATEMPTS $REMOTE_PC) == @(*100% packet loss*) ]]; then
echo "$1 not responding to ping request, probably system is not UP & without ping the status cannot be queried. Exiting ..."
exit 1
fi
# Query remote windows Logged in user using Linux WINEXE tool
winexe -U $DOMAIN/$DOMAIN_ADMIN%"$ADMIN_PASS" //$1 "quser" > $QUSER_HOLDER
QUSER_RESULT=`cat $QUSER_HOLDER |grep "Failed"`
 
if [[ -n "$QUSER_RESULT" ]]; then
echo "User Status = ERROR: Ping is ok but unable to query the user status."
exit 1
fi
QUSER_RESULT=`cat $QUSER_HOLDER |grep "Active"`
if [[ -n "$QUSER_RESULT" ]]; then
echo "User Status = Logged in User found ... details as below ...
$QUSER_RESULT"
fi
 
# Query remote windows TASK list to find if windows is locked/unlocked
winexe -U $DOMAIN/$DOMAIN_ADMIN%"$ADMIN_PASS" //$1 "tasklist" > $LOCK_HOLDER
LOCK_RESULT=`cat $LOCK_HOLDER |grep -E "LogonUI.exe|logon.scr"`
 
#Check if Someone is logged in via RDP session
QUSER_RESULT=`cat $QUSER_HOLDER |grep "rdp-tcp#0"`
if [[ -n "$QUSER_RESULT" ]]; then
echo "It seems someone is logged IN from RDP Session."
fi
 
# CHeck if windows is unlocked locally
if [[ "$LOCK_RESULT" = "" ]]; then
echo "Windows Status = Windows is UN-LOCKED"
fi
 
#Check if windwos is LOCKED locallay
if [[ -n "$LOCK_RESULT" ]]; then
echo "Windows Status = Windows Local Login seems to be Locked!"
fi
 
# Script function ends here
# Thank you