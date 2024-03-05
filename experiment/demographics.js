// Retrieve and save browser info ========================================================
var demographics_browser_info = {
    type: jsPsychBrowserCheck,
    data: {
        screen: "browser_info",
        date: new Date().toLocaleDateString("fr-FR"),
        time: new Date().toLocaleTimeString("fr-FR"),
    },
    on_finish: function (data) {
        dat = jsPsych.data.get().filter({ screen: "browser_info" }).values()[0]

        // Rename
        data["screen_height"] = dat["height"]
        data["screen_width"] = dat["width"]

        // Add URL variables - ?sona_id=x&exp=1
        let urlvars = jsPsych.data.urlVariables()
        data["researcher"] = urlvars["exp"]
        data["sona_id"] = urlvars["sona_id"]
        data["prolific_id"] = urlvars["PROLIFIC_PID"] // Prolific
        data["study_id"] = urlvars["STUDY_ID"] // Prolific
        data["session_id"] = urlvars["SESSION_ID"] // Prolific
    },
}

// Consent form ========================================================================
var demographics_consent = {
    css_classes: ["multichoice-narrow"],
    type: jsPsychHtmlButtonResponse,
    stimulus:
        // Logo
        "<img src='https://u-paris.fr/wp-content/uploads/2022/03/Universite_Paris-Cite-logo.jpeg' width='300px' align='right'/><br><br><br><br><br>" +
        // Title
        "<h1>Consentement éclairé</h1>" +
        "<p align='left'>Dans cette étude, vous allez devoir compléter [TODO].</p>" +
        "<p align='left'>Votre participation à cette recherche est confidentielle. <b>Vos réponses seront totalement anonymisées</b>, et votre adresse IP ni aucune autres informations identifiantes ne sont collectées.</p>" +
        "<p align='left'>Votre participation contribue aux avancées scientifiques. <b>En participant, vous acceptez de suivre les instructions et de fournir des réponses honnêtes.</b> Si vous ne souhaitez pas participer à cette étude, vous pouvez simplement fermer votre navigateur.</p>" +
        // "<p>Notez que des vérifications seront effectuées pour s'assurer de la validité des données.<br>Nous nous réservons le droit d'annuler votre participation ou votre compensation dans le cas de détection de réponses non-valides (e.g., réponses au hasard, consignes non lues...).</p>"
        "<p align='left'><br><sub><sup>Si vous avez des questions sur le projets, veuillez contacter Baptiste Fauvel (baptiste.fauvel@u-paris.fr). Cette étude a été expertisée et validée par le comité d'éthique de l'université de Paris.</sup></sub></p>",

    choices: ["J'ai lu et j'accepte les conditions de l'étude"],
    data: { screen: "consent" },
}

// Consent form English ========================================================================
var demographics_consent_english = {
    css_classes: ["multichoice-narrow"],
    type: jsPsychHtmlButtonResponse,
    stimulus:
        // Logo
        "<img src='https://u-paris.fr/wp-content/uploads/2022/03/Universite_Paris-Cite-logo.jpeg' width='300px' align='right'/><br><br><br><br><br>" +
        // Title
        "<h1>Consent form</h1>" +
        "<p align='left'>In this study, you will have to complete two questionnaires and two tasks.</p>" +
        "<p align='left'>The questionnaires and tasks must be completed alone. <b>Your participation is confidential and your answers will be anonymized.</b> We do not collect your IP address or any other identifying information.</p>" +
        "<p align='left'>Your data are very valuable for us. In participating, you will contribute to scientific progress. <b>In participating, you accept to follow the instructions and to supply honest answers.</b> If you don't want to participate, you can simply close your browser.</p>" +
        // "<p>Notez que des vérifications seront effectuées pour s'assurer de la validité des données.<br>Nous nous réservons le droit d'annuler votre participation ou votre compensation dans le cas de détection de réponses non-valides (e.g., réponses au hasard, consignes non lues...).</p>"
        "<p align='left'><br><sub><sup>If you have any question regarding the study, you can email Baptiste Fauvel (baptiste.fauvel@u-paris.fr). This study has been reviewed and approved by the ethical committee of the University of Paris .</sup></sub></p>",

    choices: ["I have read and I accept the terms of the study"],
    data: { screen: "consent" },
}

// Participant ID ========================================================================
var demographics_participant_id = {
    type: jsPsychSurveyText,
    questions: [
        {
            prompt: "Entrer le code participant:",
            placeholder: "001",
            name: "Participant_ID",
        },
    ],
    data: {
        screen: "participant_id",
    },
    on_finish: function () {
        // Store `participant_id` so that it can be reused later
        jsPsych.data.addProperties({
            participant_id: jsPsych.data.get().last().values()[0]["response"]["Participant_ID"],
        })
    },
}

