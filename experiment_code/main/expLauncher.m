 
%% General experimenter launcher
%  =============================
% By: Sina KLING
% Projet: DeepMReyeCalib for FrenchMinds

% Experimental design : ~3min
% Task 1: calibration fixation 
% Task 2: calibration pursuit
% Task 3: calibration freeview images


% First settings
Screen('CloseAll'); clear all; clear mex; clear functions; close all; ...
    home; AssertOpenGL;

% General settings
const.expName = 'calibration_exp';      % experiment name
const.expStart = 0;                     % Start of a recording (0 = NO, 1 = YES)
const.checkTrial = 0;                   % Print trial conditions (0 = NO, 1 = YES)
const.mkVideo = 1;                      % Make a video (0 = NO, 1 = YES)

% External controls
const.tracker = 0;                      % run with eye tracker (0 = NO, 1 = YES)
const.center = "CENIR";                 % run in which center
const.scanner = 0;                      % run in MRI scanner (0 = NO, 1 = YES)
const.scannerTest = 0;                  % fake scanner trigger (0 = NO, 1 = YES)
const.training = 0;                     % training session (0 = NO, 1 = YES)

% Time 
const.TR_sec = 1.3;                     % depending on center

% Desired screen setting
const.desiredFD = 120;                  % Desired refresh rate
const.desiredRes = [1920, 1080];        % Desired resolution

% Path
dir = which('expLauncher');
cd(dir(1:end-18));

% Add Matlab path
addpath('config', 'main', 'conversion', 'eyeTracking', 'instructions',...
    'trials', 'stim');

% Subject configuration
const = sbjConfig(const);

% Main run
main(const);