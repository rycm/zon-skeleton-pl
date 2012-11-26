#!/usr/bin/perl

use strict;
use ZeitAPI;
use Data::Dumper;

binmode(STDOUT, ":utf8");

my $api = ZeitAPI->new(api_key => `cat API_KEY`);



printfields($api->content(title => 'Obama', fields => 'title,subtitle,href,uuid', limit=> 3));


print "AND MORE:\n\n";

printfields($api->next);

print "Get more info on the first result.\n";

print Dumper($api->content_by_id(id => $api->result->{'matches'}->[0]->{'uuid'}));

print "Is there anything on computers?\n";

print Dumper($api->keyword(q => '*Computer*', limit => 3));

print "... and the CCC?\n";

print Dumper($api->keyword_by_id(id => 'chaos-computer-club', limit => 3, title => 'der'));

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

