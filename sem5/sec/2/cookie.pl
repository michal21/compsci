#!/usr/bin/env perl

use List::MoreUtils qw(uniq);
use Data::Dumper;

sub trim {
    my $s = shift;
    $s =~ s/^\s+|\s+$//g;
    return $s;
};

sub setcookie {
    my ($nam, $val, $hst, $prt) = @_;
    # date +'%a, %d-%b-%Y %H:%M:%S GMT'
    print `emacsclient --eval '(url-cookie-store \"$nam\" \"$val\" \"Fri, 17-Apr-2020 23:07:58 GMT\" \"$hst\" \"/\" nil)'`;
}

if ($#ARGV < 0) {
    $SIG{INT} = sub { print "Stopping\n" };
    $fname = 'cap.pcapng';
    `tshark -i lo -w cap.pcapng`;
} else {
    $fname = $ARGV[0];
}

open PCAP, '<', $fname;
my %cookies, $host;
while (<PCAP>) {
    if (/HTTP\/1\.1/) {
        while (my $l = <PCAP>) {
            last if ($l eq "\r\n");
            if ($l =~ /Host: (.*)/) {
                $host = trim($1);
                $cookies{$host} ||= [];
            }
            if ($l =~ /Cookie: ([^;]*)/) {
                my $m = trim($1);
                #print "Adding '$m' for '$host'\n";
                push @{$cookies{$host}}, $m;
            }
        }
    }
}

my @hosts = keys %cookies;
@{$cookies{$_}} = uniq @{$cookies{$_}} for (@hosts);
my $cmd = 'dialog --stdout --menu Host 0 0 0 ';
for (my $i = 0; $i <= $#hosts; $i++) {
    #print "$i: $hosts[$i]\n";
    my $n = scalar @{$cookies{$hosts[$i]}};
    $cmd .= "$i '$hosts[$i] - $n cookies' ";
}
my $host = $hosts[`$cmd`];
my @cks = @{$cookies{$host}}; # || die;
my $cmd = 'dialog --stdout --checklist Cookie 0 0 0 ';
for (my $i = 0; $i <= $#cks; $i++) {
    $cmd .= "$i '$cks[$i]' 0 ";
}
for (split / /, `$cmd`) {
    my ($hst, $prt) = split /:/, $host;
    my ($nam, $val) = split /=/, $cks[$_], 2;
    #print "$nam, $val, $hst, $prt\n";
    setcookie($nam, $val, $hst, $prt);
}
