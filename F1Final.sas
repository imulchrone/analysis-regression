PROC IMPORT datafile="f1data2024.csv" out=f1 replace;
delimiter=',';
getnames=YES;
datarow=2;
RUN;

PROC PRINT data=f1(obs=10);
RUN;

*Remove bad data;
DATA f1;
SET f1;
IF LapTime > 2000 THEN DELETE;
IF TrackStatus ^= 1 THEN DELETE;
IF Deleted = 'True' THEN DELETE;
IF MISSING(LapTime) THEN DELETE;
IF MISSING(SpeedI1) THEN DELETE;
IF MISSING(SpeedI2) THEN DELETE;
IF MISSING(SpeedFL) THEN DELETE;
IF MISSING(SpeedST) THEN DELETE;
IF NOT MISSING(PitOutTime) THEN DELETE;
IF SpeedFL < 10 THEN DELETE;
RUN;

*Histogram- Lap Times;
TITLE "Lap Times Histogram";
PROC UNIVARIATE normal;
VAR LapTime;
histogram / normal (mu = est sigma = est);
RUN;

*Lap times distrubution;
TITLE "Lap Times Summary";
PROC MEANS min p10 p25 median mean p75 p90 max;
VAR LapTime;
RUN;

*Bimodal distribution, will need select group that we can model effectively

*Identify categorical variable values;
TITLE "Freq Tables";
PROC FREQ data=f1;
TABLES Driver Compound Event TrackStatus / nocum missing;
RUN;


*Create dummy variables;
DATA f1;
SET f1;
ALB = (Driver = 'ALB');
ALO = (Driver = 'AL0');
BEA = (Driver = 'BEA');
BOT = (Driver = 'BOT');
COL = (Driver = 'COL');
DOO = (Driver = 'DOO');
GAS = (Driver = 'GAS');
HAM = (Driver = 'HAM');
HUL = (Driver = 'HUL');
LAW = (Driver = 'LAW');
LEC = (Driver = 'LEC');
MAG = (Driver = 'MAG'); 
NOR = (Driver = 'NOR');
OCO = (Driver = 'OCO');
PER = (Driver = 'PER');
PIA = (Driver = 'PIA');
RIC = (Driver = 'RIC'); 
RUS = (Driver = 'RUS'); 
SAI = (Driver = 'SAI'); 
SAR = (Driver = 'SAR'); 
STR = (Driver = 'STR'); 
TSU = (Driver = 'TSU'); 
VER = (Driver = 'VER'); 
ZHO = (Driver = 'ZHO');
C_HARD = (Compound = 'HARD');
C_INTER = (Compound = 'INTE');
C_MEDIUM = (Compound = 'MEDI');
C_SOFT = (Compound = 'SOFT');
C_WET = (Compound = 'WET');
AbuDhabi = (Event = 'Abu Dhabi Grand Pr');
Australian = (Event = 'Australian Grand P'); 
Austrian = (Event = 'Austrian Grand Pri');
Azerbaijan = (Event = 'Azerbaijan Grand P');
Bahrain = (Event = 'Bahrain Grand Prix'); 
Belgian = (Event = 'Belgian Grand Prix');
British = (Event = 'British Grand Prix'); 
Canadian = (Event = 'Canadian Grand Pri');
Chinese = (Event = 'Chinese Grand Prix');
Dutch = (Event = 'Dutch Grand Prix');
EmiliaRomagna = (Event = 'Emilia Romagna Gra');
Hungarian = (Event = 'Hungarian Grand Pr'); 
Italian = (Event = 'Italian Grand Prix');
Japanese = (Event = 'Japanese Grand Pri');
LasVegas = (Event = 'Las Vegas Grand Pr');
Mexico = (Event = 'Mexico City Grand');
Miami = (Event = 'Miami Grand Prix'); 
Monaco = (Event = 'Monaco Grand Prix'); 
Qatar = (Event = 'Qatar Grand Prix'); 
SaudiArabian = (Event = 'Saudi Arabian Gran');
Singapore = (Event = 'Singapore Grand Pr'); 
Spanish = (Event = 'Spanish Grand Prix'); 
SaoPaulo = (Event = 'São Paulo Grand P');
UnitedStates = (Event = 'United States Gran');
PersonalBest = (IsPersonalBest = 'True');
NewTire = (FreshTyre = 'True');
Leader = (Position = 1);
RUN;

