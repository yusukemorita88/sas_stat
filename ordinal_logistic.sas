data test;
input grp $  score count;
cards;
P 0 28
P 1 21
P 2 14
P 3 14
P 4 8
P 5 6
P 6 10
A 0 18
A 1 23
A 2 9
A 3 12
A 4 14
A 5 7
A 6 18
;
run;

proc logistic data = test order=internal;
    class grp(ref="P") score;
    freq count;
    model score = grp;
run;
