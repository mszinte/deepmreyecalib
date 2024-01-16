function expDes = designConfig(const)
% ----------------------------------------------------------------------
% expDes = designConfig(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Define experimental design
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% expDes : struct containg experimental design
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------


% Experimental variables
% Var 1: fixation location
expDes.oneV = [1:1:25]';
expDes.nb_var1 = length(expDes.oneV);
% 01 02 03 04 05
% 06 07 08 09 10
% 11 12 13 14 15
% 16 17 18 19 20
% 21 22 23 24 25

% Var 2: pursuit amplitude 
expDes.twoV = [1;2;3];
expDes.nb_var2 = length(expDes.twoV);
% 01: 3 dva/s
% 02: 5 dva/s
% 03: 7 dva/s

% Var 3: pursuit angle (nan first as defined later)
expDes.threeV = [0:20:359];
expDes.nb_var3 = length(expDes.threeV);
% 01 = 0 deg
% 02 = 20 deg
% ...
% 18 = 340 deg

% Var 4: picture id number
expDes.fourV = [1:1:10]';
expDes.nb_var4 = length(expDes.fourV);

% Experimental loop 
expDes.nb_var = 4;

% Fixation experimental loop
ii = 0;
trialMat_fixation = zeros(const.nb_trials_fixation, expDes.nb_var+1)*nan;
for rep = 1:const.nb_repeat_fixation
    for var1 = 1:expDes.nb_var1
        ii = ii + 1;
        trialMat_fixation(ii, 1) = 1;
        trialMat_fixation(ii, 2) = var1;
    end
end
trialMat_fixation = trialMat_fixation(randperm(const.nb_trials_fixation),:);

% Pursuit experimental loop
ii = 0;
trialMat_pursuit = zeros(const.nb_trials_pursuit, expDes.nb_var+1)*nan;
for rep = 1:const.nb_repeat_pursuit
    for var2 = 1:expDes.nb_var2
        for var3= 1:expDes.nb_var3
            ii = ii + 1;
            trialMat_pursuit(ii, 1) = 2;
            trialMat_pursuit(ii, 3) = var2;
            trialMat_pursuit(ii, 4) = NaN; % define later as possible to stay onscreen
        end
    end
end
trialMat_pursuit = trialMat_pursuit(randperm(const.nb_trials_pursuit),:);

% Freeview experimental loop
ii = 0;
trialMat_freeview = zeros(const.nb_trials_freeview, expDes.nb_var+1)*nan;
for rep = 1:const.nb_repeat_freeview
    for var4 = 1:expDes.nb_var4
        ii = ii + 1;
        trialMat_freeview(ii, 1) = 3;
        trialMat_freeview(ii, 5) = var4;
    end
end
trialMat_freeview = trialMat_freeview(randperm(const.nb_trials_freeview),:);

trialMat = [trialMat_fixation; ...
            trialMat_pursuit; ...
            trialMat_freeview];
        
trialMat = [zeros(const.nb_trials,2)*nan, ...
            zeros(const.nb_trials,1)*0+const.runNum,...
            [1:const.nb_trials]',trialMat];        
% 01 : onset
% 02 : duration 
% 03 : run number
% 04 : trial number
% 05 : task
% 06 : fixation location number
% 07 : pursuit amplitude
% 08 : pursuit angle
% 09 : freeview imager number
        
end