*Validate dummy variables created correctly;
PROC FREQ data=f1;
TABLES ALB ALO BEA BOT COL DOO GAS HAM HUL LAW LEC MAG NOR OCO PER PIA RIC RUS SAI SAR STR TSU VER ZHO
	C_HARD C_INTER C_MEDIUM C_SOFT C_WET PersonalBest NewTire Leader;
RUN;

PROC FREQ data=f1;
TABLES AbuDhabi Australian Austrian Azerbaijan Bahrain belgian British Canadian Chinese Dutch EmiliaRomagna
		Hungarian Italian Japanese LasVegas Mexico Miami Monaco Qatar SaudiArabian Singapore Spanish SaoPaulo
		UnitedStates;
RUN;

*Lap time summary per event;
PROC SUMMARY;
VAR LapTime;
CLASS Event;
OUTPUT OUT = summaryLapEvent;
RUN;

PROC PRINT data=summaryLapEvent;
RUN;

*MEANS
TOTAL = 89.11816564
AbuDhabi = 89.525283843
Australian = 82.793458915 
Austrian = 71.205718133
Azerbaijan = 109.21362082
Bahrain = 96.9820301
Belgian = 109.48547143
British = 95.302163237
Canadian = 87.082874244
Chinese = 101.76104252
Dutch = 76.497746767
EmiliaRomagna = 82.091605477
Hungarian =  84.66746794
Italian = 85.066931464
Japanese = 97.903507143
LasVegas = 98.829559249
Mexico = 82.254294584
Miami = 93.241219668
Monaco = 79.562373483
Qatar = 86.209146766
SaudiArabian = 94.598605489
Singapore = 98.885412596
Spanish = 80.74517234
SaoPaulo = 85.021156928
UnitedStates = 100.17735847;

*Select data from events with similar lap times;
DATA f1_1;
SET f1;
IF Event IN('Australian Grand P','Canadian Grand Pri','Dutch Grand Prix','Emilia Romagna Gra','Hungarian Grand Pr',
			'Italian Grand Prix','Mexico City Grand','Monaco Grand Prix','Qatar Grand Prix','Spanish Grand Prix','São Paulo Grand P');
RUN;

TITLE "Set 1 Freq Tables";
PROC FREQ data=f1_1;
TABLES Event / nocum missing;
RUN;

*Histogram- Lap Times 1;
TITLE "Lap Times Histogram";
PROC UNIVARIATE data=f1_1 normal;
VAR LapTime;
histogram / normal (mu = est sigma = est);
RUN;

PROC SORT;
BY Driver;
RUN;

*Box plot;
TITLE "Boxplot Driver";
PROC BOXPLOT;
PLOT LapTime*Driver;
RUN;

PROC SORT;
BY Event;
RUN;

*Box plot;
TITLE "Boxplot Event";
PROC BOXPLOT;
PLOT LapTime*Event;
RUN;

*Scatterplot Matrix;
TITLE "Scatterplot Matrix for LapTime";
PROC SGSCATTER data=f1_1;
MATRIX LapTime LapNumber SpeedI1 SpeedI2 SpeedFL SpeedST TyreLife;
RUN;

