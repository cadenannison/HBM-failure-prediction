# Ch29-AI-Economics.pdf (extracted text, 29 pages)

<!-- page 1 -->
Chapter 29
AI Economics—Managing Costs and
Measuring Returns
29.1 Motivation
ImagineifaFortune500retailerlaunchesagenerativeAIpersonalizationengineinQ2. ByQ4,the
AIinfrastructurebillhasgrownto$2.3Mpermonth,fourtimestheoriginalestimate. Thesystem
is working. Users like it. Revenue attribution looks positive. But the cost per recommendation
was never calculated, the LLM API spend has no budget ceiling, and no one has asked whether
themarginalrevenueliftjustiﬁesthemarginalcost. Financecallsitarunawaycostcenter. TheAI
teamcallsitasuccess. Bothareright.
This pattern is not isolated. Gartner forecasts worldwide AI spending will reach $1.5 trillion in
2025 and climb to $2.5 trillion in 2026, spanning AI services, AI software, AI servers, AI-enabled
PCs,andAIsmartphones(Gartner2025). Atthatmacroscale,thequestionofwhetheraparticular
AI program is economically sustainable becomes a board-level concern. The macro analysis be-
hindthatscalewasframedyearsearlierbySemiAnalysis,whichcalculatedthatrunningChatGPT-
styleinferenceatsearch-enginevolumewouldcostroughly$0.36perqueryagainstGoogle’sthen-
current $0.0106 per query, requiring more than 512,000 NVIDIA A100 servers and over $100B in
capital expenditure, and would “permanently reduce” search economics by transferring tens of
billionsinproﬁtfromincumbentplatformstohardwareproviders(PatelandAhmad2023). That
analysisiswhycost-per-queryeconomicsbecameastrategicquestioninsteadofaninfrastructure
detail.
Thisisthecostdisciplineproblem. MostAIteamsarerewardedforbuildingthingsthatwork,not
forbuildingthemefﬁciently. Costistreatedassomeoneelse’sproblemuntilitbecomeseveryone’s
problematbudgetreview. EnterpriseAIatscalegeneratescostsacrosssixdistinctcategories,and
everyarchitecturaldecisionmadeintheBuildphasehasadirectcostconsequencethatplaysout
for months or years in production. Cost discipline means spending intentionally and building
systemsinwhichtheeconomicsimproveasscaleincreasesratherthandeteriorate.
1

<!-- page 2 -->
29.2 Challenge
How do you design, operate, and continuously optimize AI systems so that costs are visible, ac-
countable, and proportionate to business value, without sacriﬁcing the performance, reliability,
andqualitythatmakethesystemworthrunning?
Thechallengehas threelayers. First, you mustsurfacecoststhatcurrentcloud billing infrastruc-
turetendstoobscure: sharedaccounts,untaggedresources,mixeddevandprodworkloads,and
engineeringlaborallocatedacrossmanyprojects. Second,youmustbuildeconomicintuitioninto
designdecisionsbeforethearchitectureiscommitted,becausethecostcurveofasystemislargely
ﬁxed by the choices made during solution design (see Chapter 18 and Chapter 17). Third, you
mustrunacontinuousoptimizationpracticethatsurvivesleadershipchangesandbudgetcycles,
treatingcostasaﬁrst-classoperationalconcernratherthanaquarterlycleanupexercise.
29.3 Objectives
Bytheendofthischapter,youwillbeableto:
1. Map the full cost structure of a production AI system across all six cost categories and re-
latethatstructuretotheFinOpsFoundation’sScopesvocabularyusedbyenterpriseFinOps
practitioners.
2. Build cost estimates into design decisions before infrastructure is provisioned, using
workload-speciﬁcestimationtechniquesfortraining,inference,pipeline,andlargelanguage
modelworkloads.
3. ApplyFinOpsprinciplestomakeAIspendvisible,accountable,andcontinuouslyoptimized,
using the FinOps Foundation’s named capabilities (allocation, forecasting, unit economics,
policyandgovernance,practiceoperations,education).
4. Choosecostoptimizationtechniquesappropriatetoyourworkloadtype,calibratedagainst
vendor-reportedempiricalsavingsforpromptcachingandinferencecompression.
5. Framethebuild-versus-buy-versus-subscribedecisionasaquestionof“intelligenceperdol-
lar,”withanannualreviewcadencetorespondtomarketvolatility.
6. Evaluate cost-performance tradeoffs through a chain-of-causation discipline so that base-
layer optimizations propagate to business outcomes rather than producing decorative sav-
ings.
7. Framecostefﬁciencyasagovernanceandstrategicaccountability, withtheAIGovernance
BoardandAIInvestmentCouncilasappropriatedecisionbodies.
The system is running reliably. This chapter turns to whether it is running economically and how to ensure
costs remain proportionate to value delivered as scale increases.
29.4 Interface with Prior Chapters
ThischapterassumesseveralinputsfrompriorchaptersintheBuildandOperateparts:
• Approved AI strategy and use case portfolio fromChapter9andChapter12,whichdeﬁne
whichAIinvestmentsareworthmaking.
• Production architecture from Chapter 18, which locks in the cost curve through infrastruc-
turechoices.
2

<!-- page 3 -->
• Observability baseline fromChapter27, whichprovidesthetelemetryneededtoattribute
coststospeciﬁcmodelsandworkloads.
• Governance model fromChapter25,whichestablishesthedecisionbodiesthatapprovecost-
performancetradeoffs.
• Reliability targets from Chapter 28, which constrain how aggressively costs can be opti-
mizedwithoutviolatingservice-levelobjectives.
Thecoreprinciple: inprioroperatingchapters,wemadethesystemreliableandobservable. Now
weaddtheeconomiccontrolplane.
29.5 The Full Cost Structure of Enterprise AI
Most cost estimates focus on compute. Most budget overruns come from everything else. The
complete cost structure of a production AI system spans six categories, and all of them must be
tracked. TheFinOpsFoundation’s2025frameworkrefreshintroducedtheconceptof Scopes toleta
singleenterpriseFinOpspracticespanPublicCloud,SaaS,DataCenters,Licensing,PrivateCloud,
andAI(Markanastasakisetal. 2025). Withinthatvocabulary,thesixcategoriesbelowdescribethe
lineitemsinsidetheAIScope.
29.5.1 The six cost categories
Table 29.1: The Full Cost Structure of Enterprise AI: Category, What It Includes, Common Underestimation.
Category WhatItIncludes CommonUnderestimation
Compute GPU/CPUtrainingruns,
inferenceendpoints,
auto-scalingoverhead,
ﬁne-tuningcompute
Trainingcostsoftenrun3to5
timesinitialestimatesdueto
iteration;inferencescaleswith
trafﬁcinwaysthatdependon
batching,caching,and
endpointsizing
Storage Trainingdata,modelartifacts,
featurestores,logs,
embeddings,vectorindexes
Logsandembeddings
accumulatequickly;data
retentionrequirementsextend
storagecostsforyears
Networking Dataegressbetweenregions
andservices,APIcall
overhead,CDNcosts,
cross-VPCtrafﬁc
Egresscostsareinvisibleuntil
volumescales;cross-region
architecturesmultiplythem
Managedservices LLMAPIfees,vectordatabase
subscriptions,MLOps
platformlicensing,monitoring
tools
Token-basedLLMpricing
scaleswithoutputlengthand
usagevolume,whichiseasy
tounderestimateatpilot
3

