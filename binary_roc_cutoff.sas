%*refer from "https://www.nshi.jp/contents/sas/roccut/";

%macro rocCut(data, out, y, var, cov =, eventcode = 1, alpha = 0.05);
    ods listing close;
    ods results off;
    proc logistic data = &data. ;
        model &y.(event="&eventcode.") = &var. &cov. / outroc = _rocdat rocci roceps = 1e-12;
        output out = _outp p = _PROB_;
        ods output ROCAssociation = _auc(keep = Area LowerArea UpperArea);
    run;
    ods results on;
    ods listing;

    proc sort data = _outp; 
        by _PROB_;
    run;

    proc sort data = _rocdat; 
        by _PROB_;
    run;

    data _outp; 
        set _outp; 
        _PROB_ = round(_PROB_, 1e-12);
    run;

    data _rocdat;
        set _rocdat;
        _PROB_ = round(_PROB_, 1e-12);
    run;

    data _rocdat;
        merge _outp(where = (_PROB_ ^= .)) _rocdat;
        by _PROB_;
    run;

    data &out.;
        set _rocdat;
        if _N_ = 1 then set _auc(obs = 1);
        se = _SENSIT_;
        _za_ = quantile("Normal", 1 - &alpha./2);
        _nn_ = _POS_ + _FALNEG_; _x_ = _POS_; _p_ = _x_ / _nn_;
        selcl = (_x_ + _za_**2*0.5)/(_nn_ + _za_**2) - 
               _za_*sqrt(_nn_)/(_nn_ + _za_**2)*sqrt(_p_*(1 - _p_) + _za_**2/_nn_*0.25);
        seucl = (_x_ + _za_**2*0.5)/(_nn_ + _za_**2) +
               _za_*sqrt(_nn_)/(_nn_ + _za_**2)*sqrt(_p_*(1 - _p_) + _za_**2/_nn_*0.25);
        _SPEC_ = 1 - _1MSPEC_;
        _nn_ = _NEG_ + _FALPOS_; _x_ = _NEG_; _p_ = _x_ / _nn_;
        splcl = (_x_ + _za_**2*0.5)/(_nn_ + _za_**2) -
               _za_*sqrt(_nn_)/(_nn_ + _za_**2)*sqrt(_p_*(1 - _p_) + _za_**2/_nn_*0.25);
        spucl = (_x_ + _za_**2*0.5)/(_nn_ + _za_**2) +
               _za_*sqrt(_nn_)/(_nn_ + _za_**2)*sqrt(_p_*(1 - _p_) + _za_**2/_nn_*0.25);
        _nn_ = _POS_ + _FALPOS_ + _NEG_ + _FALNEG_; _x_ = _POS_ + _NEG_; _p_ = _x_ / _nn_;
        acc = (_POS_ + _NEG_) / _nn_;
        acclcl = (_x_ + _za_**2*0.5)/(_nn_ + _za_**2) -
                _za_*sqrt(_nn_)/(_nn_ + _za_**2)*sqrt(_p_*(1 - _p_) + _za_**2/_nn_*0.25);
        accucl = (_x_ + _za_**2*0.5)/(_nn_ + _za_**2) +
                _za_*sqrt(_nn_)/(_nn_ + _za_**2)*sqrt(_p_*(1 - _p_) + _za_**2/_nn_*0.25);
        youden = _SENSIT_ + _SPEC_ - 1;
        distance = sqrt((1 - _SENSIT_)**2 + _1MSPEC_**2);
        drop _SENSIT_ _1MSPEC_ _p_ _za_ _nn_ _x_ _SOURCE_;
        rename
            _SPEC_ = sp 
            _POS_ = pos 
            _NEG_ = neg
            _FALPOS_ = fpos 
            _FALNEG_ = fneg 
            Area = auc
            LowerArea = auclcl
            UpperArea = aucucl 
            _LEVEL_ = level
            _PROB_ = prob
        ;
    run;

    proc sort data = &out.;
        by descending youden distance;
    run;

    proc datasets lib = work;
        delete _rocdat _outp _auc;
    run; quit;

%mend rocCut;

%*------------------------------------;
%*usage;
%*rocCut(input, output, yvar, xvar);
%*------------------------------------;
data sample;
  call streaminit(130301);
  beta = 2;
  do i = 1 to 100;
    x = rand('Normal', 0, 2);
    logit = beta*x;
    theta = 1 / (1 + exp(-logit));
    y = rand('Bernoulli', theta);
    output;
  end;
  drop beta logit theta;
run;

%rocCut(sample, outroc, y, x);

proc print data = outroc(obs = 5);
run;
