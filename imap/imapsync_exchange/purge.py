#!/usr/bin/perl

use Mail::IMAPClient;

my $imap = Mail::IMAPClient->new(
	Server => "localhost",
	User => "cyrus",
	Password => "Kg963Vx",
	Peek => 1,
) or die "Djue";

$imap->IsConnected and print "Woohoo! We're connected...\n";

my @folders = $imap->folders() or die "Could not list\n";
foreach $mailbox (@folders)
{
	$imap->select($mailbox);
	$imap->setacl($mailbox, "anyone", "lrswipcda");
	$imap->delete($mailbox);
	$imap->expunge();
	
	print "$mailbox\n";
}

print "Done :)\n";
