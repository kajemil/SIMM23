* Encoding: UTF-8.

*Descriptive statistics for each variables

FREQUENCIES VARIABLES=Survived Sex Age SibSp Parch Pclass
  /STATISTICS=STDDEV VARIANCE RANGE MINIMUM MAXIMUM MEAN MEDIAN MODE SKEWNESS SESKEW KURTOSIS 
    SEKURT
  /ORDER=ANALYSIS.

DATASET ACTIVATE DataSet1.
DESCRIPTIVES VARIABLES=Age Fare
  /STATISTICS=MEAN STDDEV RANGE MIN MAX KURTOSIS SKEWNESS.

EXAMINE VARIABLES=Age Fare
  /PLOT BOXPLOT HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

*Recode string into binary numeric variable

RECODE Sex ('female'=1) ('male'=0) (ELSE=SYSMIS) INTO Sex_dummy.
EXECUTE.

*Recode categorical variables into binary numeric variables

RECODE SibSp (0=0) (1 thru 8=1) (ELSE=SYSMIS) INTO SibSp_dummy.
EXECUTE.

RECODE Parch (0=0) (1 thru 6=1) (ELSE=SYSMIS) INTO Parch_dummy.
EXECUTE.

RECODE Pclass (1=1) (2 thru 3=0) (ELSE=SYSMIS) INTO Pclass_dummy.
EXECUTE.

FREQUENCIES VARIABLES=Sex_dummy SibSp_dummy Parch_dummy Pclass_dummy
  /STATISTICS=MINIMUM MAXIMUM MODE
  /ORDER=ANALYSIS.

