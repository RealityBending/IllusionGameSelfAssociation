# =========================================================================
# De-identified open data, from the raw jsPsych files
# =========================================================================
# Writes the open dataset in data/open/ (in git; data/open/README.md is its
# codebook), from which every other script starts:
#   data/open/participants.csv   one row per session: demographics, screening,
#                                last psychedelic experience, questionnaire items
#   data/open/illusiongame.csv   one row per Illusion Game trial (practice too)
#   data/open/selfassociation.csv  one row per self-association trial
#                                (practice too), labels as roles
# and the private key data/participant_key.csv (raw id -> open id; gitignored,
# like every data/*.csv). Only whoever holds the raw files runs this, from the
# repo root; everyone else starts at 0_preprocessing.qmd:
#
#     Rscript analysis/0_deidentify.R
#
# Reads the raw files (one <id>.csv per session) from IGSA_RAW_DIR, by default
# ~/Box/Data/IllusionGameSelfAssociation, and never writes there.
#
# Sessions: the four arms of this study (control and control_T0_bis:
# psychedelic-naive controls, in French and English; psychedelic_society and
# psychedelics_soc_english: users), whatever their later inclusion, so that
# the exclusions can be redone from the open data. Not exported: the
# longitudinal arm (control_T0, ketamine_*, *_T1), a separate study, and
# jckbwy5hlw, not a genuine session (age "XXXX", demographics blank).
#
# De-identification. Nothing is copied wholesale: every column is built from a
# named field or from the answer to a question recognised by its wording, so
# anything else in the raw files stays there. In particular, nothing of:
#   - the raw session id, replaced by S001, S002, ... (key kept private)
#   - the session's date and time: the month only (YYYY-MM)
#   - browser, OS, screen size, platform ids (sona_id, prolific_id, ...)
#   - control_T0_bis's "last four digits of your phone number"
#   - the free-text diagnoses (health data): the yes/no answers only
#   - the country of residence (English arms only)
#   - the self-association task's labels, which the jsPsych data copies onto
#     every row, Illusion Game trials included: the friend's first name, typed
#     by the participant, and the celebrity they chose. In that task's trials
#     they become roles (Self / Friend / Stranger): its practice trials store
#     the label chosen as its text ("David", "Vous"), and its stimuli show it
# The free texts that remain were read through on 2026-11-03: days since the
# last psychedelic ("18 jours", "Octobre 2023") and the three meditation
# answers (times a week, months, minutes), all numbers or durations.
#
# Recoding. Button answers are stored as indices (0 = the first choice, "Oui"
# / "Yes"): they become Yes / No. Every French label becomes the English
# version's label (experiment/demographics.js), and any label outside the
# known set stops the script. Ages: the leading number ("42 ans"); a birth
# year becomes the session's year minus it; anything else is missing. The one
# age under 18, 16 (2lm12f31t0), is set to missing here, and another one would
# stop the script. That session is excluded from the analyses since 2026-11-21,
# in 0_preprocessing.qmd, by its open ID.

raw_dir <- Sys.getenv("IGSA_RAW_DIR", unset = file.path(
  Sys.getenv("USERPROFILE", unset = Sys.getenv("HOME")), "Box/Data/IllusionGameSelfAssociation"
))
open_dir <- "data/open"
key_file <- "data/participant_key.csv"

arms <- c(
  control = "French", control_T0_bis = "English",
  psychedelic_society = "French", psychedelics_soc_english = "English"
)
not_genuine <- "jckbwy5hlw"
age_typo <- "2lm12f31t0"

if (!dir.exists(raw_dir)) stop("no raw data in ", raw_dir, " (set IGSA_RAW_DIR)", call. = FALSE)
dir.create(open_dir, showWarnings = FALSE)


# Labels ------------------------------------------------------------------
# French label -> the English version's. English labels map to themselves.

