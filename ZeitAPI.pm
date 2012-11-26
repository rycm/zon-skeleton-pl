
=head1 NAME

    ZeitApi - proviedes methods to access the API of the weekly newspaper "Die Zeit"

=head1 DESCRIPTION

    So far only doing a Content search is implemented

=head1 SYNOPSIS

    use ZeitAPI;

    binmode(STDOUT, ":utf8");

    my $api = ZeitAPI->new(api_key => YOUR_API_KEY_GOES_HERE);


    printfields($api->content(title => 'Obama', fields => 'title,subtitle,href', limit=> 3));

    print "AND MORE:\n\n";

    printfields($api->next);



    sub printfields {
        my $data = shift;

        foreach my $item ($data->{'matches'}){	
        	foreach (@$item) {		
	            print "title: " . $_->{'title'} . "\n";
	            print "subtitle: " . $_->{'subtitle'} . "\n";
	            print "link: " . $_->{'href'} . "\n\n";
	        }
        }
    
    }

=cut


package ZeitAPI;

use strict;
use LWP::UserAgent;
use JSON;

=head1 Constructor and Accessor Methods

=over 4

=item new()

    Create a new ZeitAPI object. Needs an API key as named argument api_key. Available on http://developer.zeit.de/quickstart/ 

=cut

sub new {
    my $api = {};
    bless $api;
    
    my ($self,%args) = @_;

    die "No API-key provided" unless $args{'api_key'};
    
    $api->{api_key} = $args{'api_key'};

    return $api;
}

=item content()

    takes the fields of the q query (see http://developer.zeit.de/documentation/content/) 
    as well as fields, limit, offset and operators fields as named arguments and returns a list reference. 

=cut

sub content {
    
    my ($self,%args) = @_;
    my %newargs;
    

    foreach my $key(qw(fields limit offset operator)){
	$newargs{$key} = $args{$key};
    }
    

    my $q = $self->q(\%args,qw(subtitle uuid title href release_date uri snippet supertitle teaser_title teaser_text));
       
    
    return $self->query( endpoint => 'content', params => {q =>  $q, %newargs}); 

}

=item content_by_id

    Takes id as named argument. 

=cut

sub content_by_id {
    
    my ($self, %args) = @_;
    my %newargs;

    foreach my $key(qw(fields)){
	$newargs{$key} = $args{$key};
    }
    

    return $self->query( endpoint => 'content/'.$args{'id'}, params => {%newargs}); 

}

=item keyword()

    Search for keyword 

=cut 

sub keyword {
    
    my ($self,%args) = @_;
    my %newargs;
    

    foreach my $key(qw(q fields limit offset)){
      next unless defined $args{$key};
      $newargs{$key} = $args{$key};
    }
    
    return $self->query( endpoint => 'keyword', params => \%newargs); 

}

=item keyword_by_id()

    either takes id or uri as provided by keyword search. 

=cut 

sub keyword_by_id {
    my ($self,%args) = @_;
    my %newargs;
    
    if($args{'uri'}){
      $args{'uri'} =~ /.*\//;
      
      $args{'id'} ||= $';
    }
  

    foreach my $key(qw(fields limit offset operator)){
      next unless $args{$key};
	$newargs{$key} = $args{$key};
    }
    

    my $q = $self->q(\%args,qw(subtitle title href release_date uri supertitle teaser_title teaser_text));
       
    
    return $self->query( endpoint => 'keyword/'.$args{'id'}, params => {q =>  $q, %newargs}); 

}

sub query {

    my ($self,%args) = @_;

    $self->{'args'} = \%args;

    return $self->do_query;
}

=item result()

    Returns the result of the previous query 

=cut 

sub result {
    my $self = shift;

    return $self->{'result'};
}

=item next()
    
    Returns the next items of the last query (i.e. the offset is shifted by the limit). Takes the new limit as 
    optional argument. 

=cut

sub next {
    my ($self, $limit) = @_;

    $limit ||= $self->{'args'}->{'limit'};
    $self->{'args'}->{'params'}->{'offset'} += $self->{'args'}->{'params'}->{'limit'};
    $self->{'args'}->{'params'}->{'limit'} = $limit if defined($limit);

    return $self->do_query;
}

sub do_query {

    my ($self) = shift;
    
    my $json = JSON->new;

    die "No endpoint provided" unless $self->{'args'}->{'endpoint'};


    my $url = URI->new('http://api.zeit.de/'.$self->{'args'}->{'endpoint'});

    $url->query_form(%{$self->{'args'}->{'params'}});

    my $query = LWP::UserAgent->new();
    $query->default_header('X-Authorization' => $self->{'api_key'});

    my $response = $query->get($url,%{$self->{'args'}->{'params'}});
    if($response->is_success){
      $self->{'result'} = $json->decode($response->content);
      return($self->{'result'});
    }
    else{
      die $response->status_line;
    }
}

sub q {
    my ($self, $args, @possible_keys) = @_;

    my @set_args = grep {$args->{$_}} @possible_keys;
    my @querried_args = map {"$_:$args->{$_}"} @set_args;

    return(join(',' , @querried_args));
}	


=back

=head1 AUTHOR

Martin Rycak E<lt>mail@martinrycak.de<gt>

Robert Helling E<lt>helling@atdotde.deE<gt>

=cut

1;
