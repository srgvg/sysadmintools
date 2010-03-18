#!/usr/bin/perl

use Mail::IMAPClient;

my $imap = Mail::IMAPClient->new(
	Server => $ARGV[0],
	User => $ARGV[1],
	Password => $ARGV[2],
	Peek => 1,
) or die "Djue";

$imap->IsConnected and print "Connected...\n";

my @folders = $imap->folders() or die "Could not list\n";
foreach $mailbox (@folders)
{
	$imap->expunge($mailbox);
	
	print "Expunging: $mailbox\n";
}
print "All done.\n";
