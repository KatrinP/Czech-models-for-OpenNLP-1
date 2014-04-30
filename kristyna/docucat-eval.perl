#!/usr/bin/perl	
#-CSAD	
use utf8;
use warnings;
use strict;
use open qw( :std :utf8 );

###jako první argument nutno uvést vzorový výstup, jako druhý pak reálný výstup

my $vzor = shift @ARGV;
my $vystup = shift @ARGV;



open (VYSTUP, $vystup);
my @vystupni_radky = <VYSTUP>;
my $vystupni;

open (VZOR, $vzor);
my @vzorove_radky = <VZOR>;
my $vzorova;

my $celkem = 0; my $spravne = 0;

open (VZOR, $vzor);
while (my $radek = <VZOR>) {
	$celkem += 1;
	$vystupni = shift @vystupni_radky;

	$radek =~/^(?<rad>.*?)\s/;
	my $rad = $+{rad};
	#print $radek, "\n";
	#print $+{rad}, "\n";
	$vystupni =~ /^(?<vyst>.*?)\t/;
	#print $vystupni, "\n";
	#print $+{vyst}, "\n";
	#print $rad,$+{vyst}, "\n";
	if ($rad eq $+{vyst}) { ####z nějakého důvodu nefunguje pro ten vzorový soubor
	#if ($radek eq $vystupni) {
		$spravne += 1;
	}	
}
 	
my $uspesnost = 100*$spravne/$celkem;
print $uspesnost, "\n";
#print $celkem, "\n";




