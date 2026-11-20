# Ch30-Measuring-Business-Value.pdf (extracted text, 29 pages)

<!-- page 1 -->
Chapter 30
Measuring Business Value—Closing the
Gap Between What AI Does and What
the Business Needs
30.1 Motivation
Imagine an AI team preparing for its quarterly review with the CFO. The technical results look
strong. Modelaccuracyisupthreepoints. P99latencydroppedto180milliseconds. Uptimeheld
at99.95percent. Theroadmapisonschedule. TheCFOlistenspolitely,thenaskstheonlyquestion
thatmatters: “Whatdiditdoforthebusiness?”
The team does not have a clean answer. They know the model is better. They cannot say, with
the precision the CFO needs, whether that improvement drove revenue, reduced cost, changed
customerbehavior,orsimplymadeanalready-workingsystemmarginallyfaster. Thebudgetgets
renewed,butwithanoteattached: “Nextquarter,IneednumbersIcanuse.”
That scenario is common. According to McKinsey’s March 2025 State of AI report, 88 percent of
organizationsnowuseAIinatleastonebusinessfunction,butonly6percentqualifyashighper-
formersthatcapturesigniﬁcantenterprise-widevalue,andonly39percentreportanymeasurable
EBIT impact from AI at all (Singla et al. 2025). Enterprise AI-related IT spending is on track to
reach substantial scale, with Gartner projecting worldwide AI software, hardware, and services
reaching signiﬁcant totals through 2026 (Gartner 2025a). Yet most of that spend has not crossed
the threshold from “we use AI” to “AI has changed our business in ways the income statement
reﬂects.” EnterpriseAIrarelystrugglesbecausethetechnologyfailstowork. Itstrugglesbecause
theworkfailstotranslateintovaluethebusinesscanrecognize,attribute,andrenew.
Thatgapisthevaluetranslationproblem. Engineeringexcellenceandbusinessvaluearenotthe
same thing, and the distance between them is wider than most AI teams realize. A model accu-
racygaindoesnotautomaticallytranslateintorevenue,andlowerlatencydoesnotautomatically
increasecustomersatisfaction. Amoreprecisefraudmodeldoesnotautomaticallypreventmore
loss. Every one of those connections has to be measured, attributed, and communicated in the
languageofthebusinessratherthanthemodel’s. Withoutthattranslationdiscipline,AIbecomes
anexpensivecostcenterwaitingforthenextbudgetcycletothinitout.
1

<!-- page 2 -->
30.2 Challenge
Howdoyoubuildthemeasurementandcommunicationinfrastructurethatconnectsthetechnical
performanceofAIsystemstothebusinessoutcomestheywerefundedtodeliver,inawaythatis
credibletoexecutives,usefulforresourcedecisions,andhonestaboutthelimitsofattribution?
Thisisthechapterthatclosesthelooponoperations. Thepriorchaptersestablishedthatthesystem
canbebuilt(Chapter17),thatitcanbetested(Chapter22),thatitcanbedeployedsafely(Chapter
24), that it can be monitored (Chapter 27), that it can run reliably (Chapter 28), that it can run
economically (Chapter 29), and that it can be governed (Chapter 25). The remaining question is
whether all of that runs valuably, and whether the team can prove it in terms executives can act
on.
30.3 Objectives
Bytheendofthischapter,youwillbeableto:
1. Apply the metric pyramid from the Metrics chapter bottom-up, verifying that model-level
improvementspropagatetobusinessoutcomesthroughachainofcausation.
2. Maptechnicalmetricstobusinessoutcomesacrossfourvaluedimensions: revenue,cost,risk,
andcustomerexperience.
3. Design an attribution approach (A/B test, multi-armed bandit, holdout, before/after,
matched cohort, econometric model, or Shapley-value decomposition) appropriate to the
system,theworkﬂow,andtheavailablesignal.
4. Build shared scorecards that serve both engineering accountability and executive decision-
makingfromasinglesourceoftruth.
5. CommunicateAIvaluetonon-technicalstakeholderswithoutoverstatingevidenceorhiding
behindtechnicaljargon.
6. Identify the attribution failure modes speciﬁc to AI in complex workﬂows, including the
compounding-systemproblemandthegenerative-AIcausationchain.
7. Usevaluetranslationasastrategictoolforportfolioprioritization,investmentdecisions,and
feedbacktoproductandstrategy.
30.4 Interface with Previous Chapters
Thischapteranswersthequestioneveryupstreamchapterhasbeenbuildingtoward: didthesys-
tem actually deliver what the business funded? It inherits from Part 3, Build the production AI
system, its tested and deployed capabilities and the performance baselines established in those
chapters. Within Part4, itdrawson Chapter27fordriftand degradationsignals, Chapter28for
availabilityandSLOdata,Chapter29forthecost-efﬁciencybaselineagainstwhichvaluemustbe
justiﬁed, and Chapter 25 for the accountability structures that determine who receives and acts
on value evidence. It applies the metric pyramid deﬁned in Chapter 26 as its attribution disci-
pline. The chapter’s primary output is the measurement and attribution framework: bottom-up
veriﬁcationthroughthepyramid,attributionmethodsappropriatetoeachsystemtype,andshared
scorecardsthattranslatemodel-levelmetricsintobusinessoutcomesintermslanguageexecutives
canacton. ThoseoutputsfeedbackintoportfolioprioritizationatChapter12andinvestmentdeci-
sionsatChapter9,andtheyprovidetheoperationalevidencethatPart5Evolveusestodetermine
whenthestrategyneedstoberefreshed.
2

<!-- page 3 -->
30.5 The Metric Pyramid as the Attribution Discipline
Chapter26introducedthefour-layermetricpyramid(tbl. 26.6): modelandsystemmetricsatthe
base,thenmodeloutput,userexperience,andbusinessoutcomesattheapex. Thatchapterused
ittop-down, todecomposebusinessgoalsintometricsengineeringcaninstrument. Thischapter
usesitbottom-up,asthedisciplinethateveryvalueclaimmustpassbeforeanyonerepeatsittoa
CFO.
Bottom-upveriﬁcationaskswhetheranimprovementatthebaseactuallypropagates. Atwo-point
accuracy gain that does not move the output distribution, change user behavior, or show up in
businessoutcomesisanumberthatwentupwhilethebusinessstayedthesame. Eachlayerhas
itsown failuremode: claiming creditattheapex without causalevidence, confusing an external
trend with a behavior change at the user-experience layer, or assuming that an output change
equalsanoutcomechange. Thepyramiddoesnotremoveattributiondifﬁculty, butitmakesthe
chain of reasoning visible and auditable, which is what makes a value claim credible. Huyen’s
evaluation framework for production ML reaches a compatible conclusion: production systems
mustbeevaluatedend-to-endagainstbusinessobjectives,notpiecewiseagainsttechnicalproxies
(Huyen2022).
The rest of this chapter builds on that traversal. The four value dimensions in the next section
decomposethebusinessapex,theattributionmethodsthatfollowverifythechain,andtheshared
scorecard exposes the entire pyramid to engineering and executive viewers in layer-appropriate
language.
30.6 The Four Value Dimensions
EveryAIsysteminabusinesscontextdeliversvalue,ordestroysit,acrossfourdimensions. Mea-
suring only one of them (usually revenue) misses the bigger picture and leads to poor portfolio
decisions. Thefourdimensionsarethetop-layerdecompositionofthemetricpyramid’sbusiness
apex. McKinsey’s2025datashowsthatfunction-levelAIperformanceisstrongestinrevenue(mar-
ketingandproductdevelopmentreportinggreaterthantenpercentrevenueuplifts)andcost(soft-
wareengineering,manufacturing,andITreportingtentotwentypercentcostreductions)(Singla
et al. 2025), but a portfolio that ignores risk and customer experience is one that under-weights
asymmetricoutcomes(apointChapter25treatsindetail).
Revenue growth. AI systems that directly inﬂuence purchasing decisions, customer acquisition,
retention,orshareofwallet. Thenativemetricsareattributedrevenuelift,conversionrateimprove-
ment, change in gross margin per visitor, customer lifetime value impact, and churn reduction
rate. Thegold-standardmeasurementapproachisrandomizedA/Btestingcomparingoutcomes
foruserswithandwithouttheAIsystemactive(Kohavietal. 2020). Thedominantfailuremode
isattributingallrevenueinasegmenttotheAIsystemwithoutacontrolgroup,inﬂatingtheclaim
andoftenoverstatingitbyanorderofmagnitude.
Cost reduction. AIsystemsthatautomatetasks,reduceerrors,accelerateprocesses,oreliminate
manual work. The native metrics are hours of labor automated, error rate reduction, processing
costperunit, headcountavoided, andsupportticketdeﬂectionrate. Thestandardmeasurement
approachisabefore-and-aftercomparisonagainstadeﬁnedbaselineperiod,withexplicitcontrols
for other changes within the same window. The dominant failure mode is counting automation
capacityassavingsbeforeconﬁrmingthatheadcount,contractspend,orunitcostactuallychanged.
3

