* merge_files.sas
* Steve Simon
* Creating date: 2021-11-03
* Purpose: to compute blood lead averages
*   from NHANES data
* License: Public domain;

* Key references
    https://wwwn.cdc.gov/nchs/nhanes/analyticguidelines.aspx;

ods pdf 
  file="e:/git/nhanes/results/merge_files.pdf";

libname mydata "e:\git\nhanes\perm";

libname xp_demo xport "e:\git\nhanes\data\DEMO_I.xpt";

* The demo_i dataset is documented at
    https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/DEMO_i.htm;    

data mydata.demo_i;
  set xp_demo.demo_i;
run;

libname xp_pbcd xport "e:\git\nhanes\data\PBCD_I.xpt";

data mydata.pbcd_i;
  set xp_pbcd.pbcd_i;
run;

proc sort
   data=mydata.demo_i;
  by seqn;
run;

proc sort
   data=mydata.pbcd_i;
  by seqn;
run;

data mydata.merge2015;
  merge mydata.demo_i(in=a) mydata.pbcd_i(in=b);
  if (a) then in_demo=1; else in_demo=0;
  if (b) then in_pbcd=1; else in_pbcd=0;

  child1to5=(RIDAGEYR>=1)&(RIDAGEYR<=5);
  child1to2=(RIDAGEYR>=1)&(RIDAGEYR<=2);
  child3to5=(RIDAGEYR>=3)&(RIDAGEYR<=5);

  child6to11=(RIDAGEYR>=6)&(RIDAGEYR<=11);
  child6to8 =(RIDAGEYR>=6)&(RIDAGEYR<=8);
  child9to11=(RIDAGEYR>=9)&(RIDAGEYR<=11);

  log_lead=log(LBXBPB)/log(2);

  lead_ge_5=(LBXBPB>=5);
run;

proc freq
    data=mydata.merge2015;
  tables in_demo in_pbcd;
  title1 "Table of matches/mismatches";
run;

proc means
    n nmiss mean std min max
    data=mydata.merge2015;
  var RIDAGEYR LBXBPB;
  title1 "Unweighted descriptive statistics";
run;

proc freq
    data=mydata.merge2015;
  tables
    child1to5
    child1to2
    child3to5
    child6to11
    child6to8
    child9to11;
  title1 "Table of unweighted counts on demographic subgroups";
run;

proc sgplot
    data=mydata.merge2015;
  histogram RIDAGEYR;
  title1 "Unweighted histogram for age";
run;

proc sgplot
    data=mydata.merge2015;
  histogram LBXBPB;
  title1 "Unweighted histogram for blood lead level";
run;

proc sgplot
    data=mydata.merge2015;
  histogram log_lead;
  title1 "Unweighted histogram for log transformed blood lead level";
run;


proc surveyfreq
    data=mydata.merge2015;
  cluster sdmvpsu;
  stratum sdmvstra;
  table child1to5*lead_ge_5 / row nocellpercent;
  weight wtsh2yr;
  title1 "Weighted counts";
run;

* Borrrowing code from 
    https://wwwn.cdc.gov/nchs/data/tutorials/descriptive_means_sas.sas;

proc surveymeans
    data=mydata.merge2015
    nobs mean stderr; 
  cluster sdmvpsu;
  stratum sdmvstra;
  var log_lead;
  weight wtsh2yr;
  domain child1to5;
  title1 "Weighted means";
run;

* Note: transform means back to original scale 
* using the function f(x)=2^x. For example, 
* a mean of 3.0 on the log scale is equal to
* 8.0 on the original scale.;

* Meet again on March 18, 2:30pm;

* Additional analyses:
*   prior distribution issues,
*   breakdown by other demographics,
*   means AND standard deviations, 
*   98.5 percentile.;

ods pdf close;