fr_en <- c(
  "Homme" = "Male", "Femme" = "Female", "Oui" = "Yes", "Non" = "No",
  "Langue maternelle" = "Native", "langue maternelle" = "Native", "Courant" = "Fluent",
  "Intermédiaire" = "Intermediate", "Débutant" = "Beginner",
  "Récréative" = "Recreational", "Thérapeutique" = "Therapeutic", "Curiosité" = "Curiosity",
  "Spirituelle/religieuse" = "Spiritual/religious", "Autre" = "Other",
  "Psilocybine/champignons/truffes" = "Psilocybin/mushrooms/truffles",
  "Très faible" = "Very low", "Plus faible qu'une dose typique" = "Lower than a typical dose",
  "Typique" = "Typical", "Plus élevée qu'une dose typique" = "Higher than a typical dose",
  "Très élevée" = "Very high", "Ne sais pas" = "I'm not sure", "Incertain" = "Not sure",
  "Jamais" = "Never", "Une fois" = "One time", "Entre 2 et 5 fois" = "Between 2 and 5 times",
  "Entre 6 et 10 fois" = "Between 6 and 10 times", "Entre 11 et 50 fois" = "Between 11 and 50 times",
  "Entre 51 et 100 fois" = "Between 51 and 100 times", "Plus de 100 fois" = "More than 100 times",
  "Bouddhisme tibétain" = "Tibetan Buddhism", "Pleine conscience" = "Mindfulness",
  # Education: short labels in both languages
  "Université (doctorat)" = "Doctorate", "University (doctorate)" = "Doctorate",
  "Université (master) ou équivalent" = "Master", "University (masters) or equivalent" = "Master",
  "Université (licence) ou équivalent" = "Bachelor", "University (bachelor) or equivalent" = "Bachelor",
  "Lycée" = "High school",
  # Self-association shapes
  "cercle" = "circle", "carré" = "square"
)

allowed <- list(
  Sex = c("Male", "Female"),
  Student = c("Yes", "No"),
  Education = c("Doctorate", "Master", "Bachelor", "High school", "Other"),
  Language_Level = c("Native", "Fluent", "Intermediate", "Beginner"),
  Experience_Intention = c("Recreational", "Therapeutic", "Curiosity", "Spiritual/religious", "Microdosing", "Other"),
  Experience_Substance = c("Psilocybin/mushrooms/truffles", "LSD/1P-LSD/ALD-52", "Ayahuasca", "N,N-DMT",
                           "Mescaline (Peyote, San Pedro)", "Iboga/Ibogaine", "5-MeO-DMT (Bufo)", "Other"),
  Experience_Dose = c("Very low", "Lower than a typical dose", "Typical", "Higher than a typical dose",
                      "Very high", "I'm not sure"),
  Psychedelics_Frequency = c("Never", "One time", "Between 2 and 5 times", "Between 6 and 10 times",
                             "Between 11 and 50 times", "Between 51 and 100 times", "More than 100 times"),
  Drug = c("Yes", "No", "Not sure"),
  Meditation_Tradition = c("Zen", "Vipassana", "Tibetan Buddhism", "Yoga", "Mindfulness", "Qi-gong", "Other"),
  Shape = c("circle", "square", "triangle"),
  Role = c("Self", "Friend", "Stranger"),
  Matching = c("Match", "Mismatch")
)

translate <- function(x) {
  x <- trimws(gsub("[[:space:]]+", " ", gsub("<[^>]+>", "", x)))
  x[x == ""] <- NA
  hit <- !is.na(x) & x %in% names(fr_en)
  x[hit] <- fr_en[x[hit]]
  x
}

check_labels <- function(x, set, what) {
  bad <- setdiff(unlist(strsplit(x[!is.na(x)], "; ", fixed = TRUE)), set)
  if (length(bad)) stop(what, ": unknown label(s) ", paste0('"', bad, '"', collapse = ", "), call. = FALSE)
  x
}


# Raw-file helpers --------------------------------------------------------

