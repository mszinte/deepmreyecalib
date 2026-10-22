"""
Recover per-frame target positions of the FrenchMinds DeepMReye calibration videos
(deepmreyecalib, branch `frenchminds`, CENIR settings) and build DeepMReye sub-TR labels.

Video time is frame-based: logged onsets in *_events.tsv are wall-clock times of a loop
slowed down by frame capture and are NOT used. Only the trial order is used.
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: main project directory
sys.argv[2]: project name (corresponds to directory)
sys.argv[3]: subject (e.g. sub-11) OR group name (e.g. group-all, defined in settings.yml)
sys.argv[4]: condition A (e.g. pmf-css-rdm)
sys.argv[5]: condition B (e.g. pmf-css-odm, or prf-css for a pmf-vs-prf comparison)
sys.argv[6]: (optional) task of the pmf condition(s), e.g. SacLoc or PurLoc (default SacLoc)
sys.argv[7]: (optional) task of condition B if it differs from condition A (e.g. SacLoc vs PurLoc)
             prf conditions are always task-pRF
-----------------------------------------------------------------------------------------
Output(s), all under {main_dir}/{project_dir}/derivatives/pp_data/{subject}/{format}/pmf/tsv :
- {subject}_task-{task_a}_{cond_a}_vs_task-{task_b}_{cond_b}_deriv.tsv
      merged per-vertex table for the two conditions (individual subjects only)
- {subject}_task-{task_a}_{cond_a}_vs_task-{task_b}_{cond_b}_{corr_param}-corr.tsv
      columns: roi, x_grid, y_grid, density
- {subject}_task-{task_a}_{cond_a}_vs_task-{task_b}_{cond_b}_{corr_param}-regression.tsv
      columns: roi, slope, intercept, r2_pearson, p_value, n_vertex, mean_r2_weight
      (+ *_ci_lower / *_ci_upper for group runs)
-----------------------------------------------------------------------------------------
To run:
cd ~/projects/deepmreyecalib/analysis_code/
python recover_target_positions.py ~/projects deepmreyecalib 1_63
-----------------------------------------------------------------------------------------
written by Sina Kling (sina.kling@outlook.de)
-----------------------------------------------------------------------------------------
"""
import numpy as np
import pandas as pd
import cv2
import sys

# ---- inputs ----------------------------------------------------------------------------
# Inputs
# Inputs
main_dir = sys.argv[1]
project_dir = sys.argv[2]
tr = sys.argv[3]                                           # e.g. "1_63"
acq_tr = float(sys.argv[4]) if len(sys.argv) > 4 else float(tr.replace('_', '.'))

movie_dir = f"{main_dir}/{project_dir}/experiment_code/others/movie"
events_file = f"{movie_dir}/calibration_exp_CENIR_{tr}_events.tsv"
video_file = f"{movie_dir}/calibration_exp_CENIR_{tr}.mp4"   # set to None to skip the video check
video_tr = float(tr.replace('_', '.'))                       # TR the video was generated with
n_sub = 10                                                   # DeepMReye sub-TR samples per TR

# ---- settings copied from experiment_code (frenchminds branch) -------------------------
scr_res = (1920, 1080)               # expLauncher.m desiredRes
scr_mm = (560.0, 310.0)              # scrConfig.m, CENIR disp_sizeX/Y (mm)
scr_dist_cm = 120.0                  # scrConfig.m, CENIR dist
fps = 120                            # desiredFD; VideoWriter.FrameRate = scr.hz
dur_tr = {1: 5, 2: 1, 3: 1, 4: 3}    # iti, fixation, pursuit, freeview (constConfig.m)
win_deg = (22.0, 12.375)             # window_sizeVal_x / _y
grid = (7, 3)                        # fixation_cols, fixation_rows (row-major, 1 = top-left)
pursuit_amp_deg = [3, 5, 6]
pursuit_angles = np.arange(0, 360, 20)

# vaDeg2pix: first output (x scaling) is used for every distance in the code, y included
ppd = 2 * scr_dist_cm * np.tan(np.deg2rad(0.5)) * 10 * scr_res[0] / scr_mm[0]
mid = np.array([scr_res[0] / 2, scr_res[1] / 2])