<!-- page 4 -->
McKinsey 2025 found that workﬂow redesign was the single biggest driver of measurable EBIT
impactfromAI(Singlaetal. 2025), whichisthesameﬁndingChapter15makesfromadifferent
direction: capacityisnotsavingsuntiltheworkﬂowabsorbsthechange.
A critical distinction: time saved is not the same as cost saved. Automation capacity becomes
ﬁnancialvalueonlywhenitchangeslaborcosts(throughreducedheadcount, avoidedhiring, or
reducedcontractorspend),throughput(moreoutputfromthesamecostbase),SLAperformance
(contractualpenaltiesavoided),orrevenuecapacity(staffredeployedtorevenue-generatingwork).
ThechapteronAIeconomics(Chapter29)coversthisindetail,butitbearsrepeatingherebecause
itisthemostcommonmeasurementerror.
Risk mitigation. AI systems that detect fraud, enforce compliance, ﬂag safety issues, or reduce
regulatoryexposure. Thenativemetricsarefraudlossprevented,complianceviolationsavoided,
incidentsdetectedbeforeescalation,andregulatorypenaltyexposurereduced. Thisisthehardest
dimension to measure because it requires estimating the counterfactual: what would have hap-
penedwithoutthesystem. ThedominantfailuremodeisclaimingfulllosspreventionasAIvalue
without accounting for the baseline catch rate of the non-AI controls the system replaced or aug-
mented, and without netting out false-positive costs (rejected legitimate transactions, manual re-
viewoverhead,customerfriction). Risk-mitigationvalueisalsoasymmetricinexpectedoutcome,
sostandardROIrankingtendstounder-weightit(apointwereturntoinPortfolioPrioritization).
Customer experience. AI systems that improve satisfaction, reduce friction, personalize interac-
tions, or accelerate resolution. The native metrics are CSAT delta, NPS change, resolution time
improvement, self-service deﬂection rate, and repeat-contact rate reduction. The standard mea-
surementapproachcombinescustomersurveys,supportmetrics,andbehavioralcohortanalysis.
ThedominantfailuremodeisattributingCSATimprovementtoAIwhenotherchangeshappened
concurrently(productredesign,stafﬁngchanges,processsimpliﬁcation). Thisdimensionbeneﬁts
themostfromholdout-groupmethodsbecausethealternativesleavetoomuchroomforconfound-
ing.
4

<!-- page 5 -->
Note that survey-based metrics like CSAT and NPS are lagging indicators; behavioral metrics
(repeatpurchaserate,complaintrate,escalationrate,abandonmentrate)oftenprovideearlierand
lessbiasedsignals.
Twoothervendorframeworksareworthknowingaboutfortriangulation. Gartner’s2025frame-
work for measuring GenAI ROI organizes value into productivity, revenue, risk, and customer
experience categories and pairs them with cost categories (infrastructure, talent, governance, op-
portunitycost)(Gartner2025b). Dataiku’sframeworkdecomposesAIvalueintosixdrivers(pro-
ductivity, decision quality, revenue, customer experience, risk, and innovation) (Dataiku 2022).
5

<!-- page 6 -->
The three frameworks (this chapter’s four, Gartner’s four-plus-cost, and Dataiku’s six) differ in
theirtaxonomies. Theyagreeonthediscipline. Whichdecompositionyouadoptmatterslessthan
having one: some portfolio-level decomposition is required if you want to make portfolio-level
decisions.
30.7 Attribution: The Hard Problem
Attribution is the act of credibly connecting an AI system’s technical performance to a business
outcome. Itisharderthanmostteamsrealize,andthetemptationtooverstateitisconstant. Kohavi,
Tang,andXuspentcareersrunningexperimentationplatformsatMicrosoft,LinkedIn,andGoogle,
andtheheadlinemessageoftheircanonicalguideisthatthetrustworthinessofanattributionresult
isatleastasimportantasitsmagnitude(Kohavietal. 2020). A12percentrevenueliftthatisnot
trustedbytheCFOisworthlessthana6percentliftthatis.
30.7.1 Why attribution is difﬁcult in enterprise AI
AI systems rarely operate in isolation. They contribute to workﬂows that involve human judg-
ment, process changes, and other technology. Business outcomes are simultaneously affected by
market conditions, competitive moves, pricing changes, and stafﬁng. The counterfactual (“what
wouldhavehappenedwithoutthisAIsystem?”) isalmostneverdirectlyobservable. Generative
AIattributionisparticularlychallengingbecausethesystemproducestext,summaries,orrecom-
mendationsthatahumanmayormaynotacton,andthechainfromoutputtooutcomeislonger
andnoisierthanfortraditionalML(Changetal. 2024;Aryan2025).
30.7.2 Attribution methods by rigor
Table 30.1: Attribution methods by rigor: when to use, strengths, limitations, and credibility grade for
executive reporting.
Method WhentoUse Strengths Limitations
Credibility
Grade
Randomized
A/Btest
Greenﬁeld
featureswith
controllable
trafﬁcsplit
Cleanestcausal
attribution;
supportsOverall
Evaluation
Criterion(OEC)
discipline
Requires
sufﬁcienttrafﬁc
volume;some
featurescannot
bewithheldfrom
users;vulnerable
tosample-ratio
mismatchand
carryovereffects
ifnotvalidated
High
(board-ready)
6

<!-- page 7 -->
Method WhentoUse Strengths Limitations
Credibility
Grade
Multi-armed
bandit
Production
systemswhere
opportunitycost
ofalosingarm
matters
Preserves
business-metric
performance
whilelearning;
faster
convergenceon
winner
Adaptive
assignment
complicates
inference;
requiresinverse
propensity
weightingor
specialized
methodsfor
validconﬁdence
intervals;harder
toreadouta
single
counterfactual
lift
Medium
(directional,with
caveats)
Holdoutgroup Systemsthat
cannotbeA/B
tested
per-requestbut
canholdouta
population
segment
Providesa
controlgroup;
durable
measurement
overtime
Selectionbias
riskifholdoutis
nottrulyrandom;
usersmay“leak”
betweengroups
Highifproperly
randomized
Before/after
withbaseline
Replacingan
existingsystem
orprocess
Practicaland
interpretable;
workswithout
an
experimentation
platform
Confoundedby
simultaneous
changes
(seasonality,
pricing,market
shifts)
Medium
(requiresexplicit
confounder
controls)
Matchedcohort
analysis
Post-hoc
attributionin
complex
workﬂows
Usablewhen
prospective
experimentsare
notpossible
Requirescareful
covariate
matching;
vulnerableto
unmeasured
confounders
Medium-low
(sensitiveto
matching
quality)
Econometric/
causal-inference
modeling
SeparatingAI
contribution
frommarketand
operational
factors
Handlescomplex
multi-causal
environments;
canincorporate
exogenous
variables
Requires
statistical
expertise;harder
toexplainto
executives;
sensitiveto
model
speciﬁcation
Medium
(requires
validation)
7

