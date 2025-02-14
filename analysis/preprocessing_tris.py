import json
import os
import numpy as np
import pandas as pd


## Get files from OSF ======================================================
#def osf_listfiles(data_subproject="", token="", after_date=None):
#    try:
#        import osfclient
#    except ImportError:
#        raise ImportError("Please install 'osfclient' (`pip install osfclient`)")
#    osf = osfclient.OSF(token=token).project(data_subproject)  # Connect to project
#    storage = [s for s in osf.storages][0]  # Access storage component
#    files = [
#        {
#            "name": file.name.replace(".csv", ""),
#            "date": pd.to_datetime(file.date_created),
#            "url": file._download_url,
#            "size": file.size,
#            "file": file,
#        }
#        for file in storage.files
##    ]
 #   file = [f for f in storage.files][0]
 #   file.__dict__
#
#    if after_date is not None:
#        date = pd.to_datetime(after_date, format="%d/%m/%Y", utc=True)
#        files = [f for f, d in zip(files, [f["date"] > date for f in files]) if d]
#    return files


#token = "zYboMoukFI8HKabenQ35DH6tESHJo6oZll5BvOPma6Dppjqc2jnIB6sPCERCuaqO0UrHAa"  # Paste OSF token here to access private repositories
#files = osf_listfiles(
#    token=token,
#    data_subproject="aw3x9",  # Data subproject ID
#    after_date="13/03/2023",
#)

# Path where you have saved and unzipped the data manually downloaded from OSD
path = "/Users/baptistefauvel/Documents/GitHub/IllusionGameSelfAssociation/osfstorage-archive/"
files = os.listdir(path)


# Loop through files ======================================================
alldata_sub = pd.DataFrame()  # Initialize empty dataframe
alldata_ig = pd.DataFrame()  # Initialize empty dataframe
alldata_sat = pd.DataFrame()  # Initialize empty dataframe
alldata_sat_practicetrial = pd.DataFrame()  # Initialize empty dataframe
alldata_aaq = pd.DataFrame()
alldata_dass = pd.DataFrame()
alldata_MEQ_psychsoc = pd.DataFrame()


#for i, file in enumerate(files):
    #print(f"File N°{i+1}/{len(files)}")

    #if len(alldata_sub) > 0:
        #if file["name"] in alldata_sub["Participant"].values:
            #continue
 
    #data = pd.read_csv(file["file"]._get(file["url"], stream=True).raw)

    #if not "browser_info" in data["screen"].values:
        #continue

for i, file in enumerate(files):
    print(f"File N°{i+1}/{len(files)}")

    # Skip if participant already in the dataset
    filename = file.replace(".csv", "")
    if (
        "Participant" in alldata_sub.columns
        and filename in alldata_sub["Participant"].values
    ):
        continue

    data = pd.read_csv(path + file)   




    # data["screen"].unique()
    # Browser info -------------------------------------------------------

 
    #browser = data[data["screen"] == "browser_info"].iloc[0]
    if "browser_info" not in data["screen"].values:
       browser = "null"
       continue
    browser = data[data["screen"] == "browser_info"].iloc[0]
    
    
    data_sub = pd.DataFrame(
        {
            #"Participant": file["name"],
            "Participant": filename,
            "Experiment_Duration": data["time_elapsed"].max() / 1000 / 60,
            #"Date_OSF": file["date"],
            "Date": browser["date"],
            "Time": browser["time"],
            "Browser": browser["browser"],
            "Mobile": browser["mobile"],
            "Platform": browser["os"],
            "Screen_Width": browser["screen_width"],
            "Screen_Height": browser["screen_height"],
        },
        index=[0],
    )

    group_data = data[data["screen"] == "fullscreen"]
    if not group_data.empty:
        group = group_data.iloc[0]
    data_sub["Group"] = group["group"]     

    # Demographics -------------------------------------------------------
    dem1 = data[data["screen"] == "demographics_1"].iloc[0]
    dem1 = json.loads(dem1["response"])

    data_sub["Sex"] = dem1["sex"]
    data_sub["Education"] = dem1["education"]
    data_sub["Student"] = dem1["student"]
    data_sub["Language_Level"] = dem1["language"]

    dem2 = data[data["screen"] == "demographics_2"].iloc[0]
    dem2 = json.loads(dem2["response"])

    data_sub["Age"] = dem2["age"]
    # data_sub["Country"] = dem2["country"]
    # data_sub["Psychedelic Frequency"] = dem2["psych_freq_english"]

    # Extraction des informations d'email
    email_row = data[data["screen"] == "email"]
    if not email_row.empty:
        email_response = json.loads(email_row.iloc[0]["response"])
        data_sub["Email"] = email_response.get("Q0", None)  # Ajustez la clé si nécessaire

    email_t1_row = data[data["screen"] == "email_T1"]
    if not email_t1_row.empty:
        email_t1_response = json.loads(email_t1_row.iloc[0]["response"])
        data_sub["Email_T1"] = email_t1_response.get("Q0", None)  # Ajustez la clé si nécessaire

