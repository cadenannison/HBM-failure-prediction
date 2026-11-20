# Ch28-Reliability-Engineering.pdf (extracted text, 28 pages)

<!-- page 1 -->
Chapter 28
Reliability Engineering—Building AI
Systems That Hold Under Pressure
28.1 Motivation
Considerarepresentativecase. Amajorbank’sAI-poweredfrauddetectionsystemgoesdownforfour
hours during peak transaction volume. The model itself keeps working; the failure sits upstream, in a
featurepipelinethatunderwentaschemachangenoonehadcoordinatedwiththemodelteam. Trans-
actionswentthroughwithoutfraudscoring. Losseswerecontainedonlybecauseaparallelrules-based
systemwasstillrunning,andnoonecaughtthefailureuntilacomplianceofficernoticedthemonitoring
dashboardhadgoneblank.
ThisisthereliabilityprobleminAI:asystemcanfailwithoutacrash,analert,oranythingturningredona
dashboard. Theresponsethatfollowedwasimprovised,becausenoonehadwrittenarunbook,defined
anescalationpath,ornamedanowner. Recoverytookfourhoursforafixthatshouldhavetakentwenty
minutes. Thegapwasreliabilityengineering,thedisciplineofdesigningsystemsandprocessessothat
failuresarecontained,detectedfast,andresolvedfaster.
Reliability is what separates AI demos from AI systems. A demo runs on a happy path with carefully
selected inputs. A production system runs on every input, every minute, for years, and must continue
producingusefuloutputswhiletheworldarounditkeepschanging. Upstreamdatasourcesmutate,traf-
ficpatternsshift,modelsdrift,dependenciesupdate,andusersprobeedgestheteamneveranticipated.
Withoutexplicitreliabilityengineering,thesystem’smeantimebetweenembarrassmentsshortenswith
age. Withit,thesystemtoleratestheconstantlow-gradechaosofproductionandrecoverscleanlywhen
somethinggenuinelybreaks.
Forseniorexecutives,thepracticalimplicationisdirect:AIreliabilityisaboard-levelconcernlongbefore
itbecomes a board-levelincident. Regulators, auditors, and enterprisecustomers increasinglyexpect
documentedevidencethatyourAIsystemsareoperatedwiththesamedisciplineasanyothertier-one
service. TheNISTAI600-1GenerativeAIProfile(Autioetal.,2024)addressesriskmanagementpractices
thatinformAIoperationaldiscipline,andAWS’sWell-ArchitectedReliabilityPillar(AmazonWebServices,
2024)givesreliabilityoperationalformforcloudworkloads. ThewindowinwhichAIcouldbetreatedas
anexceptiontoenterprisereliabilitystandardsisclosed.
28.2 Challenge
How do you apply site reliability engineering principles to AI systems, which have failure modes tradi-
tionalsoftwaredoesnothave,sothatproductionincidentsaredetectedquickly,containedbeforethey
causeseriousharm,resolvedwithdiscipline,andclosedwithlearningsthatpreventrecurrence?
653

<!-- page 2 -->
28.3 Objectives
Bytheendofthischapter,youwillbeableto:
1. DefineSLAs, SLOs, anderrorbudgetsforAIsystemsandexplainhowtheydifferfromtraditional
softwarereliabilitytargets.
2. IdentifythefailuremodesspecifictoAIinproduction,includingmodeldegradation,pipelinefail-
ures,latencyspikes,hallucinationevents,andagentmisbehavior.
3. Designanincidentresponseprocess(detection,escalation,containment,rootcauseanalysis,and
postmortem)tailoredforAIsystems.
4. Buildrunbooksthatenablefast,consistentresponsetothemostcommonAIfailuremodes.
5. ApplychaosengineeringprinciplestodeliberatelysurfaceAIfailuremodesbeforeusersdo.
6. Establishrollbackproceduresformodels,pipelines,prompts,andagentconfigurations.
7. Position reliability as a shared responsibility across engineering, operations, product, and gover-
nance.
8. Implement AWS-native reliability architecture using CloudWatch, SageMaker, Bedrock, Systems
Manager,andrelatedservices.
28.4 Interface with the Previous Chapter
Reliabilityengineeringstartsfromtheresiliencedesigncommittedbeforego-liveinChapter24:SLAand
SLOtargets, thedegradationchain, circuitbreakers, redundancylevel, andatestedDRrunbook. This
chapteroperatesandextendsthatdesign. Italsodependsontheobservabilityfoundationestablished
inChapter27,fromwhichitreceives:
• Service dashboards and alert rules. CloudWatch metrics, alarms, and dashboards that surface
availability,latency,andthroughputdegradation.
• SLI definitions and tracking. Thespecificmeasurements(inferencelatencypercentiles,errorrates,
data freshness) defined in the monitoring chapter serve as inputs to the SLOs established in this
chapter.
• Model quality monitors. EvidentlyAIoutputs,BedrockGuardrailsviolations,andcustomquality
metricsthatdetectsilentdegradation.
• Tracing and correlation IDs. X-RaytracesandOpenTelemetryspansthatallowincidentresponders
toreconstructrequestpathsduringrootcauseanalysis.
• Escalation signals. Thealertthresholdsandnotificationchannelsthatconnectmonitoringtoinci-
dentresponse.
Monitoringdetectswhenthingsgowrong. Thischaptercoverswhatyoudoaboutit: thearchitecture,
runbooks,andincidentprotocolsthatdeterminehowfastyoucancontain,diagnose,andrecoverfrom
productionfailures.
28.5 A Simple Model for AI Reliability
BeforedivingintoSREterminology,ithelpstoestablishaframe. AIreliabilitybreaksintofourthingsthat
mustworktogether:
1. Infrastructure reliability. Thecompute,storage,networking,andorchestrationlayersthathostAI
workloads. TraditionalSREcoversthiswell.
Build: 2026-11-0419:48 654

<!-- page 3 -->
2. Data reliability. Thepipelines,featurestores,andretrievalindexesthatfeedmodels. Datafailures
areinvisibletoinfrastructuremonitoring.
3. Model quality reliability. Theaccuracy,calibration,fairness,andbehavioralcorrectnessofmodel
outputs. Amodelcanbeavailableandfastwhileproducingwronganswers.
4. Governance and response reliability. Theprocesses,runbooks,andescalationpathsthatensure
incidentsarehandledconsistentlyandlearningsarecaptured.
Eachlayercanfailindependently. Acompletereliabilityprogramaddressesallfour.
28.6 SRE Principles Applied to AI Systems
SiteReliabilityEngineering,developedatGoogleandcodifiedinBeyeretal. (BetsyBeyer,ChrisJones,
JenniferPetoff,andNiallRichardMurphy,2016),providestheconceptualfoundationforreliablyoperat-
ingproductionAIsystems. Thecoreprinciplesapply,withimportantmodificationsforAI’suniquefailure
modes. AWS’sWell-ArchitectedReliabilityPillar(AmazonWebServices, 2024)expressesthesameun-
derlyingdisciplineincloud-nativeterms,organizedaroundfourpracticeareas: Foundations,Workload
Architecture,ChangeManagement,andFailureManagement. Citingbothmakesausefulpointforex-
ecutives: reliability principles are platform-agnostic. What changes between Google and AWS is the
vocabularyandtooling;thedisciplineunderneathstaysthesame.
28.6.1 SLIs, SLOs, SLAs, and Error Budgets
Thevocabulary,drawnfromThurgoodetal. (Thurgoodetal.,2018)andnowstandardintheindustry,is
theentrypoint. Thelogicalordermattersforunderstanding:
• Service Level Indicator (SLI). Theactualmeasurement: thep99latencyvalue,theerrorrate,and
therecallscore. Whatyoumeasure.
• Service Level Objective (SLO). The internal target that the SLI should meet. Example: internal
targetofp99latencyunder300milliseconds.
• Service Level Agreement (SLA). The external commitment: what the system promises to cus-
tomersordownstreamservices. UsuallylooserthantheSLO,givingengineeringabuffer.
• Error budget. The allowed amount of unreliability in a given period. If the SLO is 99.9 percent
availability,theerrorbudgetis0.1percent,roughly43minutespermonth. Whentheerrorbudget
isconsumed,newdeploymentspauseuntilreliabilityisrestored.
The 100 percent uptime target is an anti-goal. It is impossible to achieve, expensive to attempt, and
crowdsoutotherengineeringinvestments(Thurgoodetal.,2018). Theerrorbudgetformalizesabasic
truth: someunreliabilityisacceptable,andtherightpolicyquestionishowtospendit.
28.6.2 Why AI Systems Require Modified SRE Thinking
TraditionalSREcommonlyemphasizesavailability,latency,throughput,anderrorrate. AIsystemsadda
criticaldimension: quality. Thatqualitydimensionistheonemostlikelytofailsilently. Themodelcan
be available and fast while producing wrong outputs. The infrastructure dashboard stays green while
the business outcome deteriorates unnoticed. Sculley et al. (Sculley et al., 2015) argued more than a
decadeagothatMLsystemscarryhiddendebtthatconventionalengineeringpracticesdonotsurface.
Reliabilityengineeringiswherethatdebtcomesdue.
Theimplicationisconcrete:
• Errorbudgetsmustaccountformodelqualitydegradation,notjustinfrastructuredowntime.
• AISLOsneedanadditionaltierofqualitySLOs(minimumacceptableaccuracy,fairnessconstraints,
confidencefloor)alongsideavailabilityandlatencySLOs.
Build: 2026-11-0419:48 655

