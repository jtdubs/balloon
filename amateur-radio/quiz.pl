#!/usr/bin/perl

use strict;
use List::Util 'shuffle';

(my $questions_file) = @ARGV;

if (not -f $questions_file) {
    print "usage: $0 [questions-file]\n";
    exit 0;
}

open QF, "< $questions_file" or die "Unable to open $questions_file!";

my %questions;
while (<QF>) {
    if (/^(T\w{4})\s+\((\w)\)(\s+(\[.*?\]))?\s*$/) {
        (my $id, my $answer, my $references) = ($1, $2, $4);

        <QF>;
        my $question = "";
        while (<QF>) {
            last if (/^~~\s*$/);
            $question .= $_
        }
        chomp $question;

        $questions{$id} = [$answer, $references, $question];
    }
}

my @question_ids = shuffle(keys(%questions));

print "How many of the $#question_ids available questions do you want to be asked?\n";

my $response = "";
while (1) {
    print "> ";
    $response = <STDIN>;
    chomp $response;
    last if ($response =~ /\s*\d+\s*/ and 0 < $response and $response <= $#question_ids);
    print "Invalid response: \"$response\"\n" if ($response =~ /\w/);
}

@question_ids = @question_ids[0..$response-1];

print "\nOkay, here we go...\n\n";

my $asked = 0;
my $correct = 0;

while (my $id = shift @question_ids) {
    (my $answer, my $references, my $question) = @{$questions{$id}};

    print "$id $references\n$question\n";

    my $response = "";
    while (1) {
        print "> ";
        $response = <STDIN>;
        chomp $response;
        last if ($response =~ /^\s*([A-D]|q|quit)\s*$/i);
        print "Invalid response: \"$response\"\n" if ($response =~ /\w/);
    }
    $response =~ s/^\s*([A-D]|q|quit)\s*$/\1/i;

    last if ($response =~ /(quit|q)/i);

    $asked++;

    if ($response =~ /$answer/i) {
        $correct++;
        print "\nCorrect.";
    } else {
        print "\nIncorrect.  Right answer was $answer.";
    }
    print " " . ($correct*100/$asked) . "% ($correct out of $asked)\n\n";
}

if ($correct/$asked > 25/36) {
    print "Congratulations, you passed!\n";
} else {
    print "Sorry, you failed!\n";
}
