#!/usr/bin/perl
#
# BSD-3-Clause License
#
# (c) arsen.stasic 2020-01-22
#

use strict;
use warnings;

use Net::DNS;
use Getopt::Long;

my $cookie='0000000000000000';
my @ns=();
my $nsport=53;
my $srcip=undef;
my $srcport=undef;
my $qname='hostname.bind';
my $qtype='TXT';
my $qclass='CH';

GetOptions(
  'help'        => \&help,
  'nsip=s'      => \@ns,
  'nsport=i'    => \$nsport,
  'srcip=s'     => \$srcip,
  'srcport=i'   => \$srcport,
  'qname=s'     => \$qname,
  'qtype=s'     => \$qtype,
  'qclass=s'    => \$qclass,
  'cookie:s'    => \$cookie
);

&help unless ( @ns );           # if @ns is empty, display help & exit

my $res = new Net::DNS::Resolver(
  nameserver => ['127.0.0.1'],  # instantiate with localhost, will be overwritten by $nsip
  recurse => 0,                 # recursing is not needed, we ask authoritative nameservers
  debug => 1                    # we need debug to get full output (cookies)
);
$res->port($nsport)     if ($nsport);
$res->srcaddr($srcip)   if ($srcip);
$res->srcport($srcport) if ($srcport);

my $pack = new Net::DNS::Packet( $qname, $qtype, $qclass );
$pack->header->do(0);           # DNSSEC is not needed
$pack->edns->size(1280);        # set a bigger UDP size
$pack->edns->option( COOKIE =>  {'CLIENT-COOKIE' => $cookie} );

sub query
{
  my @NSs = @_;
  foreach my $NS ( @NSs ) {
    print "checking COOKIE on $NS\n";
    $res->nameservers( $NS );
    my $reply = $res->send( $pack );
  }
}

sub help
{
  print <<EOT;
Usage: $0 --nsip <mgmt-ip1> --nsip <mgmt-ip2>
 For less verbose output use someting like:
 $0 --nsip 10.10.10.1 --nsip my-anycast1 | grep COOKIE
 
 Required argumet:
  --nsip      mgmt-ip of nameserver to test

 Optional arguments:
  --cookie    DNS-Cookie (default: $cookie)
  --nsport    use this nameser Port (default: $nsport)
  --srcip     use this source IP (default: any local address)
  --srcport   use this source Port (default: 0, meaning any port)
  --qname     use this query Name (default: $qname)
  --qtype     use this query Type (default: $qtype)
  --qclass    use this query Class (default: $qclass)
  --help      show this help message
  
# Test your anycast-nameservers (BIND) if they all return the same DNS Cookie.
#
# With BIND 9.11 and newer DNS Cookies are enabled **automatically**.
# Either synchronize them with following config (siphash24 is available since BIND 9.14.5):
# dns-operations@lists.dns-oarc.net
#   cookie-algorithm siphash24;
#   cookie-secret "shared-secret-string";
# Or disable cookies with following config:
#   answer-cookie no;
#
# ISC addressed this issue in their knowledge base:
# https://kb.isc.org/docs/dns-cookies-on-servers-in-anycast-clusters
#
# BIND 9.14.10 ARM (Administrator Reference Manual):
# https://downloads.isc.org/isc/bind9/9.14.10/doc/arm/Bv9ARM.ch05.html#boolean_options
EOT
  exit(0);
}

&query(@ns);

# vim:spell:spelllang=en
