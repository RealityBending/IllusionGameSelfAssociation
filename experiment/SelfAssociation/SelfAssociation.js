const path =
    "https://realitybending.github.io/IllusionSelf/experiment/SelfAssociation/"
var sat_shapes = ["circle", "triangle", "square"]
// var sat_labels = ["You"]
var sat_labels = ["You", "Dupa", "Rihanna"]
var sat_answers = { v: 0, b: 1, n: 2 }
var correct_count1 = 0
var correct_count2 = 0
var correct_count3 = 0
var sat_trialnumber = 1

// Stimuli ========================================================================
var stimuli = [
    {
        stimulus: path + "stimuli/circle.png",
        data: { shape: "circle" },
    },
    {
        stimulus: path + "stimuli/triangle.png",
        data: { shape: "triangle" },
    },
    {
        stimulus: path + "stimuli/square.png",
        data: { shape: "square" },
    },
]

// Function to repeat arrays
const repeat = (arr, n) => [].concat(...Array(n).fill(arr))

var sat_preload = {
    type: jsPsychPreload,
    auto_preload: true,
    images: [
        path + "stimuli/circle.png",
        path + "stimuli/square.png",
        path + "stimuli/triangle.png",
    ],
}

// Instructions ========================================================================
var sat_instructions_general = {
    type: jsPsychHtmlButtonResponse,
    stimulus:
        "<h1>Shape-Label Association Game</h1>" +
        "<p>In this task, you will be shown some <b>shapes</b> that will be assigned to a <b>label</b> (You, Your Best Friend and a Stranger).</p>" +
        "<p>To personalize this game to your own experience, you will first select who you want the friend and the stranger to be.</p>",
    choices: ["Continue"],
    data: { screen: "SAT_instructions_general" },
}

var sat_instructions_practice = {
    type: jsPsychHtmlButtonResponse,
    stimulus:
        "<h1>Practice</h1>" +
        "<p>Each label (i.e., You, Best Friend, Stranger) will be assigned to a specific shape (circle, square or triangle)</p>" +
        "<p>During the practice phase, you will be presented with one of the shapes above a fixation cross, together with the three labels below the fixation cross.</p>" +
        "<p>Your task is to select the label that corresponds with the presented shape as quickly and accurately as possible</p>" +
        "<p>If the correct label is on the <b>left</b>, press <b>'v'</b>.</p>" +
        "<p>If the correct label is in the <b>middle</b>, press <b>'b'</b>.</p>" +
        "<p>If the correct label is on the <b>right</b>, press <b>'n'</b>.</p><br>",
    choices: ["Continue"],
    data: { screen: "SAT_instructions_practice" },
}

// Labels personalization ========================================================================
var sat_strangerlabel = {
    type: jsPsychSurveyMultiChoice,
    questions: [
        {
            prompt: "<b>Please choose a stranger's name:</b>",
            options: function () {
                if (
                    jsPsych.data
                        .get()
                        .filter({ screen: "demographics_1" })
                        .values()[0]["response"]["sex"] == "Male"
                ) {
                    return jsPsych.randomization.shuffle([
                        "Elvis",
                        "Seal",
                        "Sting",
                        "Eminem",
                        "Bono",
                    ])
                } else {
                    return jsPsych.randomization.shuffle([
                        "Beyonce",
                        "Madonna",
                        "Rihanna",
                        "Pink",
                        "Shakira",
                    ])
                }
            },
            name: "label_stranger",
            required: true,
        },
    ],
    on_finish: function () {
        var stranger = jsPsych.data.get().last().values()[0]["response"][
            "label_stranger"
        ]
        jsPsych.data.addProperties({ label_stranger: stranger })
        sat_labels.push(stranger)
    },
    data: { screen: "SAT_strangerlabel" },
}

var sat_friendlabel = {
    type: jsPsychSurveyText,
    questions: [
        {
            prompt: "<b>Now, please enter your best friend's first name (gender-matched)</b>:",
            placeholder: "e.g., John",
            name: "label_friend",
            required: true,
        },
    ],
    on_finish: function () {
        var friend = jsPsych.data.get().last().values()[0]["response"][
            "label_friend"
        ]
        jsPsych.data.addProperties({ label_friend: friend })
        sat_labels.push(friend)
    },
    data: { screen: "SAT_friendlabel" },
}