*Full model 1;
TITLE "Full Model 1";
PROC REG data=f1_1 PLOTS(MAXPOINTS=NONE);
MODEL LapTime = LapNumber Stint SpeedI1 SpeedI2 SpeedFL SpeedST TyreLife ALB ALO BEA BOT COL DOO GAS HAM HUL
				LAW LEC MAG NOR OCO PER PIA RUS SAI SAR STR TSU VER ZHO C_HARD C_INTER C_MEDIUM C_SOFT C_WET
				Australian Canadian Dutch 
				EmiliaRomagna Hungarian Italian Mexico Monaco Qatar
				Spanish SaoPaulo PersonalBest NewTire Leader/ stb vif;
RUN;

*Remove variables with multicollineairty issues;
TITLE "Full Model 1 Check Outliers 1";
PROC REG data=f1_1 PLOTS(MAXPOINTS=NONE);
MODEL LapTime = LapNumber Stint SpeedST TyreLife ALB ALO BEA BOT COL DOO GAS HAM HUL
				LAW LEC MAG NOR OCO PER PIA RUS SAI SAR STR TSU VER ZHO
				Australian Canadian Dutch 
				EmiliaRomagna Hungarian Italian Mexico Monaco Qatar
				Spanish SaoPaulo PersonalBest NewTire Leader/ stb vif;
OUTPUT OUT = residuals rstudent = student_resid;
RUN;

PROC PRINT data=residuals(obs=10);
RUN;

DATA f1_1;
SET residuals;
IF ABS(student_resid) <= 3;
RUN;

TITLE "Full Model 1 Check Outliers 2";
PROC REG data=f1_1 PLOTS(MAXPOINTS=NONE);
MODEL LapTime = LapNumber Stint SpeedST TyreLife ALB ALO BEA BOT COL DOO GAS HAM HUL
				LAW LEC MAG NOR OCO PER PIA RUS SAI SAR STR TSU VER ZHO
				Australian Canadian Dutch 
				EmiliaRomagna Hungarian Italian Mexico Monaco Qatar
				Spanish SaoPaulo PersonalBest NewTire Leader/ stb vif;
OUTPUT OUT = residuals rstudent = student_resid2;
RUN;

PROC PRINT data=residuals(obs=10);
RUN;

DATA f1_1;
SET residuals;
IF ABS(student_resid2) <= 3;
RUN;

TITLE "Full Model 1 Check Outliers 3";
PROC REG data=f1_1 PLOTS(MAXPOINTS=NONE);
MODEL LapTime = LapNumber Stint SpeedST TyreLife ALB ALO BEA BOT COL DOO GAS HAM HUL
				LAW LEC MAG NOR OCO PER PIA RUS SAI SAR STR TSU VER ZHO
				Australian Canadian Dutch 
				EmiliaRomagna Hungarian Italian Mexico Monaco Qatar
				Spanish SaoPaulo PersonalBest NewTire Leader/ stb vif;
OUTPUT OUT = residuals rstudent = student_resid3;
RUN;

PROC PRINT data=residuals(obs=10);
RUN;

DATA f1_1;
SET residuals;
IF ABS(student_resid3) <= 3;
RUN;

TITLE "Full Model Check Outliers 4";
PROC REG data=f1_1 PLOTS(MAXPOINTS=NONE);
MODEL LapTime = LapNumber Stint SpeedST TyreLife ALB ALO BEA BOT COL DOO GAS HAM HUL
				LAW LEC MAG NOR OCO PER PIA RUS SAI SAR STR TSU VER ZHO
				Australian Canadian Dutch 
				EmiliaRomagna Hungarian Italian Mexico Monaco Qatar
				Spanish SaoPaulo PersonalBest NewTire Leader/ stb vif;
OUTPUT OUT = residuals rstudent = student_resid;
RUN;

TITLE "Full Model Outlier Plots";
PROC REG data=f1_1 PLOTS(MAXPOINTS=NONE);
MODEL LapTime = LapNumber Stint SpeedST TyreLife ALB ALO BEA BOT COL DOO GAS HAM HUL
				LAW LEC MAG NOR OCO PER PIA RUS SAI SAR STR TSU VER ZHO
				Australian Canadian Dutch 
				EmiliaRomagna Hungarian Italian Mexico Monaco Qatar
				Spanish SaoPaulo PersonalBest NewTire Leader/ stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