<!-- page 4 -->
Figure 28.1: The four layers of AI reliability, each of which can fail independently and requires distinct
monitoringandresponsestrategies.Build: 2026-11-0419:48 656

<!-- page 5 -->
Figure28.2: TherelationshipbetweenSLIs,SLOs,SLAs,anderrorbudgets,showinghoweachbuildson
thepreviousconcept.
Build: 2026-11-0419:48 657

<!-- page 6 -->
• Pipeline-layerSLOs(datafreshness, featurepipelinesuccessrate)arefirst-classindicators, notaf-
terthoughts. Saltonstall and Virji (Saltonstall & Virji, 2025) argue that these data-and-model SLIs
distinguishSREforMLfromSREforstatelessservices.
Aconsequenceseniorleadersshouldinternalize: riskinAIsystemsisasymmetric. Asmallprobabilityof
ahigh-severityqualityfailure(e.g.,afraudmodelthatsilentlystopsscoringoranLLMthathallucinates
customer-impactinginformation)oftenoutweighsahigherprobabilityofalow-severityavailabilityblip.
ErrorbudgetpolicyandSLOdesignshouldreflectthatasymmetry.
28.6.3 Understanding Quality SLOs
QualitySLOsdifferfromavailabilitySLOsinmeasurementcadenceandcomplexity. Thedistinctionmat-
tersoperationally:
Real-time proxy indicators canbemeasuredoneveryrequest:
• Predictiondistributionshift(statisticaldistancefrombaseline)
• Nullorinvalidfeaturerate
• RetrievalhitrateforRAGsystems
• Guardrailviolationrate
Near-real-time indicators requiresamplingorfeedbackcollection:
• Humanfeedbacksignals(thumbsup/down,corrections)
• Evalsuitereplayresults(runproductioninputsthroughtheevaluationharness)
• Confidencecalibrationchecks
Delayed indicators requireoutcomelabels:
• Churnrecall(requireswaitingforchurntooccur)
• Fraudprecision(requiresinvestigationoutcomes)
• Fairnessmetricsonoutcomes(requiresoutcomedatabydemographicsegment)
Forincidentresponse,delayedindicatorsareinsufficient.Youcannotwaitsixweekstolearnthatchurnre-
calldropped. Thereliabilityprogrammustdefinereal-timeproxiesthatcorrelatewithdelayedoutcomes
andperiodicallyvalidatethatcorrelation.Whentheproxydrifts,youinvestigate;whenthedelayedmetric
confirmsthedrift,youknowyourproxyworks.
CaveatsforqualitySLOdesign:
• Label delay. Ifgroundtruthtakesweekstoarrive,yourqualitySLOmustrelyonproxymetricsfor
alertinganddelayedmetricsforvalidation.
• Statistical confidence. Qualitymetricsrequiresamplesizes. Adailyfairnesscheckonasegment
with50observationsperdaywillbenoisy. Defineminimumsamplesizesandconfidenceintervals.
• Seasonality and confounds. Click-throughratevarieswithmarketingcampaigns,inventory,and
seasonality. QualitySLOsmustaccountforexpectedvariation.
• Fairness metric selection. Demographicparityisnotuniversallyappropriate. Dependingonthe
usecase,equalopportunity,calibrationbygroup,orharm-basedmetricsmaybemoredefensible
legallyandtechnically.
28.6.4 Defining AI-Specific SLOs
Build: 2026-11-0419:48 658

<!-- page 7 -->
Figure28.3: QualitySLOindicatorsorganizedbymeasurementcadence,withreal-timeproxiesproviding
thealertingfoundation.
Build: 2026-11-0419:48 659

<!-- page 8 -->
Table28.1: AI-SpecificServiceLevelObjectives.
SLOType ExampleTarget Measurement Cadence
Availability 99.9%uptime SuccessfulAPI
responses/total
requests
Real-time
Latency p99<300ms Percentileofresponse
times
Real-time
Quality(proxy) Distributiondrift<0.1
PSI
Populationstability
index(Yurdakul&
Naranjo,2020)
Hourly
Quality(delayed) Churnrecall≥70% Monthlygroundtruth
evaluation
Monthly
Fairness Demographicparity
±5%
Weeklysliceevaluation Weekly
Pipelinefreshness Features<2hoursstale Datapipeline
monitoring
Per-batch
Dataquality Schemavalidationpass
rate≥99.99%
Per-batchvalidation
gates
Per-batch
Evalpassrate(LLM) ≥95%onproduction
evalsuite
Dailyevalharness Daily
Theeval-pass-rateSLOdeservesspecialnote. Graceetal. (Graceetal.,2026)arguethatevalsfunction
asthepre-launchlineofdefense,andproductionevalmonitoringisthepost-launchbackstop. ForLLM
andagentsystems,theevalsuiteistheclosestanalogtoaregressiontestsuite,thoughwithanimportant
caveat: LLMevalsareoftenstatistical,nondeterministic,andcoverage-limited. Theyarenotequivalent
todeterministicunittestsandcancreatefalseconfidenceiftreatedassuch. Trackevalpassrateasan
SLO,butunderstandwhattheevalsdoanddonotcover.
28.6.5 Error Budget Policy for Quality Degradation
Standard error budget policy governs availability. Quality error budgets require their own policy. An
example:
• Maximum1percentofrecommendationsmayviolatecontentpolicyguardrailspermonth.
• Maximum5percentrelativedropinqualityproxymetrics(distributiondrift,retrievalhitrate)overa
rollingweeklywindow.
• Ifevalsuitepassratefallsbelow90percentoncriticaltestcategories,deploymentfreezeonprompt
ormodelchanges.
• QualitySLOconsumptiontriggersdifferentremediationpaths(retraining,rollback,governancees-
calation)thanavailabilityconsumption.
Whenmorethan50percentofanymonthlyerrorbudgetisconsumed,deploymentfreezeonnon-critical
changes. When 100 percent is consumed, full deployment freeze; reliability work takes priority over
feature work. Error budget burn-rate alerts warn when the current consumption rate will exhaust the
budgetbeforemonth-end.
Kazmierczaketal. (Kazmierczaketal.,2024)situatethisdisciplinewithinMLOpsmaturity: Level0organi-
zationscannotenforceerrorbudgetsbecausetheycannotdeployquicklyenoughtofeelthecost;Level
1andbeyondmakeerrorbudgetpolicymeaningfulbygivingtheteamacredibledeploymentcadence
totradeagainst.
Build: 2026-11-0419:48 660

