* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.
RECODE sex ('female'=1) ('male'=0) (ELSE=SYSMIS) INTO sex_dummy.
VARIABLE LABELS  sex_dummy 'Sex dummy'.
EXECUTE.

DESCRIPTIVES VARIABLES=age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness weight IQ 
    household_income sex_dummy
  /STATISTICS=MEAN STDDEV RANGE MIN MAX KURTOSIS SKEWNESS.

*Restructure data

VARSTOCASES
  /ID=participant_id
  /MAKE pain_time FROM pain1 pain2 pain3 pain4
  /INDEX=Time(4) 
  /KEEP=ID sex age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness weight IQ 
    household_income sex_dummy 
  /NULL=KEEP.

*Descriptives for new variables

DATASET ACTIVATE DataSet1.
DESCRIPTIVES VARIABLES=Time pain_rating_index
  /STATISTICS=MEAN STDDEV RANGE MIN MAX KURTOSIS SKEWNESS.

*Fit model with fixed effects and random intercept

MIXED pain_rating_index WITH age sex_dummy STAI_trait pain_cat mindfulness cortisol_serum Time
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age sex_dummy STAI_trait pain_cat mindfulness cortisol_serum Time | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC)
  /SAVE=FIXPRED PRED RESID.

*Fit model with fixed effects, random intercept and random slope of time

MIXED pain_rating_index WITH age sex_dummy STAI_trait pain_cat mindfulness cortisol_serum Time
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age sex_dummy STAI_trait pain_cat mindfulness cortisol_serum Time | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT Time | SUBJECT(ID) COVTYPE(UN)
  /SAVE=PRED RESID.


