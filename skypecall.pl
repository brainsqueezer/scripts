#!/usr/bin/perl -w

# Use DBus to create a conference call with skype
# Released GPL on 10 March 2009 by orthopteroid@orthopteroid.net
# Requires the perl module Net::DBus
# Based upon "Control Skype API via DBus using perl" by jlh at gmx dot ch

use strict;
use warnings;
use Net::DBus;


package SkypeConference; # -----------------------------------------------------------

use base 'Net::DBus::Object';
use Net::DBus;

$SkypeConference::CONF_ID = 0;
@SkypeConference::Attendees =();

sub new {
    my ($class, $AttendeeList) = @_;
    my $bus = Net::DBus->session;

    # export a service and the object /com/Skype/Client, so Skype can
    # invoke the 'Notify' method on it in order to communicate with us.
    my $exp_service = $bus->export_service("com.Skype.API") or die;
    my $self = $class->SUPER::new($exp_service, '/com/Skype/Client') or die;
    bless $self, $class;

    # get a handle to Skype's /com/Skype object, so we can invoke the
    # 'Invoke' method on it to communicate with Skype.
    my $service = $bus->get_service("com.Skype.API") or die;
    $self->{invoker} = $service->get_object("/com/Skype") or die;

    # setup is done, let's shake hands
    print $self->Invoke("NAME SkypeConference") . "\n";
    print $self->Invoke("PROTOCOL 8") . "\n";

    $AttendeeList =~ s/ /, /g; # convert spaces to 'comma space's
    print $self->Invoke("CALL $AttendeeList") . "\n";
    
    return $self;
}

sub Notify {
    my ($self, $string) = @_;
    if ( $string =~ /CALL (\w+) CONF_ID (\w+)/ )
    {
        push @SkypeConference::Attendees, $1;
        $SkypeConference::CONF_ID = $2;
    }
    if ( $string !~ /DURATION/ ) { print "-> $string\n"; }
    if ( $string =~ /FINISHED/ )
    {
        # 1st caller out kills the conference
        foreach ( @SkypeConference::Attendees )
        {
            print $self->Invoke("ALTER CALL $_ HANGUP") . "\n";
        }
        @SkypeConference::Attendees = ();
        (Net::DBus::Reactor->main)->shutdown();
    }
    return 0;    # careful what is returned here
}

sub Invoke {
    my ($self, $string) = @_;
    print "$string\n";
    return $self->{invoker}->Invoke($string);
}

package main; # ---------------------------------------------------------------

use Net::DBus::Reactor;

if( $#ARGV < 1 ) { die "Must have at least 2 numbers to conference.\n"; }

my $skype = SkypeConference->new( "@ARGV" );

# Hook main loop
my $reactor = Net::DBus::Reactor->main;
$reactor->run;

# end of file