<!-- page 8 -->
Method WhentoUse Strengths Limitations
Credibility
Grade
Shapley-value
decomposition
Multi-system
portfolio
attribution
Allocatescredit
acrossinteracting
systemswithout
double-counting
whenproperly
implemented
Requiresvalid
estimatesof
marginal
contribution
from
experimentsor
causalmodels;
expensiveto
compute;easyto
misapply
Medium
(advanced
technique)
The progression from A/B test through matched cohort to econometric modeling is roughly a
progressionfrom“leastconfoundedbutmostrestrictive”to“mostﬂexiblebutmostassumption-
laden.” Use the most rigorous method you can support, but do not refuse to measure when the
rigorousmethodsareunavailable. Anhonestmatched-cohortestimatewithdocumentedcaveats
isbetterthannoestimateatall.
8

<!-- page 9 -->
A fabricated A/B test (one where the control was not truly random) is worse than a clean
before/after.
30.7.3 The A/B testing anchor
A/B testing is the practitioner gold standard because, when it works, it delivers something the
othermethodscannot: aclean,randomizedcounterfactual. Itdoesnotalwayswork,butnoother
method beats it when it does. Kohavi, Tang, and Xu codify a set of practices that separate trust-
worthyA/Btestingfromtheater(Kohavietal. 2020).
9

<!-- page 10 -->
• DeﬁneanOverallEvaluationCriterion(OEC)beforetheexperimentruns. TheOECisthesin-
glecompositemetric,orasmallsetwithexplicittrade-offweights,thatdetermineswin/loss.
Ifyoudecideafterseeingthedata,youarep-hacking.
• Validatetrustworthinessbeforereadingresults. Sample-ratiomismatch,whentheactualtraf-
ﬁcsplitdeviatesfromtheconﬁguredsplit,silentlyinvalidatesmanyexperiments. Twyman’s
lawapplies: anyﬁgurethatlookstoogoodisprobablywrong.
• Account for carryover effects and novelty effects. Users behave differently in the ﬁrst hour
ofanexperienceandinthetenthweek. Shortexperimentsoverweightnovelty;longexperi-
mentsaccumulatecontamination.
• Reserve a permanent holdout. Most A/B tests answer “is this change better than the prior
version?” Apermanentholdoutanswerstheharderquestion: “Isthecumulativevalueofall
ourchangespositive?”
Netﬂix’s published account of personalization evaluation provides a production ML example:
model improvements pass ofﬂine metrics checks before entering an online A/B test, and the
online test is the arbiter for member-facing product changes (Gomez-Uribe and Hunt 2015). The
disciplinepredatesmodernMLOpsandisthebedrockattributionmethodforthisentirechapter.
Important caveat: A/B tests and holdouts can be inappropriate in regulated or high-impact set-
tings. Healthcare,lending,employment,andinsurancedecisionsmayhaveconsentrequirements,
equal-treatmentobligations,orregulatoryconstraintsthatlimitexperimentation. Thechapteron
governance(Chapter25)coverstheseconstraints;themeasurementdesignmustrespectthem.
30.7.4 Multi-armed bandits: attribution with adaptive allocation
TraditionalA/Btestingallocatestrafﬁcequallybetweencontrolandtreatmentforthedurationof
theexperiment. Thatallocationiswastefulifonearmisclearlyworse. Multi-armedbanditsadap-
tively shift trafﬁc toward the better-performing arm as evidence accumulates, which preserves
business-metricperformanceduringtheexperiment(Sweet2023).
Thetrade-offissigniﬁcantforattribution: adaptiveassignmentcomplicatescausalinference. Be-
causetrafﬁcallocation changesbased on observedoutcomes, standardconﬁdenceintervalcalcu-
lations are invalid. Valid inference under bandit allocation requires specialized methods such as
inverse propensity weighting, doubly robust estimation, or other adaptive-inference techniques.
Teamsthatusebanditsforoptimizationshouldnotassumetheyhavecleancausalattributionun-
lesstheyhaveimplementedthesecorrections.
Bandits are appropriate when the cost of losing-arm trafﬁc is high (a large user base, expensive
impressions,regulatedallocations)andwhentheteamacceptsaless-crispcounterfactualreadout.
TheyalsolinkbacktotheoperationalMABpatternsintroducedinChapter27forsaferollout. A
team that has already invested in bandit infrastructure for canary deployments can extend that
infrastructuretoadaptiveallocationwithrelativelylittleadditionalengineering,buttheinference
layerisseparatework.
30.7.5 Shapley value for multi-system portfolio attribution
WhenmultipleAIsystemsoperateinthesameworkﬂow(arecommenderfeedsapersonalization
engine, which feeds an offer-generation system, which is moderated by a fraud-scoring system),
the individual contributions interact. Naive per-system attribution will sum to more than 100
percentofobservedlift.
10

<!-- page 11 -->
Figure 30.1: Trustworthy A/B testing requires validating the experiment’s integrity before reading results,
following Kohavi, Tang, and Xu’s discipline.
11

<!-- page 12 -->
Shapley-value decomposition, originally from cooperative game theory, allocates credit to each
system in proportion to its marginal contribution averaged across all possible orderings of sys-
tem activation. The 2024 shapiq package by Muschalik and colleagues is the current canonical
open-source implementation for computing Shapley values and Shapley interactions efﬁciently
(Muschaliketal. 2024).
A critical distinction: Shapley values in model explainability (such as SHAP and TreeSHAP) al-
locate feature contribution within a single model. Business-value attribution across multiple de-
ployed systems is a different problem. Applying Shapley-value decomposition to portfolio attri-
butionrequires:
1. Validcausalestimatesofwhateachsystemcontributeswhenactivatedalone.
2. Valid causal estimates of what each combination of systems contributes when activated to-
gether.
3. Enoughexperimentalorquasi-experimentaldatatopopulatethoseestimates.
Without those inputs, Shapley allocation is just arithmetic on unreliable numbers. The shapiq
package is a computational tool; it does not solve the measurement problem upstream of it. Use
Shapley-valueportfolioattributionwhenyouhavecrediblemarginal-contributionestimatesfrom
experimentsorwell-speciﬁedcausalmodels. Donotuseitasashortcuttoavoidthehardworkof
measurement.
Inpractice,Shapley-valueattributionisexpensiveenoughthatyoudonotrunitoneverymetric
every day. The right cadence is portfolio-level: quarterly or semi-annually, when leadership is
making allocation decisions across the AI portfolio. For day-to-day measurement, use simpler
methodsandacceptthattheydouble-countatthemargin.
30.7.6 Honest attribution principles
Thedisciplineofattributionismoreaboutwhatyousay about thenumberthanthenumberitself.
• Alwayspresenttheattributionmethodalongsidetheresult. Anumberwithoutitsmeasure-
mentmethodologyisnotcredible.
• Report conﬁdence intervals, not point estimates. “12 percent lift, 95 percent CI [8 percent,
16percent]”ismorehonestthan“12percentlift”andtellsthereaderwhatactiontheresult
actuallysupports.
• Distinguishcorrelationfromcausation. AriseinsalescoincidingwithanAIdeploymentis
not,byitself,evidenceofattribution. Stateexplicitlywhatyourcausalclaimrestson.
• Documentthecounterfactualassumption. Ifyouclaim2milliondollarsinvalue,statewhat
you assume would have happened without the system. “Holdout-group revenue per user,
multipliedbytreatmentpopulation”isadefensiblecounterfactual. “Lastquarter’srevenue
minusthisquarter’s”isnot.
• Beware Goodhart’s Law in the attribution metric itself. El-Mhamdi and Hoang show that
understrong-Goodhartconditions,optimizingthemetricactivelyharmstheunderlyingob-
jectiveonceincentivesalignaroundthemetric(El-MhamdiandHoang2024). Thesamedy-
namicGaoandcolleaguesquantiﬁedforproxyrewardinreinforcementlearningappliesto
value-proxymetricsinattribution(Gaoetal. 2022). Ifthebonuspooldependsonattributed
value,theattributedvaluewillstarttolookverygoodforreasonsunrelatedtoactualvalue.
30.7.7 Common measurement failure modes
12