### Extract past psychiatric data ###
    psych_past = data[
    (data["stimulus"] == '<p style="font-size:18px; color:black;">Have you <b>ever</b> been diagnosed with any of the following pathologies ?</p>') |
    (data["stimulus"] == '<p style="font-size:18px; color:black;">Avez-vous <b>déjà</b> été diagnostiqué(e) pour une des pathologies suivantes ?</p>')
]
# Extraire la réponse pour le diagnostic passé
    past_psych_response = psych_past["response"].values[0] if not psych_past.empty else np.nan

# Ajouter les données psychiatriques passées au DataFrame data_sub
    data_sub["Past Psychiatric"] = past_psych_response


#Past psychiatric specificities (if applicable)



# Extract current psychiatric data
    psych_current = data[
    (data["stimulus"] == '<p style="font-size:18px; color:black;">Are you <b>currently</b> diagnosed with any of the following pathologies ?</p>') |
    (data["stimulus"] == '<p style="font-size:18px; color:black;">Etes-vous <b>en ce moment</b> diagnostiqué(e) pour une des pathologies suivantes?</p>')
]   
    current_psych_response = psych_current["response"].values[0] if not psych_current.empty else np.nan

# Add current psychiatric data to data_sub DataFrame
    data_sub["Current Psychiatric"] = current_psych_response


# Extract meditation data
    meditation = data[
    (data["stimulus"] == '<p style="font-size:18px; color:black;">Do you meditate regularly? E.g. at least once a week?</p>') |
    (data["stimulus"] =='<p style="font-size:18px; color:black;">Méditez-vous régulièrement? E.g. au moins une fois par semaine</p>')
]  
    meditation_response = meditation["response"].values[0] if not meditation.empty else np.nan

# Add meditation data to data_sub DataFrame
    data_sub["Meditation"] = meditation_response

# Extract psychedelic data
    psychedelic = data[
    (data["stimulus"] == '<p style="font-size:18px; color:black;">Have you taken a psychedelic drug in the last 6 months? (E.g. LSD, psilocybin mushrooms, ayahuasca)</p>') | 
    (data["stimulus"] == '<p style="font-size:18px; color:black;">Have-you ever taken any classical psychedelic substance (e.g. LSD, psilocybin mushrooms, ayahuasca) <b>in your life</b> ?</p>') | 
    (data["stimulus"] == '<p style="font-size:18px; color:black;">Avez-vous déjà consommé une substance psychédélique au cours de votre vie (e.g., LSD, champignons à psilocybe, ayahuasca) ?</p>')
]   
    psychedelic_response = psychedelic["response"].values[0] if not psychedelic.empty else np.nan

