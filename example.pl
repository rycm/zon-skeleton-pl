#!/usr/bin/perl

use strict;
use ZeitAPI;

binmode(STDOUT, ":utf8");

my $api = ZeitAPI->new(api_key => YOUR_API_KEY);



printfields($api->content(title => 'Obama', fields => 'title,subtitle,href', limit=> 3));

print "AND MORE:\n\n";

printfields($api->next);



sub printfields {
    my $data = shift;

    foreach my $item ($data->{'matches'})
    {	
	foreach (@$item) {		
	    print "title: " . $_->{'title'} . "\n";
	    print "subtitle: " . $_->{'subtitle'} . "\n";
	    print "link: " . $_->{'href'} . "\n\n";
	}
    }
    
}

