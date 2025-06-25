*Import the dataset;
PROC IMPORT datafile="housesales.txt" out=housesales replace;
delimiter='09'x;
getnames=YES;
datarow=2;
RUN;

*prints the dataset;
TITLE "Dataset - HouseSales";
PROC PRINT;
RUN;

*Create dummy variables;
DATA housesales;
infile "housesales.txt" delimiter='09'x MISSOVER FIRSTOBS=2;
INPUT Region $ Type $ Price Cost;
RegionS = (Region = 'S');
TypeC = (Type = 'C');
RUN;

PROC PRINT;
RUN;

*Scatterplot Matrix;
TITLE "Scatterplot Matrix for HouseSales";
PROC SGSCATTER;
MATRIX Price Cost RegionS TypeC;
RUN;

*Correlation values;
TITLE "Correlation values";
PROC CORR;
VAR Price Cost RegionS TypeC;
RUN;

*Regression model;
TITLE "Regression model";
PROC REG;
MODEL Price=Cost RegionS TypeC;
RUN;

*Regression model 2;
TITLE "Regression model 2";
PROC REG;
MODEL Price=Cost TypeC;
RUN;

*Residuals;
TITLE "Residual Plots";
PROC REG;
MODEL Price=Cost TypeC;
PLOT student.*predicted.;
PLOT student.*(Cost TypeC);
PLOT npp.*student.;
RUN;


