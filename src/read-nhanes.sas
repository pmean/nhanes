* read-nhanes
* written by Steve Simon
* data created: 2021-10-29
* purpose: to read NHANES data
* license: public domain;

ods pdf file="e:/git/nhanes/results/read-nhanes.pdf";

* Code is adapted from 
*   https://www.cdc.gov/nchs/tutorials/nhanes-cms/determine/create-dataset.htm;

libname XP xport "e:/git/nhanes/data/DEMO_I.XPT"ù;

proc copy in=XP out=demo2015;
run;

proc print
    data=demo2015(obs=5);
  title1 "Listing of demo2016";
run;

ods pdf close;