# A jsPsych response: a flat JSON object of strings, numbers or arrays of
# strings. Returns a named character vector; arrays become "a; b".
json_flat <- function(x) {
  if (is.na(x) || !nzchar(x)) return(character(0))
  m <- regmatches(x, gregexpr('"[^"]+":(\\[[^]]*\\]|"(\\\\.|[^"\\\\])*"|[^,}]*)', x))[[1]]
  key <- sub('^"([^"]+)":.*$', "\\1", m)
  val <- sub('^"[^"]+":', "", m)
  arr <- startsWith(val, "[")
  val[arr] <- vapply(val[arr], function(v) {
    items <- regmatches(v, gregexpr('"[^"]*"', v))[[1]]
    paste(translate(gsub('"', "", items)), collapse = "; ")
  }, "")
  val[!arr] <- sub('^"(.*)"$', "\\1", val[!arr])
  stats::setNames(val, key)
}

# The first of `keys` (the field's name in either language) found in any
# response of the session
field <- function(responses, keys) {
  for (r in responses) {
    v <- json_flat(r)
    hit <- intersect(keys, names(v))
    if (length(hit)) return(unname(v[[hit[1]]]))
  }
  NA_character_
}

answer <- function(x) unname(c("0" = "Yes", "1" = "No")[sub("[.]0$", "", x)])

