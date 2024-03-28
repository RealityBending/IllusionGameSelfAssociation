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

    # Mege dataframes ----------------------------------------------------
    alldata_sub = pd.concat([alldata_sub, data_sub], axis=0)
    alldata_sat = pd.concat([alldata_sat, data_sat], axis=0)

alldata_sub.to_csv("../data/rawdata_participants.csv", index=False)
alldata_sat.to_csv("../data/rawdata_sat.csv", index=False)
