const path =
    "https://realitybending.github.io/IllusionGameSelfAssociation/experiment/SelfAssociation/"
var sat_shapes = ["circle", "triangle", "square"]
var sat_labels = ["You"]
var sat_characters = [
    "Elvis",
    "Seal",
    "Sting",
    "Eminem",
    "Bono",
    "Beyonce",
    "Madonna",
    "Rihanna",
    "Pink",
    "Shakira",
]
var sat_conditions = {}
var sat_labelconditions = {}
var sat_answers = { v: 0, b: 1, n: 2 }
var correct_count1 = 0
var correct_count2 = 0
var correct_count3 = 0
var sat_trialnumber = 1
var sat_blocknumber = 1
var sat_answerstrials = ["e", "i"]
var n_practice = 2 // Max number of practice trials (multiplied by 3)
var n_trials = 2 // Number of trials (multiplied by 9)

// Stimuli ========================================================================
// Function to repeat arrays
const repeat = (arr, n) => [].concat(...Array(n).fill(arr))

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
// Generate stimuli list with balanced labels
var stimuli_block = []
for (var n = 0; n < n_trials; n++) {
    for (var i = 0; i < stimuli.length; i++) {
        for (var y = 0; y < 3; y++) {
            let s = structuredClone(stimuli[i])
            s.data.label_condition = ["Self", "Friend", "Stranger"][y]
            stimuli_block.push(s)
        }
    }
}

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
    on_finish: function () {
        sat_answerstrials = jsPsych.randomization.shuffle(sat_answerstrials)
    },
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
    on_finish: function () {
        // Randomize shapes
        sat_shapes = jsPsych.randomization.shuffle(sat_shapes)
    },
}

// Matching Task Instructions
var sat_instructions_matching = {
    type: jsPsychHtmlButtonResponse,
    stimulus: function () {
        return (
            "<h1>Instructions</h1>" +
            "<p>In this part of the game, the previous shapes will be re-assigned to the labels.</p>" +
            "<p>Your task will be then to decide if the presented shape matches their newly assigned label as quickly and accurately as possible.</p>" +
            "<p>If the shape-label pair is a <b>match</b>, press <b>'" +
            sat_answerstrials[0] +
            "'</b>.</p>" +
            "<p>If the shape-label pair is <b>not a match</b>, press <b>'" +
            sat_answerstrials[1] +
            "'</b></p>" +
            "<br><p>Good luck!</p>"
        )
    },
    choices: ["Continue"],
    data: { screen: "matching_instructions" },
    on_finish: function () {
        // Randomize shapes so that no assignment is the same as before
        let old_order = structuredClone(sat_shapes)
        while (
            sat_shapes[0] == old_order[0] ||
            sat_shapes[1] == old_order[1] ||
            sat_shapes[2] == old_order[2]
        ) {
            sat_shapes = jsPsych.randomization.shuffle(sat_shapes)
        }
    },
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
        sat_conditions = Object.fromEntries(
            sat_shapes.map((key, index) => [key, sat_labels[index]])
        )
        sat_conditions = Object.fromEntries(
            sat_shapes.map(function (key, index) {
                lab = sat_labels[index]
                if (lab == "You") {
                    cond = "Self"
                } else if (sat_characters.includes(lab)) {
                    cond = "Stranger"
                } else {
                    cond = "Friend"
                }
                return [key, cond]
            })
        )
        sat_labelconditions = {
            Self: "You",
            Stranger: sat_labels[1],
            Friend: sat_labels[2],
        }
    },
    stimulus: function () {
        var text =
            "<h1>Instructions</h1>" +
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
    stimulus:
        "<div  style='font-size:500%; position:fixed; text-align: center; top:50%; bottom:50%; right:20%; left:20%'>+</div>",
    choices: "NO_KEYS",
    trial_duration: 500,
    save_trial_parameters: { trial_duration: true },
    data: { screen: "sat_fixationcross" },
}

