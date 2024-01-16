function expDes = runTrials_fix(scr, const, cFrame,expDes, my_key, aud)
% ----------------------------------------------------------------------
% expDes = runTrials(scr, const, expDes, my_key, aud)
% ----------------------------------------------------------------------
% Goal of the function :
% Draw stimuli of each indivual trial and waiting for inputs
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% expDes : struct containg experimental design
% my_key : structure containing keyboard configurations
% aud : structure containing audio configurations
% ----------------------------------------------------------------------
% Output(s):
% resMat : experimental results (see below)
% expDes : struct containing all the variable design configurations.
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

% Open video
if const.mkVideo
    open(const.vid_obj);
end

% Trial counter
t = expDes.trial;
c = cFrame;

% Check trial
if const.checkTrial && const.expStart == 0
    fprintf(1,'\n\n\t============= TRIAL %3.0f ==============\n',t);
end

% Time settings
% Task 1 Fixation
task_1_1_nbf_on = 1;
task_1_1_nbf_off = task_1_1_nbf_on + const.fixtask.dur_frm - 1; 

 
% Wait first MRI trigger
if t == 1
    Screen('FillRect',scr.main,const.background_color);
    drawBullsEye(scr, const, scr.x_mid, scr.y_mid, 'conf');
    Screen('Flip',scr.main);
    
    first_trigger = 0;
    expDes.mri_band_val = my_key.first_val(3);
    while ~first_trigger
        if const.scanner == 0 || const.scannerTest
            first_trigger = 1;
            mri_band_val = -8;
        else
            keyPressed = 0;
            keyCode = zeros(1,my_key.keyCodeNum);
            for keyb = 1:size(my_key.keyboard_idx, 2)
                [keyP, keyC] = KbQueueCheck(my_key.keyboard_idx(keyb));
                keyPressed = keyPressed + keyP;
                keyCode = keyCode + keyC;
            end
            if const.scanner == 1
                input_return = [my_key.ni_session2.inputSingleScan,...
                    my_key.ni_session1.inputSingleScan];
                if input_return(my_key.idx_mri_bands) == ...
                        ~expDes.mri_band_val
                    keyPressed = 1;
                    keyCode(my_key.mri_tr) = 1;
                    expDes.mri_band_val = ~expDes.mri_band_val;
                    mri_band_val = input_return(my_key.idx_mri_bands);
                end
            end
            if keyPressed
                if keyCode(my_key.escape) && const.expStart == 0
                    overDone(const, my_key)
                elseif keyCode(my_key.mri_tr)
                    first_trigger = 1;
                end
            end
        end
    end

    % Write in edf file
    log_txt = sprintf('trial %i mri_trigger val = %i', t, ...
                mri_band_val);
    if const.tracker; Eyelink('message', '%s', log_txt); end
end

% Write in edf file
if const.tracker
    Eyelink('message', '%s', sprintf('trial %i started\n', t));
end

%Fixation

% Trial loop
task_1_1_nbf = 0; 

% Draw background
Screen('FillRect', scr.main, const.background_color );

const.passedLocs = 1;
const.passedLocs = const.passedLocs + 1; currLoc = 0;
%instructionsIm(scr,const,my_key,'Task_1_fixation',1); %show instructions

%while currLoc<=numel(const.fixtask.xy_trials)-1 %for the amount of generated locations
%trial = trial + 1; 
%cFrame = 0;
    
   % send trial info to eye tracker
if const.tracker; Eyelink('Message',sprintf('Trial%d', trial)); end
    
    % show fixation sequence
%frames = cFrame+1:cFrame+const.fixtask.dur_sec*scr.hz;
[const, c, vbl_fix] = playGuidedViewingBullsEye(const, scr, t, c, 'fixation');
    
    
%end
%task_1_1_nbf = c + 1; 

% Flip count
const.passedLocs = const.passedLocs + currLoc;



%trial_on = vbl;
%fprintf('task 1 fixation %i onset at %f', t, vbl);
%log_txt = sprintf('task 1 fixation %i onset at %f', t, vbl);
%if const.tracker; Eyelink('message','%s',log_txt); end

%end



%instructionsIm(scr,const,my_key,'End_block',1); %show instructions


% Check keyboard
keyPressed = 0;
keyCode = zeros(1,my_key.keyCodeNum);
for keyb = 1:size(my_key.keyboard_idx,2)
    [keyP, keyC] = KbQueueCheck(my_key.keyboard_idx(keyb));
    keyPressed = keyPressed + keyP;
    keyCode = keyCode + keyC;
end

if const.scanner == 1 && ~const.scannerTest
    input_return = [my_key.ni_session2.inputSingleScan, ...
        my_key.ni_session1.inputSingleScan];
    
    % button press trigger
    if input_return(my_key.idx_button_left1) == ...
            my_key.button_press_val
        keyPressed = 1;
        keyCode(my_key.left1) = 1;
    elseif input_return(my_key.idx_button_left2) == ...
            my_key.button_press_val
        keyPressed = 1;
        keyCode(my_key.left2) = 1;
    elseif input_return(my_key.idx_button_left3) == ...
            my_key.button_press_val
        keyPressed = 1;
        keyCode(my_key.left3) = 1;
    elseif input_return(my_key.idx_button_right1) == ...
            my_key.button_press_val
        keyPressed = 1;
        keyCode(my_key.right1) = 1;
    elseif input_return(my_key.idx_button_right2) == ...
            my_key.button_press_val
        keyPressed = 1;
        keyCode(my_key.right2) = 1;
    elseif input_return(my_key.idx_button_right3) == ...
            my_key.button_press_val
        keyPressed = 1;
        keyCode(my_key.right3) = 1;
    end
    
    % mri trigger
    if input_return(my_key.idx_mri_bands) == ~expDes.mri_band_val
        keyPressed = 1;
        keyCode(my_key.mri_tr) = 1;
        expDes.mri_band_val = ~expDes.mri_band_val;
        mri_band_val = input_return(my_key.idx_mri_bands);
    end
end
% Deal with responses
if keyPressed
    if keyCode(my_key.mri_tr)
        % MRI triggers
        log_txt = sprintf('trial %i mri_trigger val = %i',t, ...
            mri_band_val);
        if const.tracker; Eyelink('message','%s',log_txt); end
    elseif keyCode(my_key.escape)
        % Escape button
        if const.expStart == 0; overDone(const, my_key);end
    end
end

%expDes.expMat(t, 1) = trial_on; % to FIX
%expDes.expMat(t, 2) = vbl - trial_on;

% Write in log/edf
if const.tracker
    Eyelink('message', '%s', sprintf('trial %i ended\n', t));
end

% When no response received
%if resp_int1 == 0
%    expDes.expMat(t, 9) = 0;
%    expDes.expMat(t, 10) = 0;
%end

%if resp_int2 == 0
%    expDes.expMat(t, 11) = 0;
%    expDes.expMat(t, 12) = 0;
%end

%if resp_conf == 0
%    expDes.expMat(t, 13) = 0;
%    expDes.expMat(t, 14) = 0;
%end

    
end