<!-- page 13 -->
Table 30.2: Common measurement failure modes and preventive practices.
FailureMode Description Prevention
Inﬂuencedvs.caused Claiming“AI-inﬂuenced
revenue”asifitwere
“AI-causedrevenue”
Requirecausalmethodology;
labeldirectionalestimates
Time-savedfallacy Reportinghourssavedascost
saved
Requirecostconversion
sign-offfromﬁnance
Weakbaseline Comparingtoastrawmanor
unusuallypoorpriorperiod
Pre-registerbaselineperiod;
userollingaverages
Doublecounting Multiplesystemsclaimingthe
samerevenueorsavings
Useportfolio-levelattribution;
documentscope
Omittedguardrails Reportingsuccessmetric
withoutguardrailimpact
Requiresuccessandguardrail
metricsonsamescorecard
Segmentmasking Aggregatewinhides
segment-levellosses
Reportbybusiness-relevant
slices
Gaming Teamsselectingfavorable
windows,baselines,or
segments
Independentvalidation;
pre-registration
30.7.8 Subgroup honesty and slice-based attribution
Aggregate value claims can mask group-level value destruction. A recommendation engine that
liftsrevenue12percentoverallbutreducesengagement18percentinahigh-valueretentionseg-
ment is not a 12 percent win. Slice-based attribution, as Johnson and colleagues demonstrate in
theiranalysisofmodelperformancedistribution,makesthesesubgroupeffectsvisible(Johnsonet
al. 2023). Thedisciplineistoreportattributionbytheslicesthatmattertothebusiness(segment,
geography,productcategory,customertenure),notonlyinaggregate. Thesameslicesthatgovern
fairnessauditsinChapter25shouldgovernvalueattribution. Ifyouarenotbreakingattribution
outbytheslicestheregulatorandtheCFObothcareabout,youareleavingcredibilityonthetable.
30.8 Measuring Value for LLM and Agentic Systems
Large language models and agentic systems present distinct value measurement challenges that
traditionalMLframeworksdonotfullyaddress. Thecausationchainfrommodeloutputtobusi-
nessoutcomeislonger, noisier, andoftenmediatedbyhumanjudgmentinwaysthatmakeattri-
butionharder.
30.8.1 LLM-speciﬁc measurement challenges
ForLLMsdeployedasproductivitytools(codingassistants,writingaids,summarizationsystems),
thehuman-in-the-loopdynamiccomplicatesmeasurement:
Task completion and acceptance rate. What fraction of generated outputs does the user accept
without modiﬁcation? What fraction requires substantial editing? Acceptance rate is a UX-layer
metric that should propagate to productivity metrics only when you can also measure time and
quality.
13

<!-- page 14 -->
Edit distance and rework rate. Howmuchdousersmodifygeneratedcontentbeforeuse? High
edit distance suggests the model is providing a starting point rather than a ﬁnished output. The
productivityvaluedependsonwhetherthatstartingpointsavesmoretimethanitcoststoreview
andrevise.
Quality of accepted outputs. Acceptancedoesnotequalquality. Auserundertimepressuremay
acceptlow-qualityoutputthatcreatesdownstreamproblems. Measuredownstreamindicators: er-
rorratesingeneratedcode,customercomplaintsaboutgeneratedcommunications,factualerrors
ingeneratedsummaries.
Hallucination and factuality metrics. Forknowledge-intensiveapplications,hallucinationrateis
aguardrailmetricthatboundsvalueclaims. Asystemthatsaves30minutespertaskbutintroduces
factualerrorsin5percentofoutputsmayhavenegativenetvaluedependingonerror-correction
cost.
30.8.2 Agentic system measurement
Foragenticsystemsthattakeactionsautonomously(bookingsystems,automatedsupport,work-
ﬂowautomation),themeasurementrequirementsaremoredemanding:
Task success rate. Whatfractionoftaskstheagentattemptsdoesitcompletesuccessfullywithout
humanintervention? Successmustbedeﬁnedagainstgroundtruth,notjustcompletion.
Tool-call success and failure. Agentsthatinvoketools(APIs,databases,externalservices)canfail
atthetoollevel. Tracktool-callsuccessrate,errortypes,andretrypatterns.
Escalation rate. What fraction of agent attempts require human takeover? Escalation may be
appropriateratherthanafailure,butitstillboundstheautomationvalue.
Cost per completed task. LLMcostsscalewithtokenconsumption. Foragents,measurecostper
successfullycompletedtask,notcostperinvocationorcostpertoken.
Safety incidents. Foragentswithsigniﬁcantactionauthority,trackincidentswheretheagenttook
harmful, incorrect, or unauthorized actions. This is a guardrail metric that can override positive
valuemetrics.
Risk-adjusted value. Agenticsystemsthatcantakeconsequentialactions(ﬁnancialtransactions,
customercommunications,systemchanges)carrytailrisk. Valuemeasurementmustincluderisk-
adjustedexpectedvalue,notjustmeanoutcome.
30.8.3 Automation versus augmentation economics
Theproductivity-to-valueconversiondiffersbetweenautomation(systemdoesthetask)andaug-
mentation(systemhelpsahumandothetask):
• Automation convertsdirectlytocostifitdisplaceslabor,throughputifitenablesmorework,
orrevenueifitenablesscale. Measurementisclosertotraditionalsystemattribution.
• Augmentation improveshumanproductivitybutdoesnoteliminatethehuman. Measuring
value requires observing human output before and after, controlling for skill and task vari-
ation. Time saved is not the same as cost saved unless the human’s time is redeployed to
value-generatingworkorthehumanisnothired.
14

