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
            prompt: "Enter participant ID:",
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
    css_classes: ["multichoice-narrow"],
    type: jsPsychHtmlButtonResponse,
    stimulus:
        // Logo
        "<img src='https://u-paris.fr/wp-content/uploads/2022/03/Universite_Paris-Cite-logo.jpeg' width='300px' align='right'/><br><br><br><br><br>" +
        // Title
        "<h1>Consent form</h1>" +
        "<p align='left'>Dans cette étude, vous allez devoir compléter [TODO].</p>" +
        "<p align='left'>Votre participation à cette recherche est confidentielle. <b>Vos réponses seront totalement anonymisées</b>, et votre adresse IP ni aucune autres informations identifiantes ne sont collectées.</p>" +
        "<p align='left'>Votre participation contribue aux avancées scientifiques. <b>En participant, vous acceptez de suivre les instructions et de fournir des réponses honnêtes.</b> Si vous ne souhaitez pas participer à cette étude, vous pouvez simplement fermer votre navigateur.</p>" +
        // "<p>Notez que des vérifications seront effectuées pour s'assurer de la validité des données.<br>Nous nous réservons le droit d'annuler votre participation ou votre compensation dans le cas de détection de réponses non-valides (e.g., réponses au hasard, consignes non lues...).</p>"
        "<p align='left'><br><sub><sup>Si vous avez des questions sur le projets, veuillez contacter Baptiste Fauvel (baptiste.fauvel@u-paris.fr). Cette étude a été expertisée et validée par le comité d'éthique de l'université de Paris.</sup></sub></p>",

    choices: ["J'ai lu et j'accepte les conditions de l'étude"],
    data: { screen: "consent" },
}

// Thank you ========================================================================
var demographics_endscreen = {
    type: jsPsychHtmlButtonResponse,
    stimulus:
        "<h1>Merci beaucoup pour votre participation <3</h1>" +
        "<p>N'hésitez pas à partager l'expérience avec d'autres!</p>" +
        "<p>Cliquez sur 'Continuer' et <b>attendez que vos données soient enregistrées</b> avant de fermer l'onglet.</p> ",
    choices: ["Continuer"],
    data: { screen: "endscreen" },
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

//more demographics info
//email address
var email = {
    type: jsPsychSurveyText,
    questions: [
        {prompt: 'Please enter your email address', required: true},
    ]
}
//age
var age = {
    type: jsPsychSurveyText,
    questions: [
        {prompt: 'Please enter your age in years', required: true },
    ]
}
//education level
var socio_cultural = {
    type: jsPsychSurveyMultiChoice,
    questions: [
        {
            prompt: "Please indicate your education level",
            name: 'genderWhat',
            options: ['High School', 'High school diploma', 'Bachelor', 'Masters', 'Doctorate'],
            required: true,
            horizontal: true
        },
    ],
}
//past psychatric diagnoses and if node
var past_psych = {
    type: jsPsychHtmlButtonResponse,
    stimulus: '<p style="font-size:18px; color:black;">Have you <b>ever</b> been diagnosed with any of the following pathologies ?</p>',
    choices: ['Yes', 'No'],
    prompt: "<p>Depression, post-traumatic stress disorder, obsessional-compulsive disorder, anxiety disorder, substance use disorder (other than nicotine) schizophrenia</p>",
    on_finish: function (data) {
        console.log("past_psych response:", data.button_pressed);
    }
}

var psych_which_ever = {
    type: jsPsychSurveyText,
    questions: [
        { prompt: 'Please specify which', required: true },
    ]
}

var if_node = {
    timeline: [psych_which_ever],
    conditional_function: function(){
        var data = jsPsych.data.get().last(1).values()[0];
        if(data.response == '1'){
            return false;
        } else {
            return true;
        }
    }
}

//current psychiatric diagnoses and if node 
var current_psych = {
    type: jsPsychHtmlButtonResponse,
    stimulus: '<p style="font-size:18px; color:black;">Are you <b>currently</b> diagnosed with any of the following pathologies ?</p>',
    choices: ['Yes', 'No'],
    prompt: "<p>Depression, post-traumatic stress disorder, obsessional-compulsive disorder, anxiety disorder, substance use disorder (other than nicotine) schizophrenia</p>",
    on_finish: function (data) {
        console.log("current_psych response:", data.button_pressed);
    }
}

var psych_which_current = {
    type: jsPsychSurveyText,
    questions: [
        { prompt: 'Please specify which', required: true },
    ]
}

var if_node1 = {
    timeline: [psych_which_current],
    conditional_function: function(){
        var data = jsPsych.data.get().last(1).values()[0];
        if(data.response == '1'){
            return false;
        } else {
            return true;
        }
    }
}

//Meditation background 
var meditation = {
    type: jsPsychHtmlButtonResponse,
    stimulus: '<p style="font-size:18px; color:black;">Do you meditate regularly? E.g. at least once a week?</p>',
    choices: ['Yes', 'No'],
    on_finish: function (data) {
        console.log("Meditation response:", data.button_pressed);
    }
}
var meditation_times = {
    type: jsPsychSurveyText,
    questions: [
        { prompt: 'How many times per week have you mediated on average in the last year? ', required: true },
    ]
}

var meditation_length = {
    type: jsPsychSurveyText,
    questions: [
        { prompt: 'On average, how long have you been meditating? Answer in number of months (e.g. 1 year = 12) ', required: true },
    ]
}

var meditation_duration = {
    type: jsPsychSurveyText,
    questions: [
        { prompt: 'On average, how long is each meditation session. Answer in number of minutes (e.g. 1 hour = 60) ', required: true },
    ]
}

var meditation_type = {
    type: jsPsychSurveyMultiSelect,
    questions: [
        {
            prompt: "In which tradition do you meditate? You may choose more than one",
            name: 'medTrad',
            options: ['Zen', 'Vipassana', 'Tibetan Buddhism', 'Yoga', 'Mindfulness', 'Qi-gong', 'Other'],
            required: true,
            horizontal: true
        },
    ],
}

var if_node2 = {
    timeline: [meditation_times, meditation_length, meditation_duration, meditation_type],
    conditional_function: function(){
        var data = jsPsych.data.get().last(1).values()[0];
        if(data.response == '1'){
            return false;
        } else {
            return true;
        }
    }
}

//Psychedelics history
var psychedelics = {
    type: jsPsychHtmlButtonResponse,
    stimulus: '<p style="font-size:18px; color:black;">Have you taken a psychedelic drug in the last 6 months? (E.g. LSD, psilocybin mushrooms, ayahausca)</p>',
    choices: ['Yes', 'No'],
    on_finish: function (data) {
        console.log("Meditation response:", data.button_pressed);
    }
} 

var psychedelics_freq = {
    type: jsPsychSurveyMultiChoice,
    questions: [
        {
            prompt: "Please indicate approximately how many times you have used a psychedelic drug in your life",
            name: 'psych_freq',
            options: ['Never', 'Between 2 and 5 times', 'Between 6 and 10 times', 'Between 11 and 50 times', 'Between 50 and 100 times', 'More than 100 times'],
            required: true,
            horizontal: true
        },
    ],
}
//English level
//var english = {
//  type: jsPsychSurveyMultiChoice,
//questions: [
//  {
//    prompt: "What is your English level",
//  name: 'english',
//options: ['Native', 'Fluent', 'Intermediate', 'Beginner'],
//required: true,
//horizontal: true
//},
//],
//}