// Demographic info ========================================================================
var demographics_multichoice = {
    type: jsPsychSurveyMultiChoice,
    preamble: "<b>Veuillez répondre aux questions suivantes:</b>",
    questions: [
        {
            prompt: "Quel est votre genre",
            options: ["Homme", "Femme"],
            name: "sex",
            required: true,
        },
        {
            prompt: "Etes vous actuellement étudiant?",
            options: ["Oui", "Non"],
            name: "student",
        },
        {
            prompt: "Quel est votre niveau d'étude?",
            options: [
                "Université (doctorat)",
                "Université (master) <sub><sup>ou équivalent</sup></sub>",
                "Université (licence) <sub><sup>ou équivalent</sup></sub>",
                "Lycée",
                "Autre",
            ],
            name: "education",
        },
        {
            prompt: "Quel est votre niveau de Français?",
            options: ["langue maternelle", "courant", "intermédiaire", "débutant"],
            name: "language",
        },
    ],
    data: {
        screen: "demographics_1",
    },
}

var demographics_freetext = {
    type: jsPsychSurveyText,
    questions: [
        {
            prompt: "Entrer votre âge (en années)",
            placeholder: "e.g., '31'",
            name: "age",
        },
    ],
    data: {
        screen: "demographics_2",
    },
}

var demographics_info = {
    timeline: [demographics_multichoice, demographics_freetext],
}

// Demographic info English ========================================================================
var demographics_multichoice_english = {
    type: jsPsychSurveyMultiChoice,
    preamble: "<b>Please answer the following questions:</b>",
    questions: [
        {
            prompt: "What is your gender?",
            options: ["Male", "Female"],
            name: "sex",
            required: true,
        },
        {
            prompt: "Are you currently a student?",
            options: ["Yes", "No"],
            name: "student",
        },
        {
            prompt: "What is your education level?",
            options: [
                "University (doctorate)",
                "University (masters) <sub><sup>or equivalent</sup></sub>",
                "University (bachelor) <sub><sup>or equivalent</sup></sub>",
                "High school",
                "Other",
            ],
            name: "education",
        },
        {
            prompt: "What is your english level?",
            options: ["native", "fluent", "intermediate", "beginner"],
            name: "language",
        },
    ],
    data: {
        screen: "demographics_1",
    },
}

var demographics_freetext_english = {
    type: jsPsychSurveyText,
    questions: [
        {
            prompt: "Enter your age (in years)",
            placeholder: "e.g., '31'",
            name: "age",
        },
    ],
    data: {
        screen: "demographics_2",
    },
}

var demographics_info_english = {
    timeline: [demographics_multichoice_english, demographics_freetext_english],
}

//past psychatric diagnoses and if node
var past_psych = {
    type: jsPsychHtmlButtonResponse,
    stimulus:
        '<p style="font-size:18px; color:black;">Avez-vous <b>déjà</b> été diagnostiqué pour une des pathologies suivantes ?</p>',
    prompt: "<p>Dépression, syndrôme de stress post-traumatique, trouble obsessionel-compulsif, anxiété, trouble de l'usage de substance (autre que la nicotine), schizophrénie</p>",
    choices: ["Oui", "Non"],
    on_finish: function (data) {
        console.log("past_psych response:", data.button_pressed)
    },
}

var psych_which_ever = {
    type: jsPsychSurveyText,
    questions: [{ prompt: "Précisez la pathologie", required: true }],
}

var if_node = {
    timeline: [psych_which_ever],
    conditional_function: function () {
        var data = jsPsych.data.get().last(1).values()[0]
        if (data.response == "1") {
            return false
        } else {
            return true
        }
    },
}

//past psychatric diagnoses and if node english
var past_psych_english = {
    type: jsPsychHtmlButtonResponse,
    stimulus:
        '<p style="font-size:18px; color:black;">Have you <b>ever</b> been diagnosed with any of the following pathologies ?</p>',
    prompt: "<p>Depression, post-traumatic stress disorder, obsessional-compulsive disorder, anxiety disorder, substance use disorder (other than nicotine), schizophrenia</p>",
    choices: ["Yes", "No"],
    on_finish: function (data) {
        console.log("past_psych_english response:", data.button_pressed)
    },
}

var psych_which_ever_english = {
    type: jsPsychSurveyText,
    questions: [{ prompt: "Please specify which", required: true }],
}

var if_node_english = {
    timeline: [psych_which_ever_english],
    conditional_function: function () {
        var data = jsPsych.data.get().last(1).values()[0]
        if (data.response == "1") {
            return false
        } else {
            return true
        }
    },
}

