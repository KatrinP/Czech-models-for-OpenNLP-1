#!/usr/bin/perl	
#-CSAD	
use utf8;
use warnings;
use strict;


my @categories = ("number", "person", "time", "institution", "location", "object", "biblio", "foreign", "number"); #address is handled separately beacause it frequently starts with a preposition

my $path = shift @ARGV; #the first argument specifies the folder where PDT tamw, amw and aw folders are saved. here: ../../PDT_3.0/data
if (!-d $path) {
    die "The specified path does not exist: $path\n";
}

my $dir = <$path/tamw>;
if ($dir ne "../../PDT_3.0/data/tamw") {
	die "The specified path does not contain the expected files: $path. You need to specify the path to the following folder: PDT_3.0/data/\n";
}
my @data_types = ("train-*", "etest", "dtest"); #names of subfolders of the input data

for my $category ( @categories ) {

	for my $type ( @data_types ) {
		open (OUTFILE, ">>named_$category-$type.txt");
	#for my $dir ( @dirs ) {
		my @current_dirs = <$dir/$type>;
		for my $current_dir ( @current_dirs ) {
			my @m_files = <$current_dir/*.m>; #list of m files in the given folder
			my @t_files = <$current_dir/*.t>; #list of t files in the given folder
			my $file_counter = 0; #index of files which will help to keep track of correspondence of opened t a m files
			for my $m_file (@m_files) {
				open (M, $m_file);
				open (T, $t_files[$file_counter]);
				my $id;
				my $t_id = "x";
				my $search = 0;
				my %start_mwes; my %end_mwes;
				my $starter = "ended";
				while (my $radek = <T>) {
					 if ($radek =~ /<LM id="s/) { #finding start of a multiword eexpression
					 	$search = 1;
					 }
					 if ($radek =~ /<\/tnode.rfs>/) { #finding end of a mwes
					 	$end_mwes{$t_id} = "1"; #saving the last lemma from the last mwes
					 	$search = 0;
					 }
					 if ($radek =~ /<type>(?<type>.*?)</) { 
						 if ($+{type} ne $category) { 
							 $search = 0;
						 }
					 }
					 if ($search != 0) { 
						 if ($radek =~ /<LM>t-(?<t_id>.*w\d+)</) { #identifying lemmas in the mwes
						 	$t_id = $+{t_id};
						 	if ($search ==1) {
						 		$start_mwes{$t_id} = "1";
								$search = 2;
						 	}
						 }
					 }
				}
				while (my $radek = <M>) { 
					if ($radek =~ /<m id="m-(?<m_id>.*)"/) {
					 	$id = $+{m_id}; #saving the id of the current node
				 	}
					if ($radek =~ /<form>(?<m_form>.*)<\/form>/) {
						if (exists($start_mwes{$id})){
							if ($starter eq "ended") {
								print OUTFILE "<START:$category> "; #
							}
							else {
								print OUTFILE "<END> <START:$category> "; ##################
								#print $id;
							}
							$starter = "started";
						}
						print OUTFILE $+{m_form}, " ";
						if (exists($end_mwes{$id})){
							unless ($starter eq "ended") {
								print OUTFILE "<END> ";
							}
							$starter = "ended";
						}
					}
					if ($category eq "biblio") {
						if ($radek =~ /<\/s>/ && $starter eq "ended") { #pro biblio, u kterých často údaje přes hrnaici věty. pokud to tak je, necháme jako jednu větu
						print OUTFILE " ";
						}
						elsif ($radek =~ /<\/s>/) { #přidá nový řádek na konci věty
							print OUTFILE "\n";
						}
					}
					else {
						if ($radek =~ /<\/s>/) { #přidá nový řádek na konci věty
							print OUTFILE "\n";
						}
					}
				}
				print OUTFILE "\n"; #vytiskne prázdný řádek za konec souboru
				$file_counter += 1; #pro udržení spárovaných trojic souborů
			}
		}	
	}
}	