<!-- page 9 -->
28.6.6 Chaos Engineering for AI Systems
Detectingfailuremodesafterusersfindthemistoolate. Chaosengineering, formalizedbyRosenthal
and Jones (Rosenthal & Jones, 2020) from the Netflix discipline that produced Chaos Monkey, inverts
thetiming: deliberatelyinjectfailuresintoproduction-likesystemsinacontrolledway,observehowthe
systemresponds,andhardenitbeforerealfailuresoccur. ThePrinciplesofChaosmanifestoframeseach
experimentasahypothesis(“ifdependencyXdegrades,thesystemwillgracefullyfallbacktoY”),and
eitherconfirmsthehypothesisorsurfacesarealreliabilitygap.
For AI systems, chaos engineering must extend beyond infrastructure faults to model and data faults.
Usefulexperimentcategoriesinclude:
• Data perturbation drills. Injectschemadriftorfeaturestalenessintoashadowpipeline.Verifythat
validationgatescatchitandthattherunbookactivatesthedocumentedfallback.
• Adversarial prompt drills. Replayknownprompt-injectionpatternsfromtheOWASPLLMTop10
(OWASPGenAISecurityProject, 2026)againstguardedendpoints. Verifythatoutputfiltershold
andthattheabusesignalreachestheon-callrotation.
• Simulated drift drills. Inject synthetic distribution shifts into the production traffic mirror. Verify
thatqualitySLOalertsfirewithintheexpectedlatency.
• Agent tool-call failure drills. Forcetoolendpointsusedbyautonomousagentstoreturnerrors,
malformedpayloads,orunexpectedlatency. Verifythattheagentdoesnotloop,retryindefinitely,
orescalateprivileges.
• Dependency degradation drills. Throttle the feature store, the vector database, or the model
endpoint. Verifygracefuldegradationratherthancascadinglatency.
AWSprovidestoolingforchaosexperiments. AWSFaultInjectionService(FIS)supportscontrolledfault
injection for EC2, ECS, EKS, and RDS. For AI-specific drills, teams typically extend FIS with custom ac-
tionsoruseLambdafunctionsscheduledtoinjecttestdatawithknownanomaliesintopipelinestaging
environments.
Leadershipposturemattersasmuchastechnicalpractice.Chaosengineeringonlyworksinorganizations
thathavegivenengineersexplicitpermissiontobreakthingsinproduction-adjacentenvironments,and
thatinterprettheresultsasdataratherthanblame. Itworkslikeafiredrillforreliability: inmatureSRE
organizations,itrunsonacalendarratherthanonanadhocbasis.
28.7 AI-Specific Failure Modes
TraditionalSREhandlescrashes,resourceexhaustion,andnetworkfailures. AIsystemshavethoseplus
asetoffailuremodesthattraditionalreliabilityengineeringwasnotdesignedtocatch. Huyen(Huyen,
2022) and Breck et al. (Breck et al., 2017) catalog the classic ML failure modes; Aryan (Aryan, 2025)
arguesthattheLLMandagentlayersintroduceafurtherclassthattraditionalMLOpspracticesdonot
adequatelyaddress. Thetaxonomybeloworganizesthem.
28.7.1 Comparing Failure Modes Across AI System Types
Table28.2: FailureModeComparisonAcrossAISystemTypes.
FailureCategory ClassicML LLM/RAGSystems AgenticSystems
Primaryqualityfailure Silentdrift,calibration
loss
Hallucination,retrieval
failure
Goaldeviation,tool
misuse
Typicaldetectionlag Daystoweeks Minutestohours Secondstominutes
Feedbacksignal Delayedlabels Userreports,eval
failures
Actionoutcomes,
resourceconsumption
Build: 2026-11-0419:48 661

<!-- page 10 -->
FailureCategory ClassicML LLM/RAGSystems AgenticSystems
Containmentpattern Modelrollback,feature
fallback
Promptrollback,
guardrailactivation
Circuitbreaker,kill
switch
KeySLIfocus Accuracyproxies,
distributionstability
Evalpassrate,guardrail
violations
Taskcompletion,tool
callcounts
28.7.2 Model-Layer Failures
• Silent degradation. Modelaccuracydeclinesgraduallywithoutanyinfrastructurealert. Themost
dangerousfailuremodebecauseitisinvisiblewithoutactivequalitymonitoring.Gamaetal. (Gama
etal.,2014)classifytheunderlyingdrifttypes(conceptdrift,virtualdrift,abruptversusgradual)and
thedetectionstrategiesthatmatcheach.
• Confidence collapse. Modeloutputsbecomesystematicallyoverconfidentorunderconfident.Pre-
dictionsremaindirectionallycorrect,butcalibrationfails,andanydownstreamdecisionthatrelies
ontheprobability(suchasa“reviewifscoreabovethreshold”routingrule)becomeswrongwithout
warning.
• Catastrophic forgetting. After retraining, the model loses performance on previously handled
subpopulations.Commonwhenretrainingdataisnotrepresentativeofthepopulationtheprevious
modelserved.
• Feedback loop amplification. Modeloutputsinfluencefuturetrainingdata,creatingrunawayfeed-
backloops. Arecommendationmodelthatpromotespopularitemsgetstrainingdatadominated
bypopularitems,whichmakesthemodelrecommendevenmorepopularitems,shrinkingthedi-
versitythatoriginallymadethesystemuseful.
28.7.3 Pipeline Failures
• Schema drift. Upstreamdatasourcechangesafieldname,type,orencoding. Thepipelineeither
failsoutrightorsilentlypasseswrongdataforward.
• Feature staleness. Real-timefeaturesarenotrefreshedonschedule. Themodelreceivesoutdated
inputswithoutknowingit.
• Partial pipeline failure. Somefeaturescomputesuccessfullywhileothersfail. Themodelreceives
anincompletefeaturevectorandmakespredictionsonincompleteinformation.
• Training-serving skew resurgence. Pipelinecodechangesintroduceadifferencebetweenhow
featuresarecomputedattrainingtimeversusservingtime. Themodelperformsworseinproduc-
tionthanofflineevaluationpredicted,andthegapmaynotsurfaceforweeks.
28.7.4 Generative AI Failures
• Hallucination events. Model generates confident, plausible-sounding false information. Partic-
ularly high-risk in customer-facing applications where users may not have the domain context to
recognizetheerror.
• Prompt injection. Adversarialinputsmanipulatethemodelintoignoringitsinstructionsorproduc-
ingprohibitedoutputs. TheOWASPTop10forLLMApplications(OWASPGenAISecurityProject,
2026) catalogues this and related risks (excessive agency, data and model poisoning, improper
outputhandling)asthestandardthreattaxonomy.
• Context window overflow. Long-runningtasksorlargedocumentsexceedmodelcontextlimits,
silentlytruncatinginformationanddegradingoutputquality.
Build: 2026-11-0419:48 662

<!-- page 11 -->
Figure28.4: CategoriesofchaosengineeringexperimentsforAIsystems,extendingtraditionalinfrastruc-
turefaultinjectiontomodel-and-datafailuremodes.
Build: 2026-11-0419:48 663

