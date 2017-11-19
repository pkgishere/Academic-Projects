#!C:\Users\perl\bin
open(FILE,"<Result.txt") or die "not able to read file";
open(Query,">Query.txt");
$Video=$ARGV[0];
$Frame=$ARGV[1];
$Xstart=$ARGV[2];
$Xstop=$ARGV[3];
$Ystart=$ARGV[4];
$Ystop=$ARGV[5];
$HASH[0] = "1";
while(<FILE>)
{
	chomp;
	if($_ =~ m/layer_num/)
	{
		next;
	}
	$_ =~ s/{(.*)}/$1/;
	$_ =~ s/,/ /g;
	$_ =~ s/<(.*)>/$1/;
	@a= split(' ',$_);
	if($Video == $a[2])
	{
		if($Frame == $a[3])
		{
			if($a[5] >= $Xstart and $Xstop >= $a[5])
			{
				if($a[6] >= $Ystart and $Ystop >= $a[6])
				{
					print Query " $a[2] $a[3] $a[4] $a[5] $a[6] $a[0] $a[1]\n";
				}
			}
		}
	}
}
close FILE ;
close Query ;

open(FILE,"<Result.txt") or die "not able to read file";
open(Data,">Data.txt");
while(<FILE>)
{
	chomp;
	if($_ =~ m/layer_num/)
	{
		next;
	}
	
	open(Query,"<Query.txt") or die "not able to read file";
	$_ =~ s/{(.*)}/$1/;
	$_ =~ s/,/ /g;
	$_ =~ s/<(.*)>/$1/;
	@a= split(' ',$_);
	while(<Query>)
	{
		@b=split(' ',$_);
		if($b[5] == $a[0] and $b[6]==$a[1])
		{
			if($b[0] != $a[2])
			{
				print Data " $a[0] $a[1] $a[2] $a[3] $a[4] $a[5] $a[6]\n";
			}					
		}
	}
	close Query;			
}


close FILE;
my %Answer;
open(Data,"<Data.txt") or die "not able to read file";
open(Final,">Final.txt") or die "not able to read file";
while(<Data>)
{
	chomp;
	if($Answer{$_} eq 'a')
	{
		next;
	}
	else
	{
		print Final "$_\n";
		$Answer{$_}='a';
	}
}