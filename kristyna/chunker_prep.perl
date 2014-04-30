#!/usr/bin/perl	
#-CSAD	
use utf8;
use warnings;
use strict;
use open qw( :std :utf8 );

my @dirs = <./PDT_3.0/data/*amw>; #seznam složek v adresáři 
for my $dir ( @dirs ) {
	#print $dir, "\n";
	#my @train_dirs = <$dir/train-*>; #seznam složek s trénovacími soubory
	#my @train_dirs = <$dir/etest>; #složka s evaluačními daty
	my @train_dirs = <$dir/dtest>; #složka s devel daty
	for my $train_dir ( @train_dirs ) {
		#print $train_dir , "\n";
		my @m_files = <$train_dir/*.m>; #seznam m souborů v dané trénovací složce
		my @a_files = <$train_dir/*.a>; #seznam w souborů v dané trénovací složce
		my $file_counter = 0; #index souborů, pomocí něj se m souboru přiřadí příslušný w soubor
		for my $m_file (@m_files) {
			open (M, $m_file);
			open (A, $a_files[$file_counter]);
			#print $m_file, $w_files[$file_counter];
			my %clause_count_hash; #slovník tvarů, za kterými není mezera
			my $id;
			while (my $radek = <A>) { #projde soubor z w roviny
				 if ($radek =~ /<m.rf>m.m-(?<a_id>.*)</) { #řádek s id    
					 $id = $+{a_id}; #uloží id aktuálního slova
					 #print $id, "\n";
				 }
				 if ($radek =~ /<clause_number>(?<cl_num>.*)</) { #u řádků s atributem <no_space_after> uloží id aktuálního slova do slovníku####
					 $clause_count_hash{$id} = $+{cl_num};
				 }
			}
			my $clause_num = 1;
			while (my $radek = <M>) { #projde soubor z m roviny
				if ($radek =~ /<m id="m-(?<m_id>.*)"/) {
				 	$id = $+{m_id}; #uloží id aktuálního uzlu
					#print $id, "\n";
					unless (exists($clause_count_hash{$id})) { #u uzlů, kterým chybí atribut clause_count přidá nulu
						$clause_count_hash{$id} = "0";
					}
			 	}
				if ($radek =~ /<form>(?<m_form>.*)<\/form>/) {
					print "$+{m_form} "; #vytiskne tvar
				}
				if ($radek =~ /<tag>(?<tag>..).*/) {
				 	print "$+{tag} $clause_count_hash{$id}\n"; #vytiskne morfologický tag a číslo klauze
			 	}
				if ($radek =~ /<\/s>/) { #přidá nový řádek na konci věty
					print "\n";
				}
			}
			$file_counter += 1; #pro udržení spárovaných dvojic a a m souborů
		}
	}	
}

