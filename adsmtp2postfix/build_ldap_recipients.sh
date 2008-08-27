#! /bin/sh

DC=domain.controller

ping -c1 $DC >/dev/null || (echo ERROR domain controller does not answer to ping ; exit

cd /etc/postfix/ldap
>ldap_recipients

./getadsmtpAllowReceive.pl >> ldap_recipients || (echo ERROR ldap query failed ; exit )
cat ldapExtraAccountsReceive.txt >> ldap_recipients
/usr/sbin/postmap ldap_recipients

cut -d@ -f2 ldap_recipients | cut -d\  -f1 | sort | uniq -i | grep -v -e ^$ -e gvb -e local.velleman.be | awk '{ print $1 "\t\t\tsmtp:[exchange.server]" }' >/etc/postfix/transport
postmap /etc/postfix/transport

postfix reload 
