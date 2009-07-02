#!/usr/bin/perl -w
my $abstractfile = shift @ARGV;
my $authorsfile = shift @ARGV;
my $pubdate = shift @ARGV;
my $year = shift @ARGV;
my $releaseinfo = shift @ARGV;

open AUTH,"<$authorsfile" or die "Can't open authors $authorsfile";
while(<AUTH>){
	next if /^#/;
	@AUTHOR=split /,/;
	next unless scalar(@AUTHOR)==4;
	push @AUTHORS,{
		firstname=>$AUTHOR[0],
		lastname=>$AUTHOR[1],
		email=>$AUTHOR[2],
		http=>$AUTHOR[3]
	};
}
close AUTH;

foreach $author (@AUTHORS) {
	print "<author>\n";
	print "<firstname>$author->{firstname}</firstname>\n";
	print "<surname>$author->{lastname}</surname>\n";
	print "</author>\n";
}

print "<pubdate>$pubdate</pubdate>\n";
print "<releaseinfo>$releaseinfo</releaseinfo>\n";

open ABSTR,"<$abstractfile" or die "Can't open abstract $abstractfile";
while(<ABSTR>) {
	if(/AUTHORSCONTACT/) {
		foreach $author (@AUTHORS) {
			print "<para>$author->{firstname} $author->{lastname}: ";
			$contacts = join(" or ",($author->{email},$author->{http}));
			print "$contacts</para>\n";
		}
		next;
	}
	s/YEAR/$year/;
	if(/\[AUTHORS\]/) {
		foreach $author (@AUTHORS) {
			push @authors, "$author->{firstname} $author->{lastname}";
		}
		$authors=join(", ",@authors);
		s/\[AUTHORS\]/$authors/;
	}
	print;
}


