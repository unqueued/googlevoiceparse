#!/usr/bin/env perl

# I would prefer to do this manually, but, I'm gonna have to use Mojo::DOM because
# I do not trust google's output to always be consistent

use Mojo::DOM;
use Data::Dumper;
use HTML::Entities;

# Parse args


if(!$ARGV[0]) {
	die("Usage: $0 [9 digit phone number 1112223333 no +1] [Optional folder. Defaults to Calls/] \n");
}
$my_number = '+1'. $ARGV[0];

if($ARGV[1]) {
	$calls_dir = $ARGV[1];
} else {
	$calls_dir = "Calls/";
}

print STDERR "Parsing messages WRT $my_number from $calls_dir\n";

opendir my $dh, $calls_dir;

@files = readdir $dh;

local $/; #Enable local slurp mode

my $limitcounter;
my $limit = 40;

my @text_clusters;

foreach(@files) {
	if($_ =~ m/Text/) {
	    open my $fh, '<', "$calls_dir/$_" or die "can't open $file: $!";
	    $input_file = <$fh>;
	    $dom = Mojo::DOM->new($input_file);

	    my $other_subject = $_;
	    @fragments = split / - Text - /, $other_subject;
	    $other_subject = shift(@fragments);
	    my @timestamp, @sender, @quotes;

		@eachmessage = $dom->find('div.message')->each();
		foreach(@eachmessage) {

			$message = Mojo::DOM->new($_);

			@abbr = $message
				->find('abbr')
				->map(attr => "title")
				->each();
			
			push @timestamp, shift(@abbr);

			# Sender
			$sender = $message
				->find('a')
				->map( attr => 'href' )
				->join("\n");
			$sender =~ s/tel\://;
			push @sender, $sender;
			if($sender == "") {
				last;
				print "timestamp: $timestamp | sender: $sender | message: $message\n";
				die("Format error");
			}
			if($sender != $my_number) {
				if($sender != $other_subject) {
					$other_subject = $sender;
				}
			}

			# Message
			$quotes = $message
				->find('q')
				->join("\n");
			$quotes =~ s/\<q\>//;
			$quotes =~ s/\<\/q\>//;
			push @quotes, $quotes;
		}
		close($fh);

		foreach(@timestamp) {
			print $_;
			print "\t";
			$i = pop @sender;
			if($i == $my_number) {
				print "Outgoing\t$other_subject\t";
			} else {
				print "Incoming\t$i\t";
			}
			my $message = pop @quotes;

			# Not really adiquate text sanitization
			$message = decode_entities($message);
			$message =~ s/\t/   /g;
			$message =~ s/\"/\\\\"/g;
			$message =~ s/\<br\>/ /g;
			print "$message";
			print "\n";
		}

		@timestamp = "";
		@sender = "";
		@quotes = "";

	}
}