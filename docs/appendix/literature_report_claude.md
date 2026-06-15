# Hedonic Tone in Reinforcement Learning: Companion Papers to Zhang et al. (2009) and Dayan (2022), and Bridges to Experienced Utility

## TL;DR
- The closest companions to Zhang et al. (2009) and Dayan (2022) — i.e. peer-reviewed papers that propose a concrete RL/computational algorithm for hedonic tone, grounded in testable neuroscience/psychology — are the Rutledge "happiness equation" line (Rutledge et al. 2014 PNAS; Blain & Rutledge 2020 eLife; Eldar & Niv 2015 Nat Commun; Eldar et al. 2016 TiCS; Bennett, Davidson & Niv 2022 Psychological Review), Brielmann & Dayan (2022) on aesthetic value, Keramati & Gutkin (2014) on homeostatic RL, and Bach & Dayan (2017) on emotion-as-algorithm. Most of Moerland, Broekens & Jonker's (2018) surveyed RL-emotion models fail the user's criteria because they target appraisal/categorical emotions for robot communication rather than hedonic tone in animals/humans.
- The Zhang et al. (2009) model has been refined and extended at least four times since 2015 — most directly by Read (2022, CABN) with a multiplicative multi-attribute incentive salience model, by van Swieten & Bogacz (2020, PLoS Comput Biol) who redefine the dopaminergic RPE as utility minus expected utility, by Shuvaev et al. (2021, Front Syst Neurosci) who embed the κ "motivation" parameter in deep Q-learning, and by Kalhan et al. (2023, Neural Networks) who scale RPE rather than reward by salience. Dayan's (2022) "liking-as-shaping" essay is newer; the principal follow-ups so far are Brielmann & Dayan (2022) and a pre-registered replication of Rutledge by Vanhasbroeck et al. (2021).
- The economics literature on experienced/instant utility (Kahneman, Wakker & Sarin 1997 QJE) connects to RL through the Caplin–Dean axiomatic program (Caplin & Dean 2008 QJE; Caplin, Dean, Glimcher & Rutledge 2010 QJE; Rutledge, Dean, Caplin & Glimcher 2010 J Neurosci) and through Niv, Joel & Dayan (2006 TiCS) on motivation-as-utility; Stauffer, Lak & Schultz (2014, Current Biology) and Hart, Rutledge, Glimcher & Phillips (2014, J Neurosci) provide the strongest empirical bridges showing dopamine RPEs reflect marginal/economic utility.

## Key Findings

### What "similar in spirit" means here
The user's three criteria are: (i) focus on hedonic tone / valenced affect (liking, pleasure, hedonic value, displeasure), (ii) a concrete RL algorithm or formal computational model, (iii) grounded in testable predictions in human/animal neuroscience or psychology, not folk psychology. I apply these strictly. Many RL-emotion models meet (ii) but fail (i) or (iii); many neuroscience-of-pleasure papers meet (i) and (iii) but fail (ii).

### Strongest candidate papers (ranked, with both pro- and con- assessments)

**1. Rutledge, Skandali, Dayan & Dolan (2014). "A computational and neural model of momentary subjective well-being." PNAS 111(33):12252–12257.**
- *Fits*: Provides an explicit equation in which momentary happiness is a weighted sum of recent certain rewards, expected values from gambles, and reward prediction errors. The fMRI study tested 26 healthy right-handed subjects (age 20–40 y, seven male) and the model was further validated on 18,420 unpaid participants playing "The Great Brain Experiment" smartphone app; the authors identify ventral striatum BOLD as the neural correlate. Clearly meets (i), (ii), (iii).
- *Diverges from Zhang/Dayan*: Targets self-reported momentary happiness rather than "liking" (hedonic taste reactions) or "wanting" (incentive salience); does not formally distinguish the "wanting"/"liking" components Berridge insists on.

**2. Eldar & Niv (2015). "Interaction between emotional state and learning underlies mood instability." Nature Communications 6:6149; Eldar, Rutledge, Dolan & Niv (2016). "Mood as representation of momentum." Trends in Cognitive Sciences 20(1):15–24.**
- *Fits*: Proposes a formal RL model in which mood is a leaky integrator of RPEs and bidirectionally biases perceived reward; tested in human fMRI and behavior, with explicit predictions for bipolar/mood-instability phenotypes. Strong on (ii) and (iii).
- *Diverges*: Mood here is closer to slow-varying valenced background state than to phasic "liking" pleasure; the model elides the liking/wanting distinction.