<!-- page 4 -->
Category WhatItIncludes CommonUnderestimation
Engineeringlabor MLengineers,dataengineers,
platformengineers,
governanceoverhead,MLOps
specialists
Oftenthelargestsinglecostin
enterpriseAIprograms
outsidefrontier-model
trainingandvery
high-volumeinference;rarely
trackedagainstindividual
systems
Operationalsupport On-callburden,incident
responsetime,retraining
cycles,modelcard
maintenance,evaluationruns
Growswiththenumberof
productionmodels;
compoundswithoutlifecycle
discipline
Theseventhimplicitcategory,whichSculleyandcolleaguesnamedadecadeago,ishiddentech-
nicaldebt: thecostthataccumulateswhereverinstrumentationisabsentandassumptionssilently
fossilize into the architecture (Sculley et al. 2015). Hidden debt is the residual that explains why
matureAIsystemsoftencostmoretooperatethanneweroneswiththesamenominalworkload.
29.5.2 Why cost estimates are almost always wrong
Teamsestimatecomputeforthehappypath: onetrainingrun,nominaltrafﬁc,thecanonicalevalu-
ationset. Productioninvolvesmultipletrainingiterations,trafﬁcspikes,retries,redundancy,and
anevaluationcadencethatscaleswithmodelcount(Graceetal. 2026). LLMcostsinparticularare
frequently underestimated. Prompt length, chain-of-thought reasoning, tool-use loops, retrieval-
augmented context injection, and multi-turn conversations inﬂate token counts far beyond what
single-queryestimatessuggest. Aryansummarizesthediscontinuitydirectly: traditionalMLOps
costassumptionsfallapartwithgenerativeAI,becausetokeneconomics,third-partymodeldepen-
dency, and non-deterministic outputs create cost surfaces that classical ML budgeting was never
designedtoforecast(Aryan2025).
Engineering labor is often the largest cost and the least tracked. When labor is not attributed to
systems,thereisnosignalaboutwhichsystemsaremostcostlytomaintain,andzombiesystems
(no longer used, never decommissioned) accumulate unnoticed on the operations team’s plate.
Operational support behaves the same way. Each new production model adds incident risk, on-
callattention,andanevaluationburdenthatcompoundsacrosstheportfolio.
29.5.3 The cost visibility imperative
You cannot manage costs you cannot see. Every production AI system should have a cost dash-
boardshowingspendbycategory,trendovertime,andatleastonecost-per-unit-of-outputmetric:
costperprediction,costperrecommendation,costpergeneratedresponse,costperattributeddol-
larofrevenue. Costvisibilityisagovernancerequirement. TheAIGovernanceBoard(seeChap-
ter25)shouldreviewcosttrendsquarterlyalongsideperformancemetrics,andtheAIInvestment
Councilpatterndescribedlaterinthischaptershouldreviewportfolio-levelallocation.
TheStanfordAIIndex2025documentsthemacroinvestmentcontextinwhichthesedashboards
sit (Stanford Institute for Human-Centered Artiﬁcial Intelligence (HAI) 2025): enterprise AI in-
4

<!-- page 5 -->
Figure 29.1: The six explicit cost categories of enterprise AI, plus hidden technical debt as the seventh implicit
category.
5

<!-- page 6 -->
vestment continues to rise faster than enterprise AI returns are being measured. Visibility is the
prerequisiteforanyhonestcomparisonbetweenthetwo.
29.6 Cost Estimation as a Design Discipline
CostestimationbelongsinthesolutiondesignphaseoftheAIdevelopmentlifecycle,notafterthe
systemisbuiltandrunning. Architecturaldecisionsmadeearlylockincostcurvesthataredifﬁcult
tochangelater. Huyenframescostasaﬁrst-classconcerninproductionmachinelearningsystems
precisely because the architecture sets the economic ceiling (Huyen 2022). A system designed
without a cost model will produce a cost number, but that number will reﬂect default choices
ratherthanintentionalones.
29.6.1 Cost estimation by workload type
Training costs. Inputs include dataset size, model parameter count, sequence length, number of
epochs, batch size, training duration estimate, GPU type and hourly cost, optimizer state over-
head,distributedtrainingefﬁciency,checkpointingcadence,andtheexpectednumberoftraining
iterations before production. A reliable rule of thumb is to multiply your ﬁrst estimate by 3 to
account for iteration overhead, but calibrate against your actual experimental history. EC2 Spot
InstancesorSageMakerManagedSpotTrainingreducetrainingcostssubstantially(AWSmarkets
savingsupto90percent,thoughactualsavingsvarybyinstancefamily,region,andinterruption
rate)withpropercheckpointing. Forcontinuous-trainingpipelines,Kazmierczakandcolleagues
notethatMLOpsLevel1orhigherisaprerequisitefordisciplinedretrainingcostforecasts: with-
out automation, the marginal cost of a retraining cycle is dominated by engineering labor rather
thancompute,whichmakesforecastsunreliable(Kazmierczaketal. 2024).
Inference costs. Inputsincludeexpectedrequestvolume,modelsize,averagelatencytarget,serv-
ing hardware (GPU versus CPU), and the choice between batch and real-time. Real-time infer-
ence is often more expensive per prediction than batch, though the ratio depends on utilization,
hardware, latency SLO, model size, batching window, and endpoint type. Use batch where la-
tency requirements allow. Auto-scaling adds elasticity but also adds cost variability; set upper
bounds. Saltonstall and Virji argue that ML-speciﬁc service-level indicators should include cost-
per-inference alongside latency and accuracy, so that cost appears on the same observability sur-
faceasreliability(SaltonstallandVirji2025).
LLM API costs. Inputs include average prompt token count, average completion token count,
requestsperday,andproviderpricingpermilliontokens. Theformulaforaﬁrstestimate:
Monthly LLM cost = daily_requests × 30 × [
(avg_input_tokens / 1,000,000 × input_price_per_MTok) +
(avg_output_tokens / 1,000,000 × output_price_per_MTok)
] × cache_adjustment × retry_and_tool_multiplier
Chain-of-thoughtandfew-shotpromptingmultiplytokencounts. Tool-useloopsfurtheramplify
them: an agent that calls four tools and reasons between each call may consume eight to twelve
timesthetokensofasingle-turncompletion. Measureactualtokenusageintheprototypebefore
estimatingproductioncosts. Cachingidenticalornear-identicalpromptscanavoidredundantAPI
callsandproducesubstantialsavingsforhigh-volumeusecases(coveredindetailintheoptimiza-
tionsection).
6

