#!/usr/bin/perl	
#-CSAD	
use utf8;
use warnings;
use strict;
use open qw( :std :utf8 );

my @dirs = <./PDT_3.0/data/*>; #seznam složek v adresáři 
for my $dir ( @dirs ) {
	#print $dir, "\n";
	#my @train_dirs = <$dir/train-*>; #seznam složek s trénovacími soubory
	#my @train_dirs = <$dir/etest>; #složka s evaluačními daty
	my @train_dirs = <$dir/dtest>; #složka s devel daty
	for my $train_dir ( @train_dirs ) {
		#print $train_dir , "\n";
		my @m_files = <$train_dir/*.m>; #seznam m souborů v dané trénovací složce
		my @w_files = <$train_dir/*.w>; #seznam w souborů v dané trénovací složce
		my $file_counter = 0; #index souborů, pomocí něj se m souboru přiřadí příslušný w soubor
		for my $m_file (@m_files) {
			#print $m_file, "\n";
			open (M, $m_file);
			open (W, $w_files[$file_counter]);
			#print $m_file, $w_files[$file_counter];
			my %space_hash; #slovník tvarů, za kterými není mezera
			my $id;
			while (my $radek = <W>) { #projde soubor z w roviny
				 if ($radek =~ /<w id="w-(?<w_id>.*)"/) { #řádek s id
					 $id = $+{w_id}; #uloží id aktuálního slova
				 }
				 if ($radek =~ /<no_space_after>1/) { #u řádků s atributem <no_space_after> uloží id aktuálního slova do slovníku####
					 $space_hash{$id} = "1";
				 }
			}
			while (my $radek = <M>) { #projde soubor z m roviny
				if ($radek =~ /<m id="m-(?<m_id>.*)"/) {
				 	$id = $+{m_id}; #uloží id aktuálního uzlu
			 	}
				if ($radek =~ /<form>(?<m_form>.*)<\/form>/) {
					print $+{m_form};
					unless (exists($space_hash{$id})) {
						print " "; #pokud id aktuálního slova není ve slovníku slov s atributem no_space_after, vytiskne za ním mezeru
					}
				}
				if ($radek =~ /<\/s>/) { #přidá nový řádek na konci věty
					print "\n";
				}
			}
			print "\n"; #vytiskne prázdný řádek za konec souboru	
			$file_counter += 1; 
		}
	}	
}

