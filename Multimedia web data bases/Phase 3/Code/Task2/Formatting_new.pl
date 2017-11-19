#!C:\Users\perl\bin
#opeing the input file 
open(FILE, "<PCADim10.txt") or die " not able to read file";

#opening the output file for writing 
open(OUT, ">OUTPUT.txt");

my $count=0;
my $Video;

while(<FILE>)
{
	chomp;
    
	if($_ =~ m/Video/)
	{
		#removing metadata
		next;
	}
    else
    {
	  #Formatting of the input
        $_ =~ s/<(.+)>/$1/;
        $_ =~ s/;/ /g;
        $_ =~ s/\s+/ /g;
        print OUT "$_\n";
    }
}