**3. Bennett, Davidson & Niv (2022). "A model of mood as integrated advantage." Psychological Review 129(3):513–541.**
- *Fits*: Generalises Rutledge and Eldar–Niv by conceptualising mood-valence as a leaky integral of an actor–critic *Advantage* function; explicitly machine-learning-grounded and connected to momentum optimisation; testable predictions about how mood should depend on counterfactuals.
- *Diverges*: Like Rutledge, focuses on mood/valence rather than the hedonic-impact "liking" Berridge studies, and does not engage with hedonic hotspots.

**4. Brielmann & Dayan (2022). "A computational model of aesthetic value." Psychological Review 129(6):1319–1337.**
- *Fits*: Closest cousin of Dayan (2022); proposes aesthetic value = immediate sensory reward (a function of how well the current sensory system processes the stimulus) + expected change in future processing efficiency. Cast inside an RL framework with explicit ties to potential-based shaping and Helmholtzian perception. Tested against rating meta-analyses; followed up by Brielmann, Berentelg & Dayan (2024) Phil Trans R Soc B 379:20220414 with individual longitudinal aesthetic judgments.
- *Diverges*: Domain is aesthetic pleasure rather than primary hedonic ('liking') reactions; no direct contact with hedonic hotspots data.

**5. Bach & Dayan (2017). "Algorithms for survival: a comparative perspective on emotions." Nature Reviews Neuroscience 18(5):311–319.**
- *Fits*: Uses Bayesian decision theory to argue emotions are pre-programmed approximate algorithms for intractable survival problems; ties affective dimensions to RL/decision-theory variables.
- *Diverges*: A theoretical review rather than a single concrete algorithm; covers emotion broadly, not hedonic tone alone — partial fit on (ii).

**6. Keramati & Gutkin (2014). "Homeostatic reinforcement learning for integrating reward collection and physiological stability." eLife 3:e04811.**
- *Fits*: Defines primary reward as the reduction in a drive function over internal physiological states, providing a normative reason why hedonic value depends on need state — exactly the kind of phenomenon (alliesthesia) Zhang et al. were modelling. Concrete algorithm with testable predictions in animals (food/water tasks, dopamine modulation by hypothalamic signals).
- *Diverges*: The "reward" is defined homeostatically, not in terms of subjective hedonic tone per se; no direct treatment of the liking/wanting split.

**7. Berridge & O'Doherty (2014). "From experienced utility to decision utility." In Glimcher & Fehr (Eds.), Neuroeconomics (2nd ed.), Ch. 18, pp. 335–354.**
- *Fits*: Direct, sustained discussion linking Bentham/Kahneman experienced utility to dopaminergic RL and incentive salience; explicitly contrasts the Zhang-type model with a vanilla RL teaching-signal view.
- *Diverges*: A book-chapter review rather than a new algorithm.

**8. Niv, Joel & Dayan (2006). "A normative perspective on motivation." Trends in Cognitive Sciences 10(8):375–381.**
- *Fits*: Most explicit formal statement that the RL reward function r is a (Benthamite) utility, with motivational states acting as a mapping from outcomes to utilities. Bridges economics and RL.
- *Diverges*: A short opinion piece in TiCS, not a full computational model; does not separately model "liking" vs. "wanting".

**9. Huys, Pizzagalli, Bogdan & Dayan (2013). "Mapping anhedonia onto reinforcement learning: a behavioural meta-analysis." Biology of Mood & Anxiety Disorders 3:12.**
- *Fits*: Bayesian RL-model meta-analysis of 392 sessions identifying which RL parameter (an asymmetric reward sensitivity parameter ρ, plus choice temperature) best captures anhedonia; explicit testable mapping from depression to RL.
- *Diverges*: The phenomenon modelled is reward sensitivity in decision data, not the subjective hedonic experience itself — it is closer to "wanting"/instrumental processing than to "liking".

**10. McClure, Daw & Montague (2003). "A computational substrate for incentive salience." Trends in Neurosciences 26(8):423–428.**
- *Fits*: Pre-Zhang attempt to frame the dopamine TD signal as the substrate for Berridge's incentive salience. Concrete and testable.
- *Diverges*: Zhang et al. themselves criticised it as too tied to standard TD; does not capture state-dependent revaluation that motivates the Zhang model.