<!-- page 12 -->
• Eval regression. Anewmodel,prompt,orRAGchangepassesmanualreviewbutfailstheproduc-
tionevalsuite. WithoutaqualitySLOgate(seeChapter22),theregressionreachesusers.
28.7.5 Agent-Specific Failures
AgenticsystemsextendtheLLMrisksurfacebecausetheyaddpersistentstate,delegatedauthority,tool
execution, and multi-step planning. The OWASP Top 10 for Agentic Applications (OWASP Gen AI Se-
curity Project, 2025) gives this class its first canonical taxonomy. The categories that matter most for
reliabilityengineeringare:
• Agent Behavior Hijacking. Adversarial inputs cause an agent to pursue goals other than its as-
signedobjective. Unlikepromptinjectioninasingle-turnLLM,theagentmaychainseveralactions
beforethedeviationbecomesvisible.
• Tool Misuse and Exploitation. Theagentcallsauthorizedtoolsinunintendedways:queryingAPIs
withabusiveparameters,performingdestructiveoperationstheuserdidnotrequest,leakingdata
throughtoolboundaries.
• Identity and Privilege Abuse. Theagentoperateswithdelegatedcredentialsandmayexercise
privilegestheuserdidnotintendtograntinthiscontext. Reliabilityandsecurityoverlaphere;the
responsepatternsdescribedinChapter21mustbecoordinatedwiththerunbookdescribedlater
inthischapter.
• Agent Runaway and Resource Exhaustion. Theagententersanactionloop(retry,toolcall,retry)
thatconsumescompute,APIquota,ordownstreamratelimits.Inpoorlyboundedsystems,runaway
agentscanrapidlyconsumecloudbudgetorexternalAPIquota.
The OWASP Agentic AI Threats and Mitigations publication (OWASP Agentic Security Initiative, 2025)
pairseachthreatcategorywithmitigationpatterns,includingcircuitbreakers,capabilityscoping,andkill
switches.
28.7.6 Latency and Throughput Failures
• Cold start latency. Inferenceendpointsthatscaletozerorequirewarm-uptimeonfirstrequest,
creatinglatencyspikesthatviolateSLOsduringtrafficramp-up.
• Cascading latency. A slow upstream dependency (feature store, vector database, external API)
causesinferencelatencytospikeacrossalldependentmodels.
• Memory leak in model serving. Gradualmemoryconsumptioninlong-runningservingprocesses
oftenmanifestsasslowlyincreasinglatencyoverdaysbeforecausingfailure.
28.8 AWS Reliability Architecture for AI Workloads
AWS is the primary cloud reference platform for this book. Implementing reliability for AI workloads
requiresmappingtheprinciplesabovetospecificAWSservicesandpatterns. Thefollowingarchitecture
providesareferenceforenterpriseAIreliability.
28.8.1 Monitoring and Alerting Layer
Amazon CloudWatch servesasthecentralobservabilityhub:
• Custommetricsformodelqualityindicators(predictiondistributionstatistics,featurefreshness,eval
scores)
• Alarmswithconfigurablethresholdsforavailability,latency,andqualitySLOs
• Dashboardscombininginfrastructureandmodelmetrics
Build: 2026-11-0419:48 664

<!-- page 13 -->
Figure28.5: QuickreferenceforAIfailuremodes,theirdetectionsignals,typicaldetectionlag,andpri-
marycontainmentactions.
• LogsInsightsforqueryinginferencelogsduringincidentinvestigation
Evidently AI providesmodel-specificmonitoring:
• Dataqualitymonitoringforfeaturedriftandschemavalidation
• Modelqualitymonitoring,comparingpredictionstogroundtruth
• BiasdriftmonitoringforfairnessSLOs
• Featureattributiondriftforexplainabilitymonitoring
Amazon Bedrock Guardrails providesLLM-specificprotection:
• Contentfilteringforharmfuloutputs
• Deniedtopicsenforcement
• PIIdetectionandredaction
• GuardrailviolationmetricspublishedtoCloudWatch
28.8.2 Incident Response Automation
Aconcreteworkflowforautomatedincidentresponse:
1. CloudWatch Alarm fireswhenSageMakerendpointp99latencyexceeds500msorerrorrateex-
ceeds2%.
2. Amazon EventBridge rulematchesthealarmstatechangeandroutestomultipletargets.
3. AWS Systems Manager Incident Manager createsanincidentrecordwithseverity,runbooklinks,
andengagementplan.
Build: 2026-11-0419:48 665

<!-- page 14 -->
4. Amazon SNS notifiestheon-callrotationviaPagerDutyorOpsgenieintegration.
5. AWS Step Functions orchestratesautomatedcontainment: evaluatesincidenttype,andifthresh-
oldcriteriaaremet,executestrafficshift.
6. Application Load Balancer or Amazon API Gateway weightedroutingshiftstrafficfromthepri-
maryendpointtothefallbackendpoint.
ThisworkflowcanbeprovisionedandmanagedthroughTerraform.Theinfrastructure-as-codeapproach
ensuresreliableinfrastructureisversioned,reviewable,andreproducible:
resource "aws_cloudwatch_metric_alarm" "endpoint_latency" {
alarm_name = "sagemaker-endpoint-p99-latency"
comparison_operator = "GreaterThanThreshold"
evaluation_periods = 2
metric_name = "ModelLatency"
namespace = "AWS/SageMaker"
period = 60
statistic = "p99"
threshold = 500
alarm_actions = [aws_sns_topic.incidents.arn]
dimensions = {
EndpointName = aws_sagemaker_endpoint.primary.name
VariantName = "AllTraffic"
}
}
28.8.3 Model Registry and Rollback Infrastructure
SageMaker Model Registry providesversionedmodelartifactswithapprovalworkflows:
• Modelpackageswithmetadataincludingtrainingdataversion,featurepipelineversion,andeval-
uationmetrics
• Modelpackagegroupsfororganizingrelatedmodelversions
• Approvalstatus(Pending,Approved,Rejected)fordeploymentgates
Forrollback,maintaindocumentedvalidpairsof(modelversion,featurepipelineversion)intheregistry
metadata. Arollbackoperationpromotesthepreviousapprovedmodelpackageandtriggerstheasso-
ciatedfeaturepipelineversiondeployment.
28.8.4 Agent Reliability Infrastructure
Foragenticworkloadsusing Amazon Bedrock AgentCore:
• Harnessversionsandnamedendpointsforrollbackcapability
• Gatewaytargetandtool-schemadefinitionsversionedininfrastructure-as-code
• KnowledgebaseversioningforRAGretrievalrollback
• CloudTrailloggingforallagentinvocationsandtoolcalls
• IAMroleswithminimalrequiredpermissions,scopedperagent
Agentkillswitchescanbeimplementedthrough:
• APIGatewayusageplanswithstrictthrottling
• LambdaconcurrencylimitsonGatewaytoolhandlers
Build: 2026-11-0419:48 666

<!-- page 15 -->
• AgentCorePolicyrulesthatforbidanagent’stoolcallsattheGateway
• StepFunctionsstatemachinetimeouts
• EventBridgerulesthatdisableagentendpointsoncircuitbreakersignals
28.8.5 Dependency and Provider Reliability
EnterpriseAIsystemsdependonexternalproviders. Forthird-partymodelproviders:
• Model version pinning whereproviderssupportit(notethathostedprovidersmaydeprecatever-
sionsoralterbehaviorbehindstableendpoints)
• Provider SLA tracking andcontractualreviewforavailabilitycommitments
• Regional failover usingRoute53healthchecksandfailoverrouting
• Fallback providers for critical workloads (e.g., Bedrock as fallback when primary provider is un-
available)
• Quota monitoring forAPIratelimitswithCloudWatchcustommetrics
28.8.6 Disaster Recovery
ForAIworkloads,disasterrecoveryextendsbeyondcompute:
• Model artifacts replicatedtoS3insecondaryregion
• Feature store datareplicatedorreconstructiblefromsource
• Vector indexes backupandrestoreprocedures
• Prompt and configuration registries versionedinCodeCommitorS3withcross-regionreplication
• Evaluation datasets backedupforregressiontestingafterrecovery
Define RTO (Recovery Time Objective) and RPO (Recovery Point Objective) for each AI component.
Modelinferencemayhavea15-minuteRTO(spin-upendpointinthesecondaryregion), whilefeature
pipelinereconstructionmayhavea4-hourRTO(reprocessfromsourcedata).
28.9 Incident Response Process for AI Systems
An incident response process is only useful if it was designed, documented, and practiced before the
incident. Withoutit,improvisedresponseisthenorm,anditisslow,inconsistent,andproducesnolearn-
ings.
Thefive-phaseAIincidentresponseprocessbelowadaptstheSREincidentmodelfromBeyeretal.(Betsy
Beyer,ChrisJones,JenniferPetoff,andNiallRichardMurphy,2016)tothefailure-modetaxonomyabove.
28.9.1 Incident Severity Matrix
Build: 2026-11-0419:48 667

