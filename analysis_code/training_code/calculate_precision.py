"""
-----------------------------------------------------------------------------------------
calculate_precision.py
-----------------------------------------------------------------------------------------
Goal of the script:
Generate prediction for eyemovements and calculate euclidean distance 
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: main directory 
sys.argv[2]: project directory 
sys.argv[3]: subject 
sys.argv[4]: task 
sys.argv[5]: subtask
sys.argv[6]: group 
-----------------------------------------------------------------------------------------
Output(s):
tsv of fraction under thresholds
tsv.gz timeseries of Euclidean distance 
tsv.gz timeseries of Prediction
-----------------------------------------------------------------------------------------
To run:
cd /Users/sinakling/disks/meso_H/projects/deepmreye/training_code
python calculate_precision.py /scratch/mszinte/data deepmreye sub-02 DeepMReyeCalib fixation 327
-----------------------------------------------------------------------------------------
"""


import pandas as pd
import json
import numpy as np
import re
import matplotlib.pyplot as plt
import glob 
import os
import sys
import math 
import h5py
import scipy.io 
from scipy.interpolate import interp1d

# path of utils folder  
sys.path.append("{}/utils".format(os.getcwd()))
from eyetrack_utils import load_event_files, euclidean_distance, fraction_under_threshold, fraction_under_one_threshold, adapt_evaluation, split_predictions
# --------------------- Load settings and inputs -------------------------------------

def load_settings(settings_file):
    with open(settings_file) as f:
        settings = json.load(f)
    return settings

def load_events(main_dir, subject, ses, task): 
    data_events = load_event_files(main_dir, subject, ses, task)
    return data_events 

def load_inputs():
    return sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6]

def ensure_save_dir(base_dir, subject):
    save_dir = f"{base_dir}/{subject}/eyetracking"
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
    return save_dir

# Load inputs and setting
main_dir, project_dir, subject, task, subtask, group = load_inputs()
with open("settings.json") as f:
    settings = json.load(f)
# Load main experiment settings
ses = settings['session'] 
eye = settings['eye']
num_run = settings['num_run']
eyetracking_sampling = settings['eyetrack_sampling']
screen_size = settings['screen_size']
ppd = settings['ppd']

#pt = "pretrained"
pt = None

file_dir_save = ensure_save_dir(f'{main_dir}/{project_dir}/derivatives/pp_data', subject)
data_events = load_event_files(main_dir, project_dir, subject, ses, task)
dfs_runs = [pd.read_csv(run, sep="\t") for run in data_events]

precision_all_runs = []
precision_one_thrs_list = []

threshold = settings['threshold']


if pt == "pretrained":
    subject_file = f'{main_dir}/{project_dir}/derivatives/deepmreye_calib/pp_data_pretrained/{subject}_DeepMReyeCalib_no_label.npz'
else: 
    subject_file = f'{main_dir}/{project_dir}/derivatives/deepmreye_calib/pp_data/{subject}_DeepMReyeCalib_label.npz'