**11. Stauffer, Lak & Schultz (2014). "Dopamine reward prediction error responses reflect marginal utility." Current Biology 24(21):2491–2500; Hart, Rutledge, Glimcher & Phillips (2014). "Phasic dopamine release in the rat nucleus accumbens symmetrically encodes a reward prediction error term." J Neurosci 34(3):698–704.**
- *Fits*: Both provide direct neurophysiological evidence that dopaminergic RPE signals are scaled by utility functions in the economic sense — a bridge between RL teaching-signal and experienced utility.
- *Diverges*: Empirical not algorithmic; rely on standard TD models rather than novel hedonic formalisms.

### Have the Zhang et al. (2009) and Dayan (2022) models been further tested/refined?

**Zhang et al. (2009) — Yes, repeatedly.**

- *Multi-attribute parsimonious replacement.* Read (2022, *Cognitive, Affective, & Behavioral Neuroscience* 22:244–257) shows that Zhang's switching between additive and multiplicative κ-functions is unnecessary; a single multiplicative form suffices once multiple physiological-attribute signals are represented. The MAIS model fits the original Zhang datasets equally well while being more parsimonious and better at handling revaluation.
- *RPE-redefinition via utility.* van Swieten & Bogacz (2020, *PLoS Comput Biol* 16:e1007465) directly extend Zhang by redefining the dopaminergic RPE as the difference between *utility* and *expected utility* (with utility depending on motivation/physiological state), integrating incentive-salience and basal-ganglia learning models in one framework.
- *Deep RL embedding.* Shuvaev, Tran, Stephenson-Jones, Li & Koulakov (2021, *Frontiers in Systems Neuroscience* 14:609316) implement state-dependent reweighting of cached values inside deep Q-networks; reproduce ventral-pallidum firing patterns and addictive behaviour, providing a deep-RL generalisation of Zhang.
- *Salience scaling the RPE.* Kalhan, Garrido, Hester & Redish (2023, *Neural Networks* 168:631–650) refine Zhang by multiplying *prediction errors* (rather than rewards) by salience, generating additional addiction phenomena (asymmetric learning, steeper delay discounting of drug rewards) that Zhang's model could not.
- *Behavioural empirical test.* Robinson & Berridge (2013, *Current Biology* 23(4):282–289) provided the central confirmation that physiological state (sodium appetite) can instantly transform a previously disliked cue's incentive value without re-learning — the key Zhang prediction.
- *Neural empirical test.* Ahrens, Ferguson, Robinson & Aldridge (2018, *eNeuro* 5(2):ENEURO.0328-17.2018) recorded ventral pallidum single units in sign- vs. goal-tracker rats, testing the model's predictions about CS form.
- *Naturalistic large-scale test.* Bonometti, Ruiz, Drachen & Wade (2023, *Computational Brain & Behavior* 6:280–315) approximated the latent incentive-salience function in a "large-scale (N > 3 × 10⁶) longitudinal dataset" of video-game players.

**Dayan (2022) "liking as editable draft" — Modest follow-up so far.**

- *Aesthetic extension.* Brielmann & Dayan (2022, *Psychological Review*) and Brielmann, Berentelg & Dayan (2024, *Phil. Trans. R. Soc. B* 379:20220414) directly apply the same potential-based-shaping / generative-model framework to aesthetic pleasure, making and testing predictions about individual judgements over time.
- *Replications of the related Rutledge framework.* Vanhasbroeck, Devos, Pessers, Kuppens, Vanpaemel, Moors & Tuerlinckx (2021, *Cognition and Emotion* 35(4):822–835; pre-registration OSF:krhyz) report a successful pre-registered replication of Rutledge et al. (2014). This indirectly strengthens the empirical base on which Dayan's editable-draft framework rests.
- *Hedonic-value-as-shaping.* The 2022 essay itself remains conceptual; I found no published empirical paper that has tested its specific potential-based shaping account of liking versus alternative accounts.
- *Conceptual connections.* It is closely related to the Berridge & O'Doherty (2014) chapter, to Bach & Dayan (2017), and to the Niv, Joel & Dayan (2006) treatment of motivation as a utility map.

