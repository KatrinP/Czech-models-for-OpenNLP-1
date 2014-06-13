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
	open (OUTFILE, ">>sentence_$type.txt");
	for my $dir ( @dirs ) {
		my @current_dirs = <$dir/$type>; #list of available data files in the given folder
		for my $current_dir ( @current_dirs ) {
			my @m_files = <$current_dir/*.m>; #a list of m files in the current folder
			my @w_files = <$current_dir/*.w>; #a list of w files in the current folder
			my $file_counter = 0; # index of files which will help to keep track of correspondence of opened w a m files
			for my $m_file (@m_files) {
				open (M, $m_file);
				open (W, $w_files[$file_counter]);
				my %space_hash; #a hash of forms with no space after
				my $id;
				while (my $radek = <W>) { #going through the lines of the w file
					 if ($radek =~ /<w id="w-(?<w_id>.*)"/) { #finding a line with id
						 $id = $+{w_id}; #saving the id
					 }
					 if ($radek =~ /<no_space_after>1/) { #saving ids of nodes with the <no space after> attribute to the corresponding hash ####
						 $space_hash{$id} = "1"; #a random value
					 }
				}
				while (my $radek = <M>) { #going through the lines of the m file
					if ($radek =~ /<m id="m-(?<m_id>.*)"/) {
					 	$id = $+{m_id}; #saving id of the current node
				 	}
					if ($radek =~ /<form>(?<m_form>.*)<\/form>/) {
						print OUTFILE $+{m_form};
						unless (exists($space_hash{$id})) {
							print OUTFILE " "; #if the current id is not in the hash with forms without a space after them, a space will be printed
						}
					}
					if ($radek =~ /<\/s>/) { #adding a new line at the end of a sentence
						print OUTFILE "\n";
					}
				}
				print OUTFILE "\n"; #adding an empty line at the end of a file	
				$file_counter += 1; 
			}
		}	
	}
}
