import json

import numpy as np
import pandas as pd


# Get files from OSF ======================================================
def osf_listfiles(data_subproject="", token="", after_date=None):
    try:
        import osfclient
    except ImportError:
        raise ImportError("Please install 'osfclient' (`pip install osfclient`)")
    osf = osfclient.OSF(token=token).project(data_subproject)  # Connect to project
    storage = [s for s in osf.storages][0]  # Access storage component
    files = [
        {
            "name": file.name.replace(".csv", ""),
            "date": pd.to_datetime(file.date_created),
            "url": file._download_url,
            "size": file.size,
            "file": file,
        }
        for file in storage.files
    ]
    file = [f for f in storage.files][0]
    file.__dict__

    if after_date is not None:
        date = pd.to_datetime(after_date, format="%d/%m/%Y", utc=True)
        files = [f for f, d in zip(files, [f["date"] > date for f in files]) if d]
    return files


token = ""  # Paste OSF token here to access private repositories
files = osf_listfiles(
    token=token,
    data_subproject="aw3x9",  # Data subproject ID
    after_date="13/03/2023",
)


# Loop through files ======================================================
alldata_sub = pd.DataFrame()  # Initialize empty dataframe
alldata_ig = pd.DataFrame()  # Initialize empty dataframe
alldata_sat = pd.DataFrame()  # Initialize empty dataframe
alldata_sat_practicetrial = pd.DataFrame()  # Initialize empty dataframe
alldata_aaq = pd.DataFrame()
alldata_dass = pd.DataFrame()