<!-- page 7 -->
Pipeline costs. Inputs include data volume processed per run, run frequency, compute required
pertransformation,andstorageforintermediateartifacts. Streamingpipelinescostmoreperevent
than batch but enable real-time features. Evaluate whether real-time features actually improve
model performance enough to justify the premium, or whether near-real-time batch (every ﬁve
minutes)woulddeliverequivalentbusinessvalueatafractionofthecost.
Evaluation costs. Oftenforgottenininitialestimates. Comprehensiveevaluationsuitescanthem-
selvescostthousandsofdollarsperrunwhentheyrelyonjudgemodelsorhumanraters(Changet
al. 2024). GraceandcolleaguesatAnthropicemphasizethatevaluationdisciplineincludessample-
rate decisions: how often to rerun the full suite, which subset to run on each commit, and what
triggersafullre-evaluation(Graceetal. 2026). Evalcostisanongoingoperationalcostthatrecurs
witheveryevaluationrun.
29.6.2 Cost modeling at three scales
• Prototype. Minimalinfrastructure,syntheticorsampleddata,singledeveloper. Thegoalis
toestablishacost-per-unitbaseline,nottopredictproductioncost.
• Pilot. Realdatasubset,smallteam,moderatetrafﬁc. Thegoalistovalidatethatcostscales
asexpected,andtodetectsuperlinearscalingearly.
• Production. Full trafﬁc, redundancy, team overhead, evaluation cadence. Apply a 30-50%
buffer for surprises. Breck and colleagues’ production-readiness rubric explicitly includes
cost and efﬁciency dimensions alongside accuracy, reliability, and reproducibility (Breck et
al. 2017). A system that has not passed cost-and-efﬁciency review is not production-ready,
regardlessofitsmodelperformance.
29.7 Measuring Returns: Connecting Costs to Business Value
Cost discipline alone does not answer the question executives actually ask: is the AI investment
producing returns that justify the spend? This chapter focuses on cost management; Chapter 30
covers business value measurement in depth. However, you need enough return measurement
vocabularytoconnectcosttovaluewithinthischapter.
29.7.1 The return measurement vocabulary
Unit economics convertscloudspendintoabusinessoperatingmetric: costperscoredcustomer,
costperacceptedoffer,costperretainedcustomer,andcostperincrementaldollarofgrossmargin.
Uniteconomicsisthebridgebetweeninfrastructurecostandbusinessreturn.
ROI (Return on Investment) =(NetBeneﬁt-TotalCost)/TotalCost. Simpleinconcept,difﬁcult
inpracticebecausebeneﬁtattributionisrarelyclean.
Payback period is the time required for cumulative beneﬁts to exceed cumulative costs. For AI
systems,includeallsixcostcategories,notjustcompute.
Incremental revenue versus attributed revenue. Attributedrevenueisrevenuegeneratedinthe
presence of the AI system. Incremental revenue is the additional revenue that would not have
occurred without it. The difference matters: a recommendation engine that “inﬂuences” $10M
in sales may produce only $500K in incremental lift if most of those purchases would have hap-
pened anyway. Causal attribution requires experiments (A/B tests, holdout groups) or quasi-
experimentalmethods(difference-in-differences,regressiondiscontinuity).
7

<!-- page 8 -->
Avoided cost is legitimate AI value but requires the same causal rigor. A fraud detection model
that “prevented” $5M in fraud must demonstrate that the fraud would have succeeded without
themodel,notmerelythatthemodelﬂaggedtransactionsthathappenedtobefraudulent.
Conﬁdence bands. Honestreturnmeasurementincludesuncertainty. Amodelthatproduces$2M
in incremental revenue with 95% conﬁdence between $1.2M and $2.8M is a different investment
thanonewith95%conﬁdencebetween$0.5Mand$3.5M.
When to require experiments. For high-stakes investment decisions, attribution claims based
solelyoncorrelationareinsufﬁcient. Governanceshouldrequirerandomizedholdoutsorequiva-
lentcausalmethodsfor: -Systemsaboveadeﬁnedspendthreshold(commonly$100K+peryear).
-Systemswherethereturnclaimistheprimaryjustiﬁcationforcontinuedinvestment. -Systems
wheremarketingorsalesismakingexternalclaimsabouttheimpactofAI.
The metric pyramid from Chapter 26 provides the discipline for connecting base-layer cost opti-
mizationstothesereturnmetrics;theCost-PerformanceTradeoffssectionbelowshowshow.
29.8 FinOps for AI: Making Spend Visible and Accountable
FinOps applied to AI is the practice of making AI spend visible, attributable, and continuously
optimized. Withoutit,AIcostsaccumulateinsharedinfrastructurebudgetswithnoaccountability.
Storment and Fuller’s foundational treatment of cloud FinOps remains a canonical book-length
reference for the discipline (J.R. Storment and Mike Fuller 2023), and the FinOps Foundation’s
2025 framework refresh extended the discipline beyond Public Cloud to a uniﬁed Scopes model
thatincludesAIasaﬁrst-classscope(Markanastasakisetal. 2025).
29.8.1 The FinOps Foundation’s named capabilities for AI
The FinOps Foundation’s AI Technology Category names six capabilities that enterprise FinOps
teamsshouldrunagainsttheirAIScope(FinOpsFoundation2025):
1. Allocation. AttributingAIcosttotherightteam,product,model,orbusinessunit. Includes
bothshared-serviceallocation(theplatformteam’sGPUcluster)anddirectallocation(asin-
gleproduct’sBedrockspend).
2. Forecasting. Projecting future AI spend with conﬁdence intervals, accounting for usage
growth, model upgrades, and known cyclicality. AI workloads with sporadic experimen-
tationpatternsmakethisharderthansteady-statecloudforecasting.
3. Unit economics. Calculating cost-per-unit-of-output (cost-per-prediction, cost-per-token,
cost-per-customer-served)sothatscaledecisionscanbemadeonmarginaleconomicsrather
thantotalspend.
4. Policy and governance. Deﬁning and enforcing spend ceilings, model approval gates, and
procurementstandards. Includesthecross-functionalapprovalbodiesdescribedbelow.
5. Practice operations. Running the FinOps practice itself: cadence of reviews, ownership of
dashboards,escalationpaths,trainingforcostowners.
6. Education. Bringing non-traditional technical participants (data scientists, product man-
agers, AI Product Owners) into a shared cost vocabulary so that cost conversations do not
requireatranslator.
The chapter’s working executive summary distills these six into three operational verbs: visibil-
ity (allocation, forecasting), accountability (policy and governance, practice operations), and opti-
8

<!-- page 9 -->
mization (uniteconomics,education). Thethree-verbsummaryisﬁneforexecutiveframing. The
Foundation’ssix-capabilitymodelisthevocabularyengineeringteamsshoulduseinpractice.
Figure 29.2: The FinOps Foundation’s six named capabilities for enterprise AI cost management, grouped
by operational function.
29.8.2 Visibility
Tageverycloudresourcewithproject,team,environment(dev,staging,prod),usecase,andmodel
name. Enforcetaggingatprovisioning. Untaggedresourcescannotbedeployed. Costdashboards
shouldbeavailabletoeveryteam,notjustﬁnance. Thechoicebetween showback (teamsseetheir
costs)and chargeback (teamsarebilled)isamaturitydecision. Showbackbuildsawareness;charge-
9

<!-- page 10 -->
backdrivesoptimization. Startwithshowback,andmovetochargebackonceteamshavethetools,
vocabulary,andauthoritytoactonwhattheysee.
Atypicalmaturityprogression:
• Months0-3: Taggingenforcementandbasicdashboards.
• Months3-6: Showbackreportsandbudgetalerts.
• Months6-12: Uniteconomicsandforecastingcapability.
• Aftermonth12: Chargebackformaturesystemswithstablecostattribution.
29.8.3 Accountability
Each AI system has a designated cost owner, typically the AI Product Owner. Monthly cost re-
view is a standing meeting for teams that exceed a deﬁned spend threshold (typically $10,000 to
$25,000permonthpersystem,dependingonenterprisesize). Costvariancefromestimatetriggers
an explanation requirement, aimed at understanding rather than punishment. Budget alerts are
automatedat50,80,and100percentofthemonthlyallocation. Thurgoodandcolleaguesdescribe
errorbudgetsasSRE’sversionof“spendceiling”thinking,whereaﬁxedbudgetdeﬁneswhatthe
team iswillingtospendonreliabilitybeforechangingposture(Thurgoodetal. 2018). Thesame
framingappliestocost: acostbudgetdeﬁneswhattheteamiswillingtospendbeforetriggering
aposturechange,whetherthatisratelimiting,modeldowngrading,orfeaturethrottling.
29.8.4 The AI Investment Council
Forportfolio-leveldecisionsacrossmultipleAIsystems,theAIProductOwnerroleisinsufﬁcient.
TheFinOpsFoundationrecommendsconsideringan AI Investment Council asthecross-functional
decisionbodythatapprovesnewAIinvestments,reallocatesspendacrosstheportfolio,andretires
underperformingsystems(FinOpsFoundation2025). Thisisagovernancepatternrecommenda-
tionthatorganizationscanadapttotheirownstructure. Typicalmembershipincludes:
• TheCFOoraFinancedelegate
• TheCIOorCTO
10