# Add psychedelic data to data_sub DataFrame
    data_sub["Psychedelics"] = psychedelic_response

    # Self Association ----------------------------------------------------
    sat_trial = data[data["screen"] == "sat_trial"]
    # Skip particpants that did not complete the task
    if len(sat_trial) == 0:
        continue

    data_sat = pd.DataFrame(
        {
            #"Participant": file["name"],
            "Participant": filename,
            "Trial": sat_trial["trial_number"],
            "Label_Stranger": sat_trial["label_stranger"].values,
            "Label_Friend": sat_trial["label_friend"].values,
            "Label_Condition": sat_trial["label_condition"].values,
            "Shape": sat_trial["shape"].values,
            "RT": sat_trial["rt"].values,
            "Response": sat_trial["response"].values,
            "Answer": sat_trial["answer"].values,
            "Correct": sat_trial["correct"].values,
        }
    )

    sat_practicetrial = data[data["screen"] == "sat_practicetrial"]
    # Skip particpants that did not complete the task
    if len(sat_practicetrial) == 0:
        continue

    data_sat_practicetrial = pd.DataFrame(
        {
            #"Participant": file["name"],
            "Participant": filename,
            "Trial": sat_practicetrial["trial_number"],
            "Answer": sat_practicetrial["answer"].values,
            "Correct": sat_practicetrial["correct"].values,
            "Correct_Answer": sat_practicetrial["answer_correct"].values,
             "Condition": sat_practicetrial["condition"].values,
            "RT": sat_practicetrial["rt"].values,
            "Response": sat_practicetrial["response"].values,
            "Shape": sat_practicetrial["shape"].values,

        }
    )


    aaq = data[(data["screen"] == "questionnaire_aaq_english") | (data["screen"] == "questionnaire_aaq_fr")]
    if not aaq.empty:
        aaq = aaq.iloc[0]
        aaq = json.loads(aaq["response"])
        data_aaq = pd.DataFrame({
            #"Participant": file["name"],
            "Participant": filename,
            "AAQ1": aaq["AAQ_1"],
            "AAQ2": aaq["AAQ_2"],
            "AAQ3": aaq["AAQ_3"],
            "AAQ4": aaq["AAQ_4"],
            "AAQ5": aaq["AAQ_5"],
            "AAQ6": aaq["AAQ_6"],
            "AAQ7": aaq["AAQ_7"]
        }, index=[0])
    else:
        #print(f"No questionnaire_aaq_english or questionnaire_aaq_fr data found for participant: {file['name']}")
        print(f"No questionnaire_aaq english or questionnaire_aas_fr data found for participant: {filename}")
        data_aaq = pd.DataFrame(columns=["AAQ1", "AAQ2", "AAQ3", "AAQ4", "AAQ5", "AAQ6", "AAQ7"])


    dass = data[(data["screen"] == "questionnaire_dass21_english") | (data["screen"] == "questionnaire_dass21_fr")]
    if not dass.empty:
        dass = dass.iloc[0]
        dass = json.loads(dass["response"])
        data_dass = pd.DataFrame({
            #"Participant": file["name"],
            "Participant": filename,
            "DASS_Stress_1": dass.get("DASS_Stress_1"),
            "DASS_Stress_6": dass.get("DASS_Stress_6"),
            "DASS_Stress_8": dass.get("DASS_Stress_8"),
            "DASS_Stress_11": dass.get("DASS_Stress_11"),
            "DASS_Stress_12": dass.get("DASS_Stress_12"),
            "DASS_Stress_14": dass.get("DASS_Stress_14"),
            "DASS_Stress_18": dass.get("DASS_Stress_18"),
            "DASS_Anxiety_2": dass.get("DASS_Anxiety_2"),
            "DASS_Anxiety_4": dass.get("DASS_Anxiety_4"),
            "DASS_Anxiety_7": dass.get("DASS_Anxiety_7"),
            "DASS_Anxiety_9": dass.get("DASS_Anxiety_9"),
            "DASS_Anxiety_15": dass.get("DASS_Anxiety_15"),
            "DASS_Anxiety_19": dass.get("DASS_Anxiety_19"),
            "DASS_Anxiety_20": dass.get("DASS_Anxiety_20"),
            "DASS_Depression_3": dass.get("DASS_Depression_3"),
            "DASS_Depression_5": dass.get("DASS_Depression_5"),
            "DASS_Depression_10": dass.get("DASS_Depression_10"),
            "DASS_Depression_13": dass.get("DASS_Depression_13"),
            "DASS_Depression_16": dass.get("DASS_Depression_16"),
            "DASS_Depression_17": dass.get("DASS_Depression_17"),
            "DASS_Depression_21": dass.get("DASS_Depression_21")


        }, index=[0])
    else:
        #print(f"No questionnaire_dass21_english or questionnaire_dass21_fr data found for participant: {file['name']}")
        print(f"No questionnaire_dass21_english or questionnaire dass21_fr data found for participant: {filename}")
        data_dass = pd.DataFrame(columns=["DASS_Stress_1", "DASS_Stress_6", "DASS_Stress_8", "DASS_Stress_11", "DASS_Stress_12", "DASS_Stress_14", "DASS_Stress_18", "DASS_Anxiety_2", "DASS_Anxiety_4", "DASS_Anxiety_7", "DASS_Anxiety_9", "DASS_Anxiety_15", "DASS_Anxiety_19", "DASS_Anxiety_20", "DASS_Depression_3", "DASS_Depression_5", "DASS_Depression_10", "DASS_Depression_13", "DASS_Depression_16", "DASS_Depression_17", "DASS_Depression_21"])