// Practice ========================================================================
// Assign shape-label randomly
// Note that in the original paradigm this training is given verbally
var sat_assignmentscreen = {
    type: jsPsychHtmlButtonResponse,
    on_start: function () {
        sat_shapes = jsPsych.randomization.shuffle(sat_shapes)
        // sat_labels = jsPsych.randomization.shuffle(sat_labels)
    },
    stimulus: function () {
        var text =
            "<h1>Learning Phase</h1>" +
            "<div id ='align-middle'><b>" +
            sat_labels[0] +
            "</b> will be represented by a <b>" +
            sat_shapes[0] +
            "</b>  " +
            `<img src= ${path + "stimuli/" + sat_shapes[0]}` +
            ".png height=40></img></div><br>" +
            "<div id ='align-middle'><b>" +
            sat_labels[1] +
            "</b> will be represented by a <b>" +
            sat_shapes[1] +
            "</b>  " +
            `<img src= ${path + "stimuli/" + sat_shapes[1]}` +
            ".png height=40></img></div><br>" +
            "<div id = 'align-middle'><b>" +
            sat_labels[2] +
            "</b> will be represented by a <b>" +
            sat_shapes[2] +
            "</b>  " +
            `<img src= ${path + "stimuli/" + sat_shapes[2]}` +
            ".png height=40></img></div><br>"
        return text
    },
    choices: ["I memorized it!"],
    data: { screen: "SAT_assignmentscreen" },
}

// Create grey fixation screen
var sat_fixationcross = {
    type: jsPsychHtmlKeyboardResponse,
    on_start: function () {
        document.body.style.cursor = "none"
    },
    stimulus: "<p style='font-size:500%;'>+</p>",
    choices: "NO_KEYS",
    trial_duration: 500,
    save_trial_parameters: { trial_duration: true },
    data: { screen: "sat_fixationcross" },
}

var sat_practicetrial = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: function () {
        var stim = jsPsych.timelineVariable("stimulus")

        return (
            "<img src=" +
            stim +
            " height=20%></img>" +
            "<p style='font-size:500%;'>+</p>" +
            '<div style = "font-size:300%; text-align: center; position:fixed; top:70%; left:20%"><b>' +
            sat_labels[0] +
            "</b></br></br></br></br>v</div>" +
            '<div style = "font-size:300%; text-align: center; position:fixed; top:70%; right:20%; left:20%"><b>' +
            sat_labels[1] +
            "</b></br></br></br></br>b</div>" +
            '<div style = "font-size:300%; text-align: center; position:fixed; top:70%; right:20%"><b>' +
            sat_labels[2] +
            "</b></br></br></br></br>n</div>"
        )
    },
    choices: ["v", "b", "n"],
    // stimulus_duration: 6000, // I have changed this in order that the stimulus remains visible during the entire trial duration
    trial_duration: 6000, // I have extended the trial duration (3000 -> 6000ms) to make the task easier
    data: function () {
        return jsPsych.timelineVariable("data")
    },
    on_finish: function (data) {
        data.trial_number = sat_trialnumber
        sat_trialnumber += 1
        data.screen = "sat_practicetrial"

        // Process answers
        var resp = jsPsych.data.get().last().values()[0]["response"]
        if (resp == null) {
            data.answer = null
        } else {
            data.answer = sat_labels[sat_answers[resp]]
        }
        var stim = jsPsych.data.get().last().values()[0]["shape"]
        data.answer_correct = sat_labels[sat_shapes.indexOf(stim)]
        data.correct = jsPsych.pluginAPI.compareKeys(
            data.answer,
            data.answer_correct
        )

        // Compute consecutive correct
        var n_consecutive = jsPsych.data
            .get()
            .filter({ screen: "sat_practicetrial" })
            .last(6)
            .values()
            .map((x) => x["correct"])
            .reduce((a, b) => a + b)

        // Autoend training if more than 6 continuous responses
        if (n_consecutive > 5) {
            jsPsych.endCurrentTimeline()
        }
    },
}

var sat_practice = {
    timeline_variables: repeat(stimuli, 2),
    randomize_order: true,
    timeline: [sat_fixationcross, sat_practicetrial],
}