//current psychiatric diagnoses and if node
var current_psych = {
    type: jsPsychHtmlButtonResponse,
    stimulus:
        '<p style="font-size:18px; color:black;"Etes-vous <b>en ce moment</b> diagnostiqué pour une des pathologies suivantes?</p>',
    prompt: "<p>Dépression, syndrôme de stress post-traumatique, trouble obsessionel compulsif, anxiété, trouble de l'usage de substance (autre que la nicotine), schizophrénie</p>",
    choices: ["Yes", "No"],
    on_finish: function (data) {
        console.log("current_psych response:", data.button_pressed)
    },
}

var psych_which_current = {
    type: jsPsychSurveyText,
    questions: [{ prompt: "Précisez la pathologie", required: true }],
}

var if_node1 = {
    timeline: [psych_which_current],
    conditional_function: function () {
        var data = jsPsych.data.get().last(1).values()[0]
        if (data.response == "1") {
            return false
        } else {
            return true
        }
    },
}

//current psychiatric diagnoses and if node english
var current_psych_english = {
    type: jsPsychHtmlButtonResponse,
    stimulus:
        '<p style="font-size:18px; color:black;">Are you <b>currently</b> diagnosed with any of the following pathologies ?</p>',
    prompt: "<p>Depression, post-traumatic stress disorder, obsessional-compulsive disorder, anxiety disorder, substance use disorder (other than nicotine) schizophrenia</p>",
    choices: ["Yes", "No"],
    on_finish: function (data) {
        console.log("current_psych_english response:", data.button_pressed)
    },
}

var psych_which_current_english = {
    type: jsPsychSurveyText,
    questions: [{ prompt: "Please specify which", required: true }],
}

var if_node1_english = {
    timeline: [psych_which_current_english],
    conditional_function: function () {
        var data = jsPsych.data.get().last(1).values()[0]
        if (data.response == "1") {
            return false
        } else {
            return true
        }
    },
}

//Meditation background
var meditation = {
    type: jsPsychHtmlButtonResponse,
    stimulus:
        '<p style="font-size:18px; color:black;">Méditez-vous régulièrement? E.g. au moins une fois par semaine</p>',
    choices: ["Oui", "Non"],
    on_finish: function (data) {
        console.log("Meditation response:", data.button_pressed)
    },
}
var meditation_times = {
    type: jsPsychSurveyText,
    questions: [
        {
            prompt: "Combien de fois par semaine avez-vous médité en moyenne l'année dernière? ",
            required: true,
        },
    ],
}

var meditation_length = {
    type: jsPsychSurveyText,
    questions: [
        {
            prompt: "En moyenne, depuis combien de temps méditez-vous? Répondez en nombre de mois (e.g. 1 an = 12) ",
            required: true,
        },
    ],
}

var meditation_duration = {
    type: jsPsychSurveyText,
    questions: [
        {
            prompt: "En moyenne, combien de temps dure chacune de vos séances de méditation? répondez en nombre de minutes (e.g. 1 heure = 60) ",
            required: true,
        },
    ],
}

var meditation_type = {
    type: jsPsychSurveyMultiSelect,
    questions: [
        {
            prompt: "Dans quelle(s) tradition(s) s'inscrit votre pratique de la méditation? Plusieurs réponses sont possibles",
            name: "medTrad",
            options: [
                "Zen",
                "Vipassana",
                "Bouddhisme tibétain",
                "Yoga",
                "Pleine conscience",
                "Qi-gong",
                "Autre",
            ],
            required: true,
            horizontal: true,
        },
    ],
}

var if_node2 = {
    timeline: [meditation_times, meditation_length, meditation_duration, meditation_type],
    conditional_function: function () {
        var data = jsPsych.data.get().last(1).values()[0]
        if (data.response == "1") {
            return false
        } else {
            return true
        }
    },
}

//Meditation background English
var meditation_english = {
    type: jsPsychHtmlButtonResponse,
    stimulus:
        '<p style="font-size:18px; color:black;">Do you meditate regularly? E.g. at least once a week?</p>',
    choices: ["Yes", "No"],
    on_finish: function (data) {
        console.log("Meditation_english response:", data.button_pressed)
    },
}
var meditation_times_english = {
    type: jsPsychSurveyText,
    questions: [
        {
            prompt: "How many times per week have you mediated on average in the last year? ",
            required: true,
        },
    ],
}

var meditation_length_english = {
    type: jsPsychSurveyText,
    questions: [
        {
            prompt: "On average, how long have you been meditating? Answer in number of months (e.g. 1 year = 12) ",
            required: true,
        },
    ],
}

