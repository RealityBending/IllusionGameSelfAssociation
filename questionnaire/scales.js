// Short form - Five Factor Mindfulness Questionnaire (15 items)
var FFMQ = [
    "<b>When I take a shower or a bath, I stay alert to the sensations of water on my body.</b><br>",
    "<b>I'm good at finding words to describe my feelings.</b><br>",
    "<b>I don't pay attention to what I'm doing because I'm daydreaming, worrying, or otherwise distracted.</b><br>",
    "<b>I believe some of my thoughts are abnormal or bad and I shouldn't think that way.</b><br>",
    "<b>When I have distressing thoughts or images, I 'step back' and am aware of the thought or image without getting taken over by it.</b><br>",
    "<b>I notice how foods and drinks affect my thoughts, bodily sensations, and emotions.</b><br>",
    "<b>I have trouble thinking of the right words to express how I feel about things.</b><br>",
    "<b>I do jobs or tasks automatically without being aware of what I'm doing.</b><br>",
    "<b>I think some of my emotions are bad or inappropriate and I shouldn't feel.</b><br>",
    "<b>When I have distressing thoughts or images I am able just to notice them without reacting.</b><br>",
    "<b>I pay attention to sensations, such as the wind in my hair or sun on my face.</b><br>",
    "<b>Even when I'm feeling terribly upset I can find a way to put it into words.</b><br>",
    "<b>I find myself doing things without paying attention.</b><br>",
    "<b>I tell myself I shouldn't be feeling the way I'm feeling.</b><br>",
    "<b>When I have distressing thoughts or images I just notice them and let them go.</b><br>",
]

var FFMQ_dim = [
    "Observation_1",
    "Description_2",
    "Awareness_3_R",
    "NonJudgemental_4_R",
    "NonReactivity_5",
    "Observation_6",
    "Description_7_R",
    "Awareness_8_R",
    "NonJudgemental_9_R",
    "NonReactivity_10",
    "Observation_11",
    "Description_12",
    "Awareness_13_R",
    "NonJudgemental_14_R",
    "NonReactivity_15",
]

// DASS-21
var DASS = [
    "<b>I found it hard to wind down.</b><br>",
    "<b>I was aware of dryness of my mouth.</b><br>",
    "<b>I couldn't seem to experience any positive feeling at all.</b><br>",
    "<b>I experienced breathing difficulty (e.g. excessively rapid breathing, breathlessness in the absence of physical exertion).</b><br>",
    "<b>I found it difficult to work up the initiative to do things.</b><br>",
    "<b>I tended to over-react to situations.</b><br>",
    "<b>I experienced trembling (e.g. in the hands).</b><br>",
    "<b>I felt that I was using a lot of nervous energy.</b><br>",
    "<b>I was worried about situations in which I might panic and make a fool of myself.</b><br>",
    "<b>I felt that I had nothing to look forward to.</b><br>",
    "<b>I found myself getting agitated.</b><br>",
    "<b>I found it difficult to relax.</b><br>",
    "<b>I felt down-hearted and blue.</b><br>",
    "<b>I was intolerant of anything that kept me from getting on with what I was doing.</b><br>",
    "<b>I felt I was close to panic.</b><br>",
    "<b>I was unable to become enthusiastic about anything.</b><br>",
    "<b>I felt I wasn't worth much as a person.</b><br>",
    "<b>I felt that I was rather touchy.</b><br>",
    "<b>I was aware of the action of my heart in the absence of physical exertion (e.g. sense of heart rate increase, heart missing a beat).</b><br>",
    "<b>I felt scared without any good reason.</b><br>",
    "<b>I felt that life was meaningless.</b><br>",
]

var DASS_dim = [
    "Stress_1",
    "Anxiety_2",
    "Depression_3",
    "Anxiety_4",
    "Depression_5",
    "Stress_6",
    "Anxiety_7",
    "Stress_8",
    "Anxiety_9",
    "Depression_10",
    "Stress_11",
    "Stress_12",
    "Depression_13",
    "Stress_14",
    "Anxiety_15",
    "Depression_16",
    "Depression_17",
    "Stress_18",
    "Anxiety_19",
    "Anxiety_20",
    "Depression_21"
]

// Watts Connectedness Scale (https://doi.org/10.1007/s00213-022-06187-5)
// Meausured on visual analog scale from Not at all to Entirely (0-100)
var WCS = [
    "<b>My mind feels connected to my heart/emotion.</b><br>",
    "<b>I feel connected to my senses (touch, taste, sight, smell, hearing).</b><br>",
    "<b>I feel connected to a range of emotions.</b><br>",
    "<b>If I had chosen to, I can 'sit with' painful memories.</b><br>",
    "<b>I feel connected to my body.</b><br>",
    "<b>I am able to fully experience emotion, whether positive or negative.</b><br>",
    "<b>I feel trapped in my mind.</b><br>",
    "<b>I feel alone.</b><br>",
    "<b>I feel connected to friends and/or family.</b><br>",
    "<b>I feel connected to a community.</b><br>",
    "<b>I feel unwelcome amongst others.</b><br>",
    "<b>I feel separate from the world around me.</b><br>",
    "<b>I feel connected to all humanity.</b><br>",
    "<b>I feel connected to a purpose in life.</b><br>",
    "<b>I feel connected to nature.</b><br>",
    "<b>I feel connected to a spiritual essence (in the secular or religious sense).</b><br>",
    "<b>I feel connected to a source of universal love.</b><br>",
    "<b>I see things from a broad perspective, the 'bigger picture'.</b><br>",
    "<b>I feel that everything is interconnected.</b><br>"
]

var WCS_dim =[
    "SelfConnectedness_1",
    "SelfConnectedness_2",
    "SelfConnectedness_3",
    "SelfConnectedness_4",
    "SelfConnectedness_5",
    "SelfConnectedness_6",
    "OtherConnectedness_7",
    "OtherConnectedness_8",
    "OtherConnectedness_9",
    "OtherConnectedness_10",
    "OtherConnectedness_11",
    "OtherConnectedness_12",
    "WorldConnectedness_13",
    "WorldConnectedness_14",
    "WorldConnectedness_15",
    "WorldConnectedness_16",
    "WorldConnectedness_17",
    "WorldConnectedness_18",
    "WorldConnectedness_19"
]

// Acceptance and Action Questionnaire-II (AAQ, Bond et al., 2002)
var AAQ =[
    "<b>My painful experiences and memories make it difficult for me to live a life that I would value.</b><br>",
    "<b>I'm afraid of my feelings.</b><br>",
    "<b>I worry about not being able to control my worries and feelings.</b><br>",
    "<b>My painful memories prevent me from having a fulfilling life.</b><br>",
    "<b>Emotions cause problems in my life.</b><br>",
    "<b>It seems like most people are handling their lives better than I am.</b><br>",
    "<b>Worries get in the way of my success.</b><br>"
]