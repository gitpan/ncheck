#!/usr/bin/perl

# ncheck -- A simple perl-script for checking ports on remote (and of course the local) machines.
# Copyright (c) May 2001
#               Oliver Pitzeier   o.pitzeier@uptime.at
#               Bernd Pinter      p.pinter@uptime.at (thanks a lot for helping me)
#
# Our license: GNU General Public License
#              available at: http://www.gnu.org/copyleft/gpl.html
#
# This script was written because of the use of a simple, but re-useable net-check script -> ncheck.pl :o)
# 
# This software is freely distributable and may be used for any purpose providing
# the original copyright notice and this notice are affixed thereto.
# No warranties of any kind is privided with this software, and it is hereby
# understood that the author is not liable for any damages arising from the use
# of this software.
#
# If you ever change something, find bugs or even make it better, please think about
# informing us.

# History (odd numbers where always unstable developer Versions):
# ---------------------------------------------------------------
# Version 0.1:
#   * Just made a short script, which did what I wanted at the first moment.
#
# Version 1.0:
#   * Added a config-file.
#
# Version 1.2
#
#   ** The good side of this version:
#   * Added history and version number.
#
#   ** The bad side:
#   * No documentation yet.
#   * Only port, wich automatically send data, after connection work.
#   * Terminal-size is fixed...
########################################################################################

use warnings;
use strict;
use IO::File;
use IO::Socket;
use Term::Screen;


my $VERSION="1.2";

my @config;
my $len;
my $hostname;
my $port;
my $protocol;
my $zeile;
my $return_value;
my $good;

my $scr = new Term::Screen;
unless ($scr) { die "Something's wrong!\n"; }

$scr = new Term::Screen;

$scr->clrscr();

while(1)
{

$scr->bold();
print "ncheck.pl - version $VERSION\n\n";
$scr->normal();

$scr->bold();
print "hostname\t\t protocol\t port\t\t OK?\t server returned\t should be\n";
print "-"x120 . "\n";
$scr->normal();

my $filehndl = new IO::File;
    if ($filehndl->open("< net.config") || die "Configfile not found!")
    {
        @config = <$filehndl>;
    }
    $len = @config;
    foreach my $i (@config)
    {
        $good = 0;
        ($hostname, $port, $protocol, $return_value) = split(/:/, $i);
        next if $hostname =~ /^#/ ;
        chomp($return_value);        
        my $remote = IO::Socket::INET->new(
            Proto => $protocol,
            PeerAddr => $hostname,
            PeerPort => $port,
        )
        or $good = 1;
        if ( $good )
        {
            print substr($hostname, 0, 15) . "\t\t $protocol\t\t " . substr($port, 0, 12) . "\t ";
            $scr->reverse();
            print "NO";
            $scr->normal();
            print "\t ";
            $scr->reverse();
            print "NOT OPENED!";
            $scr->normal();
            print "\t\t regex(^" .  substr($return_value, 0, 20) . ")\n";
            next;
        }
        $remote->autoflush(1);
        my $server_return = <$remote>;
        unless ( $server_return =~ /^$return_value/ )
        {
            chomp($server_return);
            ($server_return, my $dummy) = split(/\r/, $server_return);
            print substr($hostname, 0, 15) . "\t\t $protocol\t\t ". substr($port, 0, 12) . "\t ";
            $scr->bold();
            print "N/A";
            $scr->normal();
            print "\t ";
            $scr->bold();
            print substr($server_return, 0, 20);
            print "\t regex(^" . substr($return_value, 0, 20) . ")\n";
            $scr->normal();
        } 
        else
        {
        print substr($hostname, 0, 15) . "\t\t $protocol\t\t " . substr($port, 0, 12) . "\t YES\t " . substr($server_return, 0, 20) . "\t regex(^" . substr($return_value, 0, 20) . ")\n";
        }       
        close($remote);
    }
    $filehndl->close;
    sleep 5;
    $scr->clrscr();
    }

########################################################################################

__END__

=head1 NAME

ncheck - checking ports on remote (and of course the local) machines.

=head1 DESCRIPTION

This script was written because of the use of a simple, but re-useable net-check script -> ncheck.pl :o)

=head1 README

Download the script, write a config-file and... That's it!
But it would be nice if you make it better! :o)

For more information send a mail to oliver@matrixware.at

=head1 AUTHOR

Oliver Pitzeier <oliver@matrixware.at>
Bernd Pinter <bernd@matrixware.at>

=pod OSNAMES

Linux

=pod SCRIPT CATAGORIES

UNIX/System_administration
