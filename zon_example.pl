#!/usr/bin/perl

use strict;
use LWP::UserAgent;
use JSON;
binmode(STDOUT, ":utf8");

# configuration

my $api_key = "ENTER YOUR API KEY HERE";
my $endpoint = "content";
my %params = (q => 'title:Obama', fields => 'title,subtitle,href', limit=>'10');

# create url including parameters

my $url = URI->new("http://api.zeit.de/$endpoint");
$url->query_form(%params);

# set header, send get-request

my $zon = LWP::UserAgent->new();
$zon->default_header('X-Authorization' => $api_key);
my $result = $zon->get($url, %params);

# parse json result and print output to stdout

my $json = JSON->new;
my $data = $json->decode($result->content);

foreach my $item ($$data{'matches'})
{	
	foreach (@$item) {		
		print "title: " . $_->{'title'} . "\n";
		print "subtitle: " . $_->{'subtitle'} . "\n";
		print "link: " . $_->{'href'} . "\n\n";
	}
}