#MEQ psychsoc
    MEQ_psychsoc = data[(data["screen"] == "questionnaire_meq_psyche_society") | (data["screen"] == "questionnaire_meq")]
    if not MEQ_psychsoc.empty:
        MEQ_psychsoc = MEQ_psychsoc.iloc[0]
        MEQ_psychsoc = json.loads(MEQ_psychsoc["response"])
        data_MEQ_psychsoc = pd.DataFrame({
            #"Participant": file["name"],
            "Participant": filename,
            "Transcendence_1": MEQ_psychsoc["Transcendence_1"],
            "PositiveMood_2": MEQ_psychsoc["PositiveMood_2"],
            "Ineffability_3": MEQ_psychsoc["Ineffability_3"],
            "Mystical_4": MEQ_psychsoc["Mystical_4"],
            "Mystical_5": MEQ_psychsoc["Mystical_5"],
            "Mystical_6": MEQ_psychsoc["Mystical_6"],
            "Transcendence_7": MEQ_psychsoc["Transcendence_7"],
            "PositiveMood_8": MEQ_psychsoc["PositiveMood_8"],
            "Mystical_9": MEQ_psychsoc["Mystical_9"],
            "Ineffability_10": MEQ_psychsoc["Ineffability_10"],
            "Transcendence_11": MEQ_psychsoc["Transcendence_11"],
            "PositiveMood_12": MEQ_psychsoc["PositiveMood_12"],
            "Transcendence_13": MEQ_psychsoc["Transcendence_13"],
            "Mystical_14": MEQ_psychsoc["Mystical_14"],
            "Mystical_15": MEQ_psychsoc["Mystical_15"],
            "Mystical_16": MEQ_psychsoc["Mystical_16"],
            "PositiveMood_17": MEQ_psychsoc["PositiveMood_17"],
            "Mystical_18": MEQ_psychsoc["Mystical_18"],
            "Transcendence_19": MEQ_psychsoc["Transcendence_19"],
            "Mystical_20": MEQ_psychsoc["Mystical_20"],
            "Mystical_21": MEQ_psychsoc["Mystical_21"],
            "Transcendence_22": MEQ_psychsoc["Transcendence_22"],
            "Mystical_23": MEQ_psychsoc["Mystical_23"],
            "Mystical_24": MEQ_psychsoc["Mystical_24"],
            "Mystical_25": MEQ_psychsoc["Mystical_25"],
            "Mystical_26": MEQ_psychsoc["Mystical_26"],
            "PositiveMood_27": MEQ_psychsoc["PositiveMood_27"],
            "PositiveMood_27": MEQ_psychsoc["PositiveMood_27"],
            "Mystical_28": MEQ_psychsoc["Mystical_28"],
            "Ineffability_29": MEQ_psychsoc["Ineffability_29"],
            "PositiveMood_30": MEQ_psychsoc["PositiveMood_30"]
        

        }, index=[0])
    else:
        #print(f"No questionnaire_MEQ data found for participant: {file['name']}")
        print(f"No questionnaire_MEQ data found for participant: {filename}")
        data_MEQ_psychsoc = pd.DataFrame(columns=["Transcendence_1", "PositiveMood_2", "Ineffability_3", "Mystical_4", "Mystical_5", "Mystical_6", "Transcendence_7", "PositiveMood_8", "Mystical_9", "Ineffability_10", "Transcendence_11", "PositiveMood_12", "Transcendence_13", "Mystical_14", "Mystical_15", "Mystical_16", "PositiveMood_17", "Mystical_18", "Transcendence_19", "Mystical_20", "Mystical_21", "Transcendence_22", "Mystical_23", "Mystical_24", "Mystical_25", "Mystical_26", "PositiveMood_27", "Mystical_28", "Ineffability_29", "PositiveMood_30"])

    ig_trial = data[data["screen"] == "IG_Trial"]
    # Skip particpants that did not complete the task
    if len(ig_trial) == 0:
        #print(f"No IG_trial data found for participant: {file['name']}")  # Debugging statement
        print(f"No IG_trial data found for participant: {filename}")
        continue

    data_ig = pd.DataFrame(
        {
            #"Participant": file["name"],
            "Participant": filename,
            "Trial": ig_trial["trial_number"].values,
            "Correct_Response": ig_trial["correct_response"].values,
            "Illusion_Type": ig_trial["Illusion_Type"].values,
            "Illusion_Strength": ig_trial["Illusion_Strength"].values,
            "Illusion_Difference": ig_trial["Illusion_Difference"].values,
            "isi": ig_trial["isi"].values
        }
    )

    # Mege dataframes ----------------------------------------------------
    alldata_sub = pd.concat([alldata_sub, data_sub], axis=0) 
    alldata_sat = pd.concat([alldata_sat, data_sat], axis=0)  
    alldata_aaq = pd.concat([alldata_aaq, data_aaq], axis=0)
    alldata_dass = pd.concat([alldata_dass, data_dass], axis=0)
    alldata_ig = pd.concat([alldata_ig, data_ig], axis=0)
    alldata_sat_practicetrial = pd.concat([alldata_sat_practicetrial, data_sat_practicetrial], axis=0)  
    alldata_MEQ_psychsoc = pd.concat([alldata_MEQ_psychsoc, data_MEQ_psychsoc], axis=0)  