xs = np.linspace(mid[0] - win_deg[0] * ppd / 2, mid[0] + win_deg[0] * ppd / 2, grid[0])
ys = np.linspace(mid[1] - win_deg[1] * ppd / 2, mid[1] + win_deg[1] * ppd / 2, grid[1])
fix_coords = np.array([[x, y] for y in ys for x in xs])

# ---- per-frame positions ---------------------------------------------------------------
events = pd.read_csv(events_file, sep='\t')
n_purs = (events.task == 3).sum()
k_purs, purs_off, chunks = 0, mid.copy(), []

for _, ev in events.iterrows():
    task = int(ev.task)
    n_frm = int(round(dur_tr[task] * video_tr * fps))
    if task == 1:                                   # inter-trial interval: centre
        xy = np.tile(mid, (n_frm, 1))
    elif task == 2:                                 # fixation
        xy = np.tile(fix_coords[int(ev.fixation_location) - 1], (n_frm, 1))
    elif task == 3:                                 # pursuit, chained, last one back to centre
        k_purs += 1
        amp = pursuit_amp_deg[int(ev.pursuit_amplitude) - 1] * ppd
        ang = np.deg2rad(pursuit_angles[int(ev.pursuit_angle) - 1])
        on = mid.copy() if k_purs == 1 else purs_off
        off = mid.copy() if k_purs == n_purs else on + amp * np.array([np.cos(ang), -np.sin(ang)])
        xy = np.linspace(on, off, n_frm)
        purs_off = off
    else:                                           # free viewing: no target
        xy = np.full((n_frm, 2), np.nan)
    chunks.append(np.column_stack([np.full(n_frm, ev.trial_number), np.full(n_frm, task), xy]))

pos = pd.DataFrame(np.vstack(chunks), columns=['trial_number', 'task', 'x_pix', 'y_pix'])
pos[['trial_number', 'task']] = pos[['trial_number', 'task']].astype(int)
pos.insert(0, 'frame', np.arange(len(pos)) + 1)
pos.insert(1, 'time_s', (pos.frame - 1) / fps)
pos['x_deg'] = (pos.x_pix - mid[0]) / ppd
pos['y_deg'] = -(pos.y_pix - mid[1]) / ppd          # up = positive

out_file = events_file.replace('_events.tsv', '_targets.tsv')
pos.to_csv(out_file, sep='\t', index=False, na_rep='n/a', float_format='%.4f')
print(f'{out_file}: {len(pos)} frames, {len(pos) / fps:.2f} s')

# ---- DeepMReye sub-TR labels: (n_TR, n_sub, 2) in deg, sampled at sub-TR bin centres ---
n_tr = int(np.floor(len(pos) / fps / acq_tr))
t = (np.arange(n_tr)[:, None] + (np.arange(n_sub) + 0.5) / n_sub) * acq_tr
idx = np.clip(np.round(t * fps).astype(int), 0, len(pos) - 1)
labels = np.stack([pos.x_deg.values[idx], pos.y_deg.values[idx]], axis=-1)
np.save(events_file.replace('_events.tsv', f'_labels_acqTR-{acq_tr}.npy'), labels)
print(f'labels: {labels.shape} (NaN = free viewing, no target)')

# ---- check against the video: centroid of bright pixels every 97th frame ---------------
if video_file:
    cap, err = cv2.VideoCapture(video_file), []
    print(f'frames: video {int(cap.get(cv2.CAP_PROP_FRAME_COUNT))}, predicted {len(pos)}')
    for i in range(0, len(pos), 97):
        if pos.task[i] == 4:
            continue
        cap.set(cv2.CAP_PROP_POS_FRAMES, i)
        ok, img = cap.read()
        yy, xx = np.nonzero(img.mean(axis=2) > 128) if ok else ([], [])
        if len(xx):
            err.append(np.hypot(xx.mean() - pos.x_pix[i], yy.mean() - pos.y_pix[i]))
    print(f'checked {len(err)} frames: median error {np.median(err):.2f} px, max {np.max(err):.2f} px')