RUN;


*Split into training and testing;
PROC SURVEYSELECT data = f1_1 out = trainset1 seed = 763476
samprate = 0.75 outall;
RUN;

DATA trainset1;
SET trainset1;
IF selected THEN new_LapTime = LapTime;
RUN;

PROC PRINT data=trainset1(obs=10);
RUN;

TITLE "Backward Model";
PROC REG data=trainset1 PLOTS(MAXPOINTS=NONE);
MODEL new_LapTime = LapNumber Stint SpeedST TyreLife ALB ALO BEA BOT COL DOO GAS HAM HUL
				LAW LEC MAG NOR OCO PER PIA RUS SAI SAR STR TSU VER ZHO
				Australian Canadian Dutch 
				EmiliaRomagna Hungarian Italian Mexico Monaco Qatar
				Spanish SaoPaulo PersonalBest NewTire Leader/ selection=backward;
PLOT student.*predicted.;
PLOT npp.*student.;
OUTPUT OUT = residuals1 rstudent = student_resid;
RUN;

*Remove outlier points;
DATA trainset1;
SET residuals1;
IF ABS(student_resid4) <= 4;
RUN;

PROC PRINT data=residuals1(obs=10);
RUN;


TITLE "Final Model";
PROC REG data=trainset1 PLOTS(MAXPOINTS=NONE);
MODEL new_LapTime = LapNumber Stint SpeedST TyreLife BOT GAS HAM HUL
				 LEC NOR PER PIA RUS SAI SAR VER ZHO
				Australian Canadian Dutch 
				EmiliaRomagna Hungarian Italian Mexico Monaco Qatar
				Spanish PersonalBest NewTire Leader/ stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
RUN;

TITLE "Predictions";
proc reg data = trainset1;
model new_LapTime = LapNumber Stint SpeedST TyreLife BOT GAS HAM HUL
				 LEC NOR PER PIA RUS SAI SAR VER ZHO
				Australian Canadian Dutch 
				EmiliaRomagna Hungarian Italian Mexico Monaco Qatar
				Spanish PersonalBest NewTire Leader;
output out = pred(where=(new_LapTime=.)) p=yhat;
run;

PROC PRINT data=pred(obs=10);
RUN;

*Compute test results;
TITLE "Test Results";
DATA pred_sum;
SET pred;
d=LapTime-yhat;
absd=abs(d);
RUN;

PROC SUMMARY data=pred_sum;
VAR d absd;
OUTPUT OUT=pred_stats std(d)=rmse mean(absd)=mae;
RUN;
PROC PRINT data=pred_stats;
TITLE 'Validation Statistics for Model';
RUN;

PROC CORR data=pred;
VAR LapTime yhat;
RUN;


*Make new prediction;
DATA newpred;
INPUT LapNumber Stint SpeedST TyreLife
	  BOT GAS HAM HUL LEC NOR PER PIA RUS SAI SAR VER ZHO
	  Australian Canadian Dutch EmiliaRomagna Hungarian Italian Mexico Monaco Qatar Spanish
	  PersonalBest NewTire Leader;
DATALINES;
24 2 300 8 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1
;
RUN;
PROC PRINT;
RUN;

DATA prediction;
SET newpred trainset1;
RUN;
PROC PRINT data=prediction(obs=10);
RUN;

TITLE "New Data Prediction";
PROC REG data=prediction;
MODEL new_LapTime = LapNumber Stint SpeedST TyreLife BOT GAS HAM HUL
				 LEC NOR PER PIA RUS SAI SAR VER ZHO
				Australian Canadian Dutch 
				EmiliaRomagna Hungarian Italian Mexico Monaco Qatar
				Spanish PersonalBest NewTire Leader/p clm cli;
RUN;