<!-- page 15 -->
FormostenterpriseLLMdeploymentsin2025-2026,augmentationismorecommonthanautoma-
tion. Measurementframeworksthatassumeautomationwillsystematicallyoverstatevalue.
Figure 30.2: LLM and agentic systems require distinct measurement approaches reﬂecting the difference
between augmentation and automation economics.
30.9 Shared Scorecards: Bridging Engineering and Executive Views
Chapter 26 deﬁned what to measure and the three stakeholder views that read it. This section
deﬁnes how to organize and present those measurements to create a shared language between
engineeringteamsandexecutivestakeholders. Thesharedscorecardistheartifactthatmakesthe
metricpyramidvisibletomultipleaudiencesfromasinglesourceoftruth.
30.9.1 Why shared scorecards matter
Without a shared scorecard, engineering teams and executives maintain separate, incompatible
viewsofwhetherAIisworking. Engineeringviews(“modelaccuracyis94percent,driftiswithin
bounds”)donotanswerexecutivequestions(“shouldweinvestmoreorless”). Executiveviews
(“revenueisup8percent”)donotprovideenoughsignalforengineeringdecisions(“whichcompo-
nentshouldweoptimize”). Asharedscorecardreadsfromthesameunderlyingdatabutpresents
itinlayer-appropriatelanguageforeachaudience. Thepyramidisthestructure;thescorecardis
therendering.
30.9.2 The AI Value Scorecard structure
Top line: business value summary (executive view). Value delivered this period versus target,
broken out by the four dimensions: attributed revenue, cost savings, risk reduction, CSAT delta.
15

<!-- page 16 -->
Trendindicators(improving,stable,declining)versuspriorperiodandversustheinvestmentthe-
sis. RAG status (Red, Amber, Green) for each value dimension, with explicit thresholds docu-
mentedinthemethodologysection.
RAGstatusthresholds(example):
• Green: valuedelivered ≥ 90percentoftargetandnoguardrailbreach.
• Amber: 70to90percentoftarget,orconﬁdenceintervalcrossesminimumacceptablethresh-
old.
• Red: below70percentoftarget,negativenetvalue,ormaterialguardrailbreach.
Middle: operational performance (product manager view). SLOachievementonavailability,la-
tency,andqualitymetricsversustargets. Leadingindicatorstrendingtowardorawayfromvalue
targets (a click-through-rate decline now predicts a revenue lift decline next month). Guardrail
status: anyguardrailsatriskorbreached,withthespeciﬁcguardrailnamed.
Bottom: technical health (engineering view). Model performance metrics including accuracy,
driftindicators,retrainingstatus,andevaluation-setscores. Pipelinehealth: freshness,errorrates,
data-quality ﬂags. Cost efﬁciency: cost-per-unit trend, budget versus actual, the FinOps unit-
economicsviewthattiesbacktoChapter29(Markanastasakisetal. 2025;J.R.StormentandMike
Fuller2023).
Thethreelayerscorresponddirectlytolayersfour(apex),threepluspartsoftwo(operationaland
UX),andoneplustwo(modelandsystem)ofthemetricpyramid.
16

<!-- page 17 -->
Eachlayer’smetricsarederivedfromthelayerbelowit. Readingthescorecardfromtoptobottom
isbottom-upveriﬁcation: eachbusinessoutcomeistraceabletothemodelandpipelinebehavior
thatproducedit.
For speciﬁc quantitative vocabularies, particularly for recommendation systems, precision-at-K,
NDCG, and MRR remain the workhorses at the model-output layer (Aher 2023). These do not
appearontheexecutiveview,buttheyareessentialattheengineeringlayerbecausetheyarewhat
teamsoptimizeagainst.
17

<!-- page 18 -->
30.9.3 Success, diagnostic, and guardrail metrics
Everyscorecardshoulddistinguishthreemetrictypes:
• Success metrics measure whether the system achieved its goal. Revenue lift, cost savings,
taskcompletionrate.
• Diagnostic metrics explain performance. Click-through rate, model accuracy, latency per-
centiles.
• Guardrail metrics bound acceptable operation. A system can improve the success metric
whileviolatingaguardrail. Arecommendermayincreaseshort-termrevenuewhileincreas-
ingreturnsorcomplaints. Afraudmodelmayreducelosseswhilerejectingtoomanylegiti-
matetransactions. Guardrailsmustappearonthesamescorecardassuccessmetrics.
Figure 30.3: Every scorecard must distinguish success, diagnostic, and guardrail metrics to prevent opti-
mizing success at the cost of guardrail violations.
30.9.4 Scorecard governance
Scorecardslosevaluewhenthecadenceandownershiparenotnaileddown. Thedisciplineis:
• Publishedonadeﬁnedcadence: weeklyforproductandengineering,monthlyforexecutives,
quarterlyforboard-levelreview.
• ExceptionreportstriggeredwhenanyRAGstatuschangesfromGreentoAmber,orAmber
toRed,within48hoursofthedatapointlanding.
• Scorecard reviewed by the AI Governance Board quarterly alongside cost and risk metrics,
in the same meeting where investment decisions are made. The FinOps Foundation’s AI
Investment Council pattern is a useful organizational reference here (FinOps Foundation
2025).
• Documentationdiscipline: eachvalueclaimonthescorecardistraceabletoameasurement
18

<!-- page 19 -->
methoddocumentedinthemodelcardorvaluemethodologynote(Mitchelletal. 2019). If
anumbercannotbetraced,itdoesnotgoonthescorecard.
30.9.5 Value methodology note template
Everymeasuredsystemshouldhaveavaluemethodologynotethatdocumentsthemeasurement
approach. Template:
Table 30.3: Value methodology note template ﬁelds.
Field Description
Systemname NameoftheAIsystemorcapability
Businessobjective Thebusinessgoalthesystemwasfundedto
achieve
Valuedimension Primarydimension(revenue,cost,risk,CX)
Primarymetric TheOECorprimarysuccessmetric
Guardrailmetrics Metricsthatboundacceptableoperation
Attributionmethod A/Btest,holdout,before/after,matched
cohort,etc.
Counterfactual Whatisassumedtohappenwithoutthesystem
Measurementwindow Timeperiodoverwhichattributionis
calculated
Conﬁdencelevel Statisticalconﬁdenceandintervalwidth
Knownconfounders Factorsthatcouldbiastheresult
Financialconversion Howmetricunitsconverttodollars
Owner Personaccountableformeasurementintegrity
Reviewcadence Howoftenmethodologyisreviewed
30.9.6 Real-world case study: Airbnb’s Minerva
Airbnb’s published account of its experimentation and metrics infrastructure (the Minerva plat-
form) provides a case of operationalizing shared-scorecard discipline at scale (Amit Pahwa et al.
2021). Minervabecameacentralsourceoftruthformetricsacrossthecompanyandcutdownon
contradictorynumbersfromdifferentquerysources. Theplatformenforcedconsistentmetricdef-
initionsandcomputation,soanalystsandengineerscouldoperatefromshareddata. Thebroader
lessongeneralizesbeyondAirbnb: theplatforminvestmentmatterslessthantheconsolidationof
metricauthority. Thesamelessonapplieswhethertheunderlyingtoolingisavendorexperimen-
tationplatform,anin-housebuild,orathinlayerontopofcloud-nativeservices.
30.10 AWS Implementation Pattern for Value Measurement
ForAWS-nativeteams,theinfrastructureforcrediblevalueattributionfollowsarecognizablepat-
tern. Thedataplumbingforvaluemeasurementisnon-trivialengineeringwork,andunderfund-
ingitproducesthescorecardnobodytrusts.
Event capture. Amazon Kinesis Data Firehose captures user events (impressions, clicks, conver-
sions,supportcontacts,frauddecisions)andlandstheminS3,partitionedbydateandeventtype.
19