read_session <- function(file) {
  d <- read.csv(file, colClasses = "character", fileEncoding = "UTF-8-BOM")
  arm <- if ("group" %in% names(d)) d$group[nzchar(d$group)][1] else NA
  if (!isTRUE(arm %in% names(arms))) return(NULL)
  id <- sub("[.]csv$", "", basename(file))
  if (id == not_genuine) return(NULL)

  text <- gsub("<[^>]+>", "", d$stimulus)
  button <- d$trial_type == "html-button-response"
  ask <- function(pattern) which(button & grepl(pattern, text))[1]
  survey <- d$response[d$trial_type %in% c("survey-multi-choice", "survey-text", "survey-multi-select")]
  free_text <- function(i) {
    if (!is.na(i) && i <= nrow(d) && d$trial_type[i] == "survey-text") field(d$response[i], "Q0") else NA_character_
  }

  # Screening: each answer is read from the row of its own question
  i_ever_dx <- ask("ever been diagnosed|déjà été diagnostiqué")
  i_now_dx <- ask("currently diagnosed|en ce moment diagnostiqué")
  i_med <- ask("meditate regularly|Méditez-vous")
  i_ever <- ask("in your life|au cours de votre vie")
  i_month <- ask("last month|derniers? mois") # "du derniers mois" in the first version
  meditates <- !is.na(i_med) && answer(d$response[i_med]) %in% "Yes"
  # The follow-ups exist only after a Yes: times a week, months, minutes,
  # then the traditions
  med_ok <- meditates && i_med + 4 <= nrow(d) &&
    all(d$trial_type[i_med + 1:3] == "survey-text") && d$trial_type[i_med + 4] == "survey-multi-select"
  if (meditates && !med_ok) stop(id, ": meditation follow-ups not where expected", call. = FALSE)

  date <- as.Date(d$date[nzchar(d$date)][1], format = "%d/%m/%Y")
  likert <- function(prefix) {
    r <- d$response[startsWith(d$screen, prefix)]
    if (!length(r)) return(NULL)
    v <- json_flat(r[1])
    suppressWarnings(stats::setNames(as.integer(v), names(v)))
  }

  list(
    id = id,
    participant = data.frame(
      Raw_ID = id,
      Arm = arm,
      Session_Language = unname(arms[arm]),
      Session_Month = format(date, "%Y-%m"),
      Session_Year = as.integer(format(date, "%Y")),
      Completed_IG = sum(d$screen == "IG_Trial") == 504,
      Completed_SAT = any(d$screen == "sat_trial"),
      Age_Raw = field(survey, "age"),
      Sex = translate(field(survey, "sex")),
      Student = translate(field(survey, "student")),
      Education = translate(field(survey, "education")),
      Language_Level = translate(field(survey, "language")),
      Diagnosis_Past = if (is.na(i_ever_dx)) NA else answer(d$response[i_ever_dx]),
      Diagnosis_Current = if (is.na(i_now_dx)) NA else answer(d$response[i_now_dx]),
      Meditation = if (is.na(i_med)) NA else answer(d$response[i_med]),
      Meditation_PerWeek = if (med_ok) free_text(i_med + 1) else NA,
      Meditation_Months = if (med_ok) free_text(i_med + 2) else NA,
      Meditation_Minutes = if (med_ok) free_text(i_med + 3) else NA,
      Meditation_Tradition = if (med_ok) field(d$response[i_med + 4], "medTrad") else NA,
      Psychedelics_Ever = if (is.na(i_ever)) NA else answer(d$response[i_ever]),
      Psychedelics_LastMonth = if (is.na(i_month)) NA else answer(d$response[i_month]),
      # The days question follows the last-month one, whatever the answer
      Psychedelics_DaysAgo = if (is.na(i_month)) NA else free_text(i_month + 1),
      Psychedelics_Frequency = translate(field(survey, c("psych_freq", "psych_freq_english"))),
      Experience_Intention = translate(field(survey, "intention")),
      Experience_Substance = translate(field(survey, "substance")),
      Experience_Dose = translate(field(survey, "dose")),
      Drug_Cannabis = translate(field(survey, "cannabis")),
      Drug_Alcohol = translate(field(survey, c("Alcohol", "Alcool"))),
      Drug_Stimulants = translate(field(survey, "stimulants")),
      Drug_MDMA = translate(field(survey, "MDMA")),
      Drug_Opiates = translate(field(survey, c("Opiates", "Opiacés"))),
      Drug_Dissociatives = translate(field(survey, c("Dissociatives", "Dissociatifs")))
    ),
    items = {
      meq <- likert("questionnaire_meq")
      if (length(meq)) names(meq) <- paste0("MEQ_", names(meq))
      c(likert("questionnaire_aaq"), likert("questionnaire_dass21"), meq)
    },
    trials = {
      i <- which(d$screen == "IG_Trial")
      fix <- i - 1
      data.frame(
        Raw_ID = id,
        Illusion_Type = d$Illusion_Type[i],
        Block = d$block[i],
        Block_Number = as.integer(d$block_number[i]),
        Trial = as.integer(d$trial_number[i]),
        Illusion_Strength = as.numeric(d$Illusion_Strength[i]),
        Illusion_Difference = as.numeric(d$Illusion_Difference[i]),
        # The fixation cross before each trial; the raw `isi` column is not it
        ISI = ifelse(d$screen[fix] == "IG_FixationCross", suppressWarnings(as.numeric(d$trial_duration[fix])), NA),
        Response = d$response[i],
        Correct_Response = d$correct_response[i],
        RT = suppressWarnings(as.numeric(d$rt[i])),
        Error = as.integer(tolower(d$correct[i]) != "true")
      )
    },
    sat = sat_trials(d, id)
  )
}

