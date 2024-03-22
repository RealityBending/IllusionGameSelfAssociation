// DASS-21 ======================================================================================
var dass_items = [
    "I found it hard to wind down",
    "I was aware of dryness of my mouth",
    "I couldn't seem to experience any positive feeling at all",
    "I experienced breathing difficulty (e.g. excessively rapid breathing, breathlessness in the absence of physical exertion)",
    "I found it difficult to work up the initiative to do things",
    "I tended to over-react to situations",
    "I experienced trembling (e.g. in the hands)",
    "I felt that I was using a lot of nervous energy",
    "I was worried about situations in which I might panic and make a fool of myself",
    "I felt that I had nothing to look forward to",
    "I found myself getting agitated",
    "I found it difficult to relax",
    "I felt down-hearted and blue",
    "I was intolerant of anything that kept me from getting on with what I was doing",
    "I felt I was close to panic",
    "I was unable to become enthusiastic about anything",
    "I felt I wasn't worth much as a person",
    "I felt that I was rather touchy",
    "I was aware of the action of my heart in the absence of physical exertion (e.g. sense of heart rate increase, heart missing a beat)",
    "I felt scared without any good reason",
    "I felt that life was meaningless",
]

var dass_items_fr = [
    "J'ai trouvé difficile de décompresser",
    "J'ai été conscient(e) d'avoir la bouche sèche",
    "J'ai eu l'impression de ne pas pouvoir ressentir d'émotions positives",
    "J'ai eu des difficultés à respirer (par exemple, respirations excessivement rapides, essoufflement sans effort physique)",
    "J'ai eu des difficultés à initier de nouvelles activités",
    "J'ai eu tendance à réagir de façon exagérée",
    "J'ai eu des tremblements (par exemple, des mains)",
    "J'ai eu l'impression de dépenser beaucoup d'énergie nerveuse",
    "Je me suis inquiété(e) en pensant à des situations où je pourrais paniquer et passer pour un(e) idiot(e)",
    "J'ai eu le sentiment de ne rien envisager avec plaisir",
    "Je me suis aperçu(e) que je devenais agité(e)",
    "J'ai eu des difficultés à me détendre",
    "Je me suis senti(e) abattu(e) et triste",
    "J'ai été intolérant(e) à tout ce qui m'empêchait de faire ce que j'avais à faire",
    "J'ai eu le sentiment d'être presque pris de panique",
    "J'ai été incapable de me sentir enthousiaste au sujet de quoi que ce soit",
    "J'ai eu le sentiment de ne pas valoir grand chose en tant que personne",
    "J'ai eu l'impression d'être assez susceptible",
    "J'ai été conscient(e) de palpitations cardiaques en l'absence d'effort physique (sensation d'augmentation du rythme cardiaque ou l'impression que le coeur saute)",
    "J'ai eu peur sans raison",
    "J'ai eu l'impression que la vie n'avait pas de sens",
]

var dass_dimensions = [
    "DASS_Stress_1",
    "DASS_Anxiety_2",
    "DASS_Depression_3",
    "DASS_Anxiety_4",
    "DASS_Depression_5",
    "DASS_Stress_6",
    "DASS_Anxiety_7",
    "DASS_Stress_8",
    "DASS_Anxiety_9",
    "DASS_Depression_10",
    "DASS_Stress_11",
    "DASS_Stress_12",
    "DASS_Depression_13",
    "DASS_Stress_14",
    "DASS_Anxiety_15",
    "DASS_Depression_16",
    "DASS_Depression_17",
    "DASS_Stress_18",
    "DASS_Anxiety_19",
    "DASS_Anxiety_20",
    "DASS_Depression_21",
]

var dass_labels = [
    "<br>Did not apply to me at all",
    "<br>Applied to me to some degree<br>/ some of the time",
    "<br>Applied to me to a considerable degree<br>/ a good part of time",
    "<br>Applied to me very much<br>/ most of the time",
]

var dass_labels_fr = [
    "<br>Ne s'applique pas du tout à moi",
    "<br>S'applique un peu à moi<br>/ de temps en temps",
    "<br>S'applique beaucoup à moi<br>/ souvent",
    "<br>S'applique entièrement à moi<br>/ la plupart du temps",
]