var meditation_duration_english = {
    type: jsPsychSurveyText,
    questions: [
        {
            prompt: "On average, how long is each meditation session. Answer in number of minutes (e.g. 1 hour = 60) ",
            required: true,
        },
    ],
}

var meditation_type_english = {
    type: jsPsychSurveyMultiSelect,
    questions: [
        {
            prompt: "In which tradition do you meditate? You may choose more than one",
            name: "medTrad",
            options: [
                "Zen",
                "Vipassana",
                "Tibetan Buddhism",
                "Yoga",
                "Mindfulness",
                "Qi-gong",
                "Other",
            ],
            required: true,
            horizontal: true,
        },
    ],
}

var if_node2_english = {
    timeline: [
        meditation_times_english,
        meditation_length_english,
        meditation_duration_english,
        meditation_type_english,
    ],
    conditional_function: function () {
        var data = jsPsych.data.get().last(1).values()[0]
        if (data.response == "1") {
            return false
        } else {
            return true
        }
    },
}

//Psychedelics history
var psychedelics = {
    type: jsPsychHtmlButtonResponse,
    stimulus:
        '<p style="font-size:18px; color:black;">Avez-vous pris une drogue psychédélique au cours des 6 derniers mois? (E.g. LSD, champignons à psilocybe, ayahuasca)</p>',
    choices: ["Oui", "Non"],
    on_finish: function (data) {
        console.log("Psychedelic response:", data.button_pressed)
    },
}

var psychedelics_freq_english = {
    type: jsPsychSurveyMultiChoice,
    questions: [
        {
            prompt: "Indiquez approximativement combien de fois vous avez pris une drogue psychédélique au cours de votre vie",
            name: "psych_freq",
            options: [
                "Jamais",
                "Une fois",
                "Entre 2 et 5 fois",
                "Entre 6 et 10 fois",
                "Entre 11 et 50 fois",
                "Entre 50 et 100 fois",
                "Plus de 100 fois",
            ],
            required: true,
            horizontal: true,
        },
    ],
}

//Psychedelics history English
var psychedelics_english = {
    type: jsPsychHtmlButtonResponse,
    stimulus:
        '<p style="font-size:18px; color:black;">Have you taken a psychedelic drug in the last 6 months? (E.g. LSD, psilocybin mushrooms, ayahuasca)</p>',
    choices: ["Yes", "No"],
    on_finish: function (data) {
        console.log("Psychedelic response_english:", data.button_pressed)
    },
}

var psychedelics_freq_english = {
    type: jsPsychSurveyMultiChoice,
    questions: [
        {
            prompt: "Please indicate approximately how many times you have used a psychedelic drug in your life",
            name: "psych_freq_english",
            options: [
                "Never",
                "One time",
                "Between 2 and 5 times",
                "Between 6 and 10 times",
                "Between 11 and 50 times",
                "Between 50 and 100 times",
                "More than 100 times",
            ],
            required: true,
            horizontal: true,
        },
    ],
}

// Thank you ========================================================================
var demographics_endscreen = {
    type: jsPsychHtmlButtonResponse,
    stimulus:
        "<h1>Merci beaucoup pour votre participation <3</h1>" +
        "<p>Cliquez sur 'Continuer' et <b>attendez que vos données soient enregistrées</b> avant de fermer l'onglet.</p> ",
    choices: ["Continuer"],
    data: { screen: "endscreen" },
}

// Thank you English ========================================================================
var demographics_waitdatasaving_english = {
    type: jsPsychHtmlButtonResponse,
    stimulus:
        "<p>Done! now click on 'Continue' and <b>wait until your responses have been successfully saved</b> before closing the tab.</p> ",
    choices: ["Continue"],
    data: { screen: "waitdatasaving" },
}

var demographics_endscreen_english = {
    type: jsPsychHtmlButtonResponse,
    css_classes: ["narrow-text"],
    stimulus: function () {
        let text =
            "<h1>Thank you for participating</h1>" +
            "<p>It means a lot to us. We know participating in scientific experiments can be long and not always the most fun, so we really do appreciate your help in helping us understand how the Human brain works.</p>"

        if (
            jsPsych.data.get().filter({ screen: "browser_info" }).values()[0]["prolific_id"] !=
            undefined
        ) {
            text +=
                "<br><p><b>You will now be redirected to Prolific. Please do not close this tab.</b></p>"
        } else {
            text += "<br><p><b>You can safely close the tab now.</b></p>"
        }
        return text
    },
    choices: ["End"],
    data: { screen: "endscreen" },
}
