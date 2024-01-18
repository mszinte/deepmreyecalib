function expDes = runTrials(scr, const, expDes, my_key)
% ----------------------------------------------------------------------
% expDes = runTrials(scr, const, expDes, my_key)
% ----------------------------------------------------------------------
% Goal of the function :
% Draw stimuli of each indivual trial and waiting for inputs
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% expDes : struct containg experimental design
% my_key : structure containing keyboard configurations
% ----------------------------------------------------------------------
% Output(s):
% resMat : experimental results (see below)
% expDes : struct containing all the variable design configurations.
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------


for t = 1:const.nb_trials

    % Open video
    if const.mkVideo
        open(const.vid_obj);
    end
    
    % Compute and simplify var and rand
    task = expDes.expMat(t, 5);
    var1 = expDes.expMat(t, 6);
    var2 = expDes.expMat(t, 7);
    var3 = expDes.expMat(t, 8);
    var4 = expDes.expMat(t, 9);


    % Timing
    fix_onset_nbf = 1;
    fix_offset_nbf = const.fixtask_dur_frm;
    pursuit_onset_nbf = 1;
    pursuit_offset_nbf = const.pursuit_dur_frm;
    freeview_onset_nbf = 1;
    freeview_offset_nbf = const.freeview_dur_frm;
    
    switch task
        case 1 
            trial_offset = const.fixtask_dur_frm + 1;
        case 2
            trial_offset = const.pursuit_dur_frm + 1;
        case 3
            trial_offset = const.freeview_dur_frm + 1;
    end
    
    % compute fixation coordinates
    if task == 1
        fix_x = const.fixation_coords(var1,1);
        fix_y = const.fixation_coords(var1,2);
    end

    %compute pursuit coordinates each trial
    if task == 2
        pursuit_coords_on = [];
        pursuit_coords_off = [];
        pursuit_amp = const.pursuit_amp(var2);
        pursuit_angle = const.pursuit_angles(var3);
        
        %for trial_pursuit = 1:const.nb_trials_pursuit
        if trial_pursuit == 1
            pursuit_coord_on = [scr.x_mid, scr.y_mid];
            pursuit_coord_off = [scr.x_mid + pursuit_amp * cosd(pursuit_angle),...
                scr.y_mid + pursuit_amp * sind(pursuit_angle)];
        else
            pursuit_coord_on = pursuit_coords_off(trial_pursuit-1, :);
            pursuit_coord_off = pursuit_coord_on + [pursuit_amp * cosd(pursuit_angle), ...
                pursuit_amp * sind(pursuit_angle)];
        end
        pursuit_coords_on = [pursuit_coords_on; pursuit_coord_on]; 
        pursuit_coords_off = [pursuit_coords_off; pursuit_coord_off]; 

        %end
        
        %interpolate
        purs_x = linspace(pursuit_coords_on(1), pursuit_coords_off(1), const.pursuit_dur_sec* scr.hz+1);
        purs_y = linspace(pursuit_coords_on(2), pursuit_coords_off(2), const.pursuit_dur_sec* scr.hz+1);

   
       
        
    end

    
    % Check trial
    if const.checkTrial && const.expStart == 0
    fprintf(1,'\n\n\t============= TRIAL %3.0f ==============\n',t);
    fprintf(1,'\n\tTask =             \t%s', const.task_txt{task});
    fprintf(1,'\n\tFixation location =\t%s', const.fixations_postions_txt{var1});
    fprintf(1,'\n\tPursuit amplitude =\t%s', const.pursuit_amps_txt{var2});
    fprintf(1,'\n\tPursuit angle =    \t%s', const.pursuit_angles_txt{var3});
    fprintf(1,'\n\tPicture =          \t%s', const.freeview_pics_txt{var4});
    end

    % Wait first MRI trigger
    if t == 1
        Screen('FillRect',scr.main,const.background_color);
        drawBullsEye(scr, const, scr.x_mid, scr.y_mid);
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
    
    % 
    nbf = 0;
    while nbf <= trial_offset
        % Flip count
        nbf = nbf + 1;
    
        Screen('FillRect',scr.main,const.background_color)
    
        % Fixation task
        if task == 1
            if nbf >= fix_onset_nbf && nbf <= fix_offset_nbf
                drawBullsEye(scr, const, fix_x, fix_y);
            end
        end
        
        % Pursuit task
        if task == 2
            if nbf >= pursuit_onset_nbf && nbf <= pursuit_offset_nbf
                drawBullsEye(scr, const, purs_x(nbf), purs_y(nbf));
            end
        end
        
        % Freeview task
%         if task == 3
%             if nbf >= freeview_onset_nbf && nbf <= freeview_offset_nbf
%                 % draw image
%             end
%         end
        
        vbl = Screen('Flip',scr.main);      
    end

      



%if resp_conf == 0
%    expDes.expMat(t, 13) = 0;
%    expDes.expMat(t, 14) = 0;
%end

    
end