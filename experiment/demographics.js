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
        "<p align='left'>Dans cette étude, vous allez devoir compléter deux tâches sous forme de jeux pour mesurer (i) <b>vos capacités d'associations</b> et (ii) votre <b>sensibilité aux illusions visuelles</b>.</p>" +
        "<p align='left'>Vous aurez aussi à compléter trois questionnaires à propos de (i) <b>votre fonctionnement psychologique</b> et (ii) votre <b>dernière expérience avec une substance psychédélique classique</b>.</p>" +
        "<p align='left'>L'étude dure environ 40 minutes au total. Nous vous demandons de veiller à bien rester concentré et à fournir des réponses authentiques.</p>" +
        "<p align='left'>Votre participation à cette recherche est confidentielle. <b>Vos réponses seront totalement anonymisées</b>, et votre adresse IP ni aucune autres informations identifiantes ne sont collectées.</p>" +
        "<p align='left'>Vos données sont essentielles pour nous. Elles contribuent aux avancées scientifiques sur les thérapies-assistées par psychédéliques. <b>En participant, vous acceptez de suivre les instructions et de fournir des réponses honnêtes.</b> Si vous ne souhaitez pas participer à cette étude, vous pouvez simplement fermer votre navigateur.</p>" +
        "<p align='left'>Vous avez également le droit de vous retirer de l'étude à n'importe quel moment, pour cela, vous pouvez simplement fermer votre navigateur web.</p>" +
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
var email = {
    type: jsPsychSurveyText,
    questions: [
        {prompt: 'Please enter your email address', required: true},
    ]
};

var email_T1 = {
    type: jsPsychSurveyText,
    questions: [
        {prompt: 'Please enter the same email address as last time', required: true},
    ]
};

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
        {
            prompt: "What is your country of residence",
            placeholder: "France",
            name: "country",
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
    choices: ["Yes", "Non"],
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
        '<p style="font-size:18px; color:black;">Etes-vous <b>en ce moment</b> diagnostiqué pour une des pathologies suivantes?</p>',
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
        '<p style="font-size:18px; color:black;">Avez-vous consommé une substance psychédélique classique (e.g., LSD, champignons à psilocybe, ayahuasca) <b>au cours du derniers mois</b> ?</p>',
    choices: ["Oui", "Non"],
    on_finish: function (data) {
        console.log("Psychedelic response:", data.button_pressed)
    },
}

var psychedelics_days_ago = {
    type: jsPsychSurveyText,
    questions: [
        {
            prompt: "Veuillez indiquer le plus précisément possible combien de jours se sont écoulés depuis votre <b>dernière prise</b> d'une substance psychédélique classique ? (Si l'expérience date vous pouvez indiquer une approximation)",
            required: true,
        },
    ],
}


var psychedelics_multichoice_fr = {
    type: jsPsychSurveyMultiChoice,
    preamble: "<b>A propos de votre dernière prise d'une substance psychédélique classique:</b>",
    questions: [
        {
            prompt: "Quelle était votre intention principale pour cette expérience?",
            options: ["Récréative", "Thérapeutique", "Curiosité", "Spirituelle/religieuse", "Microdosing", "Autre",],
            add_other_option: true,
            name: "intention",
            required: true,
                },
               
                {prompt: "Quelle est la principale substance psychédélique que vous avez pris pour cette expérience?",
                options: ["Psilocybine/champignons/truffes", "LSD/1P-LSD/ALD-52", "Ayahuasca", "N,N-DMT", "Mescaline (Peyote, San Pedro)", "Iboga/Ibogaine", "5-MeO-DMT (Bufo)", "Salvia/Salvinorin A", "Autre:",],
                add_other_option: true,
                name: "substance",
                required: true,
            },
            {prompt: "Indiquez le niveau subjectif de la dose que vous avez pris pour cette expérience?",
            options: ["Très faible", "Plus faible qu'une dose typique", "Typique", "Plus élevée qu'une dose typique", "Très élevée", "Ne sais pas",],
            add_other_option: true,
            name: "dose",
            required: true,
        }
    ]
};

var psychedelics_others_fr = {
    type: jsPsychSurveyMultiChoice,
    preamble: "<b>Avez-vous utilisé ces autres substances pendant cette expérience? </b>",
    questions: [
        {
            prompt: "Cannabis",
            options: ["Oui", "Non", "Incertain"],
            name: "cannabis",
            required: true,
                },
               
                {prompt: "Alcool",
                options: ["Oui", "Non", "Incertain"],
                name: "Alcool",
                required: true,
            },
            {prompt: "Stimulants (e.g. cocaine, amphetamine, cathinones)",
            options: ["Oui", "Non", "Incertain"],
            name: "stimulants",
            required: true,
        },
        {prompt: "MDMA/ecstasy",
        options: ["Oui", "Non", "Incertain"],
        name: "MDMA",
        required: true,
    },
    {prompt: "Opiacés",
    options: ["Oui", "Non", "Incertain"],
    name: "Opiacés",
    required: true,
},
{prompt: "Dissociatifs (e.g., kétamine)",
    options: ["Oui", "Non", "Incertain"],
    name: "Dissociatifs",
    required: true,
},
    ]
};

var psychedelics_freq_french = {
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

var psychedelics_french = {
    timeline: [psychedelics_freq_french, psychedelics, psychedelics_days_ago, psychedelics_multichoice_fr, psychedelics_others_fr,],
}

//Psychedelics history English
var psychedelics_english = {
    type: jsPsychHtmlButtonResponse,
    stimulus:
        '<p style="font-size:18px; color:black;">Have you taken a psychedelic <b>during the last month</b>? (E.g. LSD, psilocybin mushrooms, ayahuasca)</p>',
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

//T1 passive control questions
var Passive_Control_Multichoice = {
    type: jsPsychSurveyMultiChoice,
    preamble: "<b>Please respond to the following questions before the tasks begin:</b>",
    questions: [
        {
            prompt: "Did you meditiate last week",
            options: ["Yes", "No"],
            name: "meditation",
            required: true,
        },
        {
            prompt: "Did you take any psychedelic substances (LSD, ayahuasca, psilocybin mushrooms) last week?",
            options: ["Yes", "No"],
            name: "psychedelics",
        },
        
    ],
    data: {
        screen: "passiveControl_1",
    },
}

//T1 meditation questions
var meditation_retreat_date = {
    type: jsPsychSurveyText,
    questions: [
        {
            prompt: "Please enter the date your retreat ended ",
            required: true,
        },
    ],
}


var Meditation_Control_psych = {
    type: jsPsychSurveyMultiChoice,
    preamble: "<b>Please respond to the following question before the tasks begin:</b>",
    questions: [
        {
            prompt: "Did you take any psychedelic substances (LSD, ayahuasca, psilocybin mushrooms) last week?",
            options: ["Yes", "No"],
            name: "psychedelics",
        },

        
    ],
    data: {
        screen: "MeditationControl_1",
    },
}

//T1 psychedelics questions
var psychedelics_retreat_date = {
    type: jsPsychSurveyText,
    questions: [
        {
            prompt: "Please enter the date your retreat ended ",
            required: true,
        },
    ],
}


var psychedelics_meditation_T1 = {
    type: jsPsychSurveyMultiChoice,
    preamble: "<b>Please respond to the following question before the tasks begin:</b>",
    questions: [
        {
            prompt: "Did you meditate last week?",
            options: ["Yes", "No"],
            name: "meditate",
        },

        
    ],
    data: {
        screen: "psychedelics_1",
    },
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