<!-- page 16 -->
Figure28.6: AWS-nativereliabilityarchitectureforAIworkloads, showingtheintegrationofmonitoring,
incidentresponse,modelmanagement,andagentsafetyinfrastructure.Build: 2026-11-0419:48 668

<!-- page 17 -->
Figure28.7: Thefive-phaseAIincidentresponseprocess,fromdetectionthroughpostmortem,withfeed-
backloopsthatimprovefutureincidenthandling.
Table28.3: IncidentSeverityMatrixforAISystems.
Severity Definition ExampleAIIncidents ResponseSLA
P0 Customer-facing
impactatscale,safety
risk,orbusiness-critical
systemdown
UnsafeLLMoutput
reachingcustomers,
fraudscoring
unavailableduring
peak,runawayagent
executingunauthorized
transactions
Acknowledgein5min,
warroomin15min
P1 Significantdegradation
orguardrailbreach
Modelqualitybelow
SLOforhigh-value
segment,fairness
guardrailbreach,agent
toolabusedetected
Acknowledgein15
min,ownerengagedin
30min
P2 Servicedegradation
withlimitedimpact
Delayedbatchscoring,
latencySLObreach
duringlowtraffic,eval
regressioncaught
pre-deployment
Acknowledgein1hour,
resolutionin8hours
P3 Anomalyrequiring
investigation
Dashboardanomaly,
non-urgentdriftsignal,
configuration
inconsistency
Acknowledgein4
hours,scheduled
investigation
28.9.2 Phase 1: Detection
• Alertfiresfrommonitoring(seeChapter27)oranomalyreportedbyauserorstakeholder.
Build: 2026-11-0419:48 669

<!-- page 18 -->
• On-callengineeracknowledgeswithinSLAdefinedinseveritymatrix.
• Initial triage: is this a model failure, pipeline failure, infrastructure failure, agent failure, or false
alarm?
• Severityassessment:assignP0throughP3usingtheseveritymatrix,notjudgmentcallsunderpres-
sure.
LLM-assisted detection is increasingly available in mature observability platforms. Wang et al. (Wang
etal.,2023),workingwithover40,000productionincidentsinMicrosoft365,demonstratedthatafine-
tuned model could generate useful root-cause and mitigation suggestions that over 70 percent of on-
callengineersrateduseful. Thepatternisreachingenterpriseobservabilitytooling: anLLMingeststhe
alert,therelevantlogs,andtherunbooklibrary,andproposesthemostlikelyfailuremodeandthefirst
containmentstep. Treatitsoutputasadraftthatthehumanon-callmustverifybeforeactingonit. The
time-to-contextsavingsduringaP0arereal,butthedecisionstayswithaperson.
28.9.3 Phase 2: Escalation
• P0/P1: notifyAIProductOwnerandaffectedstakeholderswithin15minutes.
• Guardrail breach: notify AI Governance Lead immediately. For Tier 3 systems (defined in Chap-
ter25),notifytheAIRiskReviewBoard.
• Customer-facingimpact:coordinatewithcommunicationsandsupportteams. Status-pageupdate
within30minutesofconfirmedcustomerimpact.
• War-room activation for P0: designated incident commander, dedicated bridge channel, public
statuspageupdateonafixedcadence.
28.9.4 Phase 3: Containment
Thegoalofcontainmentistostopthebleedingbeforediagnosingthecause. AI-specificcontainment
optionsinclude:
• Traffic routing. Shifttraffictoafallbackmodel,anN-1version,orarules-basedsystemusingALB
weightedroutingorAPIGatewaystagevariables.
• Model rollback. PromotethepreviousmodelversionfromSageMakerModelRegistry.
• Feature fallback. Switchtocachedorsimplifiedfeaturesifthepipelineisfailing.
• Graceful degradation. Returndefaultorpopularrecommendationsinsteadofpersonalizedones;
returnadeterministicanswerinsteadofanLLM-generatedone.
• Circuit breaker. DisabletheAIcomponententirelyandroutetoanon-AIfallback.
• Agent kill switch. Forrunawayorhijackedagents,theOWASPAgenticAIThreatsandMitigations
publication(OWASPAgenticSecurityInitiative,2025)documentsthepattern: terminateactiveses-
sions, revoke delegated credentials, freeze the tool registry, and require human re-authorization
beforeagentsresume.
• Human-in-the-loop escalation. Forhigh-risksystems(fraud,credit,healthcare),routetomanual
reviewqueuesratherthanautomateddecisions.
Everycontainmentoptionmustbetestableinanon-incidentdrill: acircuitbreakerthathasneverbeen
exercisedisonethatwillfailtotripwhenitisneeded.
28.9.5 Phase 4: Root Cause Analysis
AIincidentsrequiredifferentRCAtoolsthansoftwareincidents:
Build: 2026-11-0419:48 670

<!-- page 19 -->
• Timeline reconstruction. Correlatemonitoringdataacrossinfrastructure,data,model,application,
andbusinesslayerstoidentifythefirstanomaly.
• Data lineage tracing. For pipeline failures, trace the bad data back to its source. Lineage tools
(such as AWS Glue Data Catalog lineage or SageMaker ML Lineage Tracking) are the difference
betweena30-minuteRCAanda3-dayone.
• Model behavior analysis. Comparepredictiondistributionsbeforeandafterincidentonset. Slice
bydemographic,byfeaturevalue,andbytrafficsegmenttolocalizetheregression.
• Eval replay. ForLLMandagentincidents,replaytheproductiontrafficthattriggeredtheincident
against the prior model or prompt version. If the prior version passes the eval and the current
versionfails,thechangeisimplicated.
• Avoid premature attribution. “Themodeldrifted”isnotarootcause. Identifywhatcausedthe
drift: theupstreamschemachange, themarketingcampaignthatshiftedtrafficmix, thesilentre-
trainingjobthatpromotedaweakermodel.
Wangetal.’sfindings(Wangetal.,2023)applyhereaswell: amodeltrainedonpastincidentscanpro-
poseinitialRCAhypothesesfasterthanahumancanscandashboards.Treattheoutputasastartingpoint
thathumansmustvalidate.
28.9.6 Phase 5: Postmortem
Thepostmortemiswheretheorganizationeitherlearnsorrepeatsitself. Beyeretal. (BetsyBeyer,Chris
Jones,JenniferPetoff,andNiallRichardMurphy,2016)establishedtheblamelesspostmortemasacore
SREpractice;PagerDuty’soperationalguide(PagerDuty,2025)givesitconcretefacilitationpatterns. The
disciplinerestsonthreecommitments:
1. Blameless framing. Postmortemsdescribewhathappenedandhow,notwho. PagerDuty(Pager-
Duty, 2025) highlights the cognitive biases that erode this discipline if facilitators do not actively
counterthem: fundamentalattributionerror(overweightingindividualchoice,underweightingsys-
temcontext)andconfirmationbias(anchoringonthefirstplausiblecause). Facilitatorsmustinter-
venewhenlanguageslipsfrom“what”to“who.”
2. Learning as the primary goal. The output is not a punishment record; it is a set of changes (to
runbooks,monitoring,training,architecture,governance)thatpreventrecurrence.
3. Action items with owners and due dates. Vaguerecommendations(“improvemonitoring”)are
postmortemtheater. Eachactionitemnamesaperson,namesadeliverable,andnamesadate.
Operationalrequirements:
• BlamelesspostmortemrequiredforallP0andP1incidentswithin48hours.
• Requiredoutputs: timeline,rootcause,contributingfactors,impactassessment,actionitemswith
ownersandduedates.
• Action items feed back to runbooks, monitoring thresholds, eval suites, and (where appropriate)
thegovernanceframeworkdefinedinChapter25.
• Postmortemsarereviewedquarterlytoidentifysystemicpatternsacrossincidents.
28.9.7 Standard Incident Metrics
Trackthesemetricstomeasurereliabilityprogrameffectiveness:
• MTTD (Mean Time to Detect). Timefromincidentstarttofirstalert.
• MTTA (Mean Time to Acknowledge). Timefromalerttohumanacknowledgment.
• MTTM (Mean Time to Mitigate). Timefromacknowledgmenttocustomerimpactstopped.
Build: 2026-11-0419:48 671