var sat_practice_trial = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: function () {
        var stim = jsPsych.timelineVariable("stimulus")

        return (
            "<div style='bottom:60%; right:20%; left:20%; position:fixed'><img src=" +
            stim +
            " height=20%></img></div>" +
            "<div  style='font-size:500%; position:fixed; text-align: center; top:50%; bottom:50%; right:20%; left:20%'>+</div>" +
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
        data.condition = sat_conditions[stim]

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

var sat_feedback = {
    type: jsPsychHtmlKeyboardResponse,
    choice: "NO_KEYS",
    stimulus: function (data) {
        var last_trial = jsPsych.data.get().last().values()[0]
        if (last_trial.answer == null) {
            return "<p style = 'font-size: 300%; color:blue'>Out of Time!</p>"
        } else if (last_trial.correct == true) {
            return "<p style = 'font-size: 300%; color:green'>Correct!</p>"
        } else {
            return "<p style = 'font-size: 300%; color:red'>Incorrect!</p>"
        }
    },
    trial_duration: 500,
    data: { screen: "sat_feedback" },
}

var sat_practice = {
    timeline_variables: repeat(stimuli, n_practice),
    randomize_order: true,
    timeline: [sat_fixationcross, sat_practice_trial, sat_feedback],
}

var sat_practice_end = {
    type: jsPsychHtmlButtonResponse,
    on_start: function () {
        document.body.style.cursor = "Auto"
    },
    stimulus:
        "<h1>Congratulations!</h1>" + "<p>You have completed the training.</p>",
    choices: ["Continue"],
    data: { screen: "sat_practice_end" },
    on_finish: function () {
        sat_trialnumber = 1 // reset trial number
    },
}

// Matching Task ========================================================================
var sat_trial = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: function () {
        var stim = jsPsych.timelineVariable("stimulus")
        var cond = jsPsych.timelineVariable("data")["label_condition"]
        var label = sat_labelconditions[cond]

        return (
            "<div style='bottom:60%; right:20%; left:20%; position:fixed'><img src=" +
            stim +
            " height=20%></img></div>" +
            "<div  style='font-size:500%; position:fixed; text-align: center; top:50%; bottom:50%; right:20%; left:20%'>+</div>" +
            '<div style = "font-size:300%; text-align: center; position:fixed; top:70%; right:20%; left:20%"><b>' +
            label +
            "</div>"
        )
    },
    choices: sat_answerstrials,
    stimulus_duration: 1000, // I have extended the trial duration (100ms -> 1000ms) in order to make the task easier
    trial_duration: 4200,
    data: function () {
        return jsPsych.timelineVariable("data")
    },
    on_finish: function (data) {
        data.trial_number = sat_trialnumber
        sat_trialnumber += 1
        data.block_number = sat_blocknumber
        data.screen = "sat_trial"

        var resp = jsPsych.data.get().last().values()[0]["response"]
        var stim = jsPsych.data.get().last().values()[0]["shape"]
        var lab_cond = jsPsych.data.get().last().values()[0]["label_condition"]
        var stim_cond = sat_conditions[stim]
        if (stim_cond == lab_cond) {
            data.answer_correct = "match"
        } else {
            data.answer_correct = "mismatch"
        }
        if (resp == sat_answerstrials[0]) {
            data.answer = "match"
        } else if (resp == sat_answerstrials[1]) {
            data.answer = "mismatch"
        } else {
            data.answer = null
        }
        if (data.answer == data.answer_correct) {
            data.correct = true
        } else {
            data.correct = false
        }
    },
}

var sat_block = {
    timeline_variables: stimuli_block,
    randomize_order: true,
    timeline: [sat_fixationcross, sat_trial, sat_feedback],
}

var sat_block_debrief = {
    type: jsPsychHtmlButtonResponse,
    choices: ["Ready for the next round!"],
    on_start: function () {
        document.body.style.cursor = "Auto"
    },
    stimulus: function () {
        var results = jsPsych.data
            .get()
            .filter({ screen: "sat_trial", block_number: sat_blocknumber })
        var correct_results = results.filter({ correct: true })
        var proportion_correct = correct_results.count() / results.count()
        return (
            "<p>You responded correctly on <b>" +
            Math.round(proportion_correct * 100 * 100) / 100 +
            "" +
            "%</b> of the trials.</p>"
        )
    },
    data: { screen: "sat_block_debrief" },
    on_finish: function () {
        // Reset block number
        sat_blocknumber += 1
    },
}
