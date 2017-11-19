#!C:\Users\perl\bin
open(FILE, "<Sift_Reduced_Formatted.txt") or die " not able to read file";
open(OUT, ">OUTPUT.txt");
my $count=0;
my $Video;
while(<FILE>)
{
	chomp;
    
	if($_ =~ m/Video/)
	{
		next;
	}
    else
    {
        $_ =~ s/<(.+)>/$1/;
        $_ =~ s/;/ /g;
        $_ =~ s/\s+/ /g;
        print OUT "$_\n";
    }
}