<!-- page 11 -->
• TheheadofAIorChiefAIOfﬁcer
• TheAIGovernanceBoardchair(seeChapter25)
• Aseniorproductorbusinessunitleader
• ALegalorCompliancerepresentativeforhigh-riskdecisions
The Council meets quarterly to review portfolio cost, performance, and value, and ad hoc for in-
dividualinvestmentdecisionsaboveadeﬁnedthreshold. Itisthebodythatanswersthequestion
“should we retire this system” when no single team has the authority or incentive to do so. The
Council differs from the AI Governance Board in focus: the Governance Board addresses risk,
compliance,andpolicy;theInvestmentCounciladdresseseconomicallocationandportfolioopti-
mization. Insmallerorganizations,thesemaybethesamebody.
29.8.5 Optimization
Costoptimizationisanongoingpractice,revisitedasworkloadsandusagepatternsshift. Cost-per-
unitmetrics(costperprediction,costper$1ofattributedrevenue)aretherightoptimizationtar-
gets. Asystemwhoserawspenddoubleswhileservingfourtimesthetrafﬁchasimproveditsunit
economics. Scheduled rightsizing reviews (quarterly analysis of whether provisioned resources
match actual utilization) catch the most common form of waste: oversized inference endpoints,
overprovisionedvectordatabases,andunderusedGPUreservations.
29.8.6 Common cost accountability failures
• Sharedinfrastructureaccountswithnoper-systemattribution. Nooneknowswhichmodel
ismoreexpensive.
• Developerenvironmentsthatrun24/7eventhoughtheyareusedonly8hoursperday.
• Modelsthatarenolongerusedbutstillhaveactiveservingendpoints. Zombiemodels.
• LLMAPIintegrationswithnospendceiling. Asinglemisconﬁguredloopcangeneratetens
ofthousandsofdollarsinAPIcallsovernight.
• Evaluationrunsscheduledhourlybecausetheteamforgottheywererunning.
• Vectordatabasessizedforpeaktrafﬁcandneverscaleddown.
• Multi-regionreplicationofstaletrainingdata.
29.8.7 Case study: Intuit’s AI FinOps practice
Intuit,operatingAIatscaleacrossTurboTax,QuickBooks,andCreditKarma,implementedafor-
mal AI FinOps function that attributed costs to individual models and products (J.R. Storment
and Mike Fuller 2023). By making cost-per-prediction visible to product teams rather than bury-
ing it in shared infrastructure spend, they achieved signiﬁcant reductions in inference costs over
an18-monthperiodthroughacombinationofmodelcompression,batchingoptimization,andde-
commissioningunderperformingmodels. Thelesson: productteamsoptimizeforcostwhenthey
canseeit. Theydonotwhenitisburiedinsharedinfrastructurespend. Thepatterngeneralizes.
Costvisibilityturnsacentralizedbudgetproblemintooneindividualteamshavetheinformation
tosolve.
11

<!-- page 12 -->
29.9 Implementing AI FinOps on AWS
SinceAWSisthereferenceplatformforthisbook, thissectionprovidesconcreteimplementation
guidanceforAIFinOpsonAWSinfrastructure.
29.9.1 AWS Organizations and account structure
OrganizeAIworkloadsintodedicatedAWSaccountswithinanOrganization:
• AI Platform account: Sharedinfrastructure,SageMakerdomains,Bedrockaccess.
• AI Development account: Experimentation,trainingruns,developmentendpoints.
• AI Production account: Productioninferenceendpoints,productionpipelines.
Thisseparationenablescleanercostattributionandsecurityboundaries.
29.9.2 Cost visibility infrastructure
AWS Cost Explorer providestheprimaryinterfaceforanalyzingAIspend. Enablecostallocation
tagsandcreatesavedreportsfor: -SpendbyAIsystem(usingthe model or system tag). -Spendby
environment(dev,staging,prod). -Spendbycostcategory(compute,storage,managedservices).
AWS Cost and Usage Report (CUR) delivers detailed billing data to S3. Conﬁgure CUR with
resource-level data enabled, then use Amazon Athena and Amazon QuickSight to build custom
dashboardsthatshowcostperprediction,costpertoken,andtrendanalysis.
AWS Cost Categories allow you to map cost allocation tags to business-meaningful categories.
Create categories for: - AI system names (churn-prediction, recommendation-engine, offer-
generation). - Cost types (training, inference, data-pipeline, evaluation). - Business units (if
chargebackisenabled).
AWS Budgets providesautomatedalerting. Createbudgetswithalertsat50%,80%,and100%of
themonthlyallocationforeachAIsystemthatexceedsyourtrackingthreshold. Includeforecasted
spendalertstocatchrunawaycostsbeforemonth-end.
AWS Cost Anomaly Detection identiﬁes unusual spending patterns automatically. Enable
anomaly detection monitors for: - Individual AI accounts. - Speciﬁc services (SageMaker,
Bedrock,OpenSearch). -Costallocationtaggroups.
29.9.3 Tag enforcement with Terraform
SinceTerraformisthestandardIaCtoolforthisbook,enforcerequiredcosttagsthroughTerraform
conﬁguration:
variable "required_tags" {
description = "Required cost allocation tags for all AI resources"
type = object({
project = string
team = string
environment = string
model = string
cost_owner = string
})
12

<!-- page 13 -->
}
resource "aws_sagemaker_endpoint" "inference" {
name = var.endpoint_name
endpoint_config_name = aws_sagemaker_endpoint_configuration.config.name
tags = merge(var.required_tags, {
cost_type = "inference"
created = timestamp()
})
}
ComplementTerraformenforcementwithAWSOrganizationstagpoliciestopreventthecreation
ofuntaggedresourcesattheAPIlevel.
29.9.4 SageMaker cost allocation
Enable SageMaker-speciﬁc cost allocation in AWS Cost Explorer to see costs broken down by: -
Trainingjobsversusendpointsversusprocessingjobs. -Instancetypesandutilization. -Managed
SpotTrainingsavings.
UseSageMakerInferenceRecommendertoright-sizeinferenceendpointsbasedonactuallatency
andthroughputrequirementsratherthanover-provisioning.
29.9.5 Bedrock cost controls
Amazon Bedrock charges per token with model-speciﬁc pricing. Implement controls at multiple
layers:
Service quotas: Setquotasontokensperminuteandrequestsperminutetopreventrunawaycosts
frommisconﬁguredagentsorloops.
Application-level controls: Implementper-userorper-tenantratelimitsinyourapplicationlayer.
Include circuit breakers that halt agent loops after a conﬁgurable number of iterations or token
budget.
CloudWatch alarms: Create alarms on Bedrock invocation metrics: - Invocations exceeding ex-
pected daily volume. - InputTokenCount and OutputTokenCount trends. - Error rates that might
indicateretrystorms.
Max token settings: Always specify max_tokens in Bedrock API calls to prevent unexpectedly
longcompletions.
29.9.6 Storage lifecycle management
ImplementS3lifecyclepoliciestomanageAIdatacosts:
{
"Rules": [
{
"ID": "Training-data-lifecycle",
"Filter": {"Prefix": "training-data/"},
13

<!-- page 14 -->
"Status": "Enabled",
"Transitions": [
{"Days": 30, "StorageClass": "STANDARD_IA"},
{"Days": 90, "StorageClass": "GLACIER"}
]
},
{
"ID": "Model-artifacts-lifecycle",
"Filter": {"Prefix": "model-artifacts/"},
"Status": "Enabled",
"Transitions": [
{"Days": 60, "StorageClass": "STANDARD_IA"}
],
"NoncurrentVersionExpiration": {"NoncurrentDays": 30}
}
]
}
Conﬁgure CloudWatch Logs retention to match compliance requirements rather than defaulting
to indeﬁnite retention. Common AI log retention: 30 days for debug logs, 90 days for inference
logs,1yearforauditlogs.
29.10 Cost Optimization Techniques
CostoptimizationinAImeansusingtherighthardwareattherighttime,eliminatingwaste,and
makingarchitecturalchoicesthatimproveeconomicsatscale. Thetechniquesbelowareorganized
byworkloadtypeand,wherepossible,calibratedagainstvendor-reportedempiricalbenchmarks.
Note that vendor claims are workload-dependent; benchmark on your own trafﬁc before
14