for run in range(num_run):
    
    #Load the prediction
    if pt == "pretrained": 
        prediction_dict = np.load(f"{main_dir}/{project_dir}/derivatives/deepmreye_calib/pred/evaluation_dict_calib_pretrained.npy", allow_pickle=True).item()
    else: 
        prediction_dict = np.load(f"{main_dir}/{project_dir}/derivatives/deepmreye_calib/pred/evaluation_dict_calib.npy", allow_pickle=True).item()

    subject_prediction = prediction_dict[subject_file]
    df_pred_median, df_pred_subtr = adapt_evaluation(subject_prediction)

    #Load the eye data
    eye_data = pd.read_csv(f"{file_dir_save}/{subject}_task-{task}_run_0{run + 1}_eyedata.tsv.gz", compression='gzip', delimiter='\t')
    eye_data = eye_data[['x', 'y']].to_numpy()
    
    
    #Split into runs
    segment_lengths = [int((len(df_pred_subtr)/3)), int((len(df_pred_subtr)/3)),int((len(df_pred_subtr)/3))]

    subject_prediction_X = split_predictions(df_pred_subtr, 'X', segment_lengths)
    subject_prediction_Y = split_predictions(df_pred_subtr, 'Y', segment_lengths)

    
    #Interpolate prediction to same length as eye data 
    subject_prediction_X_run = np.interp(
                np.linspace(0, 1, len(eye_data[:184550,:])),
                np.linspace(0, 1, len(subject_prediction_X[run])),
                subject_prediction_X[run]
            )
    subject_prediction_Y_run = np.interp(
                np.linspace(0, 1, len(eye_data[:184550,:])),
                np.linspace(0, 1, len(subject_prediction_Y[run])),
                subject_prediction_Y[run]
            )
    
    
    #prediction
    if subtask == 'fixation':
        subject_prediction_X_run = subject_prediction_X_run[:71500]
        subject_prediction_Y_run = subject_prediction_Y_run[:71500]
        eye_data = eye_data[:71500,:]
    elif subject == 'pursuit':
        subject_prediction_X_run = subject_prediction_X_run[71500:145500]
        subject_prediction_Y_run = subject_prediction_Y_run[71500:145500]
        eye_data = eye_data[71500:145500,:]
    elif subtask == 'freeview':
        subject_prediction_X_run = subject_prediction_X_run[145500:]
        subject_prediction_Y_run = subject_prediction_Y_run[145500:]
        eye_data = eye_data[145500:,:]
    else: 
        pass
    
    
    eucl_dist = euclidean_distance(eye_data,subject_prediction_X_run, subject_prediction_Y_run)

    eucl_dist_df = pd.DataFrame(eucl_dist, columns=['ee'])
    # Save eucl_dist as tsv.gz
    if pt == "pretrained": 
        ee_file_path = f'{file_dir_save}/{subject}_task-{task}_subtask-{subtask}_run_0{run+1}_ee_pretrained.tsv.gz'
    else: 
        ee_file_path = f'{file_dir_save}/{subject}_task-{task}_subtask-{subtask}_run_0{run+1}_ee.tsv.gz'
    eucl_dist_df.to_csv(ee_file_path, sep='\t', index=False, compression='gzip')


    precision_fraction = fraction_under_threshold(subject_prediction_X_run, eucl_dist)
    precision_one_thrs = fraction_under_one_threshold(subject_prediction_Y_run,eucl_dist,threshold)
        
    
    # Store precision for this run
    precision_all_runs.append(precision_fraction)
    precision_one_thrs_list.append(precision_one_thrs)



# Combine all precision data into a single DataFrame
precision_df = pd.DataFrame(precision_all_runs).T  # Transpose so each column is a run
precision_one_df = pd.DataFrame(precision_one_thrs_list).T  # Transpose so each column is a run

# Rename columns to match `run_01`, `run_02`, etc.
precision_df.columns = [f"run_{i+1:02d}" for i in range(num_run)]
precision_one_df.columns = [f"run_{i+1:02d}" for i in range(num_run)]

#precision_df["threshold"] = np.linspace(0, 9.0, 100)
# Add a column for the mean across runs
precision_df["precision_mean"] = precision_df.mean(axis=1)
precision_one_df["precision_one_thrs_mean"] = precision_one_df.mean(axis=1)



# Save the DataFrame to a TSV file

if pt == "pretrained": 
    output_tsv_file = f"{file_dir_save}/{subject}_task-{task}_subtask-{subtask}_precision_summary_pretrained.tsv"
else: 
    output_tsv_file = f"{file_dir_save}/{subject}_task-{task}_subtask-{subtask}_precision_summary.tsv"
precision_df.to_csv(output_tsv_file, sep="\t", index=False)

if pt == "pretrained": 
    output_one_tsv_file = f"{file_dir_save}/{subject}_task-{task}_subtask-{subtask}_precision_one_threshold_summary_pretrained.tsv"
else: 
    output_one_tsv_file = f"{file_dir_save}/{subject}_task-{task}_subtask-{subtask}_precision_one_threshold_summary.tsv"
precision_one_df.to_csv(output_one_tsv_file, sep="\t", index=False)

print(f"Saved precision summary to {output_tsv_file}")
    
# Define permission cmd
#print('Changing files permissions in {}/{}'.format(main_dir, project_dir))
#os.system("chmod -Rf 771 {}/{}".format(main_dir, project_dir))
#os.system("chgrp -Rf {} {}/{}".format(group, main_dir, project_dir))


