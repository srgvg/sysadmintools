#!/usr/bin/perl

use Mail::IMAPClient;

my $imap = Mail::IMAPClient->new(
	Server => "localhost",
	User => "cyrus",
	Password => "cyrus",
	Peek => 1,
) or die "Djue";

$imap->IsConnected and print "Connection established.\n";

my @folders = $imap->folders() or die "Could not list\n";
foreach $mailbox (@folders)
{
	print "$mailbox\n"
}

print "Done.\n";
