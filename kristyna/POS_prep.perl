#!/usr/bin/perl	
#-CSAD	
use utf8;
use warnings;
use strict;
use open qw( :std :utf8 );

my @dirs = <./PDT_3.0/data/*>; #seznam složek v adresáři 
for my $dir ( @dirs ) {
	#my @train_dirs = <$dir/train-*>; #seznam složek s trénovacími soubory
	#my @train_dirs = <$dir/etest>; #složka s evaluačními daty
	my @train_dirs = <$dir/dtest>; #složka s devel daty
	for my $train_dir ( @train_dirs ) {
		#print $train_dir , "\n";
		my @m_files = <$train_dir/*.m>; #seznam m souborů v dané trénovací složce
		for my $m_file (@m_files) {
			open (M, $m_file);
			my %space_hash; #slovník tvarů, za kterými není mezera
			my $id;
			while (my $radek = <M>) { #projde soubor z m roviny
				if ($radek =~ /<form>(?<m_form>.*)<\/form>/) {
					print "$+{m_form}";
				}
				if ($radek =~ /<tag>(?<tag>..).*/) {
				 	print "_$+{tag} "; #uloží id aktuálního uzlu
			 	}
				if ($radek =~ /<\/s>/) { #přidá nový řádek na konci věty
					print "\n";
				}
			}
			print "\n"; #vytiskne prázdný řádek za konec souboru	
		}
	}	
}