<!-- page 20 -->
Data lake. S3withAWSGlueDataCatalogprovidestheschemalayer. ApacheIcebergtablesen-
abletime-travelqueriesforbefore/aftercomparisonsandpoint-in-timesnapshotsforexperiment
analysis.
Query and analysis. AmazonAthenaforad-hocanalysis;AmazonRedshiftorRedshiftServerless
for heavier analytical workloads. The experimentation platform queries this layer to compute
treatment/controldifferences.
Model metadata. SageMakerModelRegistrystoresmodelversionsandmetadata. EvidentlyMon-
itorcapturesmodel-layermetrics(drift,dataquality,bias)andwritestoCloudWatch.
Operational metrics. CloudWatchcollectslatency,errorrate,andthroughputmetricsfrominfer-
enceendpoints. CloudWatchMetricsandLogsInsightsprovidetheengineering-layerview.
Scorecard rendering. Amazon QuickSight for executive and product manager dashboards.
Streamlit or internal tooling for engineering deep-dives. Both read from the same underlying
data.
Governance. AWS Lake Formation for ﬁne-grained access control on metric data. IAM policies
enforcewhocanseewhatlayersofthescorecard.
Infrastructure as code. Terraformmanagestheinfrastructure. AWSCDKisareasonablealterna-
tiveiftheteamisalreadyCDK-native.
For partner data or privacy-sensitive measurement, AWS Clean Rooms enables analysis across
organizationalboundarieswithoutexposingrawdata.
30.11 Communicating AI Value to Non-Technical Stakeholders
Valuetranslationfailsnotonlywhenthemeasurementiswrong. Italsofailswhenthecommuni-
cationiswrong. Technicalteamsroutinelyunderinvestinhowtheypresentresults,assumingthe
numbersspeakforthemselves. Theydonot.
30.11.1 Principles for communicating AI value
Lead with business outcomes, not technical performance.
Wrong: “Ourmodelachieveda94percentAUC-ROCscore.”
Right: “Thefrauddetectionsystempreventedanestimated4.2milliondollarsinlosseslastquarter,
netoffalse-positivecosts.”
Thetechnicalmetricbelongsintheappendix. Thedecision-relevantbusinessoutcomebelongsin
thelede.
Anchor to the investment thesis. EveryAIsystemwasfundedonastated-valuehypothesis. Com-
municationshouldexplicitlycompareactualstothathypothesis. “Weprojected3milliondollars
inannualcostsavings. We’vedelivered2.1millionintheﬁrstsixmonths, puttingusontrackto
exceed the projection.” That structure is more useful than either projection or actual presented
alone,becauseitmakesthevariancethesubjectoftheconversation.
Be honest about conﬁdence and attribution limits. Executiveswholaterdiscoverthatattributed
valuewasoverstatedlosetrustinallfutureAIreporting,includingthetrustworthyreports. State
20

<!-- page 21 -->
conﬁdencelevelsplainly. “Ourbestestimateis2.1millioninattributedsavings. Thisisbasedon
a before/after comparison with a 90-day baseline. It is directionally reliable but not a controlled
experiment,sotheactualﬁgurecouldbe20percenthigherorlower.” Executivesacceptuncertainty.
Theydonotacceptbeingmisled.
Connect to decisions, not just data. Executivesdonotneedtounderstandhowthemodelworks.
Theyneedtoknowwhethertoinvestmore,investless,expandintonewusecases,orshutdown
the system. Frame every value communication around the decision it should inform. If a chart
doesnotchangeadecision,itdoesnotbelongintheexecutiveview.
30.11.2 Financial formulas for value conversion
Crediblevalueclaimsrequireexplicitﬁnancialconversion. Exampleformulas:
Incremental gross margin =(treatmentrevenueperuser−controlrevenueperuser) × treatment
users × grossmarginrate
Net value =incrementalbeneﬁt−infrastructurecost−laborcost−vendorcost−governancecost
Cost savings =avoidedvolume × unitcostavoided,onlyiftheunitcostactuallychanged
Fraud value = avoided chargebacks − lost margin from false positives − manual review cost −
customerfrictioncost
ROI =netvalue/totalinvestment,wheretotalinvestmentincludesdevelopmentcost,infrastruc-
ture,talent,andgovernance
Forlargerinvestments,executivesmayexpectNPV,IRR,orpaybackperiodcalculations. Finance
partnership is essential: product owns the value hypothesis, engineering owns instrumentation,
datascienceownscausaldesign,andﬁnancevalidatesﬁnancialconversionandcostassumptions.
30.11.3 Communicating when value is uncertain or negative
Thedisciplinemattersmostwhenresultsaredisappointing. NoteveryAIsystemdeliversitspro-
jectedvalue: somefallshort,somedelivernone,andafewdestroyvalueoutright. Thecommuni-
cationdisciplineforthesecases:
• Report early. Underperformance reported in month two enables corrective action. Under-
performancereportedinmontheleven,whentheannualreviewisdue,enablesonlydamage
control.
• Frameaslearning,notfailure. “Whatdidwelearn,whatwillwechange,whatistherevised
outlook”isamoreusefulstructurethan“thesystemunderperformed.”
• Distinguishbetweenattributionfailureandvaluefailure. Sometimesthesystemisdelivering
valuebuttheattributionmethodcannotproveit. Theﬁxinthatcaseismeasurementinvest-
ment,notsystemtermination. Othertimestheattributionisﬁneandthesystemisgenuinely
notdelivering. Theﬁxiscorrectiveactionorsunset.
30.12 Value Translation as a Strategic Tool
Donewell,valuetranslationbecomesmorethanareportingexercise: itisthemechanismforport-
folioprioritization,investmentdecisions,andstrategicalignmentbetweenAIteamsandbusiness
leadership.
21

<!-- page 22 -->
30.12.1 Portfolio prioritization using value data
Rank AI systems by return on investment: net value delivered divided by total cost, where total
costincludesengineeringlabor, infrastructurespend(theunit-economicsviewfromChapter29),
governanceoverhead,andoperationalsupport. Threepatternsofresponse:
• High ROI with clear attribution. Expand. Thesearethesystemsthatearnedtherighttoclaim
moreoftheportfolio.
• Low ROI or unclear attribution. Measure more rigorously before further investment. Do not
assumethesystemisbad. Assumethemeasurementisbaduntilprovenotherwise.
• Sustained negative ROI or chronic underperformance. Sunset. ZombieAIsystemsthatconsume
resourceswithoutdeliveringvalueareagovernancefailureandacredibilityrisk.
Aportfoliocomposedentirelyofhigh-ROIsystemsisrareandusuallyasignthattheteamisnot
takingenoughrisk. Someexperimentalinvestmentsareexpectedtounderperform. Thediscipline
istoknowwhichiswhichandtobewillingtoactonthedata.
Figure 30.4: Portfolio prioritization uses value attribution data to drive expand, measure, or sunset decisions
for each AI system.
ForLLMapplications,therelevantvalue-per-costmetricdependsasmuchonmodelchoice(fron-
tierAPI,hostedopen-weight, ﬁne-tunedlocal)anddeploymentpatternasonapplicationdesign
(Ruzga2026). AportfoliorankingthattreatsallLLMapplicationsasequivalentatthemodellayer
willmisrank.
30.12.2 Value-based investment decisions
AIinvestmentdecisionsshouldbegroundedinvaluedatafromexistingsystems,notonlyinpro-
jections:
22

