ods output diffs = lsmdiff lsmeans = lsm;
proc mixed data = adam_bds method = reml;
    where AVISITN > 0;
    class USUBJID TRTP(ref="Placebo") AVISITN ;
    model CHG = AVISITN TRTP TRTP*AVISITN BASE... / s ddfm = kr ;
    repeated AVISITN / type = UN subject = USUBJID r;
    lsmeans TRTP * AVISITN / pdiff cl ;
run;