* Chart Builder - exploring relationship between outcome and predictor variables

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Survived COUNT()[name="COUNT"] Sex_dummy 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Sex_dummy=col(source(s), name("Sex_dummy"), unit.category())
  GUIDE: axis(dim(1), label("Survived"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Sex_dummy"))
  GUIDE: text.title(label("Stacked Bar Count of Survived by Sex_dummy"))
  SCALE: linear(dim(2), include(0))
  SCALE: cat(aesthetic(aesthetic.color.interior), include("0.00", "1.00"))
  ELEMENT: interval.stack(position(Survived*COUNT), color.interior(Sex_dummy), 
    shape.interior(shape.square))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Survived COUNT()[name="COUNT"] SibSp_dummy 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: SibSp_dummy=col(source(s), name("SibSp_dummy"), unit.category())
  GUIDE: axis(dim(1), label("Survived"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("SibSp_dummy"))
  GUIDE: text.title(label("Stacked Bar Count of Survived by SibSp_dummy"))
  SCALE: linear(dim(2), include(0))
  SCALE: cat(aesthetic(aesthetic.color.interior), include("0.00", "1.00"))
  ELEMENT: interval.stack(position(Survived*COUNT), color.interior(SibSp_dummy), 
    shape.interior(shape.square))
END GPL.

* Chart Builder - exploring rel with y against all categories of sb/sp

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Survived COUNT()[name="COUNT"] SibSp MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: SibSp=col(source(s), name("SibSp"), unit.category())
  COORD: rect(dim(1,2), cluster(3,0))
  GUIDE: axis(dim(3), label("Survived"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("SibSp"))
  GUIDE: text.title(label("Clustered Bar Count of Survived by SibSp"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval(position(SibSp*COUNT*Survived), color.interior(SibSp), 
    shape.interior(shape.square))
END GPL.

*Recode SibSp into new dummy in where no sib/sp is the ref.category and 1 sib/sp = 1

RECODE SibSp (1=1) (MISSING=SYSMIS) (ELSE=0) INTO SibSp_dummy_1.
EXECUTE.

* Chart Builder - explore rel between survive and age through boxplot

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Survived Age MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  DATA: Age=col(source(s), name("Age"))
  DATA: id=col(source(s), name("$CASENUM"), unit.category())
  GUIDE: axis(dim(1), label("Survived"))
  GUIDE: axis(dim(2), label("Age"))
  GUIDE: text.title(label("Simple Boxplot of Age by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: schema(position(bin.quantile.letter(Survived*Age)), label(id))
END GPL.

*Running first binary log regression with the following predictors sex, age, sibbling/spouses, parents/children

LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Sex_dummy Age SibSp Parch 
  /PRINT=CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

*Runnig second binary regression with the above predictions plus ticket class (pclass)

LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Sex_dummy Age SibSp_dummy Parch_dummy Pclass_dummy 
  /PRINT=CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

*Runnig third binary regression with the above predictions, but with another dummy for sibbling/spouses in where the value of 1 is having 1 sibbling/spouse and 0 is having none or two or more
* ADD creating dummy
*Running multinominal regression in assessing goodness of fit

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH Age Sex_dummy SibSp_dummy_1 Parch_dummy 
    Pclass_dummy
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.

*Runnig model diagnostics
*Influential cases

LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Sex_dummy Age SibSp_dummy_1 Parch_dummy Pclass_dummy 
  /SAVE=COOK
  /PRINT=CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

* Chart Builder - scatterplot passenger id versus Cook's distance

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=PassengerId COO_1 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: PassengerId=col(source(s), name("PassengerId"))
  DATA: COO_1=col(source(s), name("COO_1"))
  GUIDE: axis(dim(1), label("PassengerId"))
  GUIDE: axis(dim(2), label("Analog of Cook's influence statistics"))
  GUIDE: text.title(label("Simple Scatter of Analog of Cook's influence statistics by PassengerId"))    
  ELEMENT: point(position(PassengerId*COO_1))
END GPL.

*Check potential influential cases. 6 potential influential cases (case 178, 298, 499, 571, 588, 631) - none of them are unlikely and thus, should be included in the model

USE ALL.
COMPUTE filter_$=(COO_1 > 0.050).
VARIABLE LABELS filter_$ 'COO_1 > 0.050 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

*Check for multicolinearity - no multiocolinearity was found

DATASET ACTIVATE DataSet1.
CORRELATIONS
  /VARIABLES=Survived Sex_dummy Age SibSp_dummy_1 Parch_dummy_1 Parch_dummy_2 Pclass_dummy Fare
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Survived
  /METHOD=ENTER Sex_dummy Age SibSp_dummy_1 Parch_dummy_1 Parch_dummy_2 Pclass_dummy Fare

*Check for linearity - age as it is the only continous variable in the model - it is not linear since being sign.

COMPUTE Ln_Age=LN(Age).
EXECUTE.

LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Sex_dummy Age SibSp_dummy_1 Parch_dummy Pclass_dummy Ln_Age 
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).

* Dummy coding for Parch in where 2 parents have the value 1 and the rest = 0

RECODE Parch (2=1) (MISSING=SYSMIS) (ELSE=0) INTO Parch_dummy_2.
EXECUTE.

RECODE Parch_dummy (1=1) (MISSING=SYSMIS) (ELSE=0) INTO Parch_dummy_1.
EXECUTE.

LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Sex_dummy Age SibSp_dummy_1 Parch_dummy_1 Parch_dummy_2 Pclass_dummy Fare 
  /SAVE=COOK
  /PRINT=CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH Sex_dummy Age SibSp_dummy_1 Parch_dummy_1 
    Parch_dummy_2 Pclass_dummy Fare
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.

*Check potential influential cases. 7 potential influential cases (passenger id 28, 119, 298, 499, 631, 680, 738) - they should all be included

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=PassengerId COO_6 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: PassengerId=col(source(s), name("PassengerId"))
  DATA: COO_6=col(source(s), name("COO_6"))
  GUIDE: axis(dim(1), label("PassengerId"))
  GUIDE: axis(dim(2), label("Analog of Cook's influence statistics"))
  GUIDE: text.title(label("Simple Scatter of Analog of Cook's influence statistics by PassengerId"))    
  ELEMENT: point(position(PassengerId*COO_6))
END GPL.

USE ALL.
COMPUTE filter_$=(COO_6 > 0.100).
VARIABLE LABELS filter_$ 'COO_1 > 0.100 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

*Check for multicolinearity - no multicolinearity

DATASET ACTIVATE DataSet1.
CORRELATIONS
  /VARIABLES=Survived Sex_dummy Age SibSp_dummy_1 Parch_dummy_1 Parch_dummy_2 Pclass_dummy Fare
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Survived
  /METHOD=ENTER Sex_dummy Age SibSp_dummy_1 Parch_dummy_1 Parch_dummy_2 Pclass_dummy Fare

*Check for linearity - only done for age as it is acontinous variables in the model - it is not linear since being sign. Couldn't do it for fare

COMPUTE Ln_Age=LN(Age).
EXECUTE.

LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Sex_dummy Age SibSp_dummy_1 Parch_dummy_1 Parch_dummy_2 Pclass_dummy Fare Ln_Age 
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).





