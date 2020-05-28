* Encoding: UTF-8.

*Descriptive statistics of each variables - no indications of coding errors

DATASET ACTIVATE DataSet1.
FREQUENCIES VARIABLES=pain sex age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness 
    weight IQ household_income hospital
  /STATISTICS=STDDEV RANGE MINIMUM MAXIMUM MEAN MODE SKEWNESS SESKEW KURTOSIS SEKURT
  /ORDER=ANALYSIS.

*Recoding sex into dummy

RECODE sex ('female'=1) ('woman'=1) ('male'=0) INTO Sex_dummy.
VARIABLE LABELS  Sex_dummy 'Sex dummy'.
EXECUTE.

*Exploring clustering in the data - plot with one regression line - pain versus age
* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=age pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: age=col(source(s), name("age"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("age"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("hospital"))
  GUIDE: text.title(label("Grouped Scatter of pain by age by hospital"))
  ELEMENT: point(position(age*pain), color.interior(hospital))
END GPL.

*Exploring clustering in the data - plot with one regression line - pain versus pain_cat
* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pain_cat pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pain_cat=col(source(s), name("pain_cat"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("pain_cat"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("hospital"))
  GUIDE: text.title(label("Grouped Scatter of pain by pain_cat by hospital"))
  ELEMENT: point(position(pain_cat*pain), color.interior(hospital))
END GPL.

* Plot with one line for each class - pain (dep.) versus age (indep) - random intercept and random slope since both the intercepts and the slope of the regression lines are different across classes

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=age pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: age=col(source(s), name("age"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("age"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.exterior), label("hospital"))
  ELEMENT: point(position(age*pain), color.exterior(hospital))
  ELEMENT: line(position(smooth.linear(age*pain)), split(hospital))
END GPL.

* Plot with one line for each class - pain (dep.) versus sex_dummy (indep) - random intercept and random slope since both the intercepts and the slope of the regression lines are different across classes

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=sex_dummy pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: sex_dummy=col(source(s), name("sex_dummy"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("sex_dummy"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.exterior), label("hospital"))
  ELEMENT: point(position(sex_dummy*pain), color.exterior(hospital))
  ELEMENT: line(position(smooth.linear(sex_dummy*pain)), split(hospital))
END GPL.

* Plot with one line for each class - pain (dep.) versus STAI_trait (indep) - random intercept and random slope since both the intercepts and the slope of the regression lines are different across classes

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=STAI_trait pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: STAI_trait=col(source(s), name("STAI_trait"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("STAI_trait"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.exterior), label("hospital"))
  ELEMENT: point(position(STAI_trait*pain), color.exterior(hospital))
  ELEMENT: line(position(smooth.linear(STAI_trait*pain)), split(hospital))
END GPL.

* Plot with one line for each class - pain (dep.) versus pain_cat (indep)

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pain_cat pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pain_cat=col(source(s), name("pain_cat"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("pain_cat"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.exterior), label("hospital"))
  ELEMENT: point(position(pain_cat*pain), color.exterior(hospital))
  ELEMENT: line(position(smooth.linear(pain_cat*pain)), split(hospital))
END GPL.

* Plot with one line for each class - pain (dep.) versus cortisol_serum (indep)

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES= cortisol_serum pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_serum=col(source(s), name("cortisol_serum"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label(" cortisol_serum"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.exterior), label("hospital"))
  ELEMENT: point(position(cortisol_serum*pain), color.exterior(hospital))
  ELEMENT: line(position(smooth.linear(cortisol_serum*pain)), split(hospital))
END GPL.

* Plot with one line for each class - pain (dep.) versus mindfulness (indep) - random intercept and random slope since both the intercepts and the slope of the regression lines are different across classes

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=mindfulness pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: mindfulness=col(source(s), name("mindfulness"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("mindfulness"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.exterior), label("hospital"))
  ELEMENT: point(position(mindfulness*pain), color.exterior(hospital))
  ELEMENT: line(position(smooth.linear(mindfulness*pain)), split(hospital))
END GPL.

* Plot with one line for each class, extended x and y axis to see intercept - pain (dep.) versus age (indep)

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=age pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: age=col(source(s), name("age"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("age"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.exterior), label("hospital"))
  SCALE: linear(dim(1), min(0)  )
  SCALE: linear(dim(2), max(30)  )
  ELEMENT: point(position(age*pain), color.exterior(hospital))
  ELEMENT: line(position(smooth.linear(age*pain)), split(hospital))
END GPL.

* Plot with one line for each class, extended x and y axis to see intercept - pain (dep.) versus sex_dummy (indep)

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=sex_dummy pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: sex_dummy=col(source(s), name("sex_dummy"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("sex_dummy"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.exterior), label("hospital"))
  SCALE: linear(dim(1), min(0)  )
  SCALE: linear(dim(2), max(30)  )
  ELEMENT: point(position(sex_dummy*pain), color.exterior(hospital))
  ELEMENT: line(position(smooth.linear(sex_dummy*pain)), split(hospital))
END GPL.

* Plot with one line for each class, extended x and y axis to see intercept - pain (dep.) versus STAI_trait (indep) 

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=STAI_trait pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: STAI_trait=col(source(s), name("STAI_trait"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("STAI_trait"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.exterior), label("hospital"))
  SCALE: linear(dim(1), min(0)  )
  SCALE: linear(dim(2), max(30)  )
  ELEMENT: point(position(STAI_trait*pain), color.exterior(hospital))
  ELEMENT: line(position(smooth.linear(STAI_trait*pain)), split(hospital))
END GPL.

* Plot with one line for each class, extended x and y axis to see intercept - pain (dep.) versus pain_cat (indep)

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pain_cat pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pain_cat=col(source(s), name("pain_cat"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("pain_cat"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.exterior), label("hospital"))
  SCALE: linear(dim(1), min(0)  )
  SCALE: linear(dim(2), max(30)  )
  ELEMENT: point(position(pain_cat*pain), color.exterior(hospital))
  ELEMENT: line(position(smooth.linear(pain_cat*pain)), split(hospital))
END GPL.

* Plot with one line for each class, extended x and y axis to see intercept - pain (dep.) versus cortisol_serum (indep)

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=cortisol_serum pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_serum=col(source(s), name("cortisol_serum"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("cortisol_serum"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.exterior), label("hospital"))
  SCALE: linear(dim(1), min(0)  )
  SCALE: linear(dim(2), max(30)  )
  ELEMENT: point(position(cortisol_serum*pain), color.exterior(hospital))
  ELEMENT: line(position(smooth.linear(cortisol_serum*pain)), split(hospital))
END GPL.

* Plot with one line for each class, extended x and y axis to see intercept -pain (dep.) versus mindfulness (indep)

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=mindfulness pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: mindfulness=col(source(s), name("mindfulness"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("mindfulness"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.exterior), label("hospital"))
  SCALE: linear(dim(1), min(0)  )
  SCALE: linear(dim(2), max(30)  )
  ELEMENT: point(position(mindfulness*pain), color.exterior(hospital))
  ELEMENT: line(position(smooth.linear(mindfulness*pain)), split(hospital))
END GPL.

*Simple fixed effect model - null model

MIXED pain WITH age Sex_dummy STAI_trait pain_cat cortisol_serum mindfulness
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age Sex_dummy STAI_trait pain_cat cortisol_serum mindfulness | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION TESTCOV
  /SAVE=FIXPRED RESID.

*Plot graph of residuals (assumptions for homoscedasticity) - age
* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=age residuals_fixedeffects MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: age=col(source(s), name("age"))
  DATA: residuals_nullmodel=col(source(s), name("residuals_nullmodel"))
  GUIDE: axis(dim(1), label("age"))
  GUIDE: axis(dim(2), label("Residual"))
  GUIDE: text.title(label("Simple Scatter of Residual by age"))
  ELEMENT: point(position(age*residuals_nullmodel))
END GPL.

*Plot graph of residuals (assumptions for homoscedasticity) - sex_dummy
* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=sex_dummy residuals_nullmodel MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: sex_dummy=col(source(s), name("sex_dummy"))
  DATA: residuals_nullmodel=col(source(s), name("residuals_nullmodel"))
  GUIDE: axis(dim(1), label("sex_dummy"))
  GUIDE: axis(dim(2), label("Residual"))
  GUIDE: text.title(label("Simple Scatter of Residual by sex"))
  ELEMENT: point(position(sex_dummy*residuals_nullmodel))
END GPL.

*Plot graph of residuals (assumptions for homoscedasticity) - STAI_trait
* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=STAI_trait residuals_nullmodel MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: STAI_trait=col(source(s), name("STAI_trait"))
  DATA: residuals_nullmodel=col(source(s), name("residuals_nullmodel"))
  GUIDE: axis(dim(1), label("STAI_trait"))
  GUIDE: axis(dim(2), label("Residual"))
  GUIDE: text.title(label("Simple Scatter of Residual by STAI_trait"))
  ELEMENT: point(position(STAI_trait*residuals_nullmodel))
END GPL.

*Plot graph of residuals (assumptions for homoscedasticity) - pain_cat
* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pain_cat residuals_nullmodel MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pain_cat=col(source(s), name("pain_cat"))
  DATA: residuals_nullmodel=col(source(s), name("residuals_nullmodel"))
  GUIDE: axis(dim(1), label("pain_cat"))
  GUIDE: axis(dim(2), label("Residual"))
  GUIDE: text.title(label("Simple Scatter of Residual by pain_cat"))
  ELEMENT: point(position(pain_cat*residuals_nullmodel))
END GPL.

*Plot graph of residuals (assumptions for homoscedasticity) - cortisol_serum
* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=cortisol_serum residuals_nullmodel MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_serum=col(source(s), name("cortisol_serum"))
  DATA: residuals_nullmodel=col(source(s), name("residuals_nullmodel"))
  GUIDE: axis(dim(1), label("cortisol_serum"))
  GUIDE: axis(dim(2), label("Residual"))
  GUIDE: text.title(label("Simple Scatter of Residual by cortisol_serum"))
  ELEMENT: point(position(cortisol_serum*residuals_nullmodel))
END GPL.

*Plot graph of residuals (assumptions for homoscedasticity) - mindfulness
* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=mindfulness residuals_nullmodel MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: mindfulness=col(source(s), name("mindfulness"))
  DATA: residuals_nullmodel=col(source(s), name("residuals_nullmodel"))
  GUIDE: axis(dim(1), label("mindfulness"))
  GUIDE: axis(dim(2), label("Residual"))
  GUIDE: text.title(label("Simple Scatter of Residual by mindfulness"))
  ELEMENT: point(position(mindfulness*residuals_nullmodel))
END GPL.

*Plot graph of residuals versus hospital-ID
* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=hospital residuals_nullmodel MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  DATA: residuals_nullmodel=col(source(s), name("residuals_nullmodel"))
  GUIDE: axis(dim(1), label("hospital"))
  GUIDE: axis(dim(2), label("Residual"))
  GUIDE: text.title(label("Simple Scatter of Residual by hospital"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(hospital*residuals_nullmodel))
END GPL.

*Random intercept model with fixed predictors and random effect of intercept

MIXED pain WITH age Sex_dummy STAI_trait pain_cat cortisol_serum mindfulness
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age Sex_dummy STAI_trait pain_cat cortisol_serum mindfulness | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION TESTCOV
  /RANDOM=INTERCEPT | SUBJECT(hospital) COVTYPE(VC)
  /SAVE=FIXPRED PRED RESID.




