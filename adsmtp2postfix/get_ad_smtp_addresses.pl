#!/usr/bin/perl -w

# This script will pull all users' SMTP addresses from your Active Directory
# (including primary and secondary email addresses) and list them in the
# format "user@example.com OK" which Postfix uses with relay_recipient_maps.
# Be sure to double-check the path to perl above.

# This requires Net::LDAP to be installed.  To install Net::LDAP, at a shell
# type "perl -MCPAN -e shell" and then "install Net::LDAP"

use Net::LDAP;

# Enter the FQDN of your Active Directory domain controllers below
$dc1="domain.controller1";
$dc2="domain.controller2";

# Enter the LDAP container for your userbase.
# The syntax is CN=Users,dc=example,dc=com
# This can be found by installing the Windows 2000 Support Tools
# then running ADSI Edit.
# In ADSI Edit, expand the "Domain NC [domaincontroller1.example.com]" &
# you will see, for example, DC=example,DC=com (this is your base).
# The Users Container will be specified in the right pane as
# CN=Users depending on your schema (this is your container).
# You can double-check this by clicking "Properties" of your user
# folder in ADSI Edit and examining the "Path" value, such as:
# LDAP://domaincontroller1.example.com/CN=Users,DC=example,DC=com
# which would be $hqbase="cn=Users,dc=example,dc=com"
$hqbase="OU=Accounts,DC=domain,DC=be";
# Enter the username & password for a valid user in your Active Directory
# with username in the form cn=username,cn=Users,dc=example,dc=com
# Make sure the user's password does not expire.  Note that this user
# does not require any special privileges.
# You can double-check this by clicking "Properties" of your user in
# ADSI Edit and examining the "Path" value, such as:
# LDAP://domaincontroller1.example.com/CN=user,CN=Users,DC=example,DC=com
# which would be $user="cn=user,cn=Users,dc=example,dc=com"
$user="CN=USER,OU=Service Accounts,OU=Accounts Servers,DC=domain,DC=be";
$passwd="passiewordie";

# That's it, you're done.  Let the script do its job.

# Connecting to Active Directory domain controllers
$noldapserver=0;
$ldap = Net::LDAP->new($dc1) or
   $noldapserver=1;
if ($noldapserver == 1)  {
   $ldap = Net::LDAP->new($dc2) or
      die "Error connecting to specified domain controllers $@ \n";
}
$mesg = $ldap->bind ( dn => $user,password =>$passwd);

if ( $mesg->code()) {
    die ("error:", $mesg->code(),"\n");
  }

$searchbase = $hqbase;
# Searching for users (not contacts) that are mail-enabled
$mesg = $ldap->search (base   => $searchbase,
                       filter => "(&(sAMAccountName=*)(mail=*))",
                       attrs  => "proxyAddresses");

$entries = $mesg->count;

if ($entries lt 1) {
  print "entries=0 \n";
}

# Filtering results for proxyAddresses attributes, thanks to Markus Schabel
# and Viktor Duchovni
foreach my $entry ( $mesg->entries ) {
   $test = 1;
   # LDAP Attributes are multi-valued, so we have to print each one.
   foreach my $mail ( $entry->get_value( "proxyAddresses" ) ) {
     # Test if the Line starts with one of the following lines:
     # proxyAddresses: smtp:
     # proxyAddresses: SMTP:
     # and also discard this starting string, so that $mail is only the
     # address without any other characters...
     #
     # CHECK AD if person may receive external e-mail
     #
     if ($mail =~ s/^(CALDR|CALDSR)://gs){
       $test = 0;
     }
   }
   if ($test eq 1){
     foreach my $mail ( $entry->get_value( "proxyAddresses" ) ) {
       if ( $mail =~ s/^(smtp|SMTP)://gs ) {
         print $mail." OK\n";
       }
     }
   }
}


# Unbinding
$ldap->unbind;