<!-- page 15 -->
committingtooptimizationtargets.
29.10.1 Inference optimization
Model compression. Threetechniques, quantization, pruning, anddistillation, accountformost
inference cost reduction. NVIDIA’s 2025 reference guidance on cost-efﬁcient LLM inference rec-
ommendsoneeffectivecompressionorderingofPruning,thenDistillation,thenQuantization,and
reportsempiricalresultsofroughly40percentinfrastructurecostreductionwithin1percentofac-
curacyinfavorablecases,withupto80percentoperationalcostreductionpossibleinaggressive
optimizationscenarios(NVIDIA2025). Thesearevendor-reportedbenchmarks;yourresultswill
dependonmodelarchitecture,taskcomplexity,andqualityrequirements.
• Quantization reduces weight precision from FP32 to FP16 or INT8 (or lower). Can reduce
modelsizeandinferencecostby2to4timeswithminimalaccuracylossformanyusecases,
thoughaccuracyimpactvarieswithmodelsize,tasktype,andquantizationmethod.
• Pruning removes weights judged unimportant by sensitivity analysis or magnitude thresh-
olding. Reduces parameter count, though actual compute savings depend on whether the
servingruntimeandhardwarecanexploitsparsityefﬁciently.
• Distillation trains a smaller “student” model to replicate the behavior of a larger “teacher”
model. Oftenachieves80to90percentoftheteacher’sperformanceatafractionofthecost,
thoughresultsdependheavilyontaskcomplexityanddistillationmethodology.
Batching. Groupingmultipleinferencerequestsintoasingleforwardpassreducesper-prediction
cost signiﬁcantly for throughput-tolerant workloads. The savings are largest where requests can
bequeuedbrieﬂywithoutviolatinglatencySLOs.
Caching. CachingresponsesforcommonorrepeatedinputsisespeciallyusefulforLLMsystems
withrepeatedpromptpatterns. Anthropic’sdirectAPIdocumentationstatesthatcachereadsare
pricedat10percentofthebaseinputtokencost,whilecachewritesincurapremiumforvarious
TTL durations (Anthropic 2026). Note that Amazon Bedrock caching behavior and pricing may
differfromdirectAPIpricing;consultthecurrentBedrockdocumentationforAWS-speciﬁcimple-
mentationdetails. Forahigh-volumeapplicationwithastablesystempromptservedtothousands
ofrequestsperday,promptcachingcansubstantiallyreduceLLMinputtokencosts.
29.10.2 Training optimization
Spot and preemptible instances. SageMakerManagedSpotTrainingandEC2SpotInstancescan
substantiallyreducetrainingcostsversuson-demandpricing. AWSmarketssavingsupto90per-
cent, though actual savings vary by instance family, region, availability, and interruption rate.
Requires checkpointing every N steps to survive interruptions. Include the cost of interruption-
inducedrestartsinyoureffectivesavingscalculation.
Mixed-precision training. UseFP16orBF16insteadofFP32. Reducesmemoryfootprint,increases
throughput,andspeedstrainingwithnegligibleimpactonaccuracyformostarchitectures.
Efﬁcient hyperparameter search. Early stopping, Bayesian optimization, and population-based
trainingreducethenumberoftrainingrunsneededtoﬁndgoodhyperparameters. Thenaivegrid
searchbaselineisrarelyjustiﬁedatmoderntrainingcosts.
Transfer learning and ﬁne-tuning. Startfromapretrainedfoundationmodelratherthantraining
fromscratch. Eliminatesmosttrainingcostformostenterpriseusecases.
15

<!-- page 16 -->
Parameter-efﬁcient ﬁne-tuning (PEFT). Techniques such as LoRA freeze the pretrained base
modelandtrainonlyasmallsetofadditionallow-rankadapterparameters,substantiallyreducing
the compute, memory, and storage required for model customization. QLoRA further reduces
training memory requirements by quantizing the frozen base model, typically to 4-bit precision,
whiletrainingLoRAadapters. Becausemanysmalladapterscanshareasinglebasemodel,PEFT
also enables efﬁcient multi-tenant customization and serving when combined with inference
systems that dynamically load or route requests to tenant-speciﬁc adapters Serve Many LoRA
Adapters from One Endpoint with Hugging Face vLLM ⋅ Hugging Face (n.d.).
29.10.3 LLM-speciﬁc optimization
Prompt compression. Shorter prompts cost less. Review prompts for unnecessary verbosity.
Use retrieval rather than stufﬁng entire documents into context. The difference between a well-
structured1,500-tokenpromptandaverbose4,000-tokenpromptaddsuptorealmoneyonevery
call.
Model selection by task. Use the smallest model that achieves an acceptable level of quality for
eachtask. Reservelargefrontiermodelsfortasksthatrequirethem. Acommonpatternistoroute
mostrequeststoasmaller,cheapermodelandescalateonlythehardcasestoalargerone.
Prompt caching. Covered above. Signiﬁcant savings for high-volume applications with stable
systeminstructions.
Output length control. Explicitlyconstrainoutputlengthwherepossible. Open-endedgeneration
produces longer, and therefore more expensive, outputs than structured extraction. Structured
output formats (JSON schema, function calls) often produce shorter completions than free-form
textforequivalentinformation.
Speculative decoding and batching. For self-hosted LLMs, speculative decoding can increase
throughput meaningfully. Dynamic batching at the serving layer further amortizes GPU cost
acrossrequests.
29.10.4 Agent-based system economics
Agentsystemsintroducecostampliﬁcationpatternsthatrequireexplicitcontrols:
Tool-call ampliﬁcation. Each tool call in an agent loop incurs additional token costs for the tool
request, tool response, and reasoning about the response. An agent that uses multiple tools to
completeataskmayconsumeanorderofmagnitudemoretokensthanasingle-turncompletion.
Recursive planning loops. Agentsthatplan,execute,observe,andre-plancanenterloopsthatcon-
sumetokensuntilinterrupted. Implementiterationlimitsandtokenbudgetsashardconstraints.
Multi-agent fanout. Architectureswheremultipleagentscollaboratemultiplycostsacrossagents.
Designfan-outcarefullyandconsiderwhethersequentialprocessingwouldachievesimilarresults
atlowercost.
Budget-aware agents. Implementper-taskspendingcapsinagentorchestration. Whenanagent
approachesitstokenbudget,itshouldeithercompletewithavailablecontextorescalatetoahuman
ratherthancontinuingtoconsumetokens.
Graceful degradation. Designagentstoproduceusefulpartialresultswhenbudgetisexhausted
ratherthanfailingcompletely.
16

