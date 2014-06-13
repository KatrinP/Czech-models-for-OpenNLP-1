#!/usr/bin/perl	
#-CSAD	
use utf8;
use warnings;
use strict;

my $category = "address"; 

my $path = shift @ARGV; #the first argument specifies the folder where PDT tamw, amw and aw folders are saved. here: ../../PDT_3.0/data
if (!-d $path) {
    die "The specified path does not exist: $path\n";
}

my $dir = <$path/tamw>;
if ($dir ne "../../PDT_3.0/data/tamw") {
	die "The specified path does not contain the expected files: $path. You need to specify the path to the following folder: PDT_3.0/data/\n";
}
my @data_types = ("train-*", "etest", "dtest"); #names of subfolders of the input data
for my $type ( @data_types ) {
	open (OUTFILE, ">>named_$category-$type.txt");
	my @current_dirs = <$dir/$type>;
	for my $current_dir ( @current_dirs ) {
		my @m_files = <$current_dir/*.m>; #list of m files in the given folder
		my @t_files = <$current_dir/*.t>; #list of w files in the given folder
		my $file_counter = 0; #index of files which will help to keep track of correspondence of opened w a m files
		for my $m_file (@m_files) {
			open (M, $m_file);
			open (T, $t_files[$file_counter]);
			my $id;
			my $t_id = "x";
			my $search = 0; #looking for ids of lemmas in a mwes
			my $search_A = 0; #looking for ids also for analytical nodes that are only in aux of their lemmas (identified as the beginning of the mwes)
			my %start_mwes; my %end_mwes; my %start_mwes_A; #the last dictionary includes starts of expressions from aux
			my $starter = "ended";
			my $lex; my $t_num; my $a_num;
			while (my $radek = <T>) { #browsing through the t file
				 if ($radek =~ /<LM id="s/) { #the line with the start of a multiword expression
				 	$search = 1;
				 }
				 if ($radek =~ /<\/tnode.rfs>/) { #the end of a multiword expression
				 	$end_mwes{$t_id} = "1"; #saving the last lemma from the last mwes 
				 	$search = 0;
				 }
				 if ($radek =~ /<type>(?<type>.*?)</) { 
					 if ($+{type} ne $category) { #checking for specified mwes type only
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
				 if ($radek =~ /<LM id="t-(?<t_id2>.*w\d+)"/) { #t lemma  
				 	my $t_id2 = $+{t_id2};
					if (exists($start_mwes{$t_id2})) {
						$search_A = 1;
						$lex = $t_id2;
					}	
				 }
				 if ($search_A != 0) { #identifying possible auxiliary words associated with the lemmas in mwes
					 if ($radek =~ /<LM>a\#a-(?<a_id>.*)</) {
						 my $aux = $+{a_id};
						 $search_A = 0;
						 if ($lex =~ /.*w(?<t_num>\d+)/) {
							 $t_num = $+{t_num};
						 }
						 if ($aux =~ /.*w(?<a_num>\d+)/) {
							 $a_num = $+{a_num};
						 }	 
						 if ($t_num < $a_num) {
							 $start_mwes_A{$lex} = "1";
						 }
						 else {
						 	 $start_mwes_A{$aux} = "1";
						 }
					 }
					 if ($radek =~ /<\/a>/) {
					 	$start_mwes_A{$lex} = "1";
						$search_A = 0;
					 }
				 }
			}
			while (my $radek = <M>) { #browsing through the m file
				if ($radek =~ /<m id="m-(?<m_id>.*)"/) {
				 	$id = $+{m_id}; #saving the current id
			 	}

				if ($radek =~ /<form>(?<m_form>.*)<\/form>/) {
					if (exists($start_mwes_A{$id})){
						if ($starter eq "ended") {
							print OUTFILE "<START:$category> "; 
						}
						else {
							print OUTFILE "<END> <START:$category> "; 
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
				if ($radek =~ /<\/s>/) { #new line at the end of a sentence
					print OUTFILE "\n";
				}
			}
			print OUTFILE "\n"; #new line at the end of a file
			$file_counter += 1; #to keep track of the matched files from different layers
		}
	}	
}