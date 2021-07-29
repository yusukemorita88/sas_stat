proc format;
    invalue bmtnum 'ALL'=1 'AML-Low Risk'=2 'AML-High Risk'=3;
    value bmtfmt 1='ALL' 2='AML-Low Risk' 3='AML-High Risk';
run;

data bmt;
    set sashelp.bmt(rename=(group=g));
    Group = input(g, bmtnum.);
    format group bmtfmt.;
run;

ods trace on;
ods output ProductLimitEstimates =  pe1 failureplot = fp1;
proc lifetest data=bmt  outsurv = out1  plots=survival(failure cl) reduceout timelist =(0 to 1825 by 365) conftype=loglog;
    time t*status(0);
    strata group / order=internal;
   
run; 
quit;