* Scatterplot for pain rating and time

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Time pain_rating_index MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Time=col(source(s), name("Time"))
  DATA: pain_rating_index=col(source(s), name("pain_rating_index"))
  GUIDE: axis(dim(1), label("Time"))
  GUIDE: axis(dim(2), label("pain_rating_index"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain_rating_index by Time"))
  ELEMENT: point(position(Time*pain_rating_index))
END GPL.

* Comparing models - restructuring data

VARSTOCASES
  /MAKE pain_predint_predslope FROM pain_rating_index Predval_int Predval_slope
  /INDEX=Index_prediction(pain_predint_predslope) 
  /KEEP=participant_id ID sex age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness 
    weight IQ household_income sex_dummy Time Fixed_predval_int Res_int Res_slope 
  /NULL=KEEP.

SORT CASES  BY ID.
SPLIT FILE SEPARATE BY ID.

* Visualization of pain rating and time (obs and pred values) for each participant

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Time 
    MEAN(pain_predint_predslope)[name="MEAN_pain_predint_predslope"] Index_prediction MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Time=col(source(s), name("Time"), unit.category())
  DATA: MEAN_pain_predint_predslope=col(source(s), name("MEAN_pain_predint_predslope"))
  DATA: Index_prediction=col(source(s), name("Index_prediction"), unit.category())
  GUIDE: axis(dim(1), label("Time"))
  GUIDE: axis(dim(2), label("Mean pain_predint_predslope"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Index_prediction"))
  GUIDE: text.title(label("Multiple Line Mean of pain_predint_predslope by Time by ",
    "Index_prediction"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(Time*MEAN_pain_predint_predslope), color.interior(Index_prediction), 
    missing.wings())
END GPL.

* Quadratic term of time

DATASET ACTIVATE DataSet2.
DESCRIPTIVES VARIABLES=Time
  /STATISTICS=MEAN STDDEV MIN MAX.

COMPUTE time_centered=Time - 2.5.
EXECUTE.

COMPUTE time_centered_sq=time_centered * time_centered.
EXECUTE.

DATASET ACTIVATE DataSet1.
DESCRIPTIVES VARIABLES=time_centered time_centered_sq
  /STATISTICS=MEAN STDDEV MIN MAX.

-------------------------------------------------------------------------------------------------------

*Random intercept model with the quadratic term of time

MIXED pain_rating_index WITH age sex_dummy STAI_trait pain_cat mindfulness cortisol_serum time_centered time_centered_sq
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age sex_dummy STAI_trait pain_cat mindfulness cortisol_serum time_centered time_centered_sq | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC)
  /SAVE=FIXPRED PRED RESID.

* Comparing models - restructuring data

VARSTOCASES
  /MAKE pain_rating FROM pain_rating_index Predval_int Predval_int_timesq
  /INDEX=obs_or_pred(pain_rating) 
  /KEEP=participant_id ID sex age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness 
    weight IQ household_income sex_dummy Time Fixed_predval_int Predval_int Res_int Res_slope 
    time_centered time_centered_sq Res_slope_timesq Res_int_timesq
  /NULL=KEEP.

* Visualization of pain rating and time (obs and pred values)

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Time MEAN(pain_rating)[name="MEAN_pain_rating"] 
    obs_or_pred MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Time=col(source(s), name("Time"), unit.category())
  DATA: MEAN_pain_rating=col(source(s), name("MEAN_pain_rating"))
  DATA: obs_or_pred=col(source(s), name("obs_or_pred"), unit.category())
  GUIDE: axis(dim(1), label("Time"))
  GUIDE: axis(dim(2), label("Mean pain_rating"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("obs_or_pred"))
  GUIDE: text.title(label("Multiple Line Mean of pain_rating by Time by obs_or_pred"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(Time*MEAN_pain_rating), color.interior(obs_or_pred), missing.wings())
END GPL.

* Visualization of pain rating and time (obs and pred values) for each participant

SORT CASES  BY ID.
SPLIT FILE SEPARATE BY ID.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Time MEAN(pain_rating)[name="MEAN_pain_rating"] 
    obs_or_pred MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Time=col(source(s), name("Time"), unit.category())
  DATA: MEAN_pain_rating=col(source(s), name("MEAN_pain_rating"))
  DATA: obs_or_pred=col(source(s), name("obs_or_pred"), unit.category())
  GUIDE: axis(dim(1), label("Time"))
  GUIDE: axis(dim(2), label("Mean pain_rating"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("obs_or_pred"))
  GUIDE: text.title(label("Multiple Line Mean of pain_rating by Time by obs_or_pred"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(Time*MEAN_pain_rating), color.interior(obs_or_pred), missing.wings())
END GPL.

*Model diagnostics - outliers

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Time 
    MEAN(pain_rating_index)[name="MEAN_pain_rating_index"] ID MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Time=col(source(s), name("Time"), unit.category())
  DATA: MEAN_pain_rating_index=col(source(s), name("MEAN_pain_rating_index"))
  DATA: ID=col(source(s), name("ID"), unit.category())
  GUIDE: axis(dim(1), label("Time"))
  GUIDE: axis(dim(2), label("Mean pain_rating_index"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("ID"))
  GUIDE: text.title(label("Multiple Line Mean of pain_rating_index by Time by ID"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(Time*MEAN_pain_rating_index), color.interior(ID), missing.wings())
END GPL.

EXAMINE VARIABLES=pain_rating_index BY ID
  /PLOT BOXPLOT.

*Model diagnostics - normality

EXAMINE VARIABLES=Res_int_timesq
  /PLOT BOXPLOT HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

*Model diagnostics - linearity and homoscedasticity

* Chart Builder - scatterplot residuals and predicted values

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Predval_int_timesq Res_int_timesq 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Predval_int_timesq=col(source(s), name("Predval_int_timesq"))
  DATA: Res_int_timesq=col(source(s), name("Res_int_timesq"))
  GUIDE: axis(dim(1), label("Predicted Values"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by Predicted Values"))
  ELEMENT: point(position(Predval_int_timesq*Res_int_timesq))
END GPL.

* Chart Builder - dependent variable and predictors one-by-one

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=age pain_rating_index MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: age=col(source(s), name("age"))
  DATA: pain_rating_index=col(source(s), name("pain_rating_index"))
  GUIDE: axis(dim(1), label("age"))
  GUIDE: axis(dim(2), label("pain_rating_index"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain_rating_index by age"))
  ELEMENT: point(position(age*pain_rating_index))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pain_cat pain_rating_index MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pain_cat=col(source(s), name("pain_cat"))
  DATA: pain_rating_index=col(source(s), name("pain_rating_index"))
  GUIDE: axis(dim(1), label("pain_cat"))
  GUIDE: axis(dim(2), label("pain_rating_index"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain_rating_index by pain_cat"))
  ELEMENT: point(position(pain_cat*pain_rating_index))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=cortisol_serum pain_rating_index MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_serum=col(source(s), name("cortisol_serum"))
  DATA: pain_rating_index=col(source(s), name("pain_rating_index"))
  GUIDE: axis(dim(1), label("cortisol_serum"))
  GUIDE: axis(dim(2), label("pain_rating_index"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain_rating_index by cortisol_serum"))
  ELEMENT: point(position(cortisol_serum*pain_rating_index))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=mindfulness pain_rating_index MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: mindfulness=col(source(s), name("mindfulness"))
  DATA: pain_rating_index=col(source(s), name("pain_rating_index"))
  GUIDE: axis(dim(1), label("mindfulness"))
  GUIDE: axis(dim(2), label("pain_rating_index"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain_rating_index by mindfulness"))
  ELEMENT: point(position(mindfulness*pain_rating_index))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Time pain_rating_index MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Time=col(source(s), name("Time"), unit.category())
  DATA: pain_rating_index=col(source(s), name("pain_rating_index"))
  GUIDE: axis(dim(1), label("Time"))
  GUIDE: axis(dim(2), label("pain_rating_index"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain_rating_index by Time"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(Time*pain_rating_index))
END GPL.

*Model diagnostic - multicollinearity

CORRELATIONS
  /VARIABLES=age sex_dummy STAI_trait pain_cat mindfulness cortisol_serum time_centered 
    time_centered_sq
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

*Model diagnostic - constant variance of residuals across clusters

SPSSINC CREATE DUMMIES VARIABLE=ID 
ROOTNAME1=ID_dummy 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.

COMPUTE Res_sq_int_timesq=Res_int_timesq * Res_int_timesq.
EXECUTE.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Res_sq_int_timesq
  /METHOD=ENTER ID_dummy_2 ID_dummy_3 ID_dummy_4 ID_dummy_5 ID_dummy_6 ID_dummy_7 ID_dummy_8 
    ID_dummy_9 ID_dummy_10 ID_dummy_11 ID_dummy_12 ID_dummy_13 ID_dummy_14 ID_dummy_15 ID_dummy_16 
    ID_dummy_17 ID_dummy_18 ID_dummy_19 ID_dummy_20.

*Model diagnostics - normal distribution of the random effects

MIXED pain_rating_index WITH age sex_dummy STAI_trait pain_cat mindfulness cortisol_serum time_centered time_centered_sq
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age sex_dummy STAI_trait pain_cat mindfulness cortisol_serum time_centered time_centered_sq | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC) SOLUTION
  /SAVE=PRED RESID.

*Model diagnostics - normal distribution of the random effects

DATASET ACTIVATE DataSet3.
EXAMINE VARIABLES=VAR00001
  /PLOT BOXPLOT HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

_____________________________________________________________________________________________________




