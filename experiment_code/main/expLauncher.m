 
%% General experimenter launcher
%  =============================
% By: Sina KLING
% Projet: DeepMReyeCalib

% Experimental design : ~3min
% Task 1: calibration fixation 
% Task 2: calibration pursuit
% Task 3: calibration freeview images

% TODO (Sina)  
% ----------- 
% test in scanner

% First settings
Screen('Preference', 'SkipSyncTests', 1); 
Screen('CloseAll'); clear all; clear mex; clear functions; close all; ...
    home; AssertOpenGL;

% General settings
const.expName = 'DeepMReyeCalibAms';    % experiment name
const.expStart = 0;                     % Start of a recording (0 = NO, 1 = YES)
const.checkTrial = 0;                   % Print trial conditions (0 = NO, 1 = YES)
const.mkVideo = 0;                      % Make a video (0 = NO, 1 = YES)

% External controls
const.tracker = 0;                      % run with eye tracker (0 = NO, 1 = YES)
const.comp = 3;                         % run in which computer (1 = MRI; 2 = Diplay++)
const.scanner = 0;                      % run in MRI scanner (0 = NO, 1 = YES)
const.scannerTest = 0;                  % fake scanner trigger (0 = NO, 1 = YES)
const.training = 0;                     % training session (0 = NO, 1 = YES)

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