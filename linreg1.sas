*Import the dataset;
PROC IMPORT datafile="unemployment.txt" out=unemployment replace;
delimiter='09'x;
getnames=YES;
datarow=2;
RUN;

*prints the dataset;
TITLE "Dataset - Unemployment";
PROC PRINT;
RUN;

*5-point summary ;
TITLE "5-point Summary";
PROC MEANS min max median p25 p75;
VAR Age Income Balance Education Unemployment;
RUN;

*Histogram;
TITLE "Histogram";
PROC UNIVARIATE normal;
VAR Unemployment;
histogram / normal (mu = est sigma = est);
RUN;

*Scatterplots;
TITLE "Scatterplots";
PROC GPLOT;
PLOT Unemployment*(Age Income Balance Education);
RUN;

*Scatterplot Matrix;
TITLE "Scatterplot Matrix for Unemployment";
PROC SGSCATTER;
MATRIX Unemployment Age Income Balance Education;
RUN;

*Correlation values;
TITLE "Correlation values";
PROC CORR;
VAR Unemployment Age Income Balance Education;
RUN;

*Regression model;
TITLE "Regression model";
PROC REG;
MODEL Unemployment=Age Income Balance Education;
RUN;

*Regression model 2;
TITLE "Regression model 2";
PROC REG;
MODEL Unemployment=Age Income;
RUN;

*Residuals;
TITLE "Residual Plots";
PROC REG;
MODEL Unemployment=Age Income;
PLOT student.*predicted.;
PLOT student.*(Age Income);
PLOT npp.*student.;
RUN;
