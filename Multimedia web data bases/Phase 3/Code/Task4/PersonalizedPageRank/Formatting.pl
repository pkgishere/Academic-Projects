

open(FILE,"<Phase3Q2.txt") or die "not able to open file ";
open(OUT,">OutPut.txt");
while(<FILE>)
{
	chomp;
	if($_ =~ m/Va/ or $_ =~ m/\-\-\-/)
	{
		next;
	}
	else
	{     
		$_ =~ s/\(//g;
		$_ =~ s/\)//g;
		$_ =~ s/,/ /g; 
		@a=split(' ',$_);
		print OUT " $a[0] $a[1] $a[2] $a[3] $a[4]\n";
	}
}