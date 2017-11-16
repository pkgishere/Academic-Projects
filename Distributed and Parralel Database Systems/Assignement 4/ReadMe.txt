Part 1 Mapper Class
In the mapper class I am creating a key value pair based on column no the 2nd value in line.
so for example:
Input :- 
R, 2, Don, Larson, Newark, 555-3221
S, 1, 33000, 10000, part1
S, 2, 18000, 2000, part1
R, 3, Sal, Maglite, Nutley, 555-6905
S, 3, 24000, 5000, part1
S, 4, 22000, 7000, part1
R, 4, Bob, Turley, Passaic, 555-8908

will be converted into 

key	value
1	S, 1, 33000, 10000, part1

2	R, 2, Don, Larson, Newark, 555-3221
	S, 2, 18000, 2000, part1

3	R, 3, Sal, Maglite, Nutley, 555-6905
	S, 3, 24000, 5000, part1

4	S, 4, 22000, 7000, part1
	R, 4, Bob, Turley, Passaic, 555-8908

THE ABOVE OD WHAT HAPPENED IN MAPPER IN MY PROGRAM

Now working of Reducer Class:-

1. For each Key in mapper its creating two list:-
one with table1 and other as table2
Then combining one list with other
Answer you will get is the following:-
S, 2, 18000, 2000, part1,R, 2, Don, Larson, Newark, 555-3221

S, 3, 24000, 5000, part1,R, 3, Sal, Maglite, Nutley, 555-6905

R, 4, Bob, Turley, Passaic, 555-8908,S, 4, 22000, 7000, part1 