<!-- page 20 -->
• MTTR (Mean Time to Recover). Timefromincidentstarttofullresolution.
• Change failure rate. Percentageofdeploymentsthatcauseincidents.
• Incident recurrence rate. Percentageofincidentsthatarerepeatsofpreviousincidents.
Real-WorldCaseStudy: Google’s SRE Practice. Google’sSiteReliabilityEngineeringbook(BetsyBeyer,
Chris Jones, Jennifer Petoff, and Niall Richard Murphy, 2016) established the foundational practice of
blameless postmortems and error budgets. The blameless framing is essential. When postmortems
assignblame, engineersstopwritinghonesttimelines, andtheorganizationlosesthedataitneedsto
improve. ForAIsystemsspecifically,thesamepostmortemdisciplineapplies,buttheRCAmustextend
todataquality,modelbehavior,andpipelinedependencies,notjustinfrastructurefailures.
28.10 Runbook Design for AI Systems
Arunbookisthedocumentedresponseprocedureforaknownfailuremode. Goodrunbooksmakethe
differencebetweena20-minuterecoveryanda4-hourone.
28.10.1 Runbook Template
Everyrunbookshouldfollowaconsistentstructure:
Runbook: [Failure Mode Name]
Section Contents
Severitycriteria Whatseveritydoesthisfailurewarrantunderwhat
conditions?
Detectionsignals Whatalarms,metrics,oruserreportsindicatethis
failure?
Dashboards/logs WhatCloudWatchdashboards,LogsInsights
queries,orX-Raytracestoopenfirst?
Firstfiveminutes Immediatetriagesteps: verifythefailure,assess
scope,notifystakeholders
Containmentdecisiontree If[conditionA],then[actionX];if[conditionB],
then[actionY]
Escalationpath Whotocontactatwhatseverity,withcontact
methodsandSLAs
Rollbackprocedure Step-by-steprollbackifcontainmentrequiresit
Verificationsteps Howtoconfirmthefailureisresolved
Communicationrequirements Whentoupdatestatuspage,stakeholders,
customers
Postmortemtriggers Underwhatconditionsisapostmortemrequired?
28.10.2 What Makes a Good AI Runbook
• Specific. Coversonefailuremode,not“allproblems.”
• Actionable. Step-by-stepinstructionsthatcanbefollowedunderpressurebysomeonewhodid
notwritethem.
• Decision-branched. Includes“ifX,doY;ifZ,doW”becauserealincidentshavemultiplebranches.
• Tested. Runbooksthathaveneverbeenpracticedindrillswillfailwhenneeded.
• Current. Outdatedrunbooksareworsethannorunbooks: theygivefalseconfidence.
Build: 2026-11-0419:48 672

<!-- page 21 -->
• Linked to monitoring and eval evidence. Eachrunbookreferencesthedashboards,evalsuites,
andlineagetoolstheengineershouldconsultintheordertheyshouldconsultthem.
28.10.3 Runbook Library for a Production AI System
Table28.4: RunbookLibraryforaProductionAISystem.
FailureMode RunbookContents
Modelqualitydegradation Howtoverifydegradationversusfalsealarm;
rollbackprocedure;escalationcriteria
Pipelinefailure Dependencychecksequence;datasourcetriage;
featurefallbackactivation
LatencySLObreach Trafficroutingoptions;scale-upprocedure;cold
startmitigation
Fairnessguardrailbreach Immediatecontainment(trafficpauseorfallback);
notificationchain;governanceescalation
LLMhallucinationevent Samplingandloggingprocedure;outputfiltering
activation;humanreviewescalation
Agentrunaway Circuitbreakeractivation;taskcancellation
procedure;auditlogreview
Dataschemachange Schemavalidationcheck;pipelinerollback;
upstreamteamnotification
Evalregression Rollbacktolastpassingeval;root-causereplay;
quality-SLOimpactassessment
28.10.4 Agent Runbook Considerations
Traditionalrunbooksdescribewhatahumanon-callengineerdoes. Agentsystemsforceasecondques-
tion: howdo youmanagethe agent’sown proceduralknowledge? Lorica(Lorica, 2026) describesan
emergingpatternhecallsthe“ContextFileSystem”(CFS),whichaddressestheproblemofagentslosing
proceduralknowledgeascontextwindowsgrowandattentiondegrades.
Lorica’sargumentisthatstuffingallproceduralknowledgeintothecontextwindowcreateswhathecalls
a “Context Tax”: quadratic compute cost, lost-in-the-middle attention decay, and repeated re-learning
acrosssessions. Analternativepattern,stillemergingin2026,separatespersistentproceduralmemory
fromtheactivecontext:
• Persistent procedural memory. Agent instructions and procedures stored outside the prompt,
retrievedasneeded.
• Indexed tool discovery. Toolsdescribedinasearchableregistryratherthanenumeratedinevery
systemprompt.
• Separation of reasoning from execution. Reasoningtracesinworkingmemory; executionlogs
inpersistentstorageforauditandreplay.
For reliability purposes, agent configuration, including tool registries, instructions, and memory struc-
tures,mustbeversionedandrollbackable. WhetheryouimplementthisthroughafullCFSarchitecture
orsimplerversionedconfigurationsinS3andDynamoDB,thedisciplineisthesame: youmustbeable
torevertagentbehaviortoaknown-goodstate.
28.10.5 On-Call Responsibilities
• Theon-callroleforanAIsystemisdifferentfromtraditionalon-call. Itrequiresmodelliteracy,not
justinfrastructureknowledge.
Build: 2026-11-0419:48 673

<!-- page 22 -->
• On-callrotationshouldincludebothMLengineersandplatformengineers. Aninfrastructure-only
on-callwillmissmodel-layerfailures.
• On-callhandoff: theoutgoingengineerdocumentsanyopenincidents,anomaliesobserved,and
pendingdeployments. Thisisnotoptional.
• Practice drills run on a calendar. New team members complete at least two tabletop exercises
beforetheirfirstrotation. Existingteammembersparticipateinatleastonechaosengineeringdrill
perquarter.
28.11 Rollback Procedures for AI Components
Rollback in AI systems is more complex than in traditional software because AI systems have multiple
rollbackablecomponents,androllingbackonewithoutcoordinatingtheotherscancreatenewfailures.
28.11.1 What Can Be Rolled Back
• Model version. Promotethepreviousmodelversionfromtheregistry. Themostcommonrollback
action.
• Feature pipeline. Reverttothepreviouspipelineversionifacodechangecausedtraining-serving
skeworschemafailure.
• Prompt or system configuration. ForLLMsystems,reverttothepreviousprompttemplate,system
instruction,orguardrailconfiguration.
• Agent configuration. Reverttoolregistry,memorysettings,ororchestrationlogic.
• Infrastructure. Rollbackcomputeconfigurationchangessuchasauto-scalingpolicyorendpoint
configuration.
• Retrieval index. For RAG systems, roll back the document index or embedding model if a re-
indexingjobdegradedretrievalquality.
28.11.2 Rollback Decision Tree
Incident detected
￿
￿
Is infrastructure healthy (compute, network, dependencies)?
￿
￿￿ No → Infrastructure rollback or failover
￿
￿￿ Yes → Is data pipeline healthy?
￿
￿￿ No → Feature fallback, then pipeline rollback
￿
￿￿ Yes → Is model quality within SLO?
￿
￿￿ No → Model rollback to N-1 version
￿
￿￿ Yes → Is prompt/config recent?
￿
￿￿ Yes → Prompt/config rollback
￿
￿￿ No → Investigate application layer
Build: 2026-11-0419:48 674

