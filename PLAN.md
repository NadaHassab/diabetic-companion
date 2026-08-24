# Diabetic Tracking App — Product Plan (Rev 2)

> "Not a mere app." A diabetes companion that pinpoints the individual, keeps them safe, and earns their trust for life.

**Revision notes (Rev 5):**
- Statistical humility in the calibration loop: single readings are *samples*, never verdicts; confounder tagging (portion/activity/stress/illness/sleep); matched-context comparisons only; explicit `still learning / emerging / established` confidence states; median ± IQR output; unexpected-spike confounder checklist before a sample counts toward a dish ranking
- Data provenance tiers (A = measured/cited, B = calculated/labeled estimate, C = dietitian review gate before swap numbers ship); Smart Koshari blog figures and mahshi 48g→16g explicitly re-labeled as recipe-level calculations, not lab facts
- New §4B Psychological safety escalation ladder: passive signal monitoring (incl. T1D + calorie-hyperfixation + insulin-omission pattern) mapped to 4 response rungs, with guardrails (never diagnose/label/sham/contact; no distress scores; clinician-reviewed signals and copy)
- Competitive gap claim reworded to its exact source with scope caveats (JMIR Diabetes 2025 e63278, carb-counting apps, N=196 single cohort)
- Rev 4: implementation spec for the two-layer Fix-my-favorite engine; Rev 3: Arabic Meals Studio; Rev 2: hypo protocols + ADA 2026 + psychology + store gates
- Added **§3B Arabic Meals Studio «مطبخ آمن»** — the flagship "not a mere app" feature: curated GI data for real Arab dishes, a smart-swap recipe-revamp engine, meal-sequencing coaching (veggies/protein first, carbs last), a personal post-meal glucose feedback loop, and Ramadan mode — with competitive analysis vs EEINA, i-Sukari, Ithnain, Bettera
- Rev 2 additions: clinically precise hypo protocols, ADA 2026 targets, psychology/compassion pillar, app-store launch gates (see notes below)
- Replaced generic "15-15 rule" with the clinically precise hypoglycemia protocol (levels 1/2/3, glucagon, exact fast-carb options, driving warnings)
- Hardcoded the ADA Standards of Care — **2026** glycemic targets (TIR >70%, TBR <4%/<1%, CV ≤36%, older-adult & pregnancy strata)
- Added a **psychology pillar**: diabetes distress (affects 20–40% of T1D patients), burnout, and diabulimia risk — with concrete design rules (no calorie hyperfixation, "good enough" framing, non-judgmental language)
- Added **app-store compliance requirements** (Google Play Health apps declaration, Apple privacy labels, "not a medical device" disclaimer) — these are launch gates, not afterthoughts
- Replaced "estimated A1C" with ADA's *Glucose Management Indicator (GMI)* terminology

---

## 1. Vision

Most diabetes apps are **loggers** — users log glucose and never look back. Design philosophy:

1. **Frictionless** — logging must take < 5 seconds. Every extra tap kills retention.
2. **Insightful** — show *trends*, not raw numbers. Turn data into one actionable change per week.
3. **Safe** — medically precise, clinically current, honest disclaimers, no unregulated dose calculators.
4. **Compassionate** — a patient's blood sugar is *data to understand, not a grade to pass*. No shame, no "perfect control" messaging.
5. **Respectful** — calm clinical UI, plain language ("blood sugar" not "blood glucose"), optional (not forced) gamification.
6. **Private** — local-first storage, explicit data control, GDPR/HIPAA-ready posture, store-compliant.

---

## 2. Target Users

| Segment | Pain points | What they value |
|---|---|---|
| **T2 / prediabetes, manual meter** | Post-meal spikes, carb counting, meds adherence, doctor visits | TIR, meal impact, medication reminders, doctor reports |
| **T1 insulin-dependent** | Dose decisions, hypoglycemia fear, carb counting burden | Safety protocols, glucagon awareness, CGM readiness |
| **Gestational** | Tight ranges during pregnancy | Personal ranges, education, reassurance |
| **Older adults (60+)** | Multiple conditions, hypo risk, cognitive/functional limits | More permissive targets, simpler UI, caregiver support |
| **Caregivers (later phase)** | Monitoring children/parents | Shared reading, alerts |

