FILENAME REFFILE "C:/Users/014497819/Downloads/stats (7).csv";

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=BASEBALL;
	GETNAMES=YES;
RUN;

DATA BASEBALL; *renaming vars for simplicity;
RENAME exit_velocity_avg=AvergaeExitVelocity
launch_angle_avg=AverageLaunchAngle
barrel_batted_rate=BarrelBattedRate
solidcontact_percent=SolidContactPct
flareburner_percent=FlareBurnerPct
poorlyunder_percent=PoorlyUnderPct
poorlytopped_percent=PoorlyToppedPct
poorlyweak_percent=PoorlyWeakPct
hard_hit_percent=HardHitPct
z_swing_percent=ZSwingPct
oz_swing_percent=OZSwingPct
oz_contact_percent=OZContactPct
out_zone_percent=OutZonePct
iz_contact_percent=IZContactPct
in_zone_percent=InZonePct
edge_percent=EdgePct
whiff_percent=WhiffPct
pull_percent=PullPct
straightaway_percent=StraightAwayPct
opposite_percent=OppositePct
groundballs_percent=GroundballsPct
flyballs_percent=FlyballsPct
linedrives_percent=LinedrivesPct
popups_percent=PopupsPct;
SET BASEBALL;
full_name=cat(' ',_first_name , last_name);
RUN;


*Cleaning up data set;
DATA BASEBALL;
	set BASEBALL (drop = last_name _first_name player_id  year VAR30);
RUN;
 
proc print data=BASEBALL;
run;


/******** Correlation Matrix *******/
proc corr data=BASEBALL;
run;



*Factor Analysis to determine how many factors to use;
PROC FACTOR DATA=BASEBALL SIMPLE CORR;
	VAR AvergaeExitVelocity
AverageLaunchAngle BarrelBattedRate SolidContactPct FlareBurnerPct PoorlyUnderPct
PoorlyToppedPct PoorlyWeakPct HardHitPct ZSwingPct OZSwingPct OZContactPct OutZonePct
IZContactPct InZonePct EdgePct WhiffPct PullPct StraightAwayPct OppositePct GroundballsPct
FlyballsPct LinedrivesPct PopupsPct;
RUN;

PROC PRINCOMP DATA=BASEBALL OUT=PRINCOMP;
	VAR AvergaeExitVelocity
AverageLaunchAngle BarrelBattedRate SolidContactPct FlareBurnerPct PoorlyUnderPct
PoorlyToppedPct PoorlyWeakPct HardHitPct ZSwingPct OZSwingPct OZContactPct OutZonePct
IZContactPct InZonePct EdgePct WhiffPct PullPct StraightAwayPct OppositePct GroundballsPct
FlyballsPct LinedrivesPct PopupsPct;
RUN;

*factor analysis without OPS var;
*Determined to use 6 factors;
Proc Factor DATA=BASEBALL METHOD=prin NFACT=6 out=baseballfact
     ROTATE=NONE PREPLOT PLOT; *NO ROTATION;
	 var AvergaeExitVelocity
AverageLaunchAngle BarrelBattedRate SolidContactPct FlareBurnerPct PoorlyUnderPct
PoorlyToppedPct PoorlyWeakPct HardHitPct ZSwingPct OZSwingPct OZContactPct OutZonePct
IZContactPct InZonePct EdgePct WhiffPct PullPct StraightAwayPct OppositePct GroundballsPct
FlyballsPct LinedrivesPct PopupsPct; 
run;




/**** Decided to use only Factors 1,2,4&5 for clustering because after interpreting the factors Factor3 was similar to
		factor 2 and factor 6 was similar to factor 1*/

Proc Cluster Data=baseballfact Method=ward OutTree=baseballtree pseudo;
 			Var Factor1 Factor2 Factor4 Factor5; *all of the variables to be used in cluster analysis;
 Id full_name;
Run;
* Method options: single, complete, average, centroid, ward, etc. ;

GOptions Reset=Symbol Reset=Axis;
Proc GPlot Data=baseballtree;
 Plot _HEIGHT_*_NCL_=1 / VAxis=Axis1;
 Axis1 Label=(A=90);
 Symbol1 C=Black V=Dot I=SplineS;
Run;
Quit;

Proc Gplot;
 plot _PSF_*_NCL_=1;
Axis1 Label=(A=90);
 Symbol1 C=Black V=Dot I=SplineS H=.34;
run;

Proc Tree Data=baseballtree NCL=3 out=clusters VAxis=Axis1;
 Id full_name;
 Axis1 Label=(A=90);
Run;


*Merge the datasets with clusters and the dataset with factors;
Proc Sort data=baseballfact;
By full_name; run;
Proc sort data=clusters;
by full_name; run;
data baseballclust;
merge baseballfact clusters;
by full_name;
drop ClusName; run;






/***************** Plot FACTOR1 and FACTOR2 *********/

Proc Gplot data=baseballclust;
plot Factor1*Factor2=cluster / VAxis=Axis1 HAxis=Axis2;
 Axis1 Label=(A=90 "Factor 2")
       Order=(-4 To 4 By 1)
       Length=5.75in;
 Axis2 Label=("Factor 1")
       Order=(-4 To 4 By 1)
       Length=5.75in;
 Symbol1 C=Black V=Circle    I=None Pointlabel=(C=Black H=0.75 "#full_name");
 Symbol2 C=Blue  V=Triangle  I=None Pointlabel=(C=Blue  H=0.75 "#full_name");
 Symbol3 C=Red   V=Square    I=None Pointlabel=(C=Red   H=0.75 "#full_name");
Run;
Quit;




/***************** Plot FACTOR1 and FACTOR4 *********/

Proc Gplot data=baseballclust;
plot Factor1*Factor4=cluster / VAxis=Axis1 HAxis=Axis2;
 Axis1 Label=(A=90 "Factor 4")
       Order=(-4 To 4 By 1)
       Length=5.75in;
 Axis2 Label=("Factor 1")
       Order=(-4 To 4 By 1)
       Length=5.75in;
 Symbol1 C=Black V=Circle    I=None Pointlabel=(C=Black H=0.75 "#full_name");
 Symbol2 C=Blue  V=Triangle  I=None Pointlabel=(C=Blue  H=0.75 "#full_name");
 Symbol3 C=Red   V=Square    I=None Pointlabel=(C=Red   H=0.75 "#full_name");
Run;
Quit;




/***************** Plot FACTOR1 and FACTOR5 *********/

Proc Gplot data=baseballclust;
plot Factor1*Factor5=cluster / VAxis=Axis1 HAxis=Axis2;
 Axis1 Label=(A=90 "Factor 5")
       Order=(-4 To 4 By 1)
       Length=5.75in;
 Axis2 Label=("Factor 1")
       Order=(-4 To 4 By 1)
       Length=5.75in;
 Symbol1 C=Black V=Circle    I=None Pointlabel=(C=Black H=0.75 "#full_name");
 Symbol2 C=Blue  V=Triangle  I=None Pointlabel=(C=Blue  H=0.75 "#full_name");
 Symbol3 C=Red   V=Square    I=None Pointlabel=(C=Red   H=0.75 "#full_name");
Run;
Quit;