<!-- page 23 -->
Figure28.8: Decisiontreeforselectingtheappropriaterollbackactionbasedonsystematicdiagnosisof
thefailurelayer.Build: 2026-11-0419:48 675

<!-- page 24 -->
28.11.3 Graceful Degradation as an Alternative to Rollback
Afullrollbackisnotalwayspossiblequickly,particularlyforLLMsystems,wherethe“previousversion”
is a different API endpoint controlled by a vendor whose release cadence is outside your team’s con-
trol. Every AI system should be designed with a non-AI or simplified fallback that activates when the
primary system fails. Examples: popularity-based recommendations when personalization fails, rules-
based fraudscoring when the ML model is unavailable, cached responseswhen real-timeinferenceis
tooslow,andtemplate-basedoffertextwhentheLLMgenerationservicereturnserrors. Gracefuldegra-
dationistheengineeringacknowledgmentthatAIsystemsareprobabilisticanddependenciesfail, so
reliabilityrequiresadefinedfloorbelowwhichtheuserexperiencedoesnotdrop.
28.12 Use Case: Retail Customer Acquisition and Retention
TheretailAIportfolio’sreliabilityframeworkinstrumentsSLOs,runbooks,rollbackprocedures,andinci-
dentprotocolsacrossthethreeprimarysystems.
28.12.1 Recommendation engine reliability
• SLOs: Availability99.9%(43minmonthlyerrorbudget),p99latencyunder200ms,recommenda-
tiondiversityscore≥0.6,fairnessdisparitywithin±5percentagepointsacrossdemographicseg-
ments. Errorbudgetpolicy: featuredeploymentspausewhen75%ofthemonthlylatencybudget
isconsumed.
• Runbook library: Cold-startlatencyonauto-scaledendpoints,fairnessguardrailbreach,schema
driftfromupstreamproductcatalogupdates,embeddingindexre-rankingfailures.
• Rollback playbook: Modelrollbackwithin5minutesviaSageMakermodelregistry. Fallbackto
popularity-basedrecommendationsifrollbackexceeds15minutes. Chaosengineeringdrillquar-
terly: deliberatecold-startinjectionduringsimulatedtrafficspike.
28.12.2 Churn prediction model reliability
• SLOs: Recall@30days≥70%onmonthlyground-truthevaluation,weeklyPSIunder0.2ontop-10
features,monthlyslice-basedfairnessauditwithintolerance.
• Runbook library: Conceptdriftafterseasonalmarketshift,retrieval-featurestaleness,prediction-
distributionanomalywithoutgroundtruth,partial-featurepipelinefailure.
• Rollback playbook: Coordinated(modelversion, pipelineversion)rollbackpairdocumentedin
registry. Promotionvia Thompson-samplingbandit across10%of customersfor twoweeks, with
fairness-disparityguardrailastheautomatedrollbacktrigger(McClendonetal.,2025).
28.12.3 LLM-based offer generation reliability
• SLOs: p95generationlatencyunder3seconds,refusalrateunder2%,groundednessscore≥0.8
fromLLM-as-judgeon5%sample,dailycostwithinbudget. TheLLMTop10andtheAgenticTop
10definethecatalogueoffailuremodestherunbooklibrarymustcover(OWASPGenAISecurity
Project,2025;OWASPGenAISecurityProject,2026).
• Runbook library: Prompt injection detection, hallucination event, agent runaway during multi-
stepoffergeneration,tool-callcascadefailure,Bedrockinvocationtimeout,contentsafetyguardrail
breach.
• Rollback playbook: Switchtotemplate-basedoffersasthenon-AIfallback(gracefuldegradation),
sincesame-dayrollbackoftheLLMendpointversionisnotgenerallyavailable. Persistentprocedu-
ralrunbooksfortheagentlayerfollowtheContextFileSystempattern,capturingsuccessfulwork-
flowsasversionedreusableproceduresratherthanexpandedcontextwindows(Lorica,2026).
Build: 2026-11-0419:48 676

<!-- page 25 -->
28.12.4 Cross-system incident response
Everyguardrailalertroutesthroughtheseverity-tieredescalationdefinedearlier. Thefive-phaseprocess
(detection,escalation,containment,RCA,postmortem)ispracticedquarterlythroughtabletopexercises
inwhichtheon-callrotationwalksthroughasyntheticincident: aBlackFridaytrafficspikecausingcold-
start latency, a regulatory data feed change causing schema drift, or an agent tool-call cascade. The
PagerDutyblamelesspostmortemmethodologygroundsthePhase5discipline(PagerDuty,2025),and
LLM-assistedrootcauseanalysisisusedasastartingpointforthehumanRCAreviewerratherthanthe
finalanswer(Wangetal.,2023).
28.13 Key Takeaways
• SRE principles apply to AI, with quality as a third dimension. Error budgets and SLOs must
include quality (accuracy, fairness, groundedness) alongside availability and latency, because AI
systems can satisfy availability and latency targets while silently producing wrong outputs (Betsy
Beyer,ChrisJones,JenniferPetoff,andNiallRichardMurphy,2016;Thurgoodetal.,2018).
• AI failure modes are different. Silentdegradation,conceptdrift,hallucinationevents,agentrun-
away,training-servingskew,andfeedback-loopamplificationdonotappearintraditionalSREplay-
booksandrequireAI-specificdetectionandresponsepatterns(Gamaetal.,2014;OWASPGenAI
SecurityProject,2025;OWASPGenAISecurityProject,2026).
• Chaos engineering is the discipline of deliberately breaking your system before reality does.
RosenthalandJonesestablishedthePrinciplesofChaosEngineeringatNetflix; thedisciplineex-
tends to AI through deliberate prompt injection drills, simulated drift, and agent tool-call failure
injection(Rosenthal&Jones,2020).
• The five-phase incident response process is non-negotiable. Detection, escalation, contain-
ment, root cause analysis, and postmortem must be defined and practiced before an incident
occurs, rather than improvised while one is underway. AWS’s Well-Architected Reliability Pillar
describes the same discipline as four practice areas (foundations, workload architecture, change
management,failuremanagement)andconvergesonthesameconclusion(AmazonWebServices,
2024).
• Blameless postmortems are the learning mechanism. Postmortemsthatassignblameproduce
engineerswhowritedishonesttimelines;blamelesspostmortemsproducesystemicfixes. Counter
the fundamental attribution error and confirmation bias by asking “what” and “how”, not “who”
(PagerDuty,2025).
• Runbooks must be specific, tested, and up to date. Arunbookthathasneverbeenpracticed
andhasnotbeenupdatedsincethelastarchitecturechangeisaliability. Agentrunbooksfollowa
differentpattern:persistentproceduralmemoryratherthanexpandedcontext,capturedasContext
FileSystemprocedures(Lorica,2026).
• Rollback in AI systems requires coordination across components. Model + feature pipeline
+prompt+ agent configurationform a versioned set; rollingback one without the others can in-
troducenewfailures. Documentvalid(model, pipeline)versionpairsintheregistryandpractice
rollbackinchaosdrills(Mitchelletal.,2019).
• Graceful degradation is reliability when rollback fails. EveryAIsystemshouldhaveanon-AIor
simplifiedfallbackthatactivateswhentheprimarysystemfails. Thefallbackdefinesthefloorbelow
whichtheuserexperiencedoesnotdrop,evenwhentheAIlayerisfullyunavailable.
Build: 2026-11-0419:48 677

