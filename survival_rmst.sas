*analyses of the restricted mean survival time (RMST) and restricted mean time lost (RMTL);
ods graphics on;
proc lifetest data = VALung plots = (rmst rmtl) rmst rmtl(tau = 90) maxtime = 600;
    time SurvTime*Censor(1);
    strata Cell;
run;
ods graphics off;