# Self-association trials. Practice: a shape is shown and the label that goes
# with it is chosen (`condition` is its role; `answer` and `answer_correct`
# are label texts). Test: a shape and a label are shown together and the
# answer is match or mismatch (`label_condition` is the label's role). A
# missing answer ("null") is a timeout.
sat_trials <- function(d, id) {
  i <- which(d$screen %in% c("sat_practicetrial", "sat_trial"))
  if (!length(i)) return(NULL)
  test <- d$screen[i] == "sat_trial"
  null <- function(x) ifelse(x %in% c("null", ""), NA, x)
  friend <- d$label_friend[nzchar(d$label_friend)][1]
  stranger <- d$label_stranger[nzchar(d$label_stranger)][1]
  if (isTRUE(friend == stranger) || isTRUE(friend %in% c("You", "Vous"))) {
    stop(id, ": the friend's label cannot be told from the others", call. = FALSE)
  }
  # Each maps one phase's answers, and stops on anything it does not know
  role <- function(x) {
    x <- null(x)
    out <- ifelse(x %in% c("You", "Vous"), "Self", ifelse(x %in% friend, "Friend", ifelse(x %in% stranger, "Stranger", NA)))
    if (any(!is.na(x) & is.na(out))) stop(id, ": a practice answer that is no label", call. = FALSE)
    out
  }
  matching <- function(x) {
    x <- null(x)
    out <- unname(c(match = "Match", mismatch = "Mismatch")[x])
    if (any(!is.na(x) & is.na(out))) stop(id, ": a test answer that is neither match nor mismatch", call. = FALSE)
    out
  }
  p <- !test
  label <- answer_correct <- answer <- rep(NA_character_, length(i))
  label[test] <- d$label_condition[i][test]
  label[p] <- d$condition[i][p]
  answer_correct[test] <- matching(d$answer_correct[i][test])
  answer_correct[p] <- role(d$answer_correct[i][p])
  answer[test] <- matching(d$answer[i][test])
  answer[p] <- role(d$answer[i][p])
  if (any(p & (is.na(answer_correct) | answer_correct != label))) {
    stop(id, ": practice roles disagree", call. = FALSE)
  }
  # The fixation cross before each trial is 500 ms in every session, so it is
  # not a column
  data.frame(
    Raw_ID = id,
    Phase = ifelse(test, "Test", "Practice"),
    Trial = as.integer(d$trial_number[i]),
    Shape = translate(d$shape[i]),
    Label = label,
    Matching = ifelse(test, answer_correct, NA),
    Answer = answer,
    Key = null(d$response[i]),
    RT = suppressWarnings(as.numeric(null(d$rt[i]))),
    Error = as.integer(tolower(d$correct[i]) != "true")
  )
}


# Read --------------------------------------------------------------------

sessions <- Filter(Negate(is.null), lapply(list.files(raw_dir, pattern = "[.]csv$", full.names = TRUE), read_session))
ppt <- do.call(rbind, lapply(sessions, `[[`, "participant"))
trials <- do.call(rbind, lapply(sessions, `[[`, "trials"))
sat <- do.call(rbind, lapply(sessions, `[[`, "sat"))

# Questionnaire items, in questionnaire then item-number order
item_names <- unique(unlist(lapply(sessions, function(s) names(s$items))))
item_order <- order(
  match(sub("_.*$", "", item_names), c("AAQ", "DASS", "MEQ")),
  as.integer(sub("^.*_([0-9]+)$", "\\1", item_names))
)
item_names <- item_names[item_order]
items <- do.call(rbind, lapply(sessions, function(s) {
  as.data.frame(as.list(stats::setNames(s$items[item_names], item_names)))
}))
ppt <- cbind(ppt, items)


# Ages --------------------------------------------------------------------

age <- suppressWarnings(as.numeric(sub("^ *([0-9]+).*$", "\\1", ppt$Age_Raw)))
year <- !is.na(age) & age >= 1900
age[year] <- ppt$Session_Year[year] - age[year]
minor <- !is.na(age) & age < 18
if (any(minor & !ppt$Raw_ID %in% age_typo)) {
  stop("ages under 18 not decided on: ", paste(ppt$Raw_ID[minor & !ppt$Raw_ID %in% age_typo], collapse = ", "),
       call. = FALSE)
}
age[minor] <- NA
ppt$Age <- age
odd <- !is.na(ppt$Age_Raw) & (is.na(age) | year | age > 90)
if (any(odd)) {
  cat("Ages read with a rule (raw answer -> age):\n")
  print(data.frame(Raw = ppt$Age_Raw[odd], Age = age[odd]), row.names = FALSE)
}


