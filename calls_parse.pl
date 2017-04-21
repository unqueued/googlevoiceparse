#!/usr/bin/env perl

# I would prefer to do this manually, but, I'm gonna have to use Mojo::DOM because
# I do not trust google's output to always be consistent

use Mojo::DOM;
use Data::Dumper;

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
		#print "Text message cluster: $_\n";

	    open my $fh, '<', "$calls_dir/$_" or die "can't open $file: $!";
	    #open my $fh, '<', "Calls/+17655328677\ -\ Text\ -\ 2013-03-28T21_21_24Z.html" or die "can't open $file: $!";
	    $input_file = <$fh>;
	    $dom = Mojo::DOM->new($input_file);

	    my $other_subject = $_;
	    @fragments = split / - Text - /, $other_subject;
	    #print Dumper(@fragments);
	    #exit;
	    $other_subject = shift(@fragments);

	    #print "Parsing conversation with $other_subject ($_)\n";

	    my @timestamp, @sender, @quotes;

		@eachmessage = $dom->find('div.message')->each();
		foreach(@eachmessage) {


			$message = Mojo::DOM->new($_);

			@abbr = $message
				->find('abbr')
				->map(attr => "title")
				->each();
			
			#$timestamp = shift(@abbr);
			push @timestamp, shift(@abbr);
			#print "\"$timestamp\", ";
			#print "$timestamp\t";

			# Sender
			$sender = $message
				->find('a')
				->map( attr => 'href' )
				->join("\n");
			$sender =~ s/tel\://;
			push @sender, $sender;
			#print "\"$sender\", ";
			#print "$sender\t";
			if($sender == "") {
				#print "Invalid message that was not sent\n";
				last;
				print "timestamp: $timestamp | sender: $sender | message: $message\n";
				die("Fuck");
			}
			if($sender != $my_number) {
				if($sender != $other_subject) {
					#print "AAAAAAAAAA\n";
					#print "Changed $other_subject to $sender\n";
					$other_subject = $sender;

					#print "AaaaAaAAAAA\n";
				}
			}

			# Message
			$quotes = $message
				->find('q')
				->join("\n");
			$quotes =~ s/\<q\>//;
			$quotes =~ s/\<\/q\>//;
			push @quotes, $quotes;
			#print "$quotes\n";
			#print "\"$quotes\"\n";

		}
		close($fh);
		#exit;
		#print Dumper(@quotes);
		#print Dumper(@timestamp);
		#print Dumper(@sender);

		foreach(@timestamp) {
			print $_;
			print "\t";
			$i = pop @sender;
			if($i == $my_number) {
				print "Outgoing\t$other_subject\t";
			} else {
				print "Incoming\t$i\t";
			}
			#print "\t";
			print pop @quotes;
			print "\n";
		}

		@timestamp = "";
		@sender = "";
		@quotes = "";

	}
}