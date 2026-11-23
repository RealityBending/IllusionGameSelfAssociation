# Open data

The de-identified data of this study: psychedelic users and psychedelic-naïve
adults on the Illusion Game and a self-association task, with questionnaires
(Université Paris Cité; online, March 2024 to September 2026). Every analysis
script in `analysis/` starts from these two files.

- `participants.csv`: one row per session (127), with demographics,
  screening, the last psychedelic experience and the questionnaire items.
- `illusiongame.csv`: one row per Illusion Game trial (64,008: 504 per
  session, 24 of them practice).
- `selfassociation.csv`: one row per self-association trial (44,253), for
  the 125 sessions that reached the task. Each has 324 test trials and 19 to
  108 practice trials (median 21): practice stops early by a rule in
  `experiment/SelfAssociation/SelfAssociation.js`, and 108 is its maximum.

`analysis/0_deidentify.R` builds both from the raw jsPsych files, which are
not public. Its header lists what was left out and how the answers were
recoded. In short:
- **Left out:** dates (the month is kept), device information, platform IDs,
  free-text diagnoses, country, a linking code typed by one arm, and the
  labels of the self-association task. That task's labels are a friend's
  first name, typed by the participant, and a celebrity they picked; only
  their roles are kept.
- **Recoded:** session IDs became `S001` to `S127`. French labels became the
  English version's labels. Ages became numbers.

Sessions come from the study's four arms, whatever their later inclusion. The
exclusions are made by `analysis/0_preprocessing.qmd`, not here.

## participants.csv

| column | values |
| --- | --- |
| `Participant` | `S001` to `S127`, the same in both files |
| `Arm` | the recruitment arm (the experiment's `group` URL parameter): `control` and `control_T0_bis` are psychedelic-naïve controls; `psychedelic_society` and `psychedelics_soc_english` are users recruited through psychedelic societies |
| `Session_Language` | `French` or `English`: the language the whole session ran in |
| `Session_Month` | `YYYY-MM` |
| `Completed_IG`, `Completed_SAT` | `TRUE` if the session has all 504 Illusion Game trials / the self-association task |
| `Age` | years. A birth year was converted using the session year. Missing if unreadable ("rr", "xxx"), blank, or 16 (one control, S016, whom the analyses exclude: `analysis/0_preprocessing.qmd`) |
| `Sex` | `Female`, `Male` |
| `Student` | `Yes`, `No` |
| `Education` | `High school`, `Bachelor`, `Master`, `Doctorate`, `Other` |
| `Language_Level` | level in the session's language: `Native`, `Fluent`, `Intermediate`, `Beginner` |
| `Diagnosis_Past`, `Diagnosis_Current` | `Yes` / `No` to "Have you ever been / Are you currently diagnosed with any of the following pathologies?" (depression, PTSD, OCD, anxiety, substance use disorder, …). The specified diagnoses are not included |
| `Meditation` | `Yes` / `No` to "Do you meditate regularly (at least once a week)?" |
| `Meditation_PerWeek`, `Meditation_Months`, `Meditation_Minutes` | free-text answers, as typed: times a week over the last year, months of practice, minutes per session. Asked only after a `Yes` |
| `Meditation_Tradition` | one or more of `Zen`, `Vipassana`, `Tibetan Buddhism`, `Yoga`, `Mindfulness`, `Qi-gong`, `Other`, separated by `; ` |
| `Psychedelics_Ever` | controls only: `Yes` / `No` to "Have you ever taken any classical psychedelic substance (e.g., LSD, psilocybin mushrooms, ayahuasca) in your life?" |
| `Psychedelics_LastMonth` | users only: `Yes` / `No` to "Have you taken a classic psychedelic during the last month?" |
| `Psychedelics_DaysAgo` | users only: free-text answer, as typed ("14", "3 semaines", "Environ 12 mois"), to "How many days ago did you last take a classic psychedelic substance?" |
| `Psychedelics_Frequency` | lifetime use: `Never`, `One time`, `Between 2 and 5 times`, `Between 6 and 10 times`, `Between 11 and 50 times`, `Between 51 and 100 times`, `More than 100 times`. Asked in the user arms and in `control_T0_bis` |
| `Experience_Intention`, `Experience_Substance`, `Experience_Dose` | users only, about the last classic psychedelic experience: its main intention, main substance, and subjective dose (labels as in the English version of `experiment/demographics.js`) |
| `Drug_Cannabis`, `Drug_Alcohol`, `Drug_Stimulants`, `Drug_MDMA`, `Drug_Opiates`, `Drug_Dissociatives` | users only: `Yes` / `No` / `Not sure` to "Did you use any other substances during this experience?" |
| `AAQ_1` to `AAQ_7` | AAQ-II items, 0 (never true) to 6 (always true) |
| `DASS_<Scale>_<item>` | DASS-21 items, 0 (did not apply to me at all) to 3 (applied to me very much); the scale is in the name |
| `MEQ_<Scale>_<item>` | MEQ-30 items, users only, 0 (none, not at all) to 5 (extreme); the subscale is in the name |

Questionnaire items are the index of the chosen label, as stored by jsPsych
(`experiment/questionnaires.js` has the labels and item wording). A skipped
item is missing. No reverse-keying or scoring has been applied.

## illusiongame.csv

| column | values |
| --- | --- |
| `Participant` | as in `participants.csv` |
| `Illusion_Type` | `Ebbinghaus`, `MullerLyer`, `VerticalHorizontal` |
| `Block` | `Practice`, `A`, `B`: each illusion has a practice block and two test blocks of 80 trials |
| `Block_Number` | the order of the test blocks in the session (1–6; practice is counted in block 1) |
| `Trial` | trial number within the block |
| `Illusion_Strength` | in each illusion's own units. **Positive means conflicting**: the illusion pushes towards the wrong answer, whatever the side of the difference. Negative means facilitating. There are no strength-0 trials |
| `Illusion_Difference` | the real difference between the two targets, in each illusion's units; the sign gives the side |
| `ISI` | duration of the fixation cross before the trial, ms |
| `Response`, `Correct_Response` | arrow keys |
| `RT` | response time, ms |
| `Error` | 1 if the response was wrong |

The stimuli come from the Illusion Game v3
(<https://realitybending.github.io/IllusionGame/v3>).

## selfassociation.csv

The participant first chose a celebrity (the stranger) and typed a friend's
first name. Each of three shapes was then assigned to one label: themselves,
the friend, or the stranger.
- **Practice:** a shape was shown, and the participant chose its label.
- **Test:** the shapes were reassigned (`experiment/SelfAssociation/`). Each
  trial showed a shape with a label, and the participant answered whether
  they matched.

Each label is recorded here by its role. A 500 ms fixation cross preceded
every trial.

| column | values |
| --- | --- |
| `Participant` | as in `participants.csv` |
| `Phase` | `Practice` or `Test` |
| `Trial` | trial number within the phase |
| `Shape` | `circle`, `square`, `triangle` |
| `Label` | `Self`, `Friend`, `Stranger`. In practice, the role the shape stood for; in test, the role of the label shown |
| `Matching` | test only: `Match` if the label shown is the shape's, else `Mismatch` (one trial in three is a match) |
| `Answer` | in practice, the role chosen; in test, `Match` or `Mismatch`. Missing when no answer was given in time |
| `Key` | the key pressed |
| `RT` | response time, ms; missing with the answer |
| `Error` | 1 if the answer was wrong or missing |
