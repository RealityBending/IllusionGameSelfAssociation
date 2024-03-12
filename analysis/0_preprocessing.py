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
    after_date="10/03/2023",
)


# Loop through files ======================================================
alldata_sub = pd.DataFrame()  # Initialize empty dataframe
alldata_ig = pd.DataFrame()  # Initialize empty dataframe


for i, file in enumerate(files):
    print(f"File N°{i+1}/{len(files)}")

    if len(alldata_sub) > 0:
        if file["name"] in alldata_sub["Participant"].values:
            continue
    data = pd.read_csv(file["file"]._get(file["url"], stream=True).raw)