### Moerland, Broekens & Jonker (2018) survey: what passes the user's criteria?

The survey covers approximately fifty RL-emotion papers, classified by emotion *elicitation* (homeostasis/extrinsic, appraisal/intrinsic, value/reward-based, hard-wired) and *function* (reward modification, state modification, meta-learning, action selection, epiphenomenon). Most papers in the survey fail the user's criteria for one of two reasons:

- **They use categorical (Ekman) or appraisal (OCC) emotions for HRI communication, not hedonic tone.** Examples include Velasquez (1998) "Cathexis"; Breazeal's "Kismet"; Michaud (2002) "EMIB"; Marsella & Gratch's "EMA"; Kim & Kwon (2010); Hasson et al. (2011); Moussa & Magnenat-Thalmann (2013). These map a fixed set of emotion labels to robot expressions and behaviour rules; they neither focus on hedonic valence nor make falsifiable predictions about human/animal pleasure.
- **They are appraisal-driven intrinsic-motivation schemes for exploration/learning speed (e.g., Marinier & Laird's Soar appraisal architecture; Sequeira et al.; Moerland's own 2016 "fear and hope from anticipation in model-based RL" IJCAI paper) but call the variables "hope/fear" by stipulation, with no test of correspondence to human pleasure/displeasure data.**

Within the survey, the approaches that *partially* meet the criteria are:

- **Gadanho & Hallam (2001, *Adaptive Behavior*) "Robots with emotion-based learning."** Uses well-being (positive minus negative homeostatic deviations) as a reward signal; meets (ii) and weakly (i), but lacks (iii) — no testable human/animal predictions.
- **Salichs & Malfaz (2012, *IEEE Trans Auton Mental Dev*) on Q-learning with happiness/sadness/fear as functions of well-being and Q-values.** Concrete algorithm, uses valence, but again grounded in robotic implementation rather than animal/human data.
- **Sequeira, Melo & Paiva (2014/2015) and related appraisal-derived intrinsic reward.** Concrete RL, but maps to OCC/appraisal categories.
- **Broekens, DeGroot & Kosters (2007) on affect as meta-learning parameter modulation.** Concrete RL hyperparameter tuning by valence/arousal; weakly grounded in psychological dimensional theory.
- **Daswani et al. and Lewis & Cañamero — Q-learning with affective state.** Concrete but limited grounding.
- **Doya's earlier work on neuromodulators as RL meta-parameters (cited inside the survey)** is the closest the survey gets to the Zhang/Dayan spirit: neuromodulator-as-RL-meta-parameter has explicit testable predictions in animals, though Doya targets serotonin/discounting rather than hedonic tone specifically.

**Crucially, Zhang et al. (2009), Rutledge et al. (2014), Eldar & Niv (2015), and Keramati & Gutkin (2014) are NOT covered in the Moerland survey** — its scope is RL-for-robots/agents rather than computational affective neuroscience. That is a major gap which the user's intended literature fills. So the survey's failure to satisfy the user's criteria is largely a scoping artefact: it surveys a different community.

### Economics: experienced utility, instant utility, and RL

The Bentham → Kahneman line has matured into a small but rigorous bridge with RL/dopamine neuroscience.