# Labels, then ids ---------------------------------------------------------

for (v in intersect(names(allowed), names(ppt))) ppt[[v]] <- check_labels(ppt[[v]], allowed[[v]], v)
for (v in grep("^Drug_", names(ppt), value = TRUE)) ppt[[v]] <- check_labels(ppt[[v]], allowed$Drug, v)
sat$Shape <- check_labels(sat$Shape, allowed$Shape, "Shape")
sat$Label <- check_labels(sat$Label, allowed$Role, "Label")
sat$Matching <- check_labels(sat$Matching, allowed$Matching, "Matching")
sat$Answer <- check_labels(sat$Answer, c(allowed$Role, allowed$Matching), "Answer")

# S001, S002, ... in order of raw id (random strings), kept across reruns:
# an id already in the key keeps its number
key <- if (file.exists(key_file)) read.csv(key_file, colClasses = "character") else
  data.frame(Raw_ID = character(0), Participant = character(0))
new <- sort(setdiff(ppt$Raw_ID, key$Raw_ID))
if (length(new)) {
  start <- if (nrow(key)) max(as.integer(sub("^S", "", key$Participant))) else 0
  key <- rbind(key, data.frame(Raw_ID = new, Participant = sprintf("S%03d", start + seq_along(new))))
  write.csv(key, key_file, row.names = FALSE)
}
ppt$Participant <- key$Participant[match(ppt$Raw_ID, key$Raw_ID)]
trials$Participant <- key$Participant[match(trials$Raw_ID, key$Raw_ID)]
sat$Participant <- key$Participant[match(sat$Raw_ID, key$Raw_ID)]


# Write -------------------------------------------------------------------

ppt <- ppt[order(ppt$Participant), c(
  "Participant", "Arm", "Session_Language", "Session_Month", "Completed_IG", "Completed_SAT",
  "Age", "Sex", "Student", "Education", "Language_Level", "Diagnosis_Past", "Diagnosis_Current",
  "Meditation", "Meditation_PerWeek", "Meditation_Months", "Meditation_Minutes", "Meditation_Tradition",
  "Psychedelics_Ever", "Psychedelics_LastMonth", "Psychedelics_DaysAgo", "Psychedelics_Frequency",
  "Experience_Intention", "Experience_Substance", "Experience_Dose",
  grep("^Drug_", names(ppt), value = TRUE), item_names
)]
trials <- trials[order(trials$Participant, trials$Block_Number, trials$Trial), c(
  "Participant", "Illusion_Type", "Block", "Block_Number", "Trial", "Illusion_Strength",
  "Illusion_Difference", "ISI", "Response", "Correct_Response", "RT", "Error"
)]

sat <- sat[order(sat$Participant, sat$Phase, sat$Trial), c(
  "Participant", "Phase", "Trial", "Shape", "Label", "Matching", "Answer", "Key", "RT", "Error"
)]

files <- file.path(open_dir, c("participants.csv", "illusiongame.csv", "selfassociation.csv"))
write.csv(ppt, files[1], row.names = FALSE, fileEncoding = "UTF-8")
write.csv(trials, files[2], row.names = FALSE, fileEncoding = "UTF-8")
write.csv(sat, files[3], row.names = FALSE, fileEncoding = "UTF-8")

# No raw id may reach the open files, in any column
for (f in files) {
  txt <- readLines(f, encoding = "UTF-8")
  leaked <- key$Raw_ID[vapply(key$Raw_ID, function(id) any(grepl(id, txt, fixed = TRUE)), TRUE)]
  if (length(leaked)) stop(f, " contains raw ids: ", paste(leaked, collapse = ", "), call. = FALSE)
}

cat(sprintf("%s: %d sessions x %d columns\n%s: %d trials\n%s: %d trials\n", files[1], nrow(ppt), ncol(ppt),
            files[2], nrow(trials), files[3], nrow(sat)))
print(table(Arm = ppt$Arm))