#alldata_sub.to_csv("../data/rawdata_participants.csv",index=False)
#alldata_aaq.to_csv("../data/rawdata_aaq.csv", index=False)
#alldata_dass.to_csv("../data/rawdata_dass.csv", index=False)
#alldata_ig.to_csv("../data/rawdata_ig.csv", index=False)
#alldata_sat.to_csv("../data/rawdata_sat.csv", index=False)
#alldata_sat_practicetrial.to_csv("../data/rawdata_practice_sat.csv", index=False)
#alldata_MEQ_psychsoc.to_csv("../data/rawdata_MEQ_psychsoc.csv", index=False)
    
alldata_sub.to_csv('/Users/baptistefauvel/Documents/GitHub/IllusionGameSelfAssociation/data/rawdata_participants.csv',index=False)
alldata_aaq.to_csv('/Users/baptistefauvel/Documents/GitHub/IllusionGameSelfAssociation/data/rawdata_aaq.csv', index=False)
alldata_dass.to_csv('/Users/baptistefauvel/Documents/GitHub/IllusionGameSelfAssociation/data/rawdata_dass.csv', index=False)
alldata_ig.to_csv('/Users/baptistefauvel/Documents/GitHub/IllusionGameSelfAssociation/data/rawdata_ig.csv', index=False)
alldata_sat.to_csv('/Users/baptistefauvel/Documents/GitHub/IllusionGameSelfAssociation/data/rawdata_sat.csv', index=False)
alldata_sat_practicetrial.to_csv('/Users/baptistefauvel/Documents/GitHub/IllusionGameSelfAssociation/data/rawdata_practice_sat.csv', index=False)
alldata_MEQ_psychsoc.to_csv('/Users/baptistefauvel/Documents/GitHub/IllusionGameSelfAssociation/data/rawdata_MEQ_psychsoc.csv', index=False)