var dass_instructions =
    "<p>Please indicate how much each statement applied to you <b>over the past week.</b></p>" +
    "<p>There are no right or wrong answers.</p>"
var dass_instructions_fr =
    "<p>Indiquez à quel point chaque affirmation s'applique à vous <b>au cours de la dernière semaine.</b></p>" +
    "<p>Il n'y a pas de bonnes ou mauvaises réponses.</p>"

var dass_questions_fr = []
for (var n = 0; n < 21; n++) {
    dass_questions_fr.push({
        prompt: "<b>" + dass_items_fr[n] + "</b>",
        name: dass_dimensions[n],
        labels: dass_labels_fr,
        required: false,
    })
}

var dass_questions_english = []
for (var n = 0; n < 21; n++) {
    dass_questions_english.push({
        prompt: "<b>" + dass_items[n] + "</b>",
        name: dass_dimensions[n],
        labels: dass_labels,
        required: false,
    })
}

var dass_fr = {
    type: jsPsychSurveyLikert,
    questions: dass_questions_fr,
    randomize_question_order: false,
    preamble: dass_instructions_fr,
    data: {
        screen: "questionnaire_dass21_fr",
    },
}

var dass_english = {
    type: jsPsychSurveyLikert,
    questions: dass_questions_english,
    randomize_question_order: false,
    preamble: dass_instructions,
    data: {
        screen: "questionnaire_dass21_english",
    },
}

// Acceptance and Action Questionnaire-II (AAQ, Bond et al., 2002) ----------------
var aaq_items_fr = [
    "Mes expériences et mes souvenirs douloureux me gênent pour conduire ma vie comme il me tiendrait à coeur de le faire",
    "J'ai peur de mes émotions",
    "J'ai peur de ne pas être capable de contrôler mes inquiétudes et mes émotions",
    "Mes souvenirs douloureux m'empêchent de m'épanouir dans la vie",
    "Les émotions sont une source de problèmes dans ma vie",
    "J'ai l'impression que la plupart des gens gèrent leur vie mieux que moi",
    "Mes soucis m'empêchent de réussir",
]

var aaq_items = [
    "My painful experiences and memories make it difficult for me to live a life that I would value",
    "I'm afraid of my feelings",
    "I worry about not being able to control my worries and feelings",
    "My painful memories prevent me from having a fulfilling life",
    "Emotions cause problems in my life",
    "It seems like most people are handling their lives better than I am",
    "Worries get in the way of my success",
]

var aaq_dimensions = [
    "AAQ_1",
    "AAQ_2",
    "AAQ_3",
    "AAQ_4",
    "AAQ_5",
    "AAQ_6",
    "AAQ_7",
]

var aaq_labels = [
    "<br>Never true",
    "<br>Very seldom true",
    "<br>Seldom true",
    "<br>Sometimes true",
    "<br>Frequently true",
    "<br>Almost always true",
    "<br>Always true",
]

var aaq_labels_fr = [
    "<br>Jamais vrai",
    "<br>Très rarement vrai",
    "<br>Rarement vrai",
    "<br>Parfois vrai",
    "<br>Souvent vrai",
    "<br>Presque toujours vrai",
    "<br>Toujours vrai",
]

var aaq_instructions = "<p>Please rate how true each statement is of you.</p>"
var aaq_instructions_fr =
    "<p>Merci d'évaluer à quel point chaque affirmation est vraie pour vous.</p>"

var aaq_questions_fr = []
for (var n = 0; n < 7; n++) {
    aaq_questions_fr.push({
        prompt: "<b>" + aaq_items_fr[n] + "</b>",
        name: aaq_dimensions[n],
        labels: aaq_labels_fr,
        required: false,
    })
}

var aaq_questions_english = []
for (var n = 0; n < 7; n++) {
    aaq_questions_english.push({
        prompt: "<b>" + aaq_items[n] + "</b>",
        name: aaq_dimensions[n],
        labels: aaq_labels,
        required: false,
    })
}

var aaq_fr = {
    type: jsPsychSurveyLikert,
    questions: aaq_questions_fr,
    randomize_question_order: false,
    preamble: aaq_instructions_fr,
    data: {
        screen: "questionnaire_aaq_fr",
    },
}

