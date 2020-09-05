proc sort data = adam_bds;
  by paramcd param;
run;

ods output commonpdiff = adjdiff;
proc freq data = adam_bds ;
  by paramcd param ;
  tables strata * trt01p * aval / riskdiff(column=1 common cl=newcombe);
run;

data adjdiff2;
  set adjdiff(where=(Method="Newcombe"));
run;