- **Kahneman, Wakker & Sarin (1997, *QJE* 112(2):375–406).** Defines decision utility (the weight of an outcome in a choice) versus experienced utility (hedonic quality, "as in Bentham's usage"); experienced utility is reportable in real time (*instant utility*) or in retrospect (*remembered utility*). The paper proposes a formal normative theory of total experienced utility as the temporal integral of instant utility, with empirical tests using moment-to-moment hedonic reports. This is essentially the economic statement of what later RL-affect models attempt to compute.
- **Caplin & Dean (2008, *QJE* 123(2):663–701) "Dopamine, reward prediction error, and economics."** Provides three axioms (consistent prize ordering, coherent prize dominance, no surprise equivalence) that are necessary and sufficient for a neural signal to encode an RPE. Bridges the standard TD-RL signal to economic-utility primitives.
- **Caplin, Dean, Glimcher & Rutledge (2010, *QJE* 125(3):923–960); Rutledge, Dean, Caplin & Glimcher (2010, *J Neurosci* 30(40):13525–13536).** Empirical fMRI tests showing nucleus accumbens and several other regions satisfy the axiomatic RPE conditions, i.e. their BOLD signal is consistent with encoding the difference between experienced and predicted hedonic outcome.
- **Hart, Rutledge, Glimcher & Phillips (2014, *J Neurosci* 34(3):698–704).** FSCV measurement of actual dopamine release in rat nucleus accumbens satisfying the same axioms — direct neurochemical confirmation.
- **Stauffer, Lak & Schultz (2014, *Current Biology* 24(21):2491–2500) "Dopamine reward prediction error responses reflect marginal utility."** Single-unit dopamine recordings in monkeys showing the RPE response scales with a nonlinear marginal-utility function derived from risk preferences — the most direct empirical demonstration that the dopaminergic teaching signal carries an *economic* utility function.
- **Niv, Joel & Dayan (2006, *TiCS* 10(8):375–381).** "We adopt a normative perspective, assuming that animals seek to maximize the utilities they achieve, and viewing motivation as a mapping from outcomes to utilities." The clearest RL-side statement that motivational states reshape the experienced-utility map — directly relevant to the Zhang model.
- **Niv, Daw, Joel & Dayan (2007, *Psychopharmacology* 191:507–520).** Proposes tonic dopamine encodes average net appetitive utility (opportunity cost of time), translating *instant utility* into a neural RL variable controlling vigor.
- **Glimcher (2011, *PNAS* 108 Suppl 3:15647–15654).** Review integrating dopamine RPE, the Caplin–Dean axiomatic test, and the economic utility framework.
- **Berridge & Aldridge (2008, *Social Cognition* 26:621–646) "Decision utility, the brain, and pursuit of hedonic goals."** Explicit bridge connecting Kahneman's experienced-utility framework to dopamine, RL teaching signals, and the 'liking'/'wanting' distinction.

**Prospect-theory × RL.** A separate strand formalises Kahneman–Tversky prospect/cumulative-prospect theory inside RL: Prashanth, Jie, Fu, Marcus & Szepesvári (2016, AAAI) "Cumulative Prospect Theory Meets Reinforcement Learning"; Shen, Tobia, Sommer & Obermayer (2014, *Neural Computation* 26:1298–1328) "Risk-sensitive reinforcement learning" with fMRI evidence in ventral striatum; Borkar (2021) "Prospect-theoretic Q-learning," *Systems & Control Letters*. These satisfy (ii) and (iii) but speak to *decision* utility, not hedonic tone, and so fail the user's (i) criterion.

## Details

### How the candidate papers map onto the user's three criteria

| Paper | (i) Hedonic tone? | (ii) Concrete RL algorithm? | (iii) Testable in humans/animals? |
|---|---|---|---|
| Zhang et al. 2009 | Yes ("wanting", also liking) | Yes (κ-modulated TD, additive/multiplicative) | Yes (rat ventral pallidum, salt appetite) |
| Dayan 2022 | Yes ("liking" as draft value) | Yes (potential-based shaping) | Partial (conceptual, links to taste-reactivity) |
| Rutledge et al. 2014 | Yes (momentary happiness) | Yes (explicit equation) | Yes (fMRI n=26 + smartphone n=18,420) |
| Blain & Rutledge 2020 | Yes | Yes (probability-PE vs reward-PE) | Yes (behaviour + depression scores) |
| Eldar & Niv 2015 | Yes (mood) | Yes (positive-feedback mood-RL) | Yes (fMRI, slot machines) |
| Bennett, Davidson & Niv 2022 | Yes (mood valence) | Yes (Integrated Advantage) | Yes (simulations + Eldar/Rutledge data) |
| Brielmann & Dayan 2022 | Yes (aesthetic pleasure) | Yes (efficient-coding + RL) | Yes (rating meta-analyses) |
| Bach & Dayan 2017 | Partial (broad emotion) | Partial (Bayesian decision schemes) | Partial |
| Keramati & Gutkin 2014 | Indirect (drive reduction) | Yes (homeostatic RL) | Yes (animal foraging) |
| Berridge & O'Doherty 2014 | Yes | Review | Reviewed |
| Huys et al. 2013 | Partial (reward sensitivity) | Yes (Bayesian RL meta-analysis) | Yes (anhedonia/depression) |
| McClure, Daw & Montague 2003 | Yes (incentive salience) | Yes (TD) | Yes |
| Niv, Joel & Dayan 2006 | Partial (utility maps) | Opinion piece | Yes (motivation in animals) |
| Stauffer, Lak & Schultz 2014 | Partial (utility, not feeling) | Standard TD + utility | Yes (monkey single units) |