<!-- page 17 -->
29.10.5 Workload scheduling
• Non-latency-sensitive workloads (batch scoring, retraining, reporting) should run off-peak
oncheapercompute.
• Dev and staging environments should auto-shutdown outside business hours. Often 50 to
70percentofenvironmentcostiseliminated.
• RetrainingpipelinesshoulduseSpotInstanceswithcheckpointingbydefault.
• Vectordatabasereadreplicascanscaledownovernightiftrafﬁcispredictablydiurnal.
29.10.6 The cost-performance tradeoff framework
Every optimization technique involves a tradeoff: accuracy, latency, resilience, fairness, or en-
gineering complexity. Evaluate optimizations on cost-per-unit-of-output. A 30 percent cheaper
modelthatrequires50percentmoreengineeringtimetomaintainmaynotbeworthit. Document
optimizationdecisionsinthemodelcardalongsidetheperformanceimpact(Mitchelletal. 2019),
sothatthetradeoffisauditablemonthslaterwhentheteamthatmadeithasmovedon.
Aspeciﬁcfailuremodetoavoid: optimizingonaproxymetricthatdoesnotpropagatetobusiness
outcomes. El-MhamdiandHoang’sanalysisofGoodhart’sLawinmachinelearningexplainsthe
riskdirectly(El-MhamdiandHoang2024): whencostbecomesthetargetratherthanaconstraint,
downstream quality and fairness degrade without anyone noticing. The next section formalizes
thedisciplinethatpreventsthisdrift.
29.11 Build, Buy, or Subscribe: Intelligence per Dollar
The build-versus-buy decision is the largest single architectural choice that affects long-term AI
economics. In2026,thedecisionhasthreebranchesratherthantwo: build(self-hosted,including
ﬁne-tuned open-weight models on your own infrastructure), buy (cloud API access to frontier
models,paidpertoken),orsubscribe(per-seatorper-teamsubscriptionstoAIproducts). Ruzga
frames the question as intelligence per dollar: how much usable capability does each spend dollar
produce,accountingforbothperformanceandtotalcostofownership(Ruzga2026)?
29.11.1 The three options
Build (self-hosted).
• Bestfor: high-volume,latency-sensitive,regulated,ordata-sensitiveworkloadswheretoken
volumeamortizestheoperationaloverheadofrunninginferenceinfrastructure.
• Coststructure: highﬁxedcosts(GPUreservations,MLOpsteam,evaluationinfrastructure)
pluslowmarginalcostperrequest.
• Break-even: depends on model size, GPU type, utilization, latency requirements, redun-
dancy,staffcost,andopportunitycost. Modelthisexplicitlyforyourworkloadratherthan
relyingonrulesofthumb.
• Risk: rapid model obsolescence. A self-hosted model that was state-of-the-art six months
agomayunderperformacheapercloudAPImodeltoday.
Buy (cloud API).
• Bestfor: variable-volumeworkloads,experimentation,orworkloadswhereyouwanttoride
thefrontierwithoutoperatingit.
17

<!-- page 18 -->
• Coststructure: lowﬁxedcosts,highmarginalcostpertoken,fullelasticity.
• Break-even: typicallyremainsfavorableuntilvolumeforcesthebuildconversation.
• Risk: vendor pricing changes, rate limits, and the loss of competitive advantage if your
uniquecapabilityisjust“callingthesameAPIeveryoneelsecancall.”
Subscribe (per-seat AI products).
• Best for: knowledge worker enablement (coding assistants, document analysis, internal
Q&A)wheretheuser,notthesystem,istheunitofvalue.
• Coststructure: predictableper-seatcost,reducedmarginaltokenaccountingvisibilitytothe
internalteam(thoughsubscriptionsoftenhaveusagecapsorfair-usepolicies),minimalen-
gineeringinvestmentbeyondintegration.
• Break-even: oftenfavorablefortypicalknowledgeworkerworkloadswhereannualsubscrip-
tioncostisdwarfedbyproductivitygain.
• Risk: subscription pricing has changed multiple times per year for many vendors. Ruzga
notes that AI subscription pricing volatility makes long-term TCO modeling brittle (Ruzga
2026).
Figure 29.3: Build-buy-subscribe decision factors: each option has distinct cost structures, risks, and recon-
sideration triggers.
29.11.2 Annual review as the operational discipline
Because the underlying economics shift frequently (new models, new pricing, new capabilities),
thebuild-buy-subscribedecisionrequiresanannualreview. ForeverymaterialAIworkloadabove
adeﬁnedspendthreshold,theAIInvestmentCouncilshouldask:
1. Hastheworkload’svolumeproﬁlechangedenoughtocrossabreak-evenboundary?
2. Have vendor prices, available models, or subscription terms changed enough to invalidate
thepriordecision?
18

<!-- page 19 -->
3. Hastheworkload’sstrategicimportancechanged(commoditycapabilityversusdifferentiat-
ingcapability)?
4. Doesourinternalteamhavethecapacitytooperatethealternativeweareconsidering?
Thedisciplineistoconﬁrmeveryyearthatthecurrentposturestillholdsup.
19

<!-- page 20 -->
Most
20

<!-- page 21 -->
years, the answer will be yes. The annual review prevents the rare year where the answer is no
frombeingmissedforthreeyears.
29.12 Cost-Performance Tradeoffs and Governance
Costdecisionsinvolvetradeoffsamongreliability,performance,fairness,andtime-to-market,and
those tradeoffs require governance visibility. The metric pyramid from Chapter 26 is the tool for
evaluatingthem: everycostoptimizationisabase-layerchangethathastosurvivethetriptothe
top.
29.12.1 The Metric Pyramid as Cost-Optimization Discipline
Costpercalllivesatthebaseofthepyramid,nexttolatencyandaccuracy. Everybase-layercost
optimizationshouldbeevaluatedbytraversingthepyramidupward: doesthisoptimizationpre-
serve or improve the output layer, the user-experience layer, and the business-metric layer? If a
base-layercostwindoesnotpropagate,itisdecorative. Ifabase-layercostwinproducesafairness
or trust degradation at the user-experience layer, it is harmful. The pyramid discipline prevents
themostcommonAIcostmistake: declaringvictoryatthecostdashboardwithoutcheckingwhat
happenedatthecustomer.
Figure 29.4: The metric pyramid: every base-layer cost optimization must propagate through output, user
experience, and business metrics to be valid.
Illustrative example: -Baselayer: switchoffergenerationtosmallermodel,costdown40percent.
21

<!-- page 22 -->
-Outputlayer: grammarandpolicycomplianceunchanged,personalizationscoredown3percent.
- User layer: click-through rate down 6 percent. - Business layer: gross margin lift disappears. -
Decision: optimizationrejecteddespitelowercost.
Inpractice,traversingthepyramidmeansthreethings:
1. Beforedeployinganoptimization,runtheevaluationsuitethatmeasuresthemodel-output
anduser-experiencelayers,notjustthecost-per-callmetric.
2. Afterdeploying,monitorbusiness-metriclayersforatleastonefullbusinesscycletoconﬁrm
propagation.
3. Documentthepropagationevidenceinthemodelcardalongsidetheoptimizationdecision
(Mitchelletal. 2019).
29.12.2 The four tradeoff axes
Cost versus performance. Cheaper models produce lower-quality outputs. Model compression
reducesaccuracy. Whatmattersistheminimumperformancelevelacceptableforthisusecase,and
what it costs to meet that level. For low-stakes use cases, the minimum acceptable performance
maybeachievablewithamuchcheapermodelthantheteamiscurrentlyusing.
Cost versus resilience. Redundancy costs money: multi-region deployments, hot standby mod-
els, redundant data pipelines, fallback chains (see Chapter 28). The cost of redundancy must be
weighedagainstthecostofdowntime(SLObreachpenalties,lostrevenue,reputationaldamage).
Calculatetheexpectedcostofdowntimebeforedecidingthatthecostofredundancyistoohigh.
Cost versus time-to-market. Managedservicescostmorethanself-hosted, butshipfaster. Over-
optimizing for cost at build time extends time-to-value. The right time to optimize is after the
systemisproveninproduction. Thebuild-buy-subscribeannualreview(above)istherightplace
torevisitthisaxis.
Cost versus fairness. Some fairness interventions add cost: reweighting training data, running
fairness-awareinference,andmaintainingmultiplemodelversionsfordifferentdemographiccon-
texts. Forregulatedindustriesorhigh-risksystems,thesecostsarearequiredpartofresponsible
operation. Fairnesscostsbelonginthegovernance-approvedbudget,nottheengineeringteam’s
discretionaryoptimizationtarget.
29.12.3 Governance decision rules
Tomakegovernancerequirementsconcrete:
• No governance review required: Infrastructure-only changes with no model behavior im-
pact(instancerightsizing,storagetiering,devenvironmentscheduling).
• Product owner approval: LatencyorcostchangeswithinSLOandqualityguardrails.
• AI Governance Board review: Changes affecting fairness, regulated decisions, safety,
customer-facingcontentquality,orapprovedriskposture.
• AI Investment Council review: Portfolio spend reallocation, system renewals, decommis-
sioningdecisions,orbuild-buy-subscribechangesabovethreshold.
Cost efﬁciency targets for AI systems are set by the AI Governance Board in collaboration with
Finance, the AI InvestmentCouncil, and the AI Product Owner. An annual cost-versus-value re-
view is required for every AI system above a deﬁned spend threshold: is the cost proportionate
22

