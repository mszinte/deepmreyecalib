def detrending(eyetracking_1D, subject, ses, run, fixation_column, task, design_dir_save): 
    import numpy as np
    import matplotlib.pyplot as plt
    from scipy.signal import resample
    """
    Remove linear trends from eye-tracking data and median-center it during fixation periods for drift correction.

    Args:
        eyetracking_1D (np.array): 1D array of eye-tracking data to detrend.
        task (str): Task type, currently 'pRF' or other.

    Returns:
        np.array: Detrended eye-tracking data with trends removed and median-centered.
    """
    
    # Load and resample fixation data 
    fixation_trials = load_design_matrix_fixations(subject, ses, run, fixation_column, task, design_dir_save)  # Requires design matrix from task (see create_design_matrix.py)
    resampled_fixation_type = resample(fixation_trials, len(eyetracking_1D))
    fixation_bool = resampled_fixation_type > 0.5

    fixation_data = eyetracking_1D[fixation_bool]

    # Fit a linear model for the trend during fixation periods
    fixation_indices = np.where(fixation_bool)[0]
    trend_coefficients = np.polyfit(fixation_indices, fixation_data, deg=1)

    # Apply the linear trend to the entire dataset
    full_indices = np.arange(len(eyetracking_1D))
    linear_trend_full = np.polyval(trend_coefficients, full_indices)

    # Subtract the trend from the full dataset
    detrended_full_data = eyetracking_1D - linear_trend_full

    # Median centering using numpy's median function for consistency with numpy arrays
    fixation_median = np.median(detrended_full_data)
    detrended_full_data -= fixation_median

    # Plot the original and detrended data
    plt.plot(eyetracking_1D, label="Original Data")
    plt.plot(detrended_full_data, label="Detrended Data")
    plt.title("Detrended Full Eye Data")
    plt.xlabel("Time")
    plt.ylabel("Detrended Eye Position")
    plt.legend()
    plt.show()

    return detrended_full_data


def load_design_matrix_fixations(subject, ses, run, fixation_column, task, design_dir_save): 
    """
    Load the design matrix and extract fixation trial information.

    Args:
        fixation_column (str): Column name in the design matrix that contains fixation data.

    Returns:
        np.array: Array containing fixation trial information.
    """

    import pandas as pd
    import numpy as np
   
    design_matrix = pd.read_csv(f"{design_dir_save}/{subject}/{subject}_{ses}_task-{task}_run-0{run+1}_design_matrix.tsv", sep ="\t")
    fixation_trials = np.array(design_matrix[fixation_column])

    return fixation_trials

def load_event_files(main_dir, project_dir, subject, ses, task): 
    """
    Load event files from eye-tracking experiments.

    Args:
        main_dir (str): Main directory containing all experiment data.
        project_dir (str): Main project directory
        subject (str): Subject ID.
        ses (str): Session identifier.
        task (str): Task name.

    Returns:
        list: Sorted list of event file paths.
    """
    import glob
    
    data_events = sorted(glob.glob(r'{main_dir}/{project_dir}/{sub}/{ses}/func/{sub}_{ses}_task-{task}_*_events*.tsv'.format(
        main_dir=main_dir, project_dir=project_dir, sub=subject, ses = ses, task = task)))
    
    assert len(data_events) > 0, "No event files found"

    return data_events