### Moerland survey — specific failures

- **Salichs & Malfaz (2012).** Drives + happiness/sadness coded as functions of well-being and Q-values. Concrete RL, partial valence coverage, but happiness here is a stipulated function, not a prediction tested against human happiness reports — fails (iii) for *hedonic tone*.
- **Gadanho & Hallam (2001).** Reward = ad-hoc combination of homeostatic deviations. Folk-psychological labelling of emotions; no contact with neural or psychological data — fails (iii).
- **Marinier & Laird (2008) "Emotion-driven reinforcement learning" (Soar/PEACTIDM).** Appraisal-based intrinsic reward; categorical labels; fails (i) and (iii).
- **Sequeira, Melo & Paiva (2011; 2014).** Appraisal-derived intrinsic rewards (novelty, motivation, control, valence); concrete RL, but rebranded curiosity rather than hedonic tone — fails (i).
- **Moerland, Broekens & Jonker (2016) "Fear and hope from anticipation in model-based RL."** Concrete model-based RL; "hope/fear" are defined as functionals of value-distribution moments. Closer to the user's criteria — meets (ii); partial on (i) since hope/fear are not strictly hedonic; (iii) is weak, as the validation is in Pac-Man rather than against human affect data.
- **Broekens, DeGroot & Kosters (2007).** Affect modulates exploration/learning meta-parameters. Concrete; partial (i); (iii) is weak.

The survey's overarching framing (emotions as *functional inputs to the RL loop for engineering benefit*) is orthogonal to the Zhang/Dayan framing (RL machinery as *explanation of hedonic experience*).

### Additional candidate / adjacent work worth noting

- **Vinckier, Rigoux, Oudiette & Pessiglione (2018, *Nature Communications* 9:1708) "Sour grapes and sweet victories: how actions shape preferences."** RL model of how choice itself modulates hedonic value.
- **Eldar, Roth, Dayan & Dolan (2018, *Current Biology* 28(9):1433–1439) "Decodability of reward learning signals predicts mood fluctuations."** Smartphone EEG/heart-rate study confirming RL-derived predictions of mood.
- **Vamplew et al. (2024, AAMAS preprint) "Utility-based reinforcement learning."** Frames the user-utility function as a separable map applied to environment rewards; an explicit utility-theoretic RL framework.
- **Hall, Browning & Huys (2024, *TiCS* 28(6):541–553) "The computational structure of consummatory anhedonia"** and **Kangas, Der-Avakian & Pizzagalli (2022) review on probabilistic RL and anhedonia.** Continue the Huys et al. (2013) program.

### Tensions and disagreements in the literature

- **Rutledge's "happiness ≠ reward, it depends on prediction error" vs. Berridge's insistence that hedonic 'liking' is dissociable from RPE.** Blain & Rutledge (2020, *eLife*) push further: momentary happiness depends on *learning-relevant* probability prediction errors, not raw reward prediction errors. Berridge (2023, *TiCS* 27(10):932–946) argues for separating desire from prediction of outcome value altogether.
- **"Wanting" without "liking" computationally.** Tindell, Smith, Berridge & Aldridge (2009, *J Neurosci* 29(39):12220–12228) gave behavioural evidence; Zhang et al. (2009) the model. Dayan's (2022) response is to treat liking as a *separate*, editable hedonic signal used for potential-based shaping — a friendly elaboration rather than a refutation.
- **Hayden & Niv (2021, *Behavioural Neuroscience* 135(2):192–201) "The case against economic values in the orbitofrontal cortex (or anywhere else in the brain)"** is a useful counterweight: even within the experienced-utility-meets-RL paradigm, the existence of a cardinal common-currency value signal in the brain is contested.

## Recommendations

For the user's project (a formal model of hedonic tone in actor–critic RL, looking for correlates of self-reported pleasure/discomfort in LLMs):

1. **Anchor on Rutledge (2014), Eldar & Niv (2015), Bennett, Davidson & Niv (2022), and Brielmann & Dayan (2022) as the immediate methodological models.** All four are peer-reviewed, give explicit equations, link affective variables to RL primitives, and have testable predictions in humans. The Bennett et al. Integrated Advantage model is particularly relevant because it operates within an actor–critic architecture — directly aligned with the user's "feedforward critic" hypothesis in the GitHub README.