<!-- page 23 -->
• “Our churn model delivers 6.40 dollars in attributed savings for every 1 dollar spent, mea-
suredbyaholdoutgroupoverthelastfourquarters. Weproposetoapplythesamemodeling
approachtoproductreturnprediction,whereweestimatesimilaruniteconomicsbasedon
thecoststructureofthereturnsoperation.” Thatisafundableargument.
• “WewanttobuildanAIsystemtoimproverecommendations.” Thatisahypothesis,notan
investmentcase.
TheStanfordAIIndex2025showsthatresponsibleAIinvestmentisnowatrackedcategorywithin
enterpriseAIspending(StanfordInstituteforHuman-CenteredArtiﬁcialIntelligence(HAI)2025).
Portfolioprioritizationthatignoresresponsible-AIinvestmentaspartoftotalcostwillunder-fund
thegovernanceandrisk-mitigationsystemsthatmaketherestoftheportfoliosustainable.
30.12.3 The feedback loop to strategy and product
Value translation data feeds directly into the next operating cycle. McKinsey’s 2025 ﬁnding that
workﬂowredesignhasthegreatestimpactonEBITistheempiricalanchorforhowtoactonvalue
signals(Singlaetal. 2025). WhenvaluetranslationrevealsthatAIisdeliveringinunexpectedareas,
orfailingtodeliverinexpectedones,thesignalpropagatesbacktoproductroadmap(Chapter13),
workﬂowdesign(Chapter15),andthebroaderAIstrategy(Chapter9).
Thisistheloopthatturnsoperationalexperienceintostrategiclearning, anditiswhatseparates
theorganizationsMcKinseyidentiﬁesashighperformersfromthosethathaveadoptedAIwithout
yetcapturingenterprise-widevalue(Singlaetal. 2025).
The deciding factor is discipline, not technology: letting the value data change what gets built
next.
23

<!-- page 24 -->
30.12.4 Production readiness as a precondition for credible attribution
Attributionisonlyascredibleastheunderlyingproductionsystem. Breckandcolleagues’MLTest
Scoreframeworkarticulatesthereadinesspreconditionsthathavetobeinplacebeforeattribution
numberscanbetrusted(Brecketal. 2017). Ifthesystemhasunmonitoreddrift,untestedrollback
paths, or undocumented data dependencies, attribution against it is measuring an artifact, not a
system.
30.13 Use Case: Retail Customer Acquisition and Retention
TherunningusecaseforthischapterappliesvaluetranslationdisciplinetotheretailAIplatform
thathasaccumulatedacrossthebook: arecommendationengine,achurnmodel,afraud-scoring
system, an offer-generation system, and a customer-service bot. The retail leadership team has
askedtheAIorganizationforayear-onevaluereviewandayear-twoinvestmentrecommendation.
30.13.1 Top-down decomposition
The business goals for the platform were (1) lift category-level gross margin 10 percent through
personalization,(2)reducechurn-drivenrevenueloss15percent,and(3)reducechargebacklosses
25percent,netoffalse-positivecosts. Eachgoalisdecomposedthroughthemetricpyramid:
Goal UXMetric ModelOutputMetric Model/SystemMetric
10%grossmarginlift Add-to-cartrate,
conversionrate
Recommendation
relevancedistribution
Precision@10,NDCG
15%churnreduction At-riskengagement,
retention-offer
take-up
Churn-riskscore
distribution
AUC,recallattop
decile
25%chargeback
reduction(net)
Approvalrate,
disputerate
Fraudscore
vs.historicalreference
Precision-recallat
threshold
30.13.2 Bottom-up veriﬁcation (the value scorecard)
Table 30.4: Retail AI portfolio value scorecard, Q3 actuals versus targets.
System
Attribution
Method ValueDimension
Q3Result
vs.Target
Methodology
Note
Recommendation
engine
A/Btest,10%
holdout,30-day
windows
Revenue 11%gross
marginper
visitorlift,95%
CI[8%,14%],
vs.10%target
OEC=gross
marginper
visitor;novelty
effectcontrolled
byexcludingﬁrst
7days
24

<!-- page 25 -->
System
Attribution
Method ValueDimension
Q3Result
vs.Target
Methodology
Note
Churnmodel Holdoutgroup,
propensity-
matched
Costand
Revenue
1.8MUSD
reduced
retentionspend
vs.1.5Mtarget;
3.8MUSD
retainedgross
margin(wider
CI)
Counterfactual=
matched-cohort
retentionrate
Fraudscoring Before/after
withbaseline
catch-rate
adjustment
Risk 31%net
chargeback
reduction
vs.25%target
Netof
false-positivelost
marginand
reviewcost
Offergeneration A/Btest,
segment-
stratiﬁed
RevenueandCX 0.9MUSD
attributed
revenuevs.2.0M
target;+3CSAT
foroffer
recipients
Underperformance
driver:
new-customer
relevancegap
Customer-
servicebot
Matchedcohort,
complexity-
adjusted
CostandCX 2.2MUSD
supportcost
reduction
vs.2.0Mtarget;
CXneutral
vs.matched
human-handled
contacts
Complexity
adjustmentvia
ticket-type
stratiﬁcation
Executive summary (top of scorecard). Threeoftheﬁvesystemsareovertarget, oneisontrack,
andoneismateriallyunderperforming. Combinedattributednetvalue14.1MUSDversus13.5M
target. PortfolioROI7.8xagainsttotalplatformcost. RAGstatus: revenueGreen,costGreen,risk
Green,customerexperienceAmber(drivenbyoffer-generationunderperformance).
Honest attribution notes. TherecommendationengineandoffergenerationresultsareA/Btested
andcarrythehighestconﬁdence. Thechurn-modelretained-marginﬁgurehasawiderconﬁdence
interval because it requires a matched-cohort counterfactual over a longer horizon. The fraud
scoring result is net of false-positive costs and manual review cost. The bot measurement uses
complexity-adjustedmatchingtoavoidcomparingsimplebot-handledcontactstocomplexagent-
handledcontacts.
Action items from the scorecard:
1. Expandtherecommendationenginetomobileappandemailchannels.
2. Buildaseparateoffer-generationmodelforthenew-customersegment.
3. MonitorbotCXmetricsforthenextquarterbeforeexpandingdeﬂectiontargets.
4. Conduct Shapley-value portfolio analysis at year-end to quantify recommendation-plus-
offerinteraction.
25

<!-- page 26 -->
5. Sunsetthelegacyrules-basedfraudoverlaythatthenewfraud-scoringmodelhasrendered
redundant.
30.14 Key Takeaways
• Bottom-up traversal of the metric pyramid is the attribution discipline. Amodelimprove-
mentisabusinessimprovementonlywhenevidenceshowsitpropagatingthroughoutput,
userexperience,andbusinessoutcomes.
• Value lives in four dimensions. Revenue growth, cost reduction, risk mitigation, and cus-
tomerexperience. Measuringonlyoneproducesincompleteportfoliodecisions.
• Attribution is hard, and honesty builds more credibility than false precision. State the
method, the conﬁdence level, and the counterfactual assumption alongside every value
claim.
• Multi-armed bandits are not a simple substitute for A/B tests. Adaptiveallocationcompli-
catescausalinference;usespecializedmethodsforvalidconﬁdenceintervals.
• Shapley-value portfolio attribution requires valid marginal-contribution estimates. The
computationaltooldoesnotsolvethemeasurementproblemupstreamofit.
• Aggregate value can mask subgroup destruction. Slice-basedattributionagainstbusiness-
relevantsegmentsisessential.
• Shared scorecards bridge engineering and executive views. Threelayers(technicalhealth,
operationalperformance,businessvalue)fromonedatasource.
• Lead with business outcomes in executive communication. Technicalmetricsbelonginthe
appendix.
• Value translation drives portfolio decisions. ROIranking,calibratedfortotalcostandasym-
metricrisk,determineswheretoexpand,ﬁx,orsunset.
• Underperformance reported early enables action. Latereportingenablesonlydamagecon-
trolandcostscredibility.
• The feedback loop separates high performers from adopters. Acting on value data to re-
designworkﬂowsandreallocatetheportfolioistheoperationaldifference.
30.15 Apply It
1. Bottom-up veriﬁcation. Takeonerecentorhypotheticalbase-layerimprovementinaretail
AI system (for example, a two-point AUC gain in the churn model). Using the pyramid
decompositionfromtheMetricschapter,describetheevidenceyouwouldneedatthemodel-
output,user-experience,andbusiness-outcomelayerstoclaimtheimprovementisreal,and
identifythelayerwheretheclaimismostlikelytobreak.
2. Value methodology note. Createavaluemethodologynotefortheretailoffer-generationsys-
temusingthetemplatefromthischapter. Includeallﬁelds: systemname,businessobjective,
valuedimension,primarymetric,guardrailmetrics,attributionmethod,counterfactual,mea-
surementwindow,conﬁdencelevel,knownconfounders,ﬁnancialconversionlogic,owner,
andreviewcadence.
3. Attribution design. Design the attribution approach for the underperforming offer-
generation system. Choose the method, justify the choice, specify the OEC and guardrail
metrics, document the counterfactual, and state what results would lead you to expand,
hold,orsunsetthesystem.
26

