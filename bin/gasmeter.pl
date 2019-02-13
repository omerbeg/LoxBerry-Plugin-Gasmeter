#!/usr/bin/perl

use LoxBerry::System;
use File::HomeDir;

use CGI qw/:standard/;
use Config::Simple qw/-strict/;
use warnings;
use strict;
use LoxBerry::IO;
use LoxBerry::Log;
use Time::HiRes qw ( sleep );

use DBI;
use RPi::Pin;
use RPi::Const qw(:all);


my $log = LoxBerry::Log->new(name => 'Input_handler',);

LOGSTART("Handle input daemon");

my $pcfg = new Config::Simple("$lbpconfigdir/pluginconfig.cfg");
my $database = $pcfg->param("MAIN.DATABASE");
my $samplingRate = $pcfg->param("MAIN.SAMPLINGRATE");
my $gpio = $pcfg->param("INPUT.GPIO");

# set the pin
my $pin = RPI::Pin->new($gpio);
$pin->mode(INPUT);
$pin->pull(PUD_UP);

LOGDEB "Congigured database: $database";
LOGDEB "Configured sampling rate: $samplingRate";
LOGDEB "Configured gpio: $gpio";
LOGDEB "Configured gpio as: " . $pin->mode ;
    
# connect to database
my $dsn = "DBI:SQLite:dbname=$database";
my $user = undef;
my $password = undef;
my $dbh = DBI->connect($dsn,$user,$password, { AutoCommit => 1, RaiseError => 1 }) or die $DBI::errstr;
my $sth = $dbh->prepare("INSERT INTO gasmeter_t (timestamp,counter) VALUES (CURRENT_TIMESTAMP,1)");
	 
LOGDEB "Connected to database: $dat";


my $state_old=0;
my $state_actual=0;

#endless loop
while(1){
    
    $state_actual = $pin->read();
    if ($state_actual) {
	print "contact open";
	$state_old=$pin->read();
    } else { # state_actual=0
	print "contact closed";
	if ($state_old != $state_actual) {
	    $state_old = $pin->read();
	    #write into DB
	    $sth->execute;
	}
    }
    
    #For Loglevel more than Error (e.g. Debug) we set the sleep time to 1sec
    if($log->loglevel() >3){
	sleep(1);
    } else {
	sleep ($samplingRate);
    }
	
}

exit;
END
{
    if ($log) {
        $log->LOGEND;
    }
}