**Psychological reality (why most apps fail long-term):** Diabetes distress affects **20–40% of T1D patients** and underlies burnout, insulin omission, and *diabulimia* (insulin withholding for weight loss — life-threatening). The app must never add to the load: reduce taps, reduce judgment, reduce food obsession.

---

## 3. MVP Feature Set (build order)

### Phase 1 — Core loop (weeks 1–4)
1. **5-second glucose entry** — big quick-log button, pre-filled date/time, context tags (before/after meal, fasting, exercise, stress, sick day)
2. **Personalized onboarding** — diabetes type, medication/insulin regimen, age/health profile → personal targets per ADA 2026 strata (see §4)
3. **Time in Range (TIR) + Glucose Management Indicator (GMI)** — computed from logged values; the metric mySugr misses
4. **Color-coded logbook** — green/yellow/red by personal range, daily + weekly views

### Phase 2 — Safety & habits (weeks 5–8) — exact clinical content
5. **Hypo protocol card (Level 1, <70 mg/dL)** — *always* shown with a low reading:
   - 15-15 rule: eat **15 g fast-acting carbs** → wait **15 minutes** → recheck → repeat until >70
   - Fast-carb options (no fat/protein): 4 glucose tablets, ½ cup juice, 6 oz regular soda, 1 tbsp honey/sugar, 3–4 hard candies
   - **Not effective:** chocolate, ice cream, donuts (fat slows absorption)
   - After recovery: small balanced snack with protein to prevent re-drop
   - *Tell clinician if ≥2 lows/week*
6. **Severe hypo protocol (Level 2/3, <54 mg/dL or unable to treat self)**:
   - Immediately: **glucagon** (prefer needle-free nasal or ready-to-use injection); turn person on side; **call emergency services** if unconscious or no glucagon
   - **Do not give food/drink to an unconscious person**
   - "Do you have a glucagon kit?" checklist + renewal reminder — paired with "ask your doctor"
7. **Hyper guidance (<14-day risk flags)** — hydration, retest in 2h, seek care if: vomiting, fruity breath, confusion **or ≥250 mg/dL with ketone symptoms** (DKA warning), repeated daily >300
8. **Safety extras** — medical ID recommendation, "check before driving" reminder, emergency contact spot (professional protocol: never drive when low)
9. **Medication & testing reminders** — nag until taken, retest reminders after meals, configurable schedules
10. **Trend intelligence** — pattern detection: "morning fasting crept up 3 weeks straight," "high after 9pm snacks"
11. **Weekly Review** — 10-minute recap: top 2 spike triggers + ONE suggested change for next week

### Phase 3 — Doctor & support (weeks 9–12)
12. **Doctor-ready PDF report** — one page: TIR/TBR/TAR breakdown, mean glucose, GMI, hypo events, medication adherence, trends (per CGM-metric reporting standard)
13. **Food favorites + carb database** — favorites list (85.7% demand), carb values with **sources cited**, portion presets (S/M/L instead of grams)
14. **Compassionate feedback** — reinforce *tracking consistency*, never praise or punish glucose values; "blood sugar is information, not a judgment"
15. **Learning moments** — personalized education tied to the user's last out-of-range reading; plain language
16. **Distress & eating-disorder risk system** — light-touch checks + passive signal monitoring, with a defined escalation ladder (§4B). Never reactive-only: patterns like T1D + calorie hyperfixation + skipped insulin logging trigger higher-touch care-connection responses, not just "gentle resources."

### Phase 4 — Paid features (after validation)
| Feature | Why users pay |
|---|---|
| Meal photo scanning (AI) | Eliminates carb counting burden — highest-requested feature in 2025 studies |
| Cloud sync + multi-device + caregiver sharing | Recurring value |
| Advanced analytics (90-day patterns) | Power users |
| Coach/educator tier (later) | $45/mo market benchmark (HabitNu) |