<!-- page 27 -->
4. Executive one-pager. Writeaone-pageexecutivesummarycommunicatingtheretailAIplat-
form’sQ3results. Leadwithbusinessoutcomes. Includevaluedeliveredversusprojection,
attributionmethodologysummary,theunderperformingsystemwithproposedaction,and
aresourcerecommendationthatﬂowsfromthevaluedata.
5. Failure mode audit. Reviewtheretailscorecardforcommonmeasurementfailuremodes(in-
ﬂuencedvs.caused,time-savedfallacy,weakbaseline,doublecounting,omittedguardrails,
segmentmasking). Identifyanypotentialissuesandproposecorrections.
6. AI prompt. “You are an AI investment analyst reviewing a value scorecard for a retail AI platform.
Identify (a) which systems have sufﬁcient attribution evidence to support expanded investment, (b)
which require better measurement before further decisions, (c) whether the portfolio over-indexes on
any value dimension, and (d) which Shapley-value decomposition would be most valuable to run next
quarter. Justify each recommendation in terms of the metric pyramid and attribution methodology.
Scorecard: [paste your scorecard].”
30.16 What’s Next
ValuetranslationprovesthatAIsystemsareworkingandworththeinvestment. Italsoproduces
the data that the next operating cycle is built on. The next chapter, Chapter 31, closes Part 4 by
showinghowoperationalexperience,value-attributiondata,scorecardexceptionreports,andport-
folioROItrendsﬂowbacktostrategy(Chapter9),productdesign(Chapter11),workﬂowdesign
(Chapter 15), and the build teams (Chapter 17) to drive continuous improvement. Without that
feedback loop, each generation of AI systems starts from scratch. With it, the discipline com-
pounds: every quarter’s value data tightens the next quarter’s portfolio, and every cycle of the
loopiswhatbendsanenterprisefromAI-adoptertowardAI-high-performer.
30.17 References
Aher,Pratik. 2023. Evaluation Metrics for Recommendation Systems – An Overview. Https://towardsdatascience.com/evaluation-
metrics-for-recommendation-systems-an-overview-71290690ecba;TowardsDataScience.
AmitPahwaetal. 2021. “HowAirbnbAchievedMetricConsistencyatScale.” In Airbnb Engineer-
ing & Data Science.
Aryan,Abi. 2025. LLMOps: Managing Large Language Models in Production. O’ReillyMedia.
Breck, Eric, Shanqing Cai, Eric Nielsen, Michael Salib, and D. Sculley. 2017. “The ML Test Score:
ARubricforMLProductionReadinessandTechnicalDebtReduction.” 2017 IEEE International
Conference on Big Data (Big Data),1123–32.
Chang,Yupeng,Qiang,Yang,XuWang,etal. 2024. “ASurveyonEvaluationofLargeLanguage
Models.” ACM Transactions on Intelligent Systems and Technology,aheadofprint. https://doi.or
g/10.1145/3641289.
Dataiku. 2022. The Business Value Guide for AI: 6 Drivers of Value for AI Projects. Dataiku.
El-Mhamdi,El-Mahdi,andLê-NguyênHoang. 2024. On Goodhart’s Law, with an Application to Value
27

<!-- page 28 -->
Alignment. https://doi.org/10.48550/arXiv.2410.09638.
FinOpsFoundation. 2025. FinOps for AI - FinOps Framework Technology Category. Https://www.ﬁnops.org/framework/technology-
categories/ai/;FinOpsFoundation.
Gao,Leo,JohnSchulman,andJacobHilton. 2022. Scaling Laws for Reward Model Overoptimization.
https://doi.org/10.48550/arXiv.2210.10760.
Gartner. 2025a. Gartner Says Worldwide AI Spending Will Total $1.5 Trillion in 2025. Gartner.
Gartner. 2025b. Measuring the ROI of GenAI: Assessing Value and Cost. Gartner.
Gomez-Uribe, Carlos A., and Neil Hunt. 2015. “The Netﬂix Recommender System: Algorithms,
Business Value, and Innovation.” ACM Transactions on Management Information Systems 6 (4):
1–19. https://doi.org/10.1145/2843948.
Huyen, Chip. 2022. Designing Machine Learning Systems: An Iterative Process for Production-Ready
Applications. O’ReillyMedia.
Johnson, Nari, Ángel Alexander Cabrera, Gregory Plumb, and Ameet Talwalkar. 2023. “Where
DoesMyModelUnderperform? AHumanEvaluationofSliceDiscoveryAlgorithms.” AAAI
Conference on Human Computation and Crowdsourcing (HCOMP) 11: 65–76. https://doi.org/10
.48550/arXiv.2306.08167.
J.R. Storment and Mike Fuller. 2023. Cloud FinOps: Collaborative, Real-Time Cloud Value Decision
Making. 2ndEdition. O’ReillyMedia.
Kohavi,Ron,DianeTang,andYaXu. 2020. Trustworthy Online Controlled Experiments: A Practical
Guide to A/B Testing. CambridgeUniversityPress.
Markanastasakis, Vasilio, Rob Martin, Mike Fuller, Amber Gregorio, and J. R. Storment. 2025.
FinOps Framework 2025. Https://www.ﬁnops.org/insights/2025-ﬁnops-framework/; FinOps
Foundation.
Mitchell,Margaret,SimoneWu,AndrewZaldivar,etal. 2019. “ModelCardsforModelReporting.”
Proceedings of the Conference on Fairness, Accountability, and Transparency (FAccT),220–29. https:
//doi.org/10.1145/3287560.3287596.
Muschalik et al. 2024. “Shapiq: Shapley Interactions for Machine Learning.” NeurIPS 2024 —
Datasets and Benchmarks Track.
Ruzga,Eduard. 2026. Local LLMs Vs Cloud APIs Vs Subscriptions: Which Buys the Most Intelligence
Per Dollar? Https://wonderwhy-er.medium.com/local-llms-vs-cloud-apis-vs-subscriptions-
which-buys-the-most-intelligence-per-dollar-7365e3d9eae1;Medium.
Singla,Alex,AlexanderSukharevsky,andLareinaYee. 2025. The State of AI: How Organizations Are
Rewiring to Capture Value. McKinseyQuantumBlack.
28

<!-- page 29 -->
StanfordInstituteforHuman-CenteredArtiﬁcialIntelligence(HAI).2025. The 2025 AI Index Report
— Chapter 3: Responsible AI.StanfordInstituteforHuman-CenteredArtiﬁcialIntelligence(HAI).
Sweet,David. 2023. Experimentation for Engineers: From A/B Testing to Bayesian Optimization. Man-
ningPublications.
29