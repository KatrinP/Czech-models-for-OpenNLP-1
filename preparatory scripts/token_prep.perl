#!/usr/bin/perl	
#-CSAD	
use utf8;
use warnings;
use strict;


my $path = shift @ARGV; #the first argument specifies the folder where PDT tamw, amw and aw folders are saved. here: ../../PDT_3.0/data
if (!-d $path) {
    die "The specified path does not exist: $path\n";
}

my @dirs = <$path/*>;
if (@dirs ne "../../PDT_3.0/data../../PDT_3.0/data/amw../../PDT_3.0/data/mw../../PDT_3.0/data/tamw") {
	die "The specified path does not contain the expected files: $path. You need to specify the path to the following folder: PDT_3.0/data/\n";
}
my @data_types = ("train-*", "etest", "dtest"); #names of subfolders of the input data

for my $type ( @data_types ) {
	open (OUTFILE, ">>token_$type.txt");
	for my $dir ( @dirs ) {
		my @current_dirs = <$dir/$type>; #list of available data files in the given folder
		for my $current_dir ( @current_dirs ) {
			my @m_files = <$current_dir/*.m>; #list of m files in the given folder
			my @w_files = <$current_dir/*.w>; #list of w files in the given folder
			my $file_counter = 0; #an index of files to match the m and w files
			for my $m_file (@m_files) {
				open (M, $m_file);
				open (W, $w_files[$file_counter]);
				my %space_hash; #hash of words with no space after
				my $id;
				while (my $radek = <W>) { #browsing the w file
					 if ($radek =~ /<w id="w-(?<w_id>.*)"/) { #the line with id
						 $id = $+{w_id}; #saving the current id
					 }
					 if ($radek =~ /<no_space_after>1/) { #for lines with the <no_space_after> attribute, the id of the current word is saved 
						 $space_hash{$id} = "1";
					 }
				}
				while (my $radek = <M>) { #browsing the m file
					if ($radek =~ /<m id="m-(?<m_id>.*)"/) {
					 	$id = $+{m_id}; #saving the current id
				 	}
					if ($radek =~ /<form>(?<m_form>.*)<\/form>/) {
						print OUTFILE $+{m_form};
						if (exists($space_hash{$id})) {
							print OUTFILE "<SPLIT>"; #if the id of the current word exists in the spac_hash,the <SPLIT> tag will be printed
						}
						else {
							print OUTFILE " ";
						}
					}
					if ($radek =~ /<\/s>/) { #adding a new line at the end of a sentence
						print OUTFILE "\n";
					}
				}
				print OUTFILE "\n"; #adding a new line at the end of a file	
				$file_counter += 1; 
			}
		}	
	}
}
