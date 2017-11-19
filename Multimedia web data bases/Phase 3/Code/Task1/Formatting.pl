
open(FILE, "<Phase1Q2.txt") or die " not able to read file";
open(OUT, ">OUTPUT.txt");
my $count=0;
my $Video;
while(<FILE>)
{
	chomp;
	if($_ =~ m/VIDEO_NAME/)
	{
		next;
	}
	
	if($_ =~ m/\((.+);(.+);(.+);\[(.+)\]/)
	{
		if($count == 0)
		{
				$count=1;
				$Video=$1;
				
		}
		if($Video eq $1)
		{
			print OUT " $count $2 $3 $4\n";
		}
		else
		{
	        $count+=1;	
			$Video=$1;
			print OUT " $count $2 $3 $4\n";
		}
		
		   
	}
	
}