### Phase 5 — Platform expansion (strategic, gated)
- **CGM integration (Libre/Dexcom)** — companion apps lack meal/metabolic features; bundling raises revenue/user 2.6x
- **HCP portal / clinic tier** — raises revenue/user to ~$830/quarter (app + device + HCP access)
- **Focus-mode switch for T1D food sensitivity** — option to *hide calorie displays entirely* (diabulimia-prevention request from research)

---

## 3B. Arabic Meals Studio — «مطبخ آمن» (the "not a mere app" feature)

### The problem
- Traditional Arab cuisine is carb-dense (white rice, pita, vermicelli, fried fatayer). Diabetes prevalence in the Gulf and Egypt is among the highest in the world — **yet almost no app serves native Arabic with culturally real solutions** (four of five competitors aren't natively Arabic).
- Patients are told "eat healthy" but never *how to keep their favorite dishes*. Result: they either suffer or abandon the app.

### Competitive scan (who's there, what we beat)
| App | What they do | What they miss |
|---|---|---|
| **EEINA** (Saudi, the closest) | ~12,000 native Arabic recipes, GI on every dish (WHO/2008 tables), doctor PDF report in Arabic, family mode, local payment (Mada/STC Pay), Saudi-hosted | **No connection to the user's own glucose logs; no post-meal feedback loop; recipe-only (no "fix my favorite" learning); no meal-sequencing coaching** |
| i-Sukari (Qatar) | Food + glucose tracking, community food base, caregiver view | No GI intelligence, no recipe revamping |
| Ithnain | Specialist consultations (Jordan) | Consultation marketplace, not daily food solutions |
| Bettera (India) | AI meal plans from blood report + cuisine selection incl. Middle Eastern | Not Arab-market native, no measured GI database |

**Our wedge:** recipe *revamping* + *personal glucose feedback* — take grandma's koshari, produce the "Smart Koshari," then *close the loop*: user eats it → app compares their 2h post-meal reading against the meal → learns their personal response. *(Note: the widely-circulated Smart Koshari figures — GI 75→45, carbs 85g→45g — originate in nutrition-blog recipe math, not peer-reviewed measurement; we treat them as Tier-B calculated estimates pending dietitian review, per the provenance tiers below.)*

### The science built in (evidence-based content engine)
1. **Curated GI/GL database for real Arab dishes** — not crowd-sourced (unreliable food data = #1 trust killer; cite sources on every card):
   - Mjadara (lentils+rice): **GI 24** · Stuffed grape leaves: **30** · Hummus: **15** · Lentils: **29** · Chickpeas: **10** · Khalas dates: **36** (dates + yogurt: 29) · Biryani chicken: **52** · Harees: **42** · Brown rice: 55 · Burghol: 48 · Freekeh: low
   - The heavy hitters to revamp: white basmati rice **84**, white pita **67** (tannour white 81), awama 81, fatayer cheese/zaatar 80, thareed beef 74
   - (Sources: tDNA-Middle East consensus, Frontiers in Nutrition 2022; UAE GI study, BJN 2017; Lebanese mixed-meal GI studies; Alkaabi dates study 2011; hummus GI=15, Nutrition Journal 2016; 2008 International GI Tables/WHO)
2. **Smart-swap engine** (each swap shows before/after GI + carb drop):
   - white rice → basmati/brown/freekeh/burghul/cauliflower rice
   - white flour → wholemeal/chickpea flour; frying → baking; ghee → olive oil
   - sugar → date purée (GI 36); vermicelli → lentils (koshari rule: equal lentils:rice)
   - mahshi rule: cauliflower rice + lean meat filling (48g → 16g carbs per serving is a **recipe-level calculation** from a published recipe analysis, not a lab measurement — Tier B)
3. **Meal sequencing — the free vegetable trick the user asked about («سلطتك أولاً»):**
   - Eat in order: **vegetables → protein → carbs last**. Randomized trials show protein/veg-first order cuts post-meal glucose iAUC up to ~40–55%, via GLP-1 release + delayed gastric emptying (PATTERN study, Cell/PubMed 2019; systematic reviews 2025–26; GDM food-order study 2024; MDPI Nutrients 2020 review; Japanese set-meal study 2025 — even 5 minutes of veg/protein leads suppresses peaks)
   - For every saved meal, the app shows the **eating order card**: start with the salad, end with the rice — no deprivation, pure behavior change
   - Honesty note: meta-analysis of *chronic* A1C improvement is still low-certainty → present as "lowers the spike at that meal," not a cure
4. **Personal response loop (the differentiator nobody has):**
   - Log meal → reminder to log 2h post-meal reading → app computes that meal's personal spike and color-ranks it *for this user* ("koshari spikes you +80; mahshi +20")
   - Over time: personal favorites list ranked by *their own* glucose response, not population averages
5. **Ramadan mode** (regional necessity, per tDNA-ME): suhoor guidance (protein+fat for satiety), iftar sequencing (water → dates in moderation → soup/veg → protein → carb last, spaced), hypo-watch guidance during fasting, medication-adjustment reminder to *ask doctor before fasting*
6. **Vegetable-first habit builder:** daily 1-minute nudge — "start today's lunch with سلطة/خضار" — ties vegetables directly to glucose (fiber delays absorption); content in plain Arabic, RTL-first UI

### Implementation — the two-layer engine (estimate → calibrate)

**Design principle: don't fight ingredient/method variation, measure it.** Exact GI of a family recipe is unknowable — so the engine never claims precision.

**Layer 1 — Estimate (rules engine, honest ranges):**
- Recipes modeled as **ingredient roles**, not gram lists (brittle). Each dish = roles: `starch core`, `protein`, `fat/crunch`, `sauce`:
  - كشري → starch core (rice+vermicelli+macaroni), protein (lentils, GI 29 gold), fat/crunch (fried onions), sauce (tomato, sugar knob)
  - محشي → starch core (rice filling), protein (meat), veg shell (fiber bonus)
- **Swap library keyed by role** — each swap carries: `from`, `to`, `estimated effect`, `source`, `honesty flag`:
  - white rice → basmati/brown/freekeh/burghul/half-cauliflower-rice (mahshi numbers: 48g → 16g carbs)
  - frying → baking/air-fryer; ghee → olive oil; sugar → date purée (GI 36)
  - lentil rule: equal lentils:rice halves the response (koshari)
- **Method-profile interview (4 questions max)** captures cooking variability: "fried or baked?", "rice soft-boiled or firmer grains?" (overcooking ↑ gelatinization), "chilled & reheated or fresh?" (cooling → resistant starch ↓), "ghee or oil?"
- Every estimate displayed as a **range + confidence**, plus "verify with your body" prompt — trust built on honesty, per §4

**Layer 2 — Calibrate (personal feedback loop, engineered for statistical humility):**
1. User saves dish → applies 1–3 fixes → "My Smart version" card (version-tagged)
2. Eats it → logs meal with version tag **+ confounder tags** (portion S/M/L, exercise, stress, illness, sleep) → 2h post-meal reminder fires
3. **A single reading is never a verdict.** Each spike is a *sample*, not a measurement: it carries meter error, day-to-day variation, and confounders. Attribution only happens after confounders are filtered — same-dish comparisons are made only within matched context (e.g., same portion size, no illness tag)
4. **Confidence states, shown explicitly** — the app never prints a number it can't stand behind:
   - `still learning` (<3 matched samples — shows samples only, no ranking)
   - `emerging` (3–6 matched samples — median, not single values)
   - `established` (≥7 matched samples — median + spread, re-flagged every 30 days)
   - Output is always *median ± IQR*, phrased as a pattern hypothesis ("for you so far: usually mild"), never a lab-grade fact
5. **Unexpected spike on a "safe" dish → confounder checklist, not dish blame:** "This looked different from your usual pattern — anything off? portion, stress, illness, activity?" Only after the user clears confounders does a sample count toward the dish's ranking. This is the anti-pattern that would otherwise destroy trust
6. Per-user swap effect (e.g., "freekeh works for you, brown rice doesn't") only ever surfaces at `established` confidence — otherwise it's suppressed

**Flow (MVP):** pick favorite dish by region/type → 3–4 method questions → fix cards (each: effect + how-to + source) → apply fixes → eat/measure → personal spike ranking. Photo-scan dish detection = Pro phase.

### Content & trust rules
- **Data provenance tiers** — every number ships with its tier, visible on the card:
  - **Tier A (measured):** peer-reviewed GI/GL values (2008 International Tables/WHO, tDNA-ME, UAE BJN 2017, dates studies, etc.) — cited inline per item
  - **Tier B (calculated):** macronutrient/carb deltas derived from recipe composition (e.g., cauliflower-rice mahshi math, Smart Koshari blog figures) — **labeled "calculated estimate,"** never presented as lab-measured
  - **Tier C (review gate):** no Tier-B swap effect reaches users until a registered dietitian / CDCES has signed off on the swap math. Ship order: seed database → dietitian review → publish. Until sign-off, the app shows ranges and "direction of effect," not specific deltas
- No user-generated GI values (EEINA cites WHO/2008 tables; user-submitted food DBs are the documented #1 error source in research)
- Arabic is the native language (dialect-adaptable: Egyptian/Saudi/Levantine variants for dish names), RTL throughout
- Regional dish coverage by country: Egypt (koshari, ful, molokhia, mahshi), Levant (fattoush, mujadara, kibbeh), Gulf (kabsa, machbous, harees), Maghreb (couscous, harira)
- Medical disclaimer: educational food guidance, not clinical prescription — consistent with global safety framework §4

### Monetization mapping
- Free: smart-swap library + meal-sequencing cards + Ramadan mode (safety/trust = free)
- Pro: photo-scan meal → auto-detected dish + revamp suggestions; personal spike-ranking library; doctor-ready food report (Arabic/English, like EEINA's — but *with glucose correlations*)
- Local-market play (MENA): Arabic store listings, local payment methods (Mada, STC Pay, wallet), data hosted regionally (Saudi PDPL / Egypt data law) — matching EEINA's trust pitch

---

## 4. Medical Safety Framework (non-negotiable)

### Clinical standards — ADA Standards of Care 2026 (hardcoded targets)

| Metric | Goal — most adults | Goal — older adults (complex health) | Note |
|---|---|---|---|
| A1C | <7.0% | individualized | Lower OK if no severe hypo risk |
| TIR 70–180 mg/dL | **>70%** (≥17h/day) | >50% (≥12h/day) | Pregnancy TIR 63–140 |
| TBR <70 mg/dL | **<4%** (<1h/day) | **<1%** (≤15 min/day) | |
| TBR <54 mg/dL | **<1%** | <1% | Level 2 hypo |
| TAR >180 mg/dL | <25% | <50% | |
| TAR >250 mg/dL | <5% | <10% | Level 2 hyper |
| Glucose variability (CV) | **≤36%** | — | >36% linked to hypo events |
| Fasting (preprandial) | 80–130 mg/dL | individualized | |
| Post-meal peak | **<180 mg/dL** | individualized | |

- **Glucose value tiers** (fixed, medically standard): ≥300 = urgent hyper; **>250 w/ ketone symptoms = seek care**; <70 = hyp level 1 (treat); **<54 = hyp level 2 (immediate treatment, recheck); unconscious/unable-to-treat = level 3 emergency (glucagon + EMS)**
- All targets must be **individualizable** (pregnancy, older adults, hypo-unawareness) — a goal mismatch is a safety risk in itself
- **GMI label** (not "estimated A1C"): explanation shown that GMI is a *derived estimate* from glucose values, not a lab A1C

### What we may build (regulator-safe)
- Glucose logging, carb counting, TIR/GMI estimates, reminders, alerts, education content, reports

### What requires regulation (DO NOT ship unregulated)
- **Insulin dose calculation / bolus advice** = Medical Device Software (MDSW) under EU MDR 2017/745, Class IIa+, requires CE mark, notified body, ISO 13485 QMS, IEC 62304 lifecycle — **and FDA has recalled bolus calculators over dosing errors.** Build only after regulatory pathway is engaged. (Not even a "pro tip" hint of doses.)

### Built-in safety by design
- **Disclaimer + scope screen** — app supports self-management; treatment decisions remain with clinician; "not a medical device and does not diagnose, treat, cure, or prevent any medical condition" (exact store-required wording)
- **Never display a danger threshold without a "what to do" path** — every red-zone reading opens its protocol card
- **Input sanity checks** — impossible values (0, >600 mg/dL) flagged for confirmation
- **Symptom-aware prompts** — "seeking care" criteria listing concrete symptoms (vomiting, fruity breath, confusion), never vague alarm
- **Knowledge checks** — one-time "what would you do at 55 mg/dL?" quiz during onboarding (safety + trust)

### Compliance checklist (launch gates — stores will review this)
- [ ] Google Play: **Health apps declaration form** + Data safety form + privacy policy on public non-geofenced URL; disclaimers; Health Connect permission justifications (only if used)
- [ ] Apple App Store: **App Privacy "Nutrition Label"** (health data type), AppTrackingTransparency only if tracking (we won't), HealthKit privacy rules (later phase)
- [ ] EU: GDPR DPIA for health data (special category), MDR MDSW qualification review (MDCG 2019-11)
- [ ] US: HIPAA-ready posture only if PHI exchange with covered entities; FDA wellness-app guidance (low-risk tracking = not a device as long as no dose recommendations)
- [ ] IEC 62304 software lifecycle documentation from day 1
- [ ] Local-first storage; encryption at rest; full export + delete-all; no third-party ad SDKs (health data resale is prohibited by stores)

### 4B. Psychological safety — distress & eating-disorder escalation policy

**Why it exists:** diabetes distress affects 20–40% of T1D patients and underlies burnout, insulin omission, and diabulimia (insulin withholding — life-threatening). A passive monthly mood check is *not* an adequate response to the T1D + calorie-hyperfixation + insulin-omission profile. Apps in this space can cause real harm through silence or through shaming; neither is acceptable.

**Passive signals (computed locally from the user's own logs — no extra burden):**
- T1D + repeated unlogged insulin at meals (skipped bolus pattern)
- Calorie/macro viewing hyperfixation + weight-goal emphasis, or meal logging that collapses toward near-zero carb only
- Missed glucose-logging + missed-medication streaks
- Repeatedly unaddressed post-meal spikes alongside avoiding care
- Elevated distress check responses / rising stress tags

**Escalation ladder (signal pattern → response):** every rung is factual, compassionate, and non-clinical; **the app never diagnoses, never labels, never contacts anyone, and never shames.**

| Rung | Trigger pattern | Response |
|---|---|---|
| **0 — Always on** | Baseline | "Blood sugar is information, not a grade." Weight loss is *never* praised (confirmed harm per ED literature); calories optionally hidable; gamification never rewards weight or glucose value |
| **1 — Flag** | 1 recurring pattern (e.g., ≥3 missed meal insulins in 2 weeks) | In-app education: diabetes-distress explainer, self-compassion content; resource card (diabulimia helpline, NED helpline, local services); "this pattern is common and not your failure" framing |
| **2 — Elevated** | ≥2 patterns sustained 4+ weeks, or elevated distress responses | Direct suggestion to speak with their care team + psychologist; concrete talking points for that conversation ("how to tell your doctor you've been skipping boluses"); resources repeated without alarm |
| **3 — Safety-critical** | Severe hypo events (level 2/3), ketone symptoms with hyper, any "seek care" criteria (see §4 protocols) | Protocol cards + seek-care guidance per §4; compassion-first framing; no judgment of the *reason* for the pattern |

**Guardrails:** signals stay on-device (privacy); nothing is graded or scored for the user (no "distress score" — scores invite gaming and shame); escalation phrasing is written and user-tested for judgment-vocabulary (ties to §6 Compassion check); a clinician (dietitian + psychologist) reviews the signal definitions and all rung-1/2 copy before ship.

---

## 5. Revenue Strategy (from market research)

| Model | Reality check | Our tier |
|---|---|---|
| Freemium subscription | 45% of providers; mySugr $43/yr; GluKee free + Pro | **Free core** (logging, TIR, reminders, ALL safety protocols) + **Pro ~$5–10/mo** (meal scan, cloud, advanced reports) |
| Coaching | $45–449/mo market (HabitNu, Nutrisense) | Later: education tier with certified educators |
| Bundles with devices | app ~$185/quarter; +device $490; +HCP $830 | After CGM integration |
| Reimbursement/B2B | 6.5x price difference vs self-pay | Long-term: clinic portal, employer/insurer programs |
| Hardware partnerships | Roche/Abbott give free Pro to syncing users | After traction |

**Positioning hook:** *Everything mySugr does, plus TIR, meal scan, meds, and a calm clinical UI — with a doctor-focused report and the 2026 clinical standards built in. Safety content is free. Always.* (Gap source, verbatim claim: JMIR Diabetes 2025 carb-counting needs survey [e63278, N=196] — of the 16 carb-counting apps its T1D cohort used, *none offered personalization for individual diabetes characteristics*, and only one offered bolus calculation or HCP support. Scope caveat for diligence: single-survey cohort, carb-counting app domain only — suggestive of a gap, not a market census.)

---

## 6. Key Metrics

- **Activation:** % completing onboarding → logging within 24h
- **Habit:** logging streak, 3+ entries on 5/7 days after week 2
- **Retention:** return after week 1 (benchmark 85%), week 2 (71%), D30/D90
- **Clinical proxy:** TIR improvement over 90 days, hypo events logged, % users who viewed a protocol card during a low
- **Trust:** crash-free rate, notification reliability (broken alerts = #1 review complaint)
- **Compassion check** (qualitative): user-test wording for shame/judgment vocabulary

---

## 7. Research Sources

- **ADA Standards of Care in Diabetes 2026** (Diabetes Care, Jan 2026): glycemic goals 6.1–6.4, CGM metrics table (TIR/TBR/TAR/CV/GMI), individualized goals, pregnancy section 15
- ADA/CDC/Mayo Clinic hypoglycemia guidance: 15-15 rule, level 1/2/3 definitions, glucagon administration (nasal/pre-mixed), driving warnings
- JMIR Diabetes 2023/2025: SDT motivation features, carb counting needs survey, device integration review
- Journal of Eating Disorders 2023: diabetes distress & diabulimia — distress-informed design; PAID/DDS screening
- PLOS One: multi-national user preferences (nutrient values 56.7%, BG tracker 54.8%, analytics 42.9%)
- ADA/EASD consensus report: digital diabetes app safety & efficacy
- EU MDR 2017/745 + MDCG 2019-11; FDA wellness-app guidance
- Google Play Health apps policy & Health Connect developer policy; Apple App Store privacy nutrition labels
- Market data: research2guidance pricing survey, Dexcom/Signos/Nutrisense disclosures, app comparison guides
- **Arabic nutrition science:** tDNA-Middle East consensus (Frontiers Nutr 2022); UAE GI/GL study (Br J Nutr 2017); Lebanese mixed-meal GI; date GI studies (Alkaabi 2011); hummus GI study (Nutr J 2016); NDSS Arabic GI guides; UK KnowDiabetes Arab community plans
- **Meal sequencing:** PATTERN study (2019); systematic reviews (Clin Nutr Res 2026; DRCP meta-analysis 2022; MDPI Nutrients 2020); GDM food-order trial (Frontiers Nutr 2024); Japanese set-meal CGM study (Nutrients 2025)
- **Competitor benchmarks:** EEINA (Saudi), i-Sukari (Qatar), Ithnain (Jordan), Bettera (AI cuisine meal plans)

---

## 8. Next Steps

1. Scaffold Flutter project (mobile-first, local storage first, cloud later)
2. Define data models: `GlucoseEntry`, `Meal`, `Medication`, `Profile` (with ADA target strata), + `Recipe`/`Swap`/`MealSequence` for the Arabic Meals Studio
3. Build Phase 1 core loop → test with real diabetic users before Phase 2
4. Write IEC 62304-style docs alongside code from the start
5. Draft the store-required privacy policy + "not a medical device" disclaimer text now (they gate launch)
6. Prototype Arabic Meals Studio content pipeline: seed GI database (Tier-A sourced values only) for 50 top dishes; **no Tier-B swap numbers ship until a registered dietitian/CDCES signs off (hard gate, per Tier-C review rule)**