*Import the dataset;
PROC IMPORT datafile="election.txt" out=election replace;
delimiter='09'x;
getnames=YES;
datarow=2;
RUN;

*prints the dataset;
TITLE "Dataset - Election";
PROC PRINT;
RUN;

*5-point summary ;
TITLE "5-point Summary";
PROC MEANS min max median p25 p75;
VAR PctVoted MedianAge PctUnemployment;
RUN;

*Histogram;
TITLE "Histogram";
PROC UNIVARIATE normal;
VAR PctVoted;
histogram / normal (mu = est sigma = est);
RUN;

*Boxplot;
TITLE "Boxplot";
* Sort the data by Gender;
PROC SORT;
BY Gender;
RUN;

*Generate the boxplot;
TITLE "Boxplot";
PROC BOXPLOT;
*y-axis variable * x-axis variable;
PLOT PctVoted*Gender;
RUN;

*Counts or frequency;
TITLE "Counts or frequency";
PROC FREQ;
TABLES Gender;
RUN;