for i, file in enumerate(files):
    print(f"File N°{i+1}/{len(files)}")

    if len(alldata_sub) > 0:
        if file["name"] in alldata_sub["Participant"].values:
            continue
    data = pd.read_csv(file["file"]._get(file["url"], stream=True).raw)

    if not "browser_info" in data["screen"].values:
        continue

    # data["screen"].unique()
    # Browser info -------------------------------------------------------

 
    browser = data[data["screen"] == "browser_info"].iloc[0]
    data_sub = pd.DataFrame(
        {
            "Participant": file["name"],
            "Experiment_Duration": data["time_elapsed"].max() / 1000 / 60,
            "Date_OSF": file["date"],
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
    #data_sub["Country"] = dem2["country"]
    #data_sub["Psychedelic Frequency"] = dem2["psych_freq_english"]

# Extract past psychiatric data
    psych_past = data[data["stimulus"] == '<p style="font-size:18px; color:black;">Have you <b>ever</b> been diagnosed with any of the following pathologies ?</p>']
    past_psych_response = psych_past["response"].values[0] if not psych_past.empty else np.nan

# Add past psychiatric data to data_sub DataFrame
    data_sub["Past Psychiatric"] = past_psych_response

# Extract current psychiatric data
    psych_current = data[data["stimulus"] == '<p style="font-size:18px; color:black;">Are you <b>currently</b> diagnosed with any of the following pathologies ?</p>']
    current_psych_response = psych_current["response"].values[0] if not psych_current.empty else np.nan

# Add current psychiatric data to data_sub DataFrame
    data_sub["Current Psychiatric"] = current_psych_response


# Extract meditation data
    meditation = data[data["stimulus"] == '<p style="font-size:18px; color:black;">Do you meditate regularly? E.g. at least once a week?</p>']
    meditation_response = meditation["response"].values[0] if not meditation.empty else np.nan

# Add meditation data to data_sub DataFrame
    data_sub["Meditation"] = meditation_response

# Extract psychedelic data
    psychedelic = data[data["stimulus"] == '<p style="font-size:18px; color:black;">Have you taken a psychedelic drug in the last 6 months? (E.g. LSD, psilocybin mushrooms, ayahuasca)</p>']
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
            "Participant": file["name"],
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
            "Participant": file["name"],
            "Trial": sat_practicetrial["trial_number"],
            "Answer": sat_practicetrial["answer"].values,
            "Correct": sat_practicetrial["correct"].values,
            "Correct_Answer": sat_practicetrial["answer_correct"].values,
             "Label_Condition": sat_practicetrial["condition"].values,
            "RT": sat_practicetrial["rt"].values,
            "Response": sat_practicetrial["response"].values,
        }
    )


    aaq = data[data["screen"] == "questionnaire_aaq_english"]
    data_aaq = pd.DataFrame(
        {
        },
        index=[0],
    )

    aaq = data[data["screen"] == "questionnaire_aaq_english"]
    if not aaq.empty:
        aaq = aaq.iloc[0]
        aaq = json.loads(aaq["response"])
        data_aaq = pd.DataFrame({
            "Participant": file["name"],
            "AAQ1": aaq["AAQ_1"],
            "AAQ2": aaq["AAQ_2"],
            "AAQ3": aaq["AAQ_3"],
            "AAQ4": aaq["AAQ_4"],
            "AAQ5": aaq["AAQ_5"],
            "AAQ6": aaq["AAQ_6"],
            "AAQ7": aaq["AAQ_7"]
        }, index=[0])
    else:
        print(f"No questionnaire_aaq_english data found for participant: {file['name']}")
        data_aaq = pd.DataFrame(columns=["AAQ1", "AAQ2", "AAQ3", "AAQ4", "AAQ5", "AAQ6", "AAQ7"])


    dass = data[data["screen"] == "questionnaire_dass21_english"]
    if not dass.empty:
        dass = dass.iloc[0]
        dass = json.loads(dass["response"])
        data_dass = pd.DataFrame({
            "Participant": file["name"],
            "DASS_Stress_1": dass["DASS_Stress_1"],
            "DASS_Stress_6": dass["DASS_Stress_6"],
            "DASS_Stress_8": dass["DASS_Stress_8"],
            "DASS_Stress_11": dass["DASS_Stress_11"],
            "DASS_Stress_12": dass["DASS_Stress_12"],
            "DASS_Stress_14": dass["DASS_Stress_14"],
            "DASS_Stress_18": dass["DASS_Stress_18"],
            "DASS_Anxiety_2": dass["DASS_Anxiety_2"],
            "DASS_Anxiety_4": dass["DASS_Anxiety_4"],
            "DASS_Anxiety_7": dass["DASS_Anxiety_7"],
            "DASS_Anxiety_9": dass["DASS_Anxiety_9"],
            "DASS_Anxiety_15": dass["DASS_Anxiety_15"],
            "DASS_Anxiety_19": dass["DASS_Anxiety_19"],
            "DASS_Anxiety_20": dass["DASS_Anxiety_20"],
            "DASS_Depression_3": dass["DASS_Depression_3"],
            "DASS_Depression_5": dass["DASS_Depression_5"],
            "DASS_Depression_10": dass["DASS_Depression_10"],
            "DASS_Depression_13": dass["DASS_Depression_13"],
            "DASS_Depression_16": dass["DASS_Depression_16"],
            "DASS_Depression_17": dass["DASS_Depression_17"],
            "DASS_Depression_21": dass["DASS_Depression_21"]


        }, index=[0])
    else:
        print(f"No questionnaire_dass21_english data found for participant: {file['name']}")
        data_dass = pd.DataFrame(columns=["DASS_Stress_1", "DASS_Stress_6", "DASS_Stress_8", "DASS_Stress_11", "DASS_Stress_12", "DASS_Stress_14", "DASS_Stress_18", "DASS_Anxiety_2", "DASS_Anxiety_4", "DASS_Anxiety_7", "DASS_Anxiety_9", "DASS_Anxiety_15", "DASS_Anxiety_19", "DASS_Anxiety_20", "DASS_Depression_3", "DASS_Depression_5", "DASS_Depression_10", "DASS_Depression_13", "DASS_Depression_16", "DASS_Depression_17", "DASS_Depression_21"])


    ig_trial = data[data["screen"] == "IG_Trial"]
    # Skip particpants that did not complete the task
    if len(ig_trial) == 0:
        print(f"No IG_trial data found for participant: {file['name']}")  # Debugging statement
        continue

    data_ig = pd.DataFrame(
        {
            "Participant": file["name"],
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



alldata_sub.to_csv("../data/rawdata_participants.csv",index=False)
#alldata_sat.to_csv("../data/rawdata_sat.csv", index=False)
alldata_aaq.to_csv("../data/rawdata_aaq.csv", index=False)
alldata_dass.to_csv("../data/rawdata_dass.csv", index=False)
alldata_ig.to_csv("../data/rawdata_ig.csv", index=False)
alldata_sat.to_csv("../data/rawdata_sat.csv", index=False)
alldata_sat.to_csv("../data/rawdata_sat.csv", index=False)
alldata_sat_practicetrial.to_csv("../data/rawdata_practice_sat.csv", index=False)



#1+1