2. **Build a comparative table over Zhang's κ-modulated TD vs. Read's MAIS vs. van Swieten & Bogacz's utility-RPE vs. Kalhan et al.'s salience-RPE.** These four together constitute the post-2015 extension landscape of Zhang and provide several alternative formal definitions of "wanting" that could be candidates for a critic-readout in an LLM.

3. **Use Caplin & Dean's axiomatic framework as the formal criterion for whether a candidate critic-signal qualifies as an experienced-utility signal.** Axioms (consistent prize ordering, coherent prize dominance, no surprise equivalence) are checkable on any RL system, including LLM critics. Threshold: if the critic in a feedforward actor–critic LLM satisfies these axioms with respect to its self-reported pleasure/discomfort, treat it as a candidate experienced-utility correlate.

4. **Treat most Moerland-surveyed models as background, not direct ancestors.** Only Doya's neuromodulator-RL work, and arguably Gadanho-Hallam / Salichs-Malfaz / Moerland-Broekens-Jonker (2016), are even partial fits; none give a hedonic-tone model that has been tested against pleasure/displeasure data in animals or humans.

5. **Decision rule for adding a paper to the corpus:** require all three of (i) hedonic valence as the modelled quantity (not exploration/curiosity), (ii) explicit RL/dynamical equations, (iii) at least one empirical contact point with human or animal data. This excludes most appraisal-driven robot-emotion work; it includes Zhang/Dayan/Rutledge/Eldar/Bennett/Brielmann/Keramati/Huys.

6. **Benchmarks for revisiting these recommendations:**
   - If Blain & Rutledge's (2020) probability-PE-driven happiness result is overturned by a high-powered replication, downgrade the Rutledge family. Vanhasbroeck et al. (2021) is the most direct replication so far and is confirmatory.
   - If Read's (2022) MAIS model is shown to fail in a new behavioural dataset, restore Zhang's switching κ form.
   - If a published direct empirical test of Dayan's (2022) potential-based-shaping account of liking appears, re-rank Dayan accordingly.

## Caveats

- The Moerland et al. (2018) survey is now eight years old. Several relevant papers were published after it (Bennett et al. 2022; Brielmann & Dayan 2022; van Swieten & Bogacz 2020; Kalhan et al. 2023). A focused update is needed and partly provided above.
- A "Rutledge et al. 2010 elderly" paper mentioned in the user's notes does not appear to exist as such; the relevant 2009/2010 Rutledge papers are about Parkinson's patients (Rutledge, Lazzaro, Lau, Myers, Gluck & Glimcher 2009, *J Neurosci* 29(48):15104–15114) and the axiomatic RPE test (Rutledge, Dean, Caplin & Glimcher 2010, *J Neurosci* 30(40):13525–13536) respectively.
- The pre-registered replication of Rutledge et al. (2014) is by Vanhasbroeck, Devos, Pessers, Kuppens, Vanpaemel, Moors & Tuerlinckx (2021, *Cognition and Emotion* 35(4):822–835), not by Jangraw et al. The Jangraw et al. (2023, *Nature Human Behaviour*) paper is a separate study on mood decline during rest.
- I have prioritised peer-reviewed venues; where only a preprint exists (e.g. arXiv 2410.02605 on policy-gradient CPT-RL; Vamplew et al. 2024 AAMAS preprint), this is noted.
- The user's GitHub README (https://github.com/carlhenrikrolf/rl-sentience) describes the project as trying to disprove the hypothesis that LLMs relate feelings to spatial coordinates and to identify whether actor–critic critic outputs with feedforward connections correlate with self-reported feelings. None of the surveyed papers test this exact hypothesis in LLMs; the closest indirect support is the actor–critic interpretation of basal ganglia (Joel, Niv & Ruppin 2002; Takahashi, Schoenbaum & Niv 2008) and the Bennett, Davidson & Niv (2022) actor–critic Integrated Advantage model of mood.
- Conflicting claims (Rutledge vs Berridge on whether hedonic experience reduces to prediction error) are reported without taking a side; both lines of evidence are robust within their respective experimental paradigms.