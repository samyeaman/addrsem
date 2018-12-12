################# add_RSEM_data_to_table.pl ####################
# Created by Sam Yeaman
# 
#
# Assumes: RSEM file
#
# Run: perl add_RSEM_data_to_table.pl <LIST_of_files_to_process> <LIST_of_contigs> <suffix_to_add_to_outfile>
#	
#	- requires that the RSEM output files be called *.genes.results
#   - requires that LIST_of_contigs have a single column with all the names of the
#     contigs that you want expression data for
#   - outputs a file with the name of the name of the LIST_of_contigs name, with
#     the suffix_to_add_to_outfile appended to the outfile
#
#   NOTE: not a very elegant program, but it does the job.
#
########################################################

#!usr/bin/perl
use strict;
use warnings;
use List::Util qw[min max];

print "beginning\n";


# read in sequences
my $LISTNAME = "$ARGV[0]";
my $CONTIGNAMES = "$ARGV[1]";
my $OUT_SUFF = "$ARGV[2]";

my @temp1 = split(/.txt/, $CONTIGNAMES);

my $OUTMAP = join ('',$temp1[0],$OUT_SUFF);

open (IN_list, "<$LISTNAME") || die "$LISTNAME not found.\n"; 
open (IN_map, "<$CONTIGNAMES") || die "$CONTIGNAMES not found.\n"; 
open (OUT_map, ">$OUTMAP");

my %each_map = ();
my @header = ();

push (@header, "sequence");

while (<IN_list>){

    chomp $_;
    
    my @temp5 = split ('.genes.results',$_);
    push (@header, $temp5[0]);
    
    print "$_\n";
    
    open (IN_file, "<$_") || die "$_ not found.\n"; 

    print "reading in sequences\n";


    my %each_file = ();

    my $second = 0;
    my $first = 0;
    my $int2 = 0;
    my $link = 0;
    my $position = 0;

    my @first2 = ();
    my @int1 = ();

    my @name = ();

    my $filenum = $.;
    	  
    while (<IN_file>) {
	
        chomp $_;
		
		@name = split (' ', $_);
        
        #stores the expected counts in the hash
		$each_file{$name[0]}=$name[4];

    }

	  
    while (<IN_map>) {
	
        chomp $_;
		
		@name = split (' ', $_);

        $first = shift @name;
        
        @first2 = split ('_seq1',$first);
                

        #check to see whether the current name is present in the hash for the input file, and adds its expression value.
        if (exists $each_file{$first2[0]}){
            
            if ($filenum == 1){        
                $second = join (' ', @name, $each_file{$first2[0]});
            }else{
                $second = $each_file{$first2[0]};
            }
            
        } else {
        #if not, then add an "NA" to the array in that category
            if ($filenum == 1){        
                $second = join (' ', @name, "NA");
            }else{
                $second = "NA";
            }

        }
        
        if (exists $each_map{$first}){
            
            $int2 = join (' ',$each_map{$first}, $second);    
            $each_map{$first}=$int2;
        } else {
            $each_map{$first}=$second;
        }
        

    }
    close IN_file;
    seek (IN_map,0,0);
}


my $first = 0;
my @name = ();

my $the_head = join (' ', @header);

print OUT_map "$the_head\n";

while (<IN_map>) {
    
    chomp $_;
    
    @name = split (' ', $_);

    $first = shift @name;
        
    if (exists $each_map{$first}){
        print OUT_map "$first $each_map{$first}\n";
    } 
}
    


close OUT_map;
close IN_map;