<!-- page 26 -->
28.14 Apply It
1. SLO design. DefinethecompletesetofSLOsfortheretailchurnpredictionmodel. IncludeSLOs
foravailability,latency,quality(recall@30days),andfairness(slice-baseddisparity). ForeachSLO,
specifythetarget,measurementmethod,SLIcalculation(goodeventsovertotalevents),errorbud-
getpolicy,anddeployment-freezetrigger.
2. Failure mode registry. Buildthefailuremoderegistryfortheretailrecommendationengine. For
each failure mode: describe the failure, list the signals that indicate it is happening, specify the
immediatecontainmentaction,namethelikelyrootcausecategories,andidentifywhichrunbook
entrycoversit. IncludebothtraditionalMLfailures(drift,latency)andagent-specificfailures(tool-
callcascade,promptinjection)whereapplicable.
3. Runbook. Write a complete runbook for one failure mode from Exercise 2. Include: detection
criteria, initial triage steps, containment options with decision branches, an escalation path with
namedrolesandSLAs,resolutionverification,post-incidentactions,andtheconditionsunderwhich
gracefuldegradationistriggeredinsteadofattemptingfullrecovery.
4. Incident simulation tabletop. Walkthroughthefive-phaseincidentresponseprocessforthissce-
nario: theretailrecommendationengine’sfairnessguardrailfiresat11:00PM.Demographicparity
hasdriftedto9%(limitis5%)followingaproductcatalogupdateearlierthatday. Documenteach
phase: whodoeswhat,inwhatorder,withinwhattimeSLA,therollbackdecisioncriteria,andwhat
thepostmortemmustcover.
5. Chaos engineering drill design. Designonechaosengineeringexperimentforeachofthethree
retailsystems(recommendationengine,churnmodel,LLMoffergeneration). Foreach: specifythe
hypothesis,thefailuretoinject,theblastradius,therollbacktrigger,thesuccesscriteria,andthe
learningtheteamexpectstogain. Identifywhichexperimentsrequiregovernancepre-approval.
6. AI prompt. “You are an SRE lead reviewing the following incident postmortem for an AI system
failure. Identify: (1) whether the root cause analysis is complete or whether it stopped at a symp-
tomratherthanasystemiccause, (2)whichactionitemsarelikelytopreventrecurrencevs.which
arevagueorunenforceable,(3)whatrunbookgapsthisincidentrevealed,and(4)whatchaosengi-
neeringexperimentswouldhavecaughtthisfailurebeforeitreachedproduction. Provideconcrete
remediationrecommendationsorderedbyexpectedimpact: [pasteyourincidentfromExercise4].”
28.15 What’s Next
Reliabilityengineeringkeepsthesystemrunningandensuresgracefulfailureunderpressure. Thenext
chapter,AIEconomics: ManagingCostsandMeasuringReturns,shiftsfromoperationalstabilitytofinan-
cialdiscipline. ProductionAIsystemsthatarenotcost-managedwillconsumebudgetwithoutdelivering
proportionalvalue,andcostproblemscompoundthesamewayreliabilityproblemsdo: slowly,invisibly,
until they are impossible to ignore. Reliability earns a system the right to keep operating; economics
decideswhetheroperatingitwasworththecost.
28.16 References
Amazon Web Services. (2024). Reliability Pillar - AWS Well-Architected Framework. Amazon Web Ser-
vices.
Aryan,A.(2025). LLMOps: ManagingLargeLanguageModelsinProduction. O’ReillyMedia.
Autio,C.,Schwartz,R.,Dunietz,J.,Jain,S.,Stanley,M.,Tabassi,E.,Hall,P.,Roberts,K.,&NationalInstitute
ofStandardsandTechnology. (2024).ArtificialIntelligenceRiskManagementFramework: Generative
Build: 2026-11-0419:48 678

<!-- page 27 -->
ArtificialIntelligenceProfile. NationalInstituteofStandardsandTechnology(NIST).https://doi.org/
10.6028/NIST.AI.600-1
BetsyBeyer,ChrisJones,JenniferPetoff,andNiallRichardMurphy. (2016). SiteReliabilityEngineering:
HowGoogleRunsProductionSystems. O’ReillyMedia.
Breck,E.,Cai,S.,Nielsen,E.,Salib,M.,&Sculley,D.(2017).TheMLTestScore:ARubricforMLProduction
ReadinessandTechnicalDebtReduction.2017IEEEInternationalConferenceonBigData(BigData),
1123–1132.
Gama, J., Žliobaitė, I., Bifet, A., Pechenizkiy, M., & Bouchachia, A. (2014). A Survey on Concept Drift
Adaptation.ACMComputingSurveys,46(4),1–37. https://doi.org/10.1145/2523813
Grace, M., Hadfield, J., Olivares, R., & De Jonghe, J. (2026). Demystifying evals for AI agents. https:
//www.anthropic.com/engineering/demystifying-evals-for-ai-agents;AnthropicEngineeringBlog.
Huyen,C.(2022).DesigningMachineLearningSystems: AnIterativeProcessforProduction-ReadyAppli-
cations. O’ReillyMedia.
Kazmierczak,J.,Salama,K.,&Huerta,V.(2024). MLOps: Continuousdeliveryandautomationpipelines
in machine learning. https://cloud.google.com/architecture/mlops-continuous-delivery-and-
automation-pipelines-in-machine-learning;GoogleCloudArchitectureCenter.
Lorica,B.(2026). Youragentsneedrunbooks,notbiggercontextwindows. https://gradientflow.substac
k.com/p/the-missing-layer-in-todays-agent;GradientFlow.
McClendon, S. A., Venkatesh, V., & Morinelli, J. (2025). Reinforcement Learning for Machine Learning
ModelDeployment: EvaluatingMulti-ArmedBanditsinMLOpsEnvironments. https://doi.org/10.4
8550/arXiv.2503.22595
Mitchell,M.,Wu,S.,Zaldivar,A.,Barnes,P.,Vasserman,L.,Hutchinson,B.,Spitzer,E.,Raji,I.D.,&Gebru,T.
(2019). ModelCardsforModelReporting.ProceedingsoftheConferenceonFairness,Accountability,
andTransparency(FAccT),220–229. https://doi.org/10.1145/3287560.3287596
OWASPAgenticSecurityInitiative.(2025).AgenticAI–ThreatsandMitigations.OWASPAgenticSecurity
Initiative.
OWASPGenAISecurityProject. (2025). OWASPTop10forAgenticApplicationsfor2026. https://gena
i.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/;OWASPFoundation.
OWASPGenAISecurityProject. (2026).OWASPTop10forLLMApplications2026.https://genai.owasp.
org/resource/owasp-genai-llm-top-10-2026/.
PagerDuty. (2025). TheBlamelessPostmortem. https://postmortems.pagerduty.com/culture/blameles
s/;PagerDutyPostmortemDocumentation.
Rosenthal,C.,&Jones,N.(2020). ChaosEngineering: SystemResiliencyinPractice. O’ReillyMedia.
Saltonstall,M.,&Virji,S.(2025). AnSRE’sguidetooptimizingMLsystemswithMLOpspipelines. https:
//cloud.google.com/blog/products/devops-sre/applying-sre-principles-to-your-mlops-pipelines;
GoogleCloudBlog.
Sculley,D.,Holt,G.,Golovin,D.,Davydov,E.,Phillips,T.,Ebner,D.,Chaudhary,V.,Young,M.,Crespo,J.-
F.,&Dennison,D.(2015). HiddenTechnicalDebtinMachineLearningSystems. AdvancesinNeural
Build: 2026-11-0419:48 679

<!-- page 28 -->
InformationProcessingSystems(NeurIPS),28,2503–2511.
Thurgood,S., Ferguson, D., Hidalgo, A., &Beyer, B.(2018). ImplementingSLOs. InTheSiteReliability
Workbook: PracticalWaystoImplementSRE.O’ReillyMedia.
Wang, R., Bansal, C., Ghosh, S., Zimmermann, T., Zhang, X., & Rajmohan, S. (2023). Large-language
modelsforautomaticcloudincidentmanagement. https://www.microsoft.com/en-us/research/blog
/large-language-models-for-automatic-cloud-incident-management/;MicrosoftResearchBlog.
Yurdakul,B.,&Naranjo,J.(2020). Statisticalpropertiesofthepopulationstabilityindex. JournalofRisk
ModelValidation,14(4),89–100. https://doi.org/10.21314/JRMV.2020.227
Build: 2026-11-0419:48 680