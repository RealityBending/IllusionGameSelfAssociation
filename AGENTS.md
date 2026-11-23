# IllusionGameSelfAssociation

An online study (Université Paris Cité) of psychedelic users and
psychedelic-naïve adults on two tasks: the **Illusion Game** (Ebbinghaus,
Müller-Lyer, vertical-horizontal) and a **self-association task** (shapes
matched to self / friend / stranger labels), with questionnaires (AAQ-II,
DASS-21, MEQ-30). Two manuscripts come from it, one per task. This file is the
orientation; it was written on 2026-11-02, while the illusion paper's analysis
was being redone as a single cognitive model.

> **Cluster-level instructions live in the lab HPC hub**:
> <https://github.com/RealityBending/Lab/tree/main/hpc> (start at `hpc/README.md`).
> Prefer a local clone of `RealityBending/Lab` if there is one — it also holds
> your gitignored `hpc/private/` notes. The hub wins over anything here that
> contradicts it; `analysis/server/README.md` holds what is specific to this
> project.

## Where things are

### Raw data — not in git, and keep it that way

- **`~/Box/Data/IllusionGameSelfAssociation/`**: one raw jsPsych file per
  session, `<participant id>.csv`, 199 files (copied 2026-11-02). This is the
  source for everything, but only `analysis/0_deidentify.R` reads it, through
  `IGSA_RAW_DIR`, which defaults to that path.
- `~/Box/IllusionGameSelfAssociation/` (`All/`, `Controls/`) is an older,
  partial copy. Its 114 files (March 2026, in `All/`) are byte-identical to
  files in `Box/Data`, and `Controls/` is empty (checked 2026-11-04). Use
  `Box/Data`.
- `osfstorage-archive/` is an older export (February 2025) of 150 of them,
  byte-identical, so it lacks everyone tested after that. Do not use it.
- What a raw file holds:
  - Consent and demographics (`demographics_1`, `demographics_2`).
  - Screening (`experiment/demographics.js`), which differs by arm: unnamed
    `html-button-response` and `survey-text` rows, whose question text is in
    `stimulus`.
  - Questionnaires (`questionnaire_*`).
  - The self-association task (`sat_*` screens).
  - The Illusion Game (`IG_*` screens): 24 practice trials and 480 test
    trials in blocks A and B, 160 per illusion. RT `rt` is in ms;
    `Illusion_Strength` and `Illusion_Difference` are in each illusion's
    units.
  - Identifying fields, which must never leave Box:
    - Session date and time; browser, OS and screen size.
    - Free-text diagnoses and country.
    - `control_T0_bis`'s "last four digits of your phone number", an
      unlabelled `survey-text` row right after the consent.
    - `label_friend`, the friend's first name typed for the self-association
      task. jsPsych copies it onto **every row**, Illusion Game trials
      included.
- **The arm is the `group` URL parameter**, stored in every row:
  - `control` and `control_T0_bis`: psychedelic-naïve controls.
  - `psychedelic_society` (French) and `psychedelics_soc_english`: users.
  - `control_T0`, `ketamine_*`, `*_T1`: a separate longitudinal arm, **not**
    in the illusion paper. What it holds (checked in the raw files,
    2026-11-04):
    - **Retest, controls only:** 8 `control_T1` sessions, each linked by the
      phone digits to a different `control_T0_bis` session (the English
      controls) 7–15 days earlier, all with the full Illusion Game.
    - **No retest for users:** there is no `psychedelics_T0` session, and the
      one `psychedelics_T1` session links to nothing. One `ketamine_T0` →
      `ketamine_T1` pair, its T1 with 480 Illusion Game trials. The
      meditation pages were never used.
    - **`control_T0`:** 52 English sessions with the full Illusion Game, aged
      20–58 (median 29). Its screening differs: lifetime frequency and use
      "in the last 6 months", with no last-month or days-ago question. 32 had
      never used a psychedelic (median age 28.5, 13 aged 30 or over), 20 had,
      4 of them in the last 6 months.
    - **Not in `data/open/`.** Using any of it needs `0_deidentify.R`
      extended and the consent checked, since it was collected for another
      study.
- **The repo is public, and its history holds the data.** Decided
  2026-11-02: that stays, but nothing more goes in. `data/*.csv` and
  `osfstorage-archive/` are in `.gitignore`, and the data were
  taken out of the index on 2026-11-03 (`git rm -r --cached`; the files stay
  on disk). Pulling that commit deletes a collaborator's local copies. The
  files are still in Box and in the history. Never add raw or processed data
  files to git. The one exception is `data/open/`.