var aaq_english = {
    type: jsPsychSurveyLikert,
    questions: aaq_questions_english,
    randomize_question_order: false,
    preamble: aaq_instructions,
    data: {
        screen: "questionnaire_aaq_english",
    },
}

// Mystical Experience Questionnaire - Short --------------------------------------
var meq_items = [
    "Loss of your usual sense of time",
    "Experience of amazement",
    "Sense that the experience cannot be described adequately in words",
    "Gain of insightful knowledge experienced at an intuitive level",
    "Feeling that you experienced eternity or infinity",
    "Experience of oneness or unity with objects and/or persons perceived in your surroundings",
    "Loss of your usual sense of space",
    "Feelings of tenderness and gentleness",
    'Certainty of encounter with ultimate reality (in the sense of being able to "know" and "see" what is really real at some point during your experience',
    "Feeling that you could not do justice to your experience by describing it in words",
    "Loss of usual awareness of where you were",
    "Feelings of peace and tranquility",
    'Sense of being "outside of" time, beyond past and future',
    "Freedom from the limitations of your personal self and feeling a unity or bond with what was felt to be greater than your personal self",
    "Sense of being at a spiritual height",
    "Experience of pure being and pure awareness (beyond the world of sense impressions)",
    "Experience of ecstasy.",
    'Experience of the insight that "all is One"',
    "Being in a realm with no space boundaries",
    'Experience of oneness in relation to an "inner world" within',
    "Sense of reverence",
    "Experience of timelessness",
    'You are convinced now, as you look back on your experience, that in it you encountered ultimate reality (i.e., that you "knew" and "saw" what was really real)',
    "Feeling that you experienced something profoundly sacred and holy",
    "Awareness of the life or living presence in all things",
    "Experience of the fusion of your personal self into a larger whole",
    "Sense of awe or awesomeness",
    "Experience of unity with ultimate reality.",
    "Feeling that it would be difficult to communicate your own experience to others who have not had similar experiences",
    "Feelings of joy",
]

var meq_items_fr = [
    "Perte de votre notion habituelle du temps",
    "Sentiment d'émerveillement",
    "Sentiment que l'expérience ne peut pas être décrite de manière adéquate avec des mots",
    "Acquisition de connaissances pertinentes ressenties à un niveau intuitif",
    "Impression que vous avez ressenti l'éternité ou l'infini",
    "Expérience d'unité avec les objets et/ou les personnes perçus dans votre environnement",
    "Perte de votre notion habituelle de l'espace",
    "Sentiment de tendresse et de douceur",
    "Certitude d'avoir atteint une réalité ultime (dans le sens d'être capable de « savoir » et de « voir » ce qui est vraiment réel à un moment donné au cours de votre expérience)</b><br>",
    "Sentiment que vous ne pourriez pas retranscrire fidèlement ce que vous avez vécu en le décrivant avec des mots",
    "Perte de la conscience habituelle de où vous êtes",
    "Sentiment de paix et de tranquillité",
    "Sensation d'être « en dehors » du temps, au-delà du passé et du futur",
    "Libération des limites de votre « moi » personnes et sentiment d'unité ou de lien avec quelque chose de ressenti comme plus grand que votre « moi » personnel",
    "Sensation d'être à un niveau spirituel",
    "Expérience de pure existence et de conscience pure (au-delà du monde des impressions sensorielles)",
    "Expérience d'extase",
    "Expérience de la révélation que « tout est Un »",
    "Être dans un monde sans limitation spatiale",
    "Expérience d'unité avec un « monde intérieur »",
    "Sentiment d'humilité",
    "Expérience d'intemporalité",
    "Vous êtes convaincu maintenant, quand vous repensez à votre expérience, que vous y avez atteint une réalité ultime (i.e. que vous « saviez » et « voyiez » ce qui est vraiment)",
    "Sentiment que vous avez vécu quelque chose de profondément sacré et saint",
    "Conscience de la vie ou d'une présence vivante en toutes choses",
    "Expérience de fusion de votre « moi » personnel avec un tout plus grand",
    "Sentiment d'admiration",
    "Expérience d'unité avec la réalité ultime",
    "Sentiment qu'il serait difficile de communiquer votre expérience avec des personnes qui ne l'ont pas vécue",
    "Sentiment de joie",
]

