#!/usr/bin/perl

use strict;
use LWP::UserAgent;

# configuration

my $api_key = "ENTER YOUR API KEY HERE";
my $endpoint = "content";
my %params = (q => 'title:Obama', fields => 'title,subtitle,uri', limit=>'5');

# create url including parameters

my $url = URI->new("http://api.zeit.de/$endpoint");
$url->query_form(%params);

# set header, send get-request

my $zon = LWP::UserAgent->new();
$zon->default_header('X-Authorization' => $api_key);
my $result = $zon->get($url, %params);

# output

print $result->content;