<!-- page 23 -->
Figure 29.5: Cost decision governance tiers: escalation requirements based on scope and impact of the pro-
posed change.
23

<!-- page 24 -->
to the business value being delivered? Systems that fail this review should either be redesigned,
re-scopedwithaclearimprovementplan,ordecommissioned.
29.13 Use Case: Retail Customer Acquisition and Retention
The retail AI platform we have followed through prior chapters now needs a coherent cost dis-
cipline. The platform runs three production systems: a churn prediction model that scores active
customersmonthly,a recommendation engine thatpersonalizesthehomepageandemailcampaigns,
andan offer generation systemthatusesalargelanguagemodeltodraftpersonalizedpromotional
copy. Eachsystemhasadifferentcostproﬁle.
29.13.1 Cost structure mapping
Workingthroughthesixcategoriesfortheplatformasawhole:
• Compute. Amazon SageMaker training runs for churn and recommendation (monthly re-
trainonthechurnmodel,weeklyonrecommendation),SageMakerinferenceendpointsfor
both,andAmazonBedrockinvocationsforoffergeneration. Estimatedproductionscalefor
computeacrossallthreesystems: $35,000permonth,ofwhichapproximatelytwo-thirdsis
inferenceandone-thirdistraining.
• Storage. Amazon S3 for raw transaction data, the Feature Store, model artifacts, and a 90-
daylogretentionwindow. AmazonOpenSearchforvectorembeddingsbackingrecommen-
dation similarity search. Estimated production scale: $9,000 per month, growing 10 to 15
percentperquarter.
• Networking. Inter-service egress, CDN for the recommendation endpoint’s edge cache,
cross-AZtrafﬁcfortheOpenSearchcluster. Estimatedproductionscale: $4,000permonth.
• Managed services. BedrockAPIforoffergeneration,AmazonCloudWatchformonitoring,
MLOpsplatformtooling,andvectordatabasesubscriptionbeyondwhatOpenSearchcovers.
Estimatedproductionscale: $32,000permonth,dominatedbyBedrockLLMspend.
• Engineering labor. 3MLengineers,1dataengineer,0.5platformengineer,0.25governance
and compliance time. At fully-loaded cost, roughly $80,000 per month attributed to this
platform. Note: thisistrackedseparatelyfrominfrastructurecostsintheannualreview.
• Operational support. On-call rotation for the three engineers, monthly retraining cycles,
weeklyevaluationruns, modelcardmaintenance, quarterlyfairnessaudits. Estimatedpro-
ductionscale: $15,000permonthincludingallocatedSREtime.
Infrastructuresubtotal(excludinglabor): approximately$95,000permonth. Totalincludinglabor
andoperationalsupport: approximately$175,000permonth.
29.13.2 Cost model for offer generation
Theoffergenerationsystemisthehighest-variancesystemontheplatform. Hereisthecostmodel
withexplicitassumptions:
Assumptions: - Average prompt: 1,800 tokens (1,400 token system prompt + 400 tokens of cus-
tomer context) - Average completion: 220 tokens - Production volume: 95,000 requests per day
(2.85Mrequestspermonth)-Bedrockpricing: $Xpermillioninputtokens,$Ypermillionoutput
tokens(consultcurrentBedrockpricingforyourmodelchoice)
Formula:
24

<!-- page 25 -->
Figure 29.6: Monthly cost breakdown for the retail AI platform showing infrastructure costs and total costs
including engineering labor. 25

<!-- page 26 -->
Monthly cost = requests × [(input_tokens / 1M × input_price) +
(output_tokens / 1M × output_price)] ×
cache_adjustment × retry_multiplier
29.14 Key Takeaways
• AIcostdisciplinemeansspendingintentionally,withcostsvisible,attributable,andpropor-
tionatetobusinessvaluedelivered(J.R.StormentandMikeFuller2023).
• The full cost structure of enterprise AI spans six categories: compute, storage, networking,
managed services, engineering labor, and operational support. Engineering labor is often
thelargestcostandtheleasttracked(Sculleyetal. 2015).
• At$1.5trillionin2025risingto$2.5trillionin2026forworldwideAIspending,costdiscipline
isaboard-levelconcern(Gartner2025).
• Cost estimation belongs in the solution design phase. Architectural decisions made early
lockincostcurvesthataredifﬁculttochangelater(Huyen2022).
• The FinOps Foundation’s 2025 framework extends cost discipline beyond public cloud to
include AI as a ﬁrst-class Scope, with six named capabilities: allocation, forecasting, unit
economics, policy and governance, practice operations, and education (Markanastasakis et
al. 2025;FinOpsFoundation2025).
• LLM-speciﬁc optimizations, including prompt caching and model compression through
pruning, distillation, and quantization, can produce substantial cost reductions when
calibratedagainstyouractualworkload(Anthropic2026;NVIDIA2025).
• The build-versus-buy-versus-subscribe decision should be framed as “intelligence per dol-
lar”andrevisitedannually,becauseunderlyingeconomicsshiftfrequentlywithnewmodels,
pricing,andcapabilities(Ruzga2026).
• Every cost optimization should traverse the metric pyramid: base-layer cost wins that do
not propagate through model output, user experience, and business metrics are decorative
atbestandharmfulatworst(El-MhamdiandHoang2024).
• Cost efﬁciency targets require governance oversight. The AI Governance Board reviews
tradeoffs affecting fairness, safety, or risk posture; the AI Investment Council reviews
portfolio-levelspendallocationanddecommissioningdecisions.
29.15 Apply It
1. Map your cost structure. ForoneproductionAIsystem(ortheretailplatformifworkingwith
thebook’susecase),documentthecurrentspendacrossallsixcostcategories. Identifywhich
categories are tracked today and which are estimated or untracked. Use the production-
readinessrubricdimensionsfromBreckandcolleaguesasachecklistforcostandefﬁciency
coverage(Brecketal. 2017).
2. Calculate unit economics. Forthesamesystem,computeatleastonecost-per-unit-of-output
metric: cost per prediction, cost per recommendation, cost per generated offer, or cost per
26

