// Retrieve and save browser info ========================================================
var demographics_browser_info = {
    type: jsPsychBrowserCheck,
    data: {
        screen: "browser_info",
        date: new Date().toLocaleDateString("fr-FR"),
        time: new Date().toLocaleTimeString("fr-FR"),
    },
    on_finish: function () {
        data = jsPsych.data.get().filter({ screen: "browser_info" }).values()[0]
        jsPsych.data.addProperties({
            ["screen_height"]: data["height"],
            ["screen_width"]: data["width"],
        })
        for (var key in data) {
            if (
                [
                    "vsync_rate",
                    "os",
                    "mobile",
                    "browser",
                    "browser_version",
                ].includes(key)
            ) {
                jsPsych.data.addProperties({
                    [key]: data[key],
                })
            }
        }
        jsPsych.data.addProperties()
    },
}

// Participant ID ========================================================================
var demographics_participant_id = {
    type: jsPsychSurveyText,
    questions: [
        {
            prompt: "Entrer le code particpant:",
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
            participant_id: jsPsych.data.get().last().values()[0]["response"][
                "Participant_ID"
            ],
        })
    },
}

// Consent form ========================================================================
var demographics_consent = {
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
        // {
        //     prompt: "Etes vous actuellement étudiant?",
        //     options: ["Oui", "Non"],
        //     name: "student",
        // },
        // {
        //     prompt: "Quel est votre niveau d'étude?",
        //     options: [
        //         "Université (doctorat)",
        //         "Université (master) <sub><sup>or equivalent</sup></sub>",
        //         "Université (licence) <sub><sup>or equivalent</sup></sub>",
        //         "Lycée",
        //         "Autre",
        //     ],
        //     name: "education",
        // },
        // {
        //     prompt: "Quel est votre niveau de Français?",
        //     options: ["langue maternelle", "courant", "intermédiaire", "débutant"],
        //     name: "english",
        // },
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
        {
            prompt: "Quel est votre groupe ethnique",
            placeholder: "e.g., Caucasien",
            name: "ethnicity",
        },
    ],
    data: {
        screen: "demographics_2",
    },
}

var demographics_info = {
    timeline: [demographics_multichoice, demographics_freetext],
}
