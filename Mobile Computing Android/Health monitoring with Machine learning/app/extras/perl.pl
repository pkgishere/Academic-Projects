open(File,"<Group2.txt")or die " Not able to open";
open(Out,">output.txt");

while(<File>)
{
	chomp;
	$_ =~ s/(\d+)://g;
	print Out " $_";
}
