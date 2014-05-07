#!/usr/bin/perl	
#-CSAD	
use utf8;
use warnings;
use strict;
use open qw( :std :utf8 );

my @dirs = <~/Documents/ufal/studium/textoanal/opennlp/PDT_3.0/data/tamw>; #seznam složek v adresáři 
for my $dir ( @dirs ) {
	print $dir, "\n";
	my @train_dirs = <$dir/train-*>; #seznam složek s trénovacími soubory
	#my @train_dirs = <$dir/etest>; #složka s evaluačními daty
	#my @train_dirs = <$dir/dtest>; #složka s devel daty
	for my $train_dir ( @train_dirs ) {
		#print $train_dir , "\n";
		my @m_files = <$train_dir/*.m>; #seznam m souborů v dané trénovací složce
		my @t_files = <$train_dir/*.t>; #seznam t souborů v dané trénovací složce
		my $file_counter = 0; #index souborů, pomocí něj se m souboru přiřadí příslušný w soubor
		for my $m_file (@m_files) {
			open (M, $m_file);
			open (T, $t_files[$file_counter]);
			#print $m_file, $w_files[$file_counter];
			my $id;
			my $t_id = "x";
			my $search = 0;
			my %start_mwes; my %end_mwes;

			#print $m_file, $w_files[$file_counter];
			while (my $radek = <T>) { #projde soubor z t roviny
				 if ($radek =~ /<LM id="s/) { #identifikace multiword expression (není to "<mwes>", protože to může obsahovat více mwes)
				 	$search = 1;
				 }
				 if ($radek =~ /\s\s\s\s<\/LM>/) { #identifikace konce multiword expression
				 	$end_mwes{$t_id} = "1"; #uloží poslední t_lemma z minulé mwes
				 	$search = 0;
				 }
				 if ($radek =~ /<type>(?<type>.*?)</) { ################
					 if ($+{type} ne "time") { ################## checking for specified mwes only: person, time, institution, lexeme, location, object, address, biblio, foreign, number
						 $search = 0;
					 }
				 }
				 if ($search != 0) { 
					 if ($radek =~ /<LM>t-(?<t_id>.*?)</) { #identifikace lemmat v mwes
					 	$t_id = $+{t_id};
					 	if ($search ==1) {
					 		$start_mwes{$t_id} = "1";
							$search = 2;
					 	}
					 }
				 }
			}
			while (my $radek = <M>) { #projde soubor z m roviny
				if ($radek =~ /<m id="m-(?<m_id>.*)"/) {
				 	$id = $+{m_id}; #uloží id aktuálního uzlu
			 	}
				if ($radek =~ /<form>(?<m_form>.*)<\/form>/) {
					if (exists($start_mwes{$id})){
						print "<START:time> "; ########################
					}
					print $+{m_form}, " ";
					if (exists($end_mwes{$id})){
						print "<END> ";
					}
				}
				if ($radek =~ /<\/s>/) { #přidá nový řádek na konci věty
					print "\n";
				}
			}
			print "\n"; #vytiskne prázdný řádek za konec souboru
			$file_counter += 1; #pro udržení spárovaných trojic souborů
		}
	}	
}