- **The illusion paper is no longer gitignored** (Dom, 2026-11-21: "remove
  from gitignore the paper and its files (just keep gitignored the other
  paper on the self association task)"). `paper/*.docx` was the rule; it is
  now `paper/Article associative memory*.docx` only. So the illusion paper's
  Word files can be tracked: `paper.docx`, Marco's commented export
  (`Manuscript_Psychopharmacology_*.docx`) and the earlier
  `Article_visual_illusions_*.docx` with their reviews. Never add the
  self-association manuscripts.

### Open data in `data/open/` (in git)

The de-identified dataset, decided 2026-11-03, and the starting point of
every analysis script. `data/open/README.md` is its codebook.
- **`participants.csv`:** 127 sessions. It holds demographics, screening, the
  last psychedelic experience and the questionnaire items (unscored).
- **`illusiongame.csv`:** all 64,008 Illusion Game trials, practice included.
- **`selfassociation.csv`:** all 44,253 self-association trials of the 125
  sessions that reached the task, practice included. Labels are given as
  roles (Self / Friend / Stranger).
- **Built by** `analysis/0_deidentify.R` from Box.
  - Every column is built from a named field or a recognised question. Nothing
    is copied wholesale, so the identifying fields above stay out.
  - Its privacy checks found no raw ID, friend name, celebrity label,
    diagnosis text, country or phone digits in any of the three files
    (2026-11-03).
- **Which sessions:**
  - All sessions of the four arms, so the exclusions can be redone from the
    open data.
  - Not the longitudinal arm, and not jckbwy5hlw (not genuine).
- **IDs:** `S001`…`S127`. The key to the raw IDs is
  `data/participant_key.csv`, which is gitignored and private. Rerunning
  keeps existing numbers.
- **The consent form** promised that answers would be anonymised and that no
  identifying information is collected. It does not mention public sharing,
  so the PI (Baptiste) should confirm before this is pushed.

### Processed files in `data/` (derived or legacy; gitignored)

| file | from | caveats |
| --- | --- | --- |
| `rawdata_participants.csv`, `rawdata_aaq.csv`, `rawdata_dass.csv`, `rawdata_MEQ_psychsoc.csv`, `rawdata_psychedelics.csv`, `rawdata_practice_sat.csv` | Baptiste's Python preprocessing (deleted from the tree on 2026-11-04, in the git history before that), last run in 2025 on `osfstorage-archive/` | 144 sessions only; mixes in the longitudinal arm; double-encoded accents (`UniversitÃ©`, from reading UTF-8 as latin1); ages as typed (6 fixed by hand on 2026-11-02, uncommitted); `Psychedelics`, `Afterglow`, the psychiatric and meditation columns are **raw button indices (0 = yes)** |
| `rawdata_control_IllusionGame.csv`, `rawdata_control_participants.csv` | Oliver, June 2026 | the 43 controls *before* the paper's two exclusions, and without two controls the paper includes |
| `participant_key.csv` | `analysis/0_deidentify.R` | **private**: raw ID → open ID |
| `groups.csv` | `analysis/0_preprocessing.qmd` | Never / Past / Recent; see below |
| `questionnaires.csv` | `analysis/0_preprocessing.qmd` | AAQ-II, DASS-21 and MEQ-30 scores, every session with items |
| `data_illusiongame.csv` | `analysis/0_preprocessing.qmd` | the trial-level input of the model |
| `script_analyse_*.R` | — | analyses of the self-association task, not the illusions |

### Scripts

| | |
| --- | --- |
| `analysis/0_deidentify.R` | Box raw files → `data/open/` (and the private key). Only whoever holds the raw files runs it |
| `analysis/0_preprocessing.qmd` | the open data → the derived files, and the report `analysis/0_preprocessing.html`: Never / Past / Recent with the exclusions → `data/groups.csv`; the sample per group (Table 1, ages); the questionnaire scores, their missing-item rule and reliability → `data/questionnaires.csv`; the test trials of everyone in `groups.csv`, cleaned and scaled → `data/data_illusiongame.csv`. Each section stops the render if a count changes. ~15 s |
| `analysis/2_priors.R` | IllusionGameComputational's surfaces projected onto this design → the prior centres hard-coded in `models.R`, for the LNR and the DDM-5 check. It reads IGC's prediction and prior-check files from `../IllusionGameComputational` (`IGSA_IGC_DIR`); run it only when the priors change |
| `analysis/3_ddm_groups.qmd` | **the paper's model since 2026-11-18.** The DDM-5 fit (`analysis/models/ddm5.rds`) at the population level → `analysis/3_ddm_groups.html`, `analysis/results/ddm_groups_{means,contrasts,averaged,averaged_means,slopes}.csv` and `ddm_ppc_{densities,errors,curves}.csv`. The same sections as `3_lnr_groups.qmd`, with the DDM's parameters (drift, boundary, start point, ndt, `sigmadrift`; discriminability is −drift), its response-time densities from `cogmod::dcogmod_ddm()`, and its posterior predictive check through cogmod's vectorised `posterior_predict_cogmod_ddm()`. `modelbased` handles its parameters (softplus and logit links included) and agrees with `marginals.R` to 1e-15. Needs cogmod ≥ 0.3.6. ~9 min |
| `analysis/4_ddm_correlates.qmd` | the DDM-5 at the participant level, as `4_lnr_correlates.qmd` with the boundary in place of speed → `analysis/4_ddm_correlates.html`, `ddm_participants.csv`, `ddm_correlations.csv`, `ddm_correlates.csv`. Since 2026-11-21 also, on users only, the regressions on the time since the last use (log10 days from `data/groups.csv`, alone and with age) and on Group and lifetime use (the six answer categories, scored 1 to 6). ~1 min |
| `analysis/3_lnr_groups.qmd` | (the paper's model until 2026-11-18; kept as the record) the merged fit (`analysis/models/lnr.rds`) → the report `analysis/3_lnr_groups.html` and `analysis/results/lnr_groups_{means,contrasts,averaged,averaged_means,slopes}.csv` and `lnr_ppc_{densities,errors,curves}.csv`, all at the population level: convergence, each group's parameter surface, the predicted RT distributions per group (correct above, errors below), the posterior predictive check (100 draws simulated with the participant effects in, against the observed error rates, median RTs and RT distributions), the Past − Never, Recent − Never and Recent − Past contrasts per illusion and parameter, across strength and as two numbers (at strength 0; in the 0 → 1 effect) at mid difficulty; the contrasts averaged over the whole design (`modelbased::estimate_contrasts()` per parameter, `marginals.R` for the derived quantities, the two cross-checked) and the per-group values behind them; the marginal slopes of strength and difficulty per parameter (`estimate_slopes()`) with their group contrasts; and the illusion magnitude index per group. ~9 min |
| `analysis/4_lnr_correlates.qmd` | (LNR, kept as the record) the fit at the participant level → `analysis/4_lnr_correlates.html`, `analysis/results/lnr_participants.csv` (every participant's indices per illusion and averaged, with age and scores) and `lnr_correlates.csv`: the indices per group, their correlations across illusions, and what age, native language, student status, AAQ-II, DASS-21 and (users only) MEQ-30 account for of the group differences, by per-draw regressions, with the raw-trial summaries as the unshrunk check. Needs `data/questionnaires.csv`. ~2 min |
| `analysis/5_ddm_vs_lnr.qmd` | the DDM-5 fit (`analysis/models/ddm5.rds`) against the LNR's, to decide whether the paper switches model → `analysis/5_ddm_vs_lnr.html` and `analysis/results/ddm5_*.csv`: sampling diagnostics, PSIS-LOO on ~1,000 draws each, posterior predictive checks (error rates, median RTs, RT percentiles, distributions), the matched group contrasts averaged over the design, the illusion magnitude and its components, participant-level agreement, a crude age check, and a summary at the end. Reads `lnr_participants.csv` from `4_lnr_correlates.qmd`. Needs cogmod ≥ 0.3.6. ~20 min. **Stays on the 118-participant fit**, like the LNR it is compared with: re-render it with `IGSA_FIT_DDM=analysis/models/ddm5_n118.rds`, since its default, `ddm5.rds`, is the 117-participant fit since 2026-11-22. The paper does not read its outputs. |
| `analysis/server/` | the model and its cluster workflow (`README.md` there): `models.R` (formula, priors), `fit_model.R`, `combine_model.R`, `marginals.R`, `./hpc` |
| `experiment/` | the task: one entry page per arm (`*.html`), `demographics.js` (screening), `questionnaires.js`, `SelfAssociation/`; the Illusion Game stimuli load from `realitybending.github.io/IllusionGame/v3` |

Run from the repo root. Rscript on Dom's laptop is `"/c/Program
Files/R/R-4.5.3/bin/Rscript.exe"`, which is not on `PATH`; the reports render
with Quarto, which there is RStudio's bundled copy and needs `QUARTO_R` to
find R:

```bash
Rscript analysis/0_deidentify.R   # only with the raw files; data/open/ is in git
quarto render analysis/0_preprocessing.qmd
QUARTO_R="C:/Program Files/R/R-4.5.3/bin" "/c/Program Files/RStudio/resources/app/bin/quarto/bin/quarto.exe" render analysis/0_preprocessing.qmd   # Dom's laptop
```

The rebuilt pipeline, open data → `0_preprocessing.qmd`, reproduces the
raw-based one exactly (checked 2026-11-03). The groups and all 55,937 rows of
`data_illusiongame.csv` are identical once the IDs are mapped. The document
replaced the scripts `0_groups.R` and `1_data.R` on 2026-11-04, with both
derived files byte-identical before and after. `0_deidentify.R` stays a
script, because it reads the private raw files.

### Manuscripts (`paper/`; only the self-association paper is gitignored)

- **Revised on 2026-11-21 after Marco Sperduti's review**
  (`paper/Manuscript_Psychopharmacology_Dominique_UPDATED_MS.docx`: 36
  comments, in French, and tracked edits, on a Word export of the paper). Dom:
  "do the refit without the 16, and implement the fixes you recommended". The
  version before is `paper/paper_before_marco_2026-11-21.{qmd,pdf}`.
  - **Sample:** the control who stated an age of 16 is excluded (see "Groups"),
    so 117 participants, and the model was refitted (commands in
    `analysis/server/README.md`, "The 117-participant refit"; outcome in the
    DDM-5 entry below). The reports and the paper rest on that fit since
    2026-11-22, and no finding changed.
  - **New analysis:** among users, the indices against the time since the last
    use and the lifetime number of uses (`4_ddm_correlates.qmd`). The paper
    reports them in "Age, Demographics, Questionnaires and Psychedelic Use",
    and its setup chunk `stopifnot()`s that neither relates reliably to the
    illusion magnitude or to the boundary.
  - **Introduction:** REBUS's prediction is conditional on how much an illusion
    depends on high-level priors. The afterglow sentences moved into a new
    paragraph after the acute evidence, with the applied interest (Aday 2020,
    Knudsen 2023). The Illusion Game paragraph leads with three advantages
    over classical procedures, and the point-of-subjective-equality analogy is
    in the Methods only. The graded prediction (recent < past < naïve) is
    attributed to the afterglow, not to REBUS. Manning's three methods are
    named.
  - **Methods, checked in the task's code and the data:** the order of the
    illusions was Müller-Lyer, Ebbinghaus, vertical-horizontal, block A before
    B, for every participant (the task's code asks for random orders, but
    `randomize_order` does nothing on a timeline without variables, and the
    shuffled list `igs` is never used). A speed-and-accuracy score (100 −
    IES / 35) was shown after each test block. The self-association task came
    first, and the AAQ-II and DASS-21 between the two series of blocks. The
    stimuli are 800 × 800 px images shown at native size, and the real
    differences are relative (5–50%, 4.5–45%, 3–30%). No trial has a response
    time of zero: all those removed are ≥ 6 s. The removals are given per
    group; the six removed blocks are all Ebbinghaus. Lifetime use was a
    seven-category choice. Three past users gave no number of days and were
    classified from the yes/no question. "Reliable" is defined as a 95%
    interval excluding zero.
  - **Discussion:** age is presented as a candidate explanation of the wider
    boundaries that the regressions cannot rule out (one naïve participant aged
    31–50). The error effect is said to hold on the Ebbinghaus only. The
    lasting-change interpretation cites the long-term literature (Aday 2020,
    Knudsen 2023, Bouso 2015) but stays one of three. A passage on the
    differences between illusions cites Cretenoud 2019, Axelrod 2017, Chouinard
    2013, Navarrete 2025 and Jastrzębowska 2026, which did not replicate the V1
    surface-area result that the paper cites from Schwarzkopf 2011.
  - **References:** seven added, each found on Crossref and its PubMed abstract
    read on 2026-11-21.
  - **Not taken from Marco:** "sensory processes" for "perception"; "reaction
    time"; a chance-level criterion for removing blocks (a binomial test
    against 50% would flag five of the same six); Figure 2A redrawn over all
    participants; boundary optimality; the lasting change as the main
    interpretation; "(boosting the illusion)", "for the first time", "as
    accurate as possible" (the instruction said "without making errors").
  - **Still open:** why these three illusions were chosen (a TODO comment in
    the Introduction's last paragraph; nothing in the repository says), and
    why the data were frozen in April 2026 (Marco asked; the three later users
    are still out).

- **Switched to the DDM-5 on 2026-11-18** (Dom: "let's swap the model reported
  in the paper. Let's not mention the lnr at all anymore", after
  `analysis/5_ddm_vs_lnr.qmd`; no refit with constant boundary and start point,
  which was proposed and declined). The version before is
  `paper/paper_before_ddm_2026-11-18.{qmd,pdf}`. The paper now reads
  `analysis/results/ddm_*.csv` (`3_ddm_groups.qmd`, `4_ddm_correlates.qmd`),
  and the PDF has no mention of the race (checked by text search). What
  changed, beyond the numbers:
  - **Methods:** the model paragraph describes the DDM's five parameters
    (drift v towards the correct response, boundary a as caution, start point
    w from the correct boundary, ndt, drift variability s_v; the start point's
    and ndt's ranges fixed at 0). Priors are from IGC's Ebbinghaus and
    Müller-Lyer DDM fits, with vertical-horizontal their average at twice the
    SD, and the Group priors normal(0, 2.5) on the drift. Convergence is typed
    by hand: no divergences, max Rhat 1.015 (7 of 181 above 1.01), min bulk
    ESS 640, participant max Rhat 1.024 (the 118-participant fit; the
    117-participant refit's numbers are in the DDM-5 entry). The derived quantities are
    discriminability = v and P(error) by quadrature. Speed is gone.
  - **Figure 2A** is a diffusion diagram from the posterior medians at the
    same condition: boundaries ±a/2, the start point, the mean drift with a
    fan of the middle half of drift rates, three simulated paths (seed 7),
    the predicted RT densities beyond each boundary from
    `cogmod::dcogmod_ddm()` (so the paper needs cogmod ≥ 0.3.6 too), and the
    naïve group as a dashed outline. Figure 2B shows boundary, ndt,
    discriminability and P(error).
  - **Results:** users set wider boundaries (+0.50 / +0.48) and make fewer
    errors. ndt is +19 / +17 ms, not reliable. Recent users discriminate better
    than both other groups. The illusion magnitude is lower in all six
    contrasts (13–36%, 22% on average; the abstract says 22%). The illusion's
    effect on discriminability does not differ between groups. On errors it
    is smaller on the Ebbinghaus, not reliably on the vertical-horizontal,
    and the same on the Müller-Lyer. The magnitude now correlates
    *moderately* across illusions (0.29–0.48, against 0.62–0.64 for
    no-illusion discriminability), so "weakly" became "moderately" in the
    abstract and Results. Age accounts for all of the ndt gap and part of
    past users' lower error rate, not for the boundaries. Among users, the
    MEQ-30 total goes with a slightly longer ndt (+14 ms per SD [0, 26]).
  - **Guards:** the setup chunk `stopifnot()`s every qualitative claim of the
    Results (which intervals include zero) and of the age paragraph, so a
    refit that changes one stops the render.
  - **Discussion:** the first difference is caution (wider boundaries), with
    the ageing references (`ratcliff2001effects`, `theisen2021age`, until
    now in the bib but uncited). The three-indices paragraph says the
    illusion costs users as much discriminability, while the real difference
    moves it more. Two model limitations: a too-long tail of slow errors, and
    boundary and start point varying with strength although trials are mixed
    within blocks. "Recent did not differ from Past" is now qualified as "in
    their sensitivity to the illusions".
- **`paper.qmd`**: the illusion paper, restarted on 2026-11-04 as a Quarto
  article on the lab's `apaquasi` template (`_extensions/apaquasi/`, copied
  from IllusionGameComputational; `references.bib` beside it). It is
  computational: every number, table and figure is read from
  `analysis/results/*.csv`, `data/open/`, `data/groups.csv` and
  `data/data_illusiongame.csv`, so after any refit the sequence is
  `./hpc combine lnr`, `./hpc pull`, re-render `3_lnr_groups.qmd` and
  `4_lnr_correlates.qmd`, then the paper. The only hand-typed numbers are
  the convergence diagnostics and the cluster settings in its Methods
  (from the 16-chain fit, 2026-11-06), the convergence sentence
  of its limitations, and the rounded numbers of the abstract. Author order
  and affiliations were given by Dom on 2026-11-19 (Makowski, Sperduti,
  Collins, Daudé, Zogheib, Kervadec, Roméo, Piolino, Fauvel; Makowski also
  at the Sussex Centre for Consciousness Science, Sperduti also at Tor
  Vergata's Department of Systems Medicine; Kervadec and Roméo at AP-HP Paul
  Brousse), with ORCIDs from orcid.org (Fauvel has an empty second record,
  0000-0003-4435-9480, not used). The corresponding author (Fauvel) and the
  data-sharing statement are still the docx's and marked TODO. The postcode
  and town go in each affiliation's `address`, because apaquasi's title
  block does not print `postal-code`.
  IllusionGameComputational is not cited (Dom, 2026-11-19: no "unpublished"
  reference): the Data Cleaning paragraph links its repository, and the
  priors paragraph refers to "that larger study". Its bib entry is unused.
  Two figures (decided 2026-11-04): Figure 1 is the stimulus panel
  (`paper/stimuli_panel.py` → `paper/figures/stimuli.png`, composed from the
  task's own images in `~/Dropbox/Software/IllusionGame/v3/stimuli`) over
  the observed error rates and median RTs across strength with the posterior
  predictive bands; Figure 2 is the observed and posterior predictive RT
  distributions (no illusion / conflicting) over the per-group values
  (averaged over the design) and the illusion magnitude per illusion, with
  bracketed asterisks for pd ≥ 0.975 / 0.995 / 0.9995. Everything else
  is in the tables. `paper/mockups/` holds the candidates that were weighed
  (contrasts instead of group values, a three-band PPC, a scale schematic,
  the cross-illusion scatter), drawn by a scratch script.
  The template needs Quarto ≥ 1.9, and which copy has it keeps changing.
  On 2026-11-06 the system Quarto (`C:/Program Files/Quarto`) is 1.10.18
  and renders it, while RStudio's bundled copy is 1.8.25 and refuses it
  ("incompatible with this quarto version"; on 2026-11-05 it was the other
  way round). On 2026-11-19 the system Quarto was gone and RStudio's copy,
  1.9.38, rendered it. Check `--version` first:

  ```bash
  cd paper && QUARTO_R="C:/Program Files/R/R-4.5.3/bin" "/c/Program Files/RStudio/resources/app/bin/quarto/bin/quarto.exe" render paper.qmd   # paper.pdf, about 35 s
  ```

  The `fig-model` chunk needs the RWiener package (brms's `dwiener`
  backend), installed 2026-11-19. Each render also writes the two figures
  to `paper/figures/Figure1.{pdf,png}` and `Figure2.{pdf,png}` (vector PDF
  and 300-dpi PNG at the article's size, for submission) through
  `save_figure()` in the setup chunk; the numbers in the file names are set
  by hand in each chunk.

  Figure conventions (2026-11-05): the model is a line (posterior predictive
  mean) with its 95% band, the data are points. Figure 1's curves pool each
  pair of neighbouring strengths (see "Easy to get wrong", the design), and
  Figure 2A's distributions are 50 ms histograms. Figure 2B–C mark every
  group contrast with pd ≥ 0.975 by a bracket with its asterisks. The
  contrasts table averaged over the design and the cross-illusion
  correlations were in an appendix until 2026-11-16 (see "Structure" below).

  Changed on 2026-11-15 (Dom): Figure 1B draws the observed values as small
  crosses (`shape = 4`, kept out of the legend). Figure 2A is no longer a
  posterior predictive check but a diagram of the race, drawn like a
  diffusion model, at one condition (Ebbinghaus, strength 1, mid
  difficulty), one panel per group with the other groups as dashed
  outlines. It is computed in the paper's `fig-model` chunk from the
  posterior medians in `lnr_groups_means.csv` (`race_par` in the setup
  chunk), so it carries no posterior uncertainty and is a typical
  participant, not the pooled data. The response-time distributions of the
  check (`lnr_ppc_densities.csv`) are only in `3_lnr_groups.qmd` now (see
  "Structure" below). Each figure's legend is its `fig-cap` (there is no `apa-note`).
  Recent users are neon cyan (`#00dcff`) in the paper; the reports still
  use the orange (`#eb6834`).

  Group labels (decided with Dom, 2026-11-05): the paper shows
  "Psychedelic-naïve", "Past users" and "Recent users" (`group_lab` in its
  setup chunk), and "Naïve", "Past" and "Recent" in contrasts ("Past −
  Naïve"; `contrast_lab`). Only the display changes: the data, the model,
  the reports and the results files keep Never / Past / Recent, so the
  lookups in the paper use those keys. Rejected: "Control" (implies a
  matched group, which these are not) and "Active" for the ≤ 30-day group
  (reads as under the influence, or as regular use).

  Wording (prose revised 2026-11-15, no number or analysis changed; the
  version before it is `paper/paper_before_revision_2026-11-15.{qmd,pdf}`):
  - "Real difference" for the objective difference between the targets, and
    never "stimulus units". The title no longer says "in stimulus units".
  - The illusion magnitude is explained as the number of units of task
    difficulty that one unit of illusion strength is worth (the difficulty
    scale spans 2 units), so "smaller in users" means the illusion is
    equivalent to a smaller real difference.
  - Discriminability is glossed at first use (how well the targets are told
    apart; the correct accumulator's advantage), and the abstract avoids the
    term.
  - Figure 2A's "no illusion" bin is |strength| ≤ 0.3, and the design has no
    strength 0, so the text calls it "the weakest illusions".

  Structure (revised 2026-11-15, after the wording; no number or analysis
  changed; the version before it is
  `paper/paper_before_structure_2026-11-15.{qmd,pdf}`):
  - **Title:** "Psychedelic users are slightly less susceptible to visual
    illusions, whatever the recency of use: An evidence accumulation
    analysis". The one before led with "slower, more accurate", the finding
    that age confounds, and its subtitle read like IllusionGameComputational's.
  - **Introduction:** the task and the model are one short paragraph (their
    details are in the Methods only), and the last paragraph is the present
    study: groups, then the three questions in the order of the Results.
    Revised again on 2026-11-16 (Dom; the version before it is
    `paper/paper_before_intro_2026-11-16.{qmd,pdf}`): the measurement problem
    is no longer a paragraph of its own. It is the opening of the task
    paragraph: illusion paradigms can conflate the illusion with other
    effects (metacognitive judgements and response criteria for ratings and
    adjustment, discrimination and overall performance for error rates), and
    the Illusion Game tries to accommodate this. Dom rejected two framings of
    the old text: that studying users outside the acute state *requires*
    comparing independent groups (a within-person design is possible), and
    that errors are "the usual measure" of susceptibility (studies use
    adjustment, subjective scales and more). The illusion magnitude is
    introduced in the task paragraph as an index computed *in addition to*
    the model's parameters, to facilitate comparisons between groups that
    differ in average performance, no longer as the remedy for a problem the
    old text overstated. The general-factor paragraph is cut (not a goal of
    this study), and so is the cross-illusion question from the list. Dom
    keeps the abstract as it is: the magnitude as its primary index, and the
    weak cross-illusion correlation as context, not as a main finding.
  - **Methods:** "Quantities and contrasts" is split into that, "The illusion
    magnitude", "Participant-level analyses", "Model checking" and
    "Transparency and openness". Table 2 describes the users' psychedelic use
    (from `data/open/participants.csv`, `Days` in `data/groups.csv` and the
    MEQ-30 in `data/questionnaires.csv`, which the paper now reads); Table 1
    has the AAQ-II and DASS-21 per group. The contrasts table is now Table 3.
  - **No appendix** (removed 2026-11-16, Dom; the version before it is
    `paper/paper_before_appendix_2026-11-16.{qmd,pdf}`). It held the
    convergence details, Figure A1 (the response-time distributions of the
    check, `lnr_ppc_densities.csv`), the contrasts averaged over the design
    (Table A1) and the cross-illusion correlations (Table A2). The text now
    points to the reports instead: "Transparency and openness" names
    `analysis/3_lnr_groups` (convergence, posterior predictive checks, every
    group contrast) and `analysis/4_lnr_correlates` (participant level,
    correlations between illusions), and the Results cite them by name. The
    Methods' convergence paragraph is all the paper says about convergence,
    and "Across illusions" gives the three magnitude correlations with their
    intervals in the text (`cor_mag()` in the setup chunk). Those pointers
    need the reports on GitHub: the `.qmd` reports, their `.html` and
    `analysis/results/` were committed on 2026-11-16 (6e3023e).
  - **Covariates** (2026-11-16, Dom): the paper no longer mentions shrinkage
    or the raw-trial check (the 10th-percentile correct RT and the error
    rates, regressed the same way). The check agreed with the per-draw
    regressions, and a check that passed is the authors' due diligence, not
    content for the paper. It stays in `4_lnr_correlates.qmd`. Cut from the
    Methods ("Participant-level Analyses") and two sentences of the Results
    ("Age, demographics and the questionnaires"); the wording before is in
    `paper/paper_before_appendix_2026-11-16.qmd`. The caveat that native
    language and student status are each confined to one group stays.
  - **Model fit** (2026-11-16, Dom): the Results no longer have a "Model
    fit" section. Dom judged the misfit small (conflicting errors ~1.5
    points under, median RTs 10–30 ms over per group), and better than
    linear models of RT do. One sentence opening "General performance"
    introduces Figure 1B and says the predictions follow the observed values
    closely. Its `ppc-deviations` chunk (`err_dev`, `rt_dev`) went with it,
    and so did the unused `ppc_errs`. The paragraph before is in
    `paper/paper_before_appendix_2026-11-16.qmd`. The RT-shape sentence in
    the limitations stays.
  - **Results streamlined** (2026-11-16, Dom asked for it focused on the main
    results; the version before is in Dropbox's history). General performance
    keeps non-decision time, the error rate, speed, discriminability and
    P(error), and drops the past users' slower correct accumulator and their
    noisier `sigmazero` (still in `3_lnr_groups`). Illusion sensitivity leads
    with the magnitude: the naïve values, the 7–21% reduction, that one
    illusion at a time only the Ebbinghaus contrasts exclude zero (a
    `stopifnot` in the setup chunk guards that sentence), and the average over
    the illusions from the participant-level Group regression (−0.25 in each
    user group). The discriminability and error effects follow as ranges, with
    Table 3 holding the intervals. "Across Illusions" keeps the magnitude
    correlations and the no-illusion discriminability, and drops precision and
    the illusion effect on δ. Figure 2A no longer labels the fan ("Middle half
    of the trials (σ)", unclear); its caption explains it.
  - **Discussion, illusion sensitivity** (2026-11-16, Dom): the paragraph
    goes through the three indices one by one (what each measures, which
    way users differed, what that suggests), and no longer explains the
    disagreement between them by the groups' different starting performance.
    The logit-scale remark stays in the Results only. The larger effect on
    discriminability is not read as more susceptibility (that contradicts
    the conclusion): users' discriminability also changes more with the real
    difference, proportionally more than with the illusion in all six
    group × illusion cells, so any change in the stimulus has a larger effect
    on their discriminability. (Not "their evidence responds": Dom, evidence
    is not something that responds.)
  - **References:** twelve added (schizophrenia and autism illusions, early
    visual accounts, cross-illusion correlations, ageing in diffusion models,
    cognition in users), each checked against Crossref and its PubMed
    abstract on 2026-11-15.
  - **"Transparency and openness"** (decided with Dom, 2026-11-15): there was
    no power analysis; as much data as possible was collected, and the paper
    answers that with uncertainty on every estimate and Bayesian methods. The
    earlier manuscript's GLMM analysis is not mentioned in the paper.
  - The template counts the abstract's words and warns above 250; it is at
    about 247.
- `Article_visual_illusions_neuropsychopharmacology*.docx`: the previous
  illusion paper, aimed at *Neuropsychopharmacology*, which the restart
  replaces.
  - `_revised_Marco` is its last version (October 2026).
  - `_revised_Marco_DM` is Dom's review of it: comments in French, tracked
    changes.
- `Article associative memory_revised_v7*.docx`: the self-association paper,
  with Dom's earlier review (`_dm`).

## The illusion paper as it stands

- **Sample:** 117 adults in three groups.
  - Never used a classic psychedelic: 43.
  - Recent use, within 30 days: 39.
  - Past use, longer ago: 35.
- **Data used:** incongruent trials only.
- **Analyses:**
  - Error and RT GLMMs with only a participant random intercept: median-split
    difficulty, then per-illusion models on standardised strength and
    difference.
  - RT on correct trials, with an exploratory correct-vs-error RT analysis.
  - EZ-diffusion per participant × illusion × difficulty.
  - Questionnaire correlations.
- **Claims:** users are more accurate but slower, with higher EZ boundaries;
  recent users show a *steeper* illusion-strength effect on errors (logit
  scale) for Müller-Lyer and vertical-horizontal, not Ebbinghaus. The paper
  *predicted* a weaker one (REBUS), so there is no support for "relaxed
  priors". Adjusting for age and gender changed none of this. (An earlier
  note here gave the prediction as the finding; checked in both manuscript
  versions on 2026-11-04.)
- **Main problems** (Dom's review):
  - No random slopes, so the Group × strength tests are anti-conservative.
  - Discarding the congruent trials means illusion sensitivity cannot be
    separated from general accuracy or attention.
  - Steeper slopes in a more attentive group are not more illusion
    sensitivity.
  - Age, native language and recruitment route confound Group: the controls
    are younger and less than half are native speakers.
  - The two-stage EZ approach throws away uncertainty.

## The revised analysis: plan and status

**Since 2026-11-18 the paper reports the DDM-5, not the LNR** (step 8 below,
and "Manuscripts"). What follows describes the LNR, which stays as the record.

**One model replaces the paper's analyses.** It is a log-normal race
(`cogmod_lnr`, cogmod ≥ 0.3.5) of choice and RT on every trial, congruent and
incongruent:

```
param ~ Group * (Illusion_Type / (Illusion_Strength * Task_Difficulty))
        + (0 + <random part> | Participant)
```

- **Parameters:** `mu` is the correct accumulator's rate, plus `nuone`,
  `sigmazero`, `sigmaone` and `ndt`. `sigmabias = 0`, and
  `poutlier ~ 1 + (1 | Participant)`.
- **Random part:** the full per-illusion strength × difficulty surface for the
  two drift rates (12 per participant), and an intercept per illusion for the
  others.
- **Coding:** `Group` is treatment-coded with Never as the reference. Group
  comparisons are read from marginal means and contrasts per posterior draw
  (`analysis/server/marginals.R`), not from coefficients. That was decided
  rather than tinkering with contrast coding.
- **Priors:** IllusionGameComputational's `gam_lnr` fits set the Never
  group's surface. Only Müller-Lyer and vertical-horizontal are used: every
  IGC Ebbinghaus LNR fit has population Rhat 2–6.
  - **Slopes:** the per-illusion strength, difficulty and interaction slopes
    come from IGC's smooths, read at this task's 160 design points and
    projected onto the linear surface (`analysis/2_priors.R`; R² 0.93–0.98
    for the drift rates).
    - The SD is √((0.4 b)² + (τ/2)²), where τ is the parameter's IGC
      participant SD.
    - Ebbinghaus gets the average of the other two illusions, with twice the
      SD.
  - **Intercept differences** between illusions: normal(0, τ).
  - **Also from IGC:** the centred intercepts, and the participant SDs of the
    per-illusion intercepts and of `poutlier`.
  - **Group coefficients:** all stay weak, because the group differences are
    the question.
  - **What this changes:** the old priors implied a flat ~12% error rate for
    Never (90% intervals of 0–97%) everywhere on the grid. The new ones follow
    IGC: ~0% on easy facilitating trials, ~40% on hard weak-conflicting ones,
    and 90–100% on hard strong-conflicting ones.
  - `models.R` has the numbers and the reasoning.
- **Derived quantities** (`marginals.R`):
  - P(error) = Φ((ν₁ − ν₀)/√(σ₀² + σ₁²)).
  - Discriminability ν₀ − ν₁.
  - Overall speed (ν₀ + ν₁)/2, the LNR's analogue of caution, since its
    threshold is fixed.
  - Strength slopes per group and illusion, and their group contrasts.
- **Covariates** (age, language, gender) stay out of the model. Correlating
  participant-level estimates with them afterwards describes them, but does
  not adjust the Group effect for them. How age is handled instead is in "Age
  and the other group differences: the plan" below (2026-11-04).

**Status (2026-11-03):**
- **Written:** data scripts, model, cluster scripts, marginals.
  - The `./hpc` driver was dry-run with a fake ssh: `push` packs the scripts
    and the data, and `fit` builds the right `sbatch` command.
  - The model compiles locally.
  - The IGC-informed priors (2026-11-03) pass brms's `validate_prior()` and
    generate Stan code, and the smoke test sampled with them.
- **Cluster smoke test done** on 2026-11-03 (cmdstanr, job 11645856).
  - On `general`, not `short`, whose 2-hour limit it would probably exceed.
  - 30 participants, 300 warmup + 100 draws, 2 chains × 4 threads,
    `IGSA_MODELS_DIR=.../smoke`.
  - It ran on the data with raw IDs, pushed before the open-data switch. The
    trials are identical; only the participant IDs differ.
  - **48 min** (chains 39 and 46 min). Mean tree depth 9.1 (~600 leapfrog
    steps a draw) at step size 0.0075, 0.5% divergent, max Rhat 1.25, min
    ESS ratio 0.03: fine for a smoke test, and a hard geometry.
- **stanli was tried and dropped** the same day (job 11645959, same settings,
  participants and node, into `smoke_stanli/`). Cancelled at 50 of 400
  iterations after 70 min: about 55 s an iteration, against at most ~11 s for
  cmdstanr over its first 200.
  - **stanli does not thread this model.** 0.25.0 finds "no reduce_sum call
    to run in parallel": brms's likelihood writes in place. So each chain
    uses one core (1.6 of 8 cores busy, against cmdstanr's 6.7).
  - IGC's speed-up was measured with threading, so it does not carry over.
    More chains per CPU would not help: warmup time per chain is the limit.
  - So cmdstanr is the sampler; `IGSA_BACKEND=stanli` still works.
- **Local test fit stopped** before finishing, at 200 of 500 warmup
  iterations after ~55 min. That was 24 participants, 2 chains × 4 threads,
  laptop. `marginals.R` is therefore still untested on a real fit.

**Next steps:**
1. Questionnaires scored (2026-11-04): `0_preprocessing.qmd` →
   `data/questionnaires.csv` (see "Participant-level preprocessing").
2. **Production fit done** (job 11646279, submitted 2026-11-03): 4 shards ×
   2 chains × 8 threads, 1,500 warmup + 1,000 draws per chain, cmdstanr, the
   open-ID data.
   - On `verylong`, not `long`: IllusionGameComputational held 128 of
     `long`'s 140 CPUs. `verylong` has its own 70-CPU cap at `long`'s
     priority (the lab hub's `artemis.md`, "Quotas", updated the same day).
   - Shard wall times were 7.4–13.5 h, far below the "day or two" scaled
     from the smoke test. The last shard finished 2026-11-04 03:44.
   - Combined on 2026-11-04 (job 11648293, 1.5 min): 8 chains, 8,000 draws.
   - **Shards 5–8** (job 11648330, submitted 2026-11-04 with `./hpc fit lnr
     --partition=verylong --array=5-8`): same settings, scripts and data
     checked byte-identical to shards 1–4, seeds `1234 + task_id`. Wall
     times 8.3, 18.2, 18.4 and 32.1 h; the last finished 2026-11-05 19:21.
   - **The final fit: all 8 shards combined** on 2026-11-06 (job 11664030,
     2.3 min) and pulled to `analysis/models/lnr.rds` (511 MB): 16 chains,
     16,000 draws. The first combine job was held on `general` by
     `QOSMaxCpuPerUserLimit` (another project's jobs held 400 CPUs there),
     so it ran on `short` instead: `./hpc combine lnr --partition=short
     --time=01:00:00`. It peaks at ~5 GB.
3. **Convergence of the final 16-chain fit** (2026-11-06, laptop,
   `posterior`):
   - Sampler: 28 divergent of 16,000 (0.17%). E-BFMI 0.58–0.77.
   - **Chain 9 (shard 5, chain 1) adapted badly:** step size 0.0014 against
     0.007–0.014 for the other chains, and max tree depth (10) on 999 of its
     1,000 draws. Chain 2 hits it 24 times; no other chain does.
   - Population level (`b_`, 181): max Rhat 1.044, and 19 are above 1.01.
     Minimum bulk ESS is 279 (`b_GroupRecent`), then 366 (`b_Intercept`);
     minimum tail ESS 937. That is no better than the 8-chain fit (1.030,
     16, 274, 943): see the next point.
   - `sd_` and `cor_` are fine: Rhat ≤ 1.014, bulk ESS ≥ 1,272.
   - **S092 has two modes.** Chains 9 and 12 (shards 5 and 6, the two with
     high within-shard Rhat) put much more of S092's trials in the outlier
     component (`r_Participant__poutlier[S092,Intercept]` ≈ 2.9 against ≈
     1.05 in the other chains), with a longer `ndt` and a higher drift on
     Müller-Lyer; chain 16 visits it partly. Those two chains are also
     sticky on `b_GroupRecent` (per-chain bulk ESS 5 and 3).
     - Without chain 9: max `b_` Rhat 1.030, min bulk ESS 474. Without 9
       and 12: 1.022 and 767.
     - **It changes no result** (scratch check, 2026-11-06). Over chains
       1–8, all 16, and all but 9 and 12, the illusion index per group and
       its contrasts, and the group contrasts of every parameter and derived
       quantity averaged over the design, agree within 0.005. So all 16
       chains were kept, and the paper's Methods say so.
     - S092's data look ordinary: faster than the Past median, ordinary
       error rates, but no facilitating errors on Müller-Lyer against 47.5%
       conflicting ones, the near-deterministic pattern that tracks mixing
       (below).
   - Participant level (`r_`, 4,012): 245 have Rhat above 1.01 (18 above
     1.05), with a max of 1.268, in S092. Then S088 (1.146), S116, S003 and
     S097, the four slow ones of the 8-chain fit. Bulk ESS is down to ~44.
   - So the population-level marginals are usable with a caveat: they fall
     just short of Vehtari et al.'s Rhat < 1.01 and ESS > 400. The
     participant-level estimates of those five participants are less
     reliable than the rest.
   - **8 → 16 chains moved nothing** (2026-11-06): in the five results
     files every median moved by at most 3% of its 95% interval width. Two
     rows of `lnr_correlates.csv` crossed pd 0.975: Past − Never on the
     illusion effect on discriminability, 0.972 → 0.979 (Group) and 0.968 →
     0.984 (Group + DASS-21).
   - **Not a cleaning problem** (checked 2026-11-04, on the four slow
     participants of the 8-chain fit). IGC's
     `0_preprocessing.qmd`, re-run in base R, keeps exactly the same 55,937
     trials as this project's cleaning (then `1_data.R`, now its own
     `0_preprocessing.qmd`).
     - The four are clean, engaged responders: no RT below 350 ms, 0–5%
       facilitating errors, no block removed. Across all 353 participant ×
       illusion cells, mixing tracks no RT feature (|ρ| ≤ 0.2).
     - IGC's shelved 1/6–4 s RT window would drop 0.9% of trials. It drops
       none in S097 or S003 and only the slow tails of S088 and S116 (4 and
       12 trials). Its drops do not track mixing (ρ = 0.01).
     - What does track it, partly, is a near-deterministic choice: the cell's
       error-by-strength logistic slope has a large SE (ρ = −0.44 with `ndt`
       ESS). Of the 20 worst cells, 55% have zero facilitating errors, against
       37% of all cells. The three worst cells are not extreme on it, though,
       so it reads as the model's hard geometry rather than bad data.
     - A trial or block rule would mostly remove good data. As IGC notes,
       error-based rules would remove the most illusion-sensitive
       participants first.
4. Remaining checks (Rhat, ESS and divergences are in 3):
   - Posterior predictive check: done 2026-11-04, in `3_lnr_groups.qmd`
     (100 draws, `posterior_predict()` with the participant effects in).
     Overall 17.6% errors simulated against 18.3% observed. cogmod's
     `posterior_predict()` returns one matrix with two interleaved columns
     per trial, RT then choice.
     - **Not a clean fit** (re-read 2026-11-05, when the paper's figures
       were redrawn with the model as lines and the data as points). The
       error rate's rise with strength is reproduced, but conflicting errors
       are underpredicted by ~1.5 points. Median RTs are overpredicted by
       ~10–30 ms per group, most in Past (up to ~100 ms at one point), and
       42% of the median-RT points fall outside the 95% band. The cause is
       the shape: the observed RT distributions are more sharply peaked
       than the LNR's, with more mass just after the mode and less in the
       slow tail, while their position and leading edge match. Clearest for
       the users' correct RTs with no illusion and Never's errors under
       conflicting illusions. The paper's limitations say so; its "Model
       fit" section was cut on 2026-11-16 (see "Manuscripts", "Model fit").
   - Priors against posteriors: still to do.
5. Results, in `analysis/3_lnr_groups.qmd` (population level) and
   `4_lnr_correlates.qmd` (participant level), both scripted on 2026-11-04
   with `marginals.R` and `modelbased`, re-rendered on the final 16-chain
   fit on 2026-11-06 (numbers below; 8 → 16 chains changed none of them
   beyond rounding, step 3). Both user
   groups have a longer non-decision time than Never (+41–49 ms averaged
   over the design) and a slower error accumulator. So they are slower
   overall, more discriminating and less error-prone, most of all on
   Ebbinghaus and vertical-horizontal under strong illusions. Past and
   Recent barely differ.
   - **Averaged over the design** (every strength × difficulty point shown;
     `estimate_contrasts()` per parameter, the per-draw grid for the derived
     quantities, the two agreeing to 1e-6 on the same draws). Across the
     illusions, Past − Never and Recent − Never are −0.77 and −0.88 on the
     error drift, −0.48 and −0.46 on speed, +0.58 and +0.84 on
     discriminability, −3 and −4 points on P(error). Recent − Past is
     within noise on all of them.
   - **Across illusions** (`4_lnr_correlates.qmd`, per-draw correlations
     of the participant estimates): the illusion magnitude correlates only
     weakly between illusions (0.15 / 0.13 / 0.38 for Ebbinghaus–Müller-Lyer
     / Ebbinghaus–vertical-horizontal / Müller-Lyer–vertical-horizontal),
     whereas precision (0.70–0.79) and no-illusion discriminability
     (0.74–0.84) are strongly shared. The raw illusion effect on δ
     correlates ~0.5, largely that shared global part. So there is a general
     *performance* factor and little general *illusion* factor.
   - **Covariates** (per-draw regressions, indices averaged over the
     illusions). Age adds +21 ms per decade to non-decision time and nothing
     to the illusion magnitude (−0.01 per decade [−0.05, 0.03]); the
     magnitude's group differences (Past − Never −0.25, Recent − Never
     −0.25) do not move with age, language or student status. AAQ-II and
     DASS-21 go with a slightly shorter non-decision time (−13 ms per SD)
     and nothing else. The MEQ-30, total and factors, relates to nothing
     (users only, n = 71). No covariate moves the index.
   - **Illusion magnitude** (`igsa_index()`: the strength slope over the
     difficulty slope of δ, at strength 0 and mid difficulty; the PSE shift
     in stimulus units, which nothing that scales the whole surface can
     move). Users have steeper strength slopes, as the paper reports, but
     steeper difficulty slopes too, so their illusion is *smaller* in
     stimulus units. Never: 1.38 / 1.74 / 1.60 (Ebbinghaus / Müller-Lyer /
     vertical-horizontal). Recent − Never: −0.29 [−0.49, −0.11] / −0.13
     [−0.37, 0.12] / −0.22 [−0.46, 0.01]. Past − Never: −0.22 on each (pd
     0.97–0.98). Recent − Past: nothing. Relative to Never that is 7–21%
     (about 14% on average). The paper's Results and Discussion compute
     these percentages (`idx_pct` in its setup); the abstract types them
     (2026-11-06; it said "about a fifth" before, which overstated them). The ratio is stable: no
     participant × illusion cell has 5% of its draws with a non-negative
     difficulty slope.
     - An earlier probit GLMM per illusion (glmmTMB, no lapse, no
       covariates; scratch, not kept) agreed: Recent − Never −0.38 [−0.62,
       −0.16], −0.10 [−0.30, 0.07], −0.20 [−0.44, 0.04].
     - **The same contrast on the other scales**, in `3_lnr_groups.qmd`: on
       P(error) the 0 → 1 effect says users are *less* affected (Recent −
       Never −25 / +1 / −12 points); on δ it says *more* affected (−0.48 /
       −0.43 / −0.52), which is the paper's steeper logit slope. The index
       is the one global performance cannot move, hence primary (plan, item
       2); the other two are reported beside it. The nulling and
       local-ratio variants on P(error) were dropped with that decision.
6. Age. The plan is in "Age and the other group differences: the plan"
   below (2026-11-04): no refit unless a reviewer asks, and then with age on
   `ndt` only.
   - **First check without a refit** (2026-11-04, now in
     `4_lnr_correlates.qmd`). It regresses each participant's estimates, per
     posterior draw, on Group, then on Group + age, then also on native
     language and student status. Never averages 29 years old against ~40
     for both user groups.
   - **Non-decision time:** age, +21 ms per decade, accounts for about half
     of the users' longer ndt: Past +52 → +27 ms, Recent +41 → +16 ms, the
     latter no longer credible. The raw 10th-percentile correct RT agrees
     (+65 → +33 ms and +41 → +10 ms).
   - **Not explained by age:** the slower accumulators, the slower error
     drift, higher discriminability, fewer errors (raw too), and Recent's
     larger illusion effect on discriminability. These barely move.
   - **Native language** pushes the other way: native speakers have the
     shorter ndt, and they are almost all users.
   - **Its caveats go in the paper, not into a refit** (2026-11-04).
     Participant estimates are shrunk towards their group's mean, which
     understates age. Native language and student status sit almost entirely
     in one group each.
7. The paper. `paper/paper.qmd` is a full restart (2026-11-04) that reports
   the LNR results, with everything read from the results files (see
   "Manuscripts"). Re-rendered on the 16-chain fit on 2026-11-06, with its
   Methods convergence paragraph and the limitation on convergence
   rewritten by hand. Still needed: the co-authors' agreement (Marco,
   Baptiste, Oliver), the prior-versus-posterior check, and the TODOs in its
   header (corresponding author, data sharing, funding and CRediT; author
   order and affiliations settled 2026-11-19).
8. **A DDM-5 as a check on the LNR** (2026-11-17, Dom: to compare with the
   LNR's results, not necessarily for the paper). `ddm5` in `models.R`:
   IllusionGameComputational's DDM-5 (drift, boundary, bias, ndt,
   `sigmadrift`) with the LNR's fixed part, the full participant surface on
   the drift, and priors from IGC's converged DDM-5 fits (MullerLyer and
   Ebbinghaus) by the LNR's rules. The LNR's resolved priors are unchanged by
   the refactor that shares the code (checked with `validate_prior()`).
   - **cogmod 0.3.6**, from its own library on the cluster (the shared one
     stays at 0.3.5 for IGC): 0.3.5's likelihood was wrong in the tails with
     `sigmadrift` estimated. Commands in `analysis/server/README.md`, "DDM-5".
   - Submitted as job 11757858 on `verylong` (4 shards × 2 chains × 8
     threads, 1,500 + 1,000), after a local run compiled and sampled.
     It landed on non-zen5 nodes (`general-01`, `cpu-01`).
   - **Done (2026-11-18): `analysis/models/ddm5.rds`.** The 4 shards took
     4.3–5.2 h each, with no divergences and tree depth ~7. Combined (job
     11763573): 8,000 draws from 8 chains, max Rhat 1.024, min neff_ratio
     0.023.
   - **Re-fitted with stanli + nutpie** the same day (Dom): job 11757991,
     `IGSA_BACKEND=nutpie` in `fit_model.R`, 4 shards × 2 chains × 1 CPU,
     1,500 + 1,000, into `models_nutpie/`, with brms 2.23.1, stanli 0.26.0
     and nutpieR 1.9.2 from IGC's `cogmod_nutpie/R_libs`. Two things found on
     the way (README, "The same model with stanli + nutpie"). First, stanli
     cannot thread brms's likelihood here, so one core per chain. The cause
     is the drift's 12 participant terms: above 10 terms in one brms loop,
     stanli (0.26.0 and 0.27.0) leaves its fast path, ~25x slower and
     unthreaded; two loops of 6 restore it. Second, stanli 0.26.0's
     `bridgestan_data()` cuts the data JSON at 1e6 characters
     (`substring()`'s default `last`); the job patches it, and 0.27.0 is
     fixed. A local run (6 participants, 40 + 20) sampled, saved and
     combined. **Cancelled on 2026-11-18** (Dom) once the cmdstanr fit was
     in, with no shard saved. After ~20–24 h it was 8–20% into sampling on
     three shards and 60–65% on the fourth: ~130 gradients per draw on one
     core per chain, about 7x cmdstanr's wall time. It did not have the
     two-loops split, so it says nothing about nutpie on a threaded program.
     Its progress lines went to the `.err` log, which `./hpc progress` does
     not read.
   - **stanli issue drafted for Dom** (the 10-term cliff, with a brms-only
     reprex run on 0.26.0 and 0.27.0), not posted. The laptop crashed during
     an earlier run of that test, but the rerun peaked at under 1.2 GB per
     process, so the crash's cause is not known.
   - **Compared with the LNR** (2026-11-18, Dom: "eventually swapping the
     model from the paper if the new one offers clearer and more
     interpretable results"), in `analysis/5_ddm_vs_lnr.qmd`.
     `marginals.R` now takes either family: for the DDM-5, `delta` is −drift
     (towards the correct response), and `perror` is the first-passage
     probability averaged over `sigmadrift` by Gauss-Legendre quadrature
     (`igsa_ddm_perror()`, checked to 1e-7 against numerical integration;
     Gauss-Hermite was off by up to 0.03). The LNR's path is unchanged.
     Findings:
     - **Fit:** LOO ahead by 787 (SE 83), p_loo 2,069 against 2,846. There
       are many high Pareto k (212 LNR, 82 DDM), so the estimate is
       approximate. Median RTs are off by 18 against 27 ms, with 70% against
       51% inside the 95% band. The no-illusion distributions are more
       peaked, closer to the data, but the errors' slow tail is worse.
     - **Sampling:** no divergences, max Rhat 1.015 / 1.024 (population /
       participant) against 1.044 / 1.268, ESS per draw ~5x.
     - **Groups:** users' slowness is a wider boundary (+0.5, pd 1; ρ = −0.97
       with the LNR's speed). ndt is +17–19 ms, not credible, and age
       absorbs all of it. P(error) is the same as in the LNR. New: Recent >
       Past on drift (+0.51 [0.19, 0.83]).
     - **Illusion magnitude:** smaller in users in all six contrasts with
       Never (pd ≥ 0.987; LNR: 2 of 6 at pd ≥ 0.975), 13–36% smaller (most on
       the Ebbinghaus). Users' illusion effect on the drift equals Never's,
       and only their precision term is steeper. In the LNR, the illusion
       effect is also larger in users, the tension the paper's Discussion
       has to explain.
     - **Against it as fitted:** boundary and start point vary with
       strength (Never's boundary 2.53 → 1.77 from −1 to +1, start point
       0.73 → 0.52), and strengths are mixed within blocks. A refit with
       boundary and bias on Group × illusion only was proposed; Dom declined
       it and **adopted the DDM-5 for the paper as fitted** (2026-11-18; see
       "Manuscripts").
   - **Refitted on the 117 participants** (without the age-16 control; see
     "Groups"), the same model and settings, into its own models directory
     (`models_n117/`; commands in `analysis/server/README.md`). Job 11781109,
     submitted 2026-11-21: the 4 shards took 4.1–5.3 h, the fourth 13.5 h,
     with no divergences, tree depth ~7.3 and step size ~0.027. Combined on
     2026-11-22 (job 11781960) and pulled to `analysis/models/ddm5.rds`; the
     118-participant fit is kept as `ddm5_n118.rds`. Diagnostics (computed
     from the fit; the 118 fit's in brackets): population (`b_`, 181) max
     Rhat 1.022 (1.015), 4 above 1.01 (7), min bulk ESS 494 (640); `sd_` and
     `cor_` max Rhat 1.009 (1.016); participant (`r_`, 2,925) max Rhat 1.033
     (1.024), 23 above 1.01 (3), both times on S010's Ebbinghaus ndt. The
     paper's Methods give these.
     - **Findings unchanged** (2026-11-22). `3_ddm_groups.qmd`,
       `4_ddm_correlates.qmd` and the paper were re-rendered, and every
       `stopifnot()` guard of the paper passed. Its text changed only in its
       numbers: boundary +0.52 / +0.51, drift Recent − Never 0.74 and
       Recent − Past 0.50, ndt +18 / +15 ms (not reliable), illusion
       magnitude 22% lower on average (15–37%; was 13–36%), magnitude
       correlations 0.29–0.49. Of 800 tested intervals in the six result
       tables, 8 changed side of zero, all at pd 0.968–0.981 in both fits and
       none reported in the paper (`sigmadrift`'s illusion effects, two MEQ
       regressions of the illusion's effect on discriminability, the
       days-since-use + age regression of discriminability, and the
       Ebbinghaus–vertical-horizontal correlation of the illusion's effect on
       P(error)).
     - `5_ddm_vs_lnr.qmd` stays on the 118-participant fit (see the table
       of reports).

## Age and the other group differences: the plan (2026-11-04)

Decided with Dom on 2026-11-04, after weighing an age covariate and a new
control group drawn from IllusionGameComputational. **The main model stays
Group-only, and age is reported, not adjusted for.**

**The problem.** Ages by group, from `data/open/participants.csv` (one Never
age is missing):

| | n | median | ≤ 25 | 26–30 | 31–50 | > 50 |
| --- | --- | --- | --- | --- | --- | --- |
| Never | 43 | 23 | 29 | 6 | **1** | 7 |
| Past | 34 | 40 | 10 | 2 | 13 | 9 |
| Recent | 39 | 40 | 2 | 2 | **31** | 4 |

Group differs on more than age (Never / Past / Recent):
- **Recruitment arm:** the same split as Group (control arms against
  psychedelic societies).
- **Students:** 29/44, 10/34, 5/39.
- **Native speakers** of the session's language: 21/44, 33/34, 35/39.
- **Women:** 33/44, 17/35, 17/39.
- **Session in English:** 15/44, 3/35, 6/39.

**Why age stays out of the main model.**
- *Not* because aging is implausible. A longer non-decision time with age is
  one of the most robust findings on cognitive aging, and here age accounts
  for about half of the users' longer `ndt` (Status, step 6).
- Because this sample cannot separate age from Group. Recent sits at 31–50,
  where Never has one participant, so an age-adjusted Recent − Never contrast
  extrapolates a linear age slope across the gap. Past overlaps Never at both
  ends, so its adjustment would at least rest on data.
- Because age is one of a bundle. Adjusting for it alone would look as if the
  confounding had been handled. The group differences are reported as
  differences between these populations, with no causal reading.

**Why no control group from IllusionGameComputational.** Checked on
2026-11-04 in the participant files of its source studies, read from GitHub:
- 291 of their participants are aged 30–50: Reliability 161 (of 500),
  Validation 55 (of 250), Suggestibility 45 (of 780, mostly SONA students),
  International 30 (of 44). The EEG study's file has no age column.
- None of those files has a column on psychedelic or other drug use, so a
  psychedelic-naïve group cannot be defined.
- Their stimulus grid is wider than this task's, so pooling means modelling
  two designs.
- They are English-speaking Prolific or SONA samples, against French
  psychedelic-society members. That swaps one measured confound for several
  unmeasured ones.
- IGC already sets the priors of Never's surface (`2_priors.R`). Using it as
  data too would count it twice.
- The longitudinal arm's `control_T0` would be the better source of older
  controls: same experiment, screened for psychedelic use. But it is young
  too (median 28.5), English, and was collected under another consent. Not
  used.

**The plan.**
1. **Primary model:** the Group-only LNR specified above, with no covariates.
2. **An illusion index that global performance cannot move.** Decided
   2026-11-04: the strength slope over the difficulty slope of
   discriminability (δ), both at strength 0 and mid difficulty
   (`igsa_index()` in `marginals.R`): the PSE shift in stimulus units. It is
   unchanged by anything that scales the whole surface, which is most of
   what age, student status and attention change. It is defined on δ rather
   than on P(error) because the surface is linear there and the sigmas stay
   out; the nulling and local-ratio variants on P(error) were dropped. It was
   chosen on that ground, before its per-group numbers were read, because it
   can flip the paper's headline; the P(error) and δ scales are reported
   beside it.
3. **Recent − Past as the matched contrast.** The two have the same ages
   (means 40.4 and 40.6), the same recruitment and nearly the same language.
   That they barely differ points to a difference between populations rather
   than an effect of recent use.
4. **Age in the paper, as numbers:**
   - The table above and an age-by-group figure in the sample description.
   - The participant-level check in `4_lnr_correlates.qmd` ("What the
     covariates account for"), stated per parameter: about half of the
     `ndt` gap, almost nothing of the rest. Its shrinkage caveat and the
     raw-trial check stay in the report: the paper mentions neither (Dom,
     2026-11-16; see "Manuscripts", "Covariates").
5. **Optional outside benchmark** (not done): the age slope of fast RTs (the
   10th-percentile correct RT) across IGC's ~1,500 participants with an age,
   from the raw trials. It gives the milliseconds per decade expected on this
   task without this sample's collinearity, to set against the +21 ms per
   decade found here.
6. **A refit only if a reviewer asks for one,** with centred age on `ndt`
   only, as a sensitivity analysis.

## Groups: how they are derived

The Groups section of `analysis/0_preprocessing.qmd` applies the rules to
`data/open/participants.csv`. It reproduces the paper's 43 / 39 / 35 exactly.
It also matches Table 1's demographics on every row for Never and Recent, and
within one participant for Past. The rules, all stated there:
- **Eligibility:**
  - Completed both tasks.
  - Tested by 2026-04-02, the data freeze; three users tested later are out.
    The open data keep only the month, and no session falls between that day
    and May, so the rule is "tested by April 2026".
  - Did not state an age under 18. The only such answer is the age-16
    control below. `0_deidentify.R` blanks that age and stops on any other,
    so `0_preprocessing.qmd` names the session by its open ID (`under_18`).
- **Never:** control arm, answering "No" to "ever taken a classic
  psychedelic?". th4rdac2zk answered "Yes" and is out.
- **Recent vs Past:**
  - Recent means the free-text "days since your last classic psychedelic" is
    ≤ 30 ("18 jours", "3 semaines" parsed); where unreadable, the yes/no "in
    the last month?" decides.
  - The yes/no answer alone gives 43 / 32, so the paper used the days.
- **Out:**
  - 15n9ak40tf (lifetime use "Never" and last substance "Other": the paper's
    "non-classic only" exclusion).
  - 4eq5nwtp70 and eh9g6rsn2l (no self-association task; chance-level
    illusion responses).
  - jckbwy5hlw (age "XXXX", blank demographics) is not in the open data.
- **The age-16 control is out** (2lm12f31t0, S016 in the open data; Dom,
  2026-11-21, after Marco's review: "do the refit without the 16"). So the
  groups are the manuscript's 43 / 35 / 39 (Never / Past / Recent): 117
  participants and 55,470 trials after cleaning, which are the previous trials
  minus that session's (checked). The record says student, with high school as
  the highest education, so the age may be real, and the study was open to
  adults only. From 2026-11-02 to 2026-11-21 the session was kept as a probable
  typing error with age missing (Never 44, 118 participants, 55,937 trials),
  and every fit before 2026-11-21 includes it. The session is still in
  `data/open/`; whether a possible minor's data should stay public is for the
  PI to decide.
- **The three post-freeze users stay out** (Marco asked why; not changed on
  2026-11-21). The paper gives no reason for the freeze date.

## Participant-level preprocessing

Baptiste's Python outputs are replaced by `data/open/participants.csv`
(2026-11-03). `0_deidentify.R` already does what they lacked:
- It includes everyone: the 35 users tested after April 2025, and the two
  controls the paper includes but Baptiste's files lack (79n86np48z,
  7dsbljnh6j).
- It cleans ages, recodes the button answers to Yes / No, and harmonises the
  French and English labels.
- It reads UTF-8, so there is no `Ã©` mojibake.
- It leaves out the longitudinal arm.

**Questionnaires scored** (2026-11-04) by the Questionnaires section of
`analysis/0_preprocessing.qmd`, into `data/questionnaires.csv`: every session
with items, with `Group` missing for the excluded. The conventions are the
manuscript's: AAQ-II the sum on the published 1–7 item scale (7–49); DASS-21
the subscale means on 0–3 and the total as their mean; MEQ-30 the means of
Barrett et al.'s four factors and of all 30 items, on 0–5, with
`MEQ_Complete` for ≥ 3 on all four. No item is reverse-keyed, and index 0 is
the lowest anchor everywhere (checked against `experiment/questionnaires.js`).
Missing-item rule: a scale is scored when at most one of its items is
missing, as the mean of the answered items; a total is missing when any part
is. The report tabulates how many sessions that prorates or drops, and
Cronbach's alpha per scale.

Decide too whether to include the three post-freeze users.

## Easy to get wrong

- **Strength sign:** positive `Illusion_Strength` is *conflicting* (pushes
  towards the error), in every Illusion Game file, whatever the side of the
  difference. Errors in the controls: 1–6% when negative, 34–45% when
  positive. An earlier note here said "conflicting = same sign as the
  difference", and that was wrong.
- **Button answers:** 0 = the first choice, "Oui" / "Yes". So a 1 in
  `Psychedelics` means *no*.
- **RT units:** the raw and open files are in ms; everything from
  `0_preprocessing.qmd` on is in seconds, which cogmod requires.
- **Self-association practice trials** store the label chosen as its text:
  `answer` and `answer_correct` hold the friend's name, "You" or "Vous". Every
  test stimulus shows the label too. `0_deidentify.R` turns both into roles.
- **ISI:** the raw `isi` column on Illusion Game trials is not the interval:
  its values are in the millions. The open data's `ISI` is the
  `trial_duration` of the fixation-cross row before each trial (600–1,100
  ms).
- **Wording varies between versions:** the first French version asks "au
  cours du derniers mois", and "diagnostiqué" lacks its "(e)". The
  question-matching patterns in `0_deidentify.R` allow for both. Check new
  patterns against every session, not just one.
- **Model scaling:** `0_preprocessing.qmd` scales by the task's fixed stimulus grid, not
  by the data.
  - `Illusion_Strength` ∈ [−1, 1], with + = conflicting.
  - `Task_Difficulty` ∈ [−1, 1], with + = the smallest difference (hardest).
  - This task's grid is narrower than IllusionGameComputational's, so the
    units are not the same as there.
- **Cleaning** follows IllusionGameComputational, not the paper:
  - RT ≤ 0 or ≥ 6 s.
  - Blocks with errors on ≥ 1/3 of facilitating trials (6 blocks here).
  - The LNR's outlier component handles the rest.
- **No `set.seed()` before sampling in a cluster job.** The module's processx
  makes array tasks with the same seed kill each other's chains (hub,
  `troubleshooting.md`).
- **Versions:** cluster brms 2.21.0, laptop 2.23.1. The 2.21-vs-2.23
  misprediction IllusionGameComputational found comes from rebuilt `t2()`
  bases, and this model has no smooths. The laptop's default library has
  cogmod 0.3.3 (checked 2026-11-06; 0.2.2 the day before), which is still
  too old. The test above, and every re-render of the reports and the paper
  (last on 2026-11-06), used a scratch install
  of the local `~/Dropbox/Software/cogmod` (dev, 0.3.5): `R CMD INSTALL
  --library=<dir> ~/Dropbox/Software/cogmod`, then `R_LIBS=<dir>` before
  `quarto render`. Since 2026-11-18 the DDM reports and the paper need
  cogmod ≥ 0.3.6: the same scratch install from the local
  `~/Dropbox/Software/cogmod` (0.3.6 at `ccf2351`, the cluster's commit).
  Last done on 2026-11-22 (the 117-participant re-render), with the system
  Quarto 1.10.18 (`C:/Program Files/Quarto`) for the reports and the paper.
- **The design is a checkerboard split across blocks.** Block A of each
  illusion shows the odd tenths of strength (±0.1, ±0.3, …, ±0.9) with the
  four easier differences (difficulty −1, −0.28, 0.31, 0.79); block B the
  even tenths (±0.2, …, ±1) with the four harder ones (−0.62, 0.03, 0.56,
  1). Each cell twice, once per side. So anything summarised per strength
  zigzags with difficulty and block; a pair of neighbouring strengths covers
  all eight differences (`strength_pair()` in `3_lnr_groups.qmd`).

## Decisions (2026-11-02, Dom)

- **Data:** raw and processed data are gitignored from now on, and their git
  history stays public. The de-identified `data/open/` is in git, and every
  analysis starts from it (2026-11-03).
- **Preprocessing** (2026-11-04): one Quarto document,
  `analysis/0_preprocessing.qmd`, holds everything downstream of the open
  data (groups, questionnaire scores, trial cleaning), as in the lab's other
  projects. `0_deidentify.R` stays a script, because it reads the private raw
  files. Baptiste's Python scripts were deleted from the tree.
- **Indices** (2026-11-04): the illusion magnitude, the strength slope over
  the difficulty slope of δ at strength 0 and mid difficulty
  (`igsa_index()`), is the primary illusion index. Beside it: the group
  contrasts averaged over the design and the marginal slopes per parameter,
  through `modelbased` on the fit (`predict` = the distributional parameter,
  `newdata` = the design grid, `re_formula = NA`), with the derived
  quantities from `marginals.R` and the two paths cross-checked in
  `3_lnr_groups.qmd`. The participant-level correlates (age, language,
  student status, questionnaires) are per-draw regressions in
  `4_lnr_correlates.qmd`, not a refit.
- **Ages:** a birth year becomes an age; the age-16 control was kept with age
  missing until 2026-11-21, and is excluded since (see "Groups").
- **Analysis:** one LNR with Group and the illusion design, reported through
  marginal means. No covariates in the main model.
- **Age** (2026-11-04): it stays out of the main model, and no control group
  is drawn from IllusionGameComputational. The group differences are reported
  as differences between populations, with age given as numbers. The plan
  and its reasons are in "Age and the other group differences: the plan".
- **Priors:** the Never group's whole surface comes from
  IllusionGameComputational (its slopes added 2026-11-03); group effects stay
  weak.
- **Model** (2026-11-18, Dom): the paper reports the DDM-5 and no longer
  mentions the LNR, which stays in `analysis/` as the record. The refit with
  boundary and start point constant across strength was proposed and
  declined; the paper states the limitation instead.
- **Sampler:** cmdstanr (2026-11-03). stanli was the default for a day, on
  IllusionGameComputational's evidence, until the smoke tests showed it
  several times slower per chain on this model (it cannot thread it).
