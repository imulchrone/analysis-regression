*Import the dataset;
PROC IMPORT datafile="banking.txt" out=banking replace;
delimiter='09'x;
getnames=YES;
datarow=2;
RUN;

*prints the dataset;
TITLE "Dataset - Banking";
PROC PRINT;
RUN;

*Scatterplot Matrix;
TITLE "Scatterplot Matrix for Banking";
PROC SGSCATTER;
MATRIX Balance Age Education Income HomeVal Wealth;
RUN;

*Correlation values;
TITLE "Correlation values";
PROC CORR;
VAR Balance Age Education Income HomeVal Wealth;
RUN;

*Regression model;
TITLE "Regression model";
PROC REG;
MODEL Balance=Age Education Income HomeVal Wealth /VIF TOL;
RUN;

*Regression model 2;
TITLE "Regression model 2";
PROC REG;
MODEL Balance=Age Education Wealth /VIF TOL;
RUN;

*Residuals;
TITLE "Residual Plots";
PROC REG;
MODEL Balance=Age Education Wealth/INFLUENCE R;
PLOT student.*predicted.;
PLOT student.*(Age Education Wealth);
PLOT npp.*student.;
RUN;

*Remove outliers and influential points;
data bankingnew;
set banking;
if _n_ in (38,59,77,82,84,85,91,102) then delete;
run;

*Regression model new;
TITLE "Regression model new";
PROC REG data = bankingnew;
MODEL Balance=Age Education Wealth /VIF TOL;
PLOT student.*predicted.;
PLOT student.*(Age Education Wealth);
PLOT npp.*student.;
RUN;

*Standardized coefficients;
TITLE "Standardized coefficients";
PROC REG data = bankingnew;
MODEL Balance=Age Education Wealth /stb;
RUN;


*PART 2;
*import data from file; 
proc import datafile="golf.csv" out=golf replace; 
delimiter=','; 
getnames=yes; 
run;

*prints the dataset;
TITLE "Dataset - Golf";
PROC PRINT;
RUN;

*Scatterplot Matrix;
TITLE "Scatterplot Matrix for Golf";
PROC SGSCATTER;
MATRIX PrizeMoney DrivingAccuracy GIR PuttingAverage BirdieConversion PuttsPerRound;
RUN;

*Histogram;
TITLE "Histogram";
PROC UNIVARIATE normal;
VAR PrizeMoney;
histogram / normal (mu = est sigma = est);
RUN;

*Create ln_prize;
data golf;
set golf;
ln_Prize = log(PrizeMoney);
RUN;

PROC PRINT;
RUN;

TITLE "Histogram";
PROC UNIVARIATE normal;
VAR ln_Prize;
histogram / normal (mu = est sigma = est);
RUN;

*Regression model;
TITLE "Regression model";
PROC REG data = golf;
MODEL ln_Prize=DrivingAccuracy GIR PuttingAverage BirdieConversion PuttsPerRound /VIF TOL;
PLOT student.*predicted.;
PLOT student.*(DrivingAccuracy GIR PuttingAverage BirdieConversion PuttsPerRound);
PLOT npp.*student.;
RUN;

*Regression model 2;
TITLE "Regression model 2";
PROC REG data = golf;
MODEL ln_Prize=GIR BirdieConversion PuttsPerRound /VIF TOL;
PLOT student.*predicted.;
PLOT student.*(GIR BirdieConversion PuttsPerRound);
PLOT npp.*student.;
RUN;

*Check for outliers and influential points;
TITLE "Outliers check";
PROC REG;
MODEL ln_Prize=GIR BirdieConversion PuttsPerRound/INFLUENCE R;
RUN;

*Remove outliers and influential points;
DATA golfnew;
SET golf;
IF _n_ in (1,39,40,47,60,63,101,115,141,180,185) THEN DELETE;
RUN;

*Final model;
TITLE "Final model";
PROC REG data = golfnew;
MODEL ln_Prize=GIR BirdieConversion PuttsPerRound/INFLUENCE R;
RUN;

*5-point summary ;
TITLE "5-point Summary";
PROC MEANS min max median p25 p75;
VAR ln_Prize GIR BirdieConversion PuttsPerRound;
RUN;

DATA golfnew2;
SET golfnew;
IF _n_ in (8,17,42,77,95) THEN DELETE;
RUN;

TITLE "Final model 2";
PROC REG data = golfnew2;
MODEL ln_Prize=GIR BirdieConversion PuttsPerRound/INFLUENCE R;
RUN;

DATA golfnew3;
SET golfnew2;
IF _n_ in (6,27,112,136,154,169) THEN DELETE;
RUN;

TITLE "Final model 3";
PROC REG data = golfnew3;
MODEL ln_Prize=GIR BirdieConversion PuttsPerRound/INFLUENCE R;
RUN;

DATA golfnew4;
SET golfnew3;
IF _n_ in (22,28,133,155) THEN DELETE;
RUN;

TITLE "Final model 4";
PROC REG data = golfnew4;
MODEL ln_Prize=GIR BirdieConversion PuttsPerRound/INFLUENCE R;
RUN;
*Adj R2 did not increase by 2% so we will keep model 3;
