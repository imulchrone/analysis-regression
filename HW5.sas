*Import the dataset;
PROC IMPORT datafile="College.csv" out=college replace;
delimiter=',';
getnames=YES;
datarow=2;
RUN;

*prints the dataset;
TITLE "Dataset - College";
PROC PRINT;
RUN;

*5-number summary grade rate;
TITLE "5-number Summary Grad Rate";
PROC MEANS min max median mean p25 p75;
VAR grad_rate;
RUN;

*Histogram Grad Rate;
TITLE "Histogram - Grad Rate";
PROC UNIVARIATE normal;
VAR grad_rate;
histogram / normal (mu = est sigma = est);
RUN;

*remove incorrect data;
DATA college;
SET college;
IF _n_ = 96 THEN DELETE;
RUN;

*Scatterplot Matrix 1;
TITLE "Scatterplot Matrix for Grad Rate 1";
PROC SGSCATTER;
MATRIX grad_rate accept_pct f_undergrad outstate room_board books;
RUN;

*Scatterplot Matrix 2;
TITLE "Scatterplot Matrix for Grad Rate 2";
PROC SGSCATTER;
MATRIX grad_rate personal phd terminal s_f_ratio perc_alumni expend;
RUN;

*Boxplots;
* Sort the data - by the text variable;
PROC SORT;
BY private;
RUN;

*Boxplot - private;
TITLE "Boxplot Private";
PROC BOXPLOT;
*y-axis variable * x-axis variable;
PLOT grad_rate*private;
RUN;


PROC SORT;
BY elite10;
RUN;

*Boxplot - elite;
TITLE "Boxplot Elite";
PROC BOXPLOT;
*y-axis variable * x-axis variable;
PLOT grad_rate*elite10;
RUN;

*Create dummy variables;
DATA college;
SET college;
dprivate = (private = 'Yes');
RUN;

PROC PRINT;
RUN;

*Full model;
TITLE "Full model";
PROC REG;
MODEL grad_rate=accept_pct f_undergrad outstate room_board books personal phd terminal s_f_ratio perc_alumni expend elite10 dprivate/stb vif;
RUN;

TITLE "Selection Method-1: Stepwise Selection Method";
* Selection Method-1: Stepwise Selection Method;
PROC REG;
MODEL grad_rate=accept_pct f_undergrad outstate room_board books personal phd terminal s_f_ratio perc_alumni expend elite10 dprivate/selection=stepwise;
RUN;

TITLE "Selection Method-2: cp Selection Method";
* Selection Method-4: cp Selection Method;
PROC REG;
MODEL grad_rate=accept_pct f_undergrad outstate room_board books personal phd terminal s_f_ratio perc_alumni expend elite10 dprivate/selection=cp;
RUN;

*Final model;
TITLE "Final Model";
PROC REG;
MODEL grad_rate = accept_pct f_undergrad outstate room_board personal phd perc_alumni expend elite10 dprivate/INFLUENCE R;
PLOT student.*predicted.;
PLOT npp.*student.;
RUN;

*Outliers and influential points;
*70,113,317,377,394,585;
DATA collegenew;
SET college;
IF _n_ in (70,113,317,377,394,585) THEN DELETE;
RUN;

*Final model;
TITLE "Final Model 2";
PROC REG data = collegenew;
MODEL grad_rate = accept_pct f_undergrad outstate room_board personal phd perc_alumni expend elite10 dprivate/stb;
RUN;

DATA collegenew;
SET collegenew2;
IF _n_ = 262 THEN DELETE;
RUN;

TITLE "Final Model 3";
PROC REG data = collegenew2;
MODEL grad_rate = accept_pct f_undergrad outstate room_board personal phd perc_alumni expend elite10 dprivate/stb;
RUN;

TITLE "Compute Predictions";

*creates dataset with new value;
DATA pred;
*list of final model predictors;
INPUT accept_pct f_undergrad outstate room_board personal phd perc_alumni expend elite10 dprivate;
DATALINES;
0.87 3000 6500 3300 1350 40 13 5201 0 1
;
RUN;
PROC PRINT;
RUN;



*combine new dataset with current bank dataset;
DATA prediction;
SET pred collegenew;
RUN;
PROC PRINT data=college(obs=5);
RUN;


*compute predicted values (p), CI(clm), PI (cli);
proc reg data = prediction;
model  grad_rate = accept_pct f_undergrad outstate room_board personal phd perc_alumni expend elite10 dprivate/p clm cli;
run;
