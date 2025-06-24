*Import the dataset;
PROC IMPORT datafile="churn.csv" out=churn replace;
delimiter=',';
getnames=YES;
datarow=2;
RUN;

PROC PRINT;
RUN;

*Boxplots;
* Sort the data - by the text variable;
PROC SORT;
BY churn;
RUN;

*Boxplot - age;
TITLE "Boxplot Age";
PROC BOXPLOT;
*y-axis variable * x-axis variable;
PLOT age*churn;
RUN;

*Boxplot - pct change bill;
TITLE "Boxplot PCT_CHNG_BILL_AMT";
PROC BOXPLOT;
*y-axis variable * x-axis variable;
PLOT PCT_CHNG_BILL_AMT*churn;
RUN;

*Gender dummy variable;
DATA churn;
SET churn;
dgender = (gender = 'M');
education2 = (education = 2);
education3 = (education = 3);
education4 = (education = 4);
education5 = (education = 5);
education6 = (education = 6);
RUN;
PROC PRINT;
RUN;

*Stepwise selection;
TITLE "Stepwise selection model";
PROC LOGISTIC;
MODEL churn (event='1') = dgender education2 education3 education4 education5 education6 PRICE_PLAN_CHNG TOT_ACTV_SRV_CNT AGE PCT_CHNG_IB_SMS_CNT PCT_CHNG_BILL_AMT COMPLAINT / selection=stepwise rsquare;
RUN;

*final model;
TITLE "Final model";
PROC LOGISTIC;
MODEL churn (event='1') = education2 education3 TOT_ACTV_SRV_CNT AGE PCT_CHNG_IB_SMS_CNT PCT_CHNG_BILL_AMT COMPLAINT / corrb influence iplots;
RUN;

*Input orediction values;
DATA new;
INPUT GENDER $ PRICE_PLAN_CHNG TOT_ACTV_SRV_CNT AGE PCT_CHNG_IB_SMS_CNT PCT_CHNG_BILL_AMT COMPLAINT;
DATALINES;
M 0 4 43 1.04 1.19 1
;
RUN;
PROC PRINT;
RUN;

*Join datasets;
DATA prediction;
SET new churn;
dgender = (gender = 'M');
education2 = (education = 2);
education3 = (education = 3);
education4 = (education = 4);
education5 = (education = 5);
education6 = (education = 6);
RUN;
PROC PRINT data=prediction;
RUN;

*Model predictions;
TITLE "Prediction";
PROC LOGISTIC;
MODEL churn (event='1') = education2 education3 TOT_ACTV_SRV_CNT AGE PCT_CHNG_IB_SMS_CNT PCT_CHNG_BILL_AMT COMPLAINT;
output out=prediction p=phat lower=lcl upper=ucl;
RUN;

*View predictions;
PROC PRINT data=prediction;
RUN;