// TODO: Format dimensions
var meq_dimensions = [
    "Transcendence_1",
    "PositiveMood_2",
    "Ineffability_3",
    "Mystical_4",
    "Mystical_5",
    "Mystical_6",
    "Transcendence_7",
    "PositiveMood_8",
    "Mystical_9",
    "Ineffability_10",
    "Transcendence_11",
    "PositiveMood_12",
    "Transcendence_13",
    "Mystical_14",
    "Mystical_15",
    "Mystical_16",
    "PositiveMood_17",
    "Mystical_18",
    "Transcendence_19",
    "Mystical_20",
    "Mystical_21",
    "Transcendence_22",
    "Mystical_23",
    "Mystical_24",
    "Mystical_25",
    "Mystical_26",
    "PositiveMood_27",
    "Mystical_28",
    "Ineffability_29",
    "PositiveMood_30",
]

var meq_labels = [
    "<br>None, not at all",
    "<br>So slight, cannot decide",
    "<br>Slight",
    "<br>Moderate",
    "<br>Strong (equivalent in degree to any other strong experience)",
    "<br>Extreme (more than any other time in my life)",
]

var meq_labels_fr = [
    "<br>Non, pas du tout",
    "<br>Très légèrement, indiscernable",
    "<br>Légèrement",
    "<br>Modérément",
    "<br>Fort (équivalent en degré à tout autre expérience forte",
    "<br>Extrême (plus qu'à aucun autre moment dans ma vie)",
]

var meq_instructions =
    "<p>Looking back on the entirety of your session, please rate the degree to which at any time during that session you experienced the following phenomena.</p>" +
    "<p>Answer each question according to your feelings, thoughts, and experiences at the time of the session</p>"

    var meq_instructions_fr =
    "<p>En vous référant à l'ensemble de votre dernière expérience avec un psychédélique classique, veuillez évaluer le degré avec lequel vous avez vécu les phénomènes suivants.</p>" +
    "<p>Répondez à chaque question en fonction de vos ressentis, pensées et expériences durant la session.</p>"
   
 var meq_instructions_control = 
 "<p>Think of a moment over your past week where you felt the most spiritual, mystical or religious.</p>" +
 "<p>Answer each question according to your feelings, thoughts, and experiences at that moment</p>"

 var meq_instructions_meditation = 
 "<p>Looking back to the entirety of your strongest meditation session, please rate the degree to which any time during that session, you experienced the following phenomena.</p>" +
 "<p>Answer each question according to your feelings, thoughts, and experiences at that moment</p>"

 var meq_instructions_psilocybin = 
 "<p>Looking back to the entirety of your strongest psilocybin session, please rate the degree to which any time during that session, you experienced the following phenomena.</p>" +
 "<p>Answer each question according to your feelings, thoughts, and experiences at that moment</p>"


var meq_questions = []
for (var n = 0; n < 30; n++) {
    meq_questions.push({
        prompt: "<b>" + meq_items[n] + "</b>",
        name: meq_dimensions[n],
        labels: meq_labels,
        required: false,
    })
}

var meq_questions_fr = []
for (var n = 0; n < 30; n++) {
    meq_questions.push({
        prompt: "<b>" + meq_items_fr[n] + "</b>",
        name: meq_dimensions[n],
        labels: meq_labels_fr,
        required: false,
    })
}


var meq_control = {
    type: jsPsychSurveyLikert,
    questions: meq_questions,
    randomize_question_order: true,
    preamble: meq_instructions_control,
    data: {
        screen: "questionnaire_meq",
    },
}

var meq_meditation = {
    type: jsPsychSurveyLikert,
    questions: meq_questions,
    randomize_question_order: true,
    preamble: meq_instructions_meditation,
    data: {
        screen: "questionnaire_meq",
    },
}

var meq_psilocybin = {
    type: jsPsychSurveyLikert,
    questions: meq_questions,
    randomize_question_order: true,
    preamble: meq_instructions_psilocybin,
    data: {
        screen: "questionnaire_meq",
    },
}