<!-- page 27 -->
attributed dollar of revenue. Compare this to your current budget reporting, which likely
showsonlyaggregatespend.
3. Build a cost estimate for a new workload. Usingthecostestimationformulasinthischap-
ter,buildathree-tierestimate(prototype,pilot,production)foranewAIcapabilityyouare
considering. Include a 30 to 50 percent buffer and explicitly state your assumptions about
trafﬁcvolume,tokencounts,anditerationoverhead.
4. Audit tagging compliance. Review your current AWS resource tagging for AI workloads.
Identify resources that lack the required cost allocation tags (project, team, environment,
model,costowner). Proposearemediationplanwithatimelineforenforcement.
5. Traverse the metric pyramid for a proposed optimization. Selectonecostoptimizationyou
are considering (for example, switching to a smaller model, enabling prompt caching, or
reducingevaluationfrequency). Documenthowyouwillmeasuretheimpactateachlayerof
themetricpyramid: modelandsystem,modeloutput,userexperience,andbusinessmetric.
Identifywhichlayeryoulackmeasurementfortoday.
6. AI prompt exercise. Use the following prompt template with your own system’s cost data
togenerateaﬁrst-passannualcost-versus-valuereviewsummary:
You are helping me prepare an annual cost-versus-value review for an AI system.
System name: [YOUR SYSTEM NAME]
Monthly infrastructure cost (excluding labor): [AMOUNT]
Monthly cost including labor and operational support: [AMOUNT]
Primary business metric the system supports: [METRIC NAME]
Current measured value of that metric: [VALUE]
Attribution method used: [e.g., A/B test, holdout group, correlation only]
Based on this information:
1. Calculate the implied cost per unit of the business metric.
2. Identify the largest cost category and suggest one optimization to investigate.
3. Flag any attribution weakness that would require a stronger causal method before the next review.
4. Recommend whether this system should continue, be redesigned, or be considered for decommissioning, with reasoning.
UsetheAI’soutputasaﬁrstdraftforthereviewdocument;bringittotheAIInvestmentCouncil
withyourownannotationsandthecostowner’sresponse.
29.16 What’s Next
CostdisciplineensuresAIsystemsareeconomicallysustainable,butsustainabilityisnotthesame
asvalue. Asystemcanbecost-efﬁcientandstillfailtojustifyitsexistence;anothercanbeexpen-
siveandstillpayforitselftentimesover. Thenextchapter, Measuring Business Value: Closing the
Gap Between What AI Does and What the Business Needs,closesthelooponthequestionthatcostop-
timizationalonecannotanswer: isthemoneybeingspentonAIactuallygeneratingproportionate
business value, and how do you measure that with enough rigor to drive renewal, redesign, or
decommissioning decisions? The pyramid traversal applied here to cost becomes the attribution
disciplineinthenextchapter,wherebottom-upveriﬁcationtestswhethertechnicalimprovements
actuallypropagatetobusinessoutcomes.
27

<!-- page 28 -->
29.17 References
Anthropic. 2026. Prompt Caching. Https://docs.anthropic.com/en/docs/build-with-claude/prompt-
caching;AnthropicDocumentation.
Aryan,Abi. 2025. LLMOps: Managing Large Language Models in Production. O’ReillyMedia.
Breck, Eric, Shanqing Cai, Eric Nielsen, Michael Salib, and D. Sculley. 2017. “The ML Test Score:
ARubricforMLProductionReadinessandTechnicalDebtReduction.” 2017 IEEE International
Conference on Big Data (Big Data),1123–32.
Chang,Yupeng,Qiang,Yang,XuWang,etal. 2024. “ASurveyonEvaluationofLargeLanguage
Models.” ACM Transactions on Intelligent Systems and Technology,aheadofprint. https://doi.or
g/10.1145/3641289.
El-Mhamdi,El-Mahdi,andLê-NguyênHoang. 2024. On Goodhart’s Law, with an Application to Value
Alignment. https://doi.org/10.48550/arXiv.2410.09638.
FinOpsFoundation. 2025. FinOps for AI - FinOps Framework Technology Category. Https://www.ﬁnops.org/framework/technology-
categories/ai/;FinOpsFoundation.
Gartner. 2025. Gartner Says Worldwide AI Spending Will Total $1.5 Trillion in 2025. Gartner.
Grace,Mikaela,JeremyHadﬁeld,RodrigoOlivares,andJiriDeJonghe. 2026. Demystifying Evals for
AI Agents. Https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents; An-
thropicEngineeringBlog.
Hu, Edward J., Yelong Shen, Phillip Wallis, et al. 2022. “LoRA: Low-Rank Adaptation of Large
LanguageModels.” International Conference on Learning Representations (ICLR).https://doi.or
g/10.48550/arXiv.2106.09685.
Huyen, Chip. 2022. Designing Machine Learning Systems: An Iterative Process for Production-Ready
Applications. O’ReillyMedia.
J.R. Storment and Mike Fuller. 2023. Cloud FinOps: Collaborative, Real-Time Cloud Value Decision
Making. 2ndEdition. O’ReillyMedia.
Kazmierczak, Jarek, Khalid Salama, and Valentin Huerta. 2024. MLOps: Continuous Delivery
and Automation Pipelines in Machine Learning. Https://cloud.google.com/architecture/mlops-
continuous-delivery-and-automation-pipelines-in-machine-learning; Google Cloud Architec-
tureCenter.
Markanastasakis, Vasilio, Rob Martin, Mike Fuller, Amber Gregorio, and J. R. Storment. 2025.
FinOps Framework 2025. Https://www.ﬁnops.org/insights/2025-ﬁnops-framework/; FinOps
Foundation.
Mitchell,Margaret,SimoneWu,AndrewZaldivar,etal. 2019. “ModelCardsforModelReporting.”
Proceedings of the Conference on Fairness, Accountability, and Transparency (FAccT),220–29. https:
28

<!-- page 29 -->
//doi.org/10.1145/3287560.3287596.
NVIDIA.2025. “TheGood,theBad,andtheUgly: Cost-EfﬁcientLLMInferenceWithQuantization,
Pruning,andDistillation.” NVIDIA GTC San Jose 2025.
Patel, Dylan, and Afzal Ahmad. 2023. The Inference Cost of Search Disruption — Large Language
Model Cost Analysis. Https://newsletter.semianalysis.com/p/the-inference-cost-of-search-
disruption;SemiAnalysis.
Ruzga,Eduard. 2026. Local LLMs Vs Cloud APIs Vs Subscriptions: Which Buys the Most Intelligence
Per Dollar? Https://wonderwhy-er.medium.com/local-llms-vs-cloud-apis-vs-subscriptions-
which-buys-the-most-intelligence-per-dollar-7365e3d9eae1;Medium.
Saltonstall, Max, and Salim Virji. 2025. An SRE’s Guide to Optimizing ML Systems with MLOps
Pipelines. Https://cloud.google.com/blog/products/devops-sre/applying-sre-principles-to-
your-mlops-pipelines;GoogleCloudBlog.
Sculley,D.,GaryHolt,DanielGolovin,etal. 2015. “HiddenTechnicalDebtinMachineLearning
Systems.” Advances in Neural Information Processing Systems (NeurIPS) 28: 2503–11.
Serve Many LoRA Adapters from One Endpoint with Hugging Face vLLM ⋅ Hugging Face. n.d.
Https://huggingface.co/docs/sagemaker/examples/sagemaker-sdk-multi-lora-adapters-
vllm.
StanfordInstituteforHuman-CenteredArtiﬁcialIntelligence(HAI).2025. The 2025 AI Index Report
— Chapter 3: Responsible AI.StanfordInstituteforHuman-CenteredArtiﬁcialIntelligence(HAI).
Thurgood,Steven,DavidFerguson,AlexHidalgo,andBetsyBeyer. 2018. “ImplementingSLOs.”
In The Site Reliability Workbook: Practical Ways to Implement SRE.O’ReillyMedia.
29