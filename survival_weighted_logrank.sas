*https://www.sas.com/content/dam/SAS/support/en/sas-global-forum-proceedings/2020/5062-2020.pdf;

data bmt2;
    set sashelp.bmt(where=(group in ("ALL","AML-Low Risk")));
run;

ods output HomTests=chisq HomStats=Q FlemingHomCov=var;
proc lifetest data=bmt2;
    time T*status(0);
    strata group / test = FH(1,0);
run;
