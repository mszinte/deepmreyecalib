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
expDes.oneV = const.fixtask.n_locs;
expDes.nb_var1 = const.fixtask.n_locs(1) * const.fixtask.n_locs(2); %number of levels in task variable



% Var 2: pursuit amplitude 
expDes.twoV = const.pursuit.mov_amp;
expDes.nb_var2 = length(const.pursuit.mov_amp);



% Var 3: pursuit angle 
expDes.threeV = const.pursuit.angles;
expDes.nb_var3 = length(const.pursuit.angles);

% Var 4: picture number 
expDes.fourV   =   const.pics.paths; %extract number from string of paths 
expDes.nb_var4 =   const.picTask.n_pics; 

% Experimental loop
trialMat = zeros(const.nb_trials, expDes.nb_var1);
ii = 0;
for rep = 1:const.nb_repeat
    for var1 = 1:expDes.nb_var1
           ii = ii + 1;
            trialMat(ii, 1) = var1;
    end
end

for t_trial = 1:const.nb_trials
    %header: onset, duration, run num, trial num, task
    expDes.expMat(t_trial, :) = [NaN, NaN, const.runNum, t_trial, NaN, NaN, NaN, NaN];
    
    % 01: trial onset
    % 02: trial duration
    % 03: run number
    % 04: trial number
    % 05: var1: fixation location 
    % 06: var2: pursuit amplitude 
    % 07: var3: purusit angle 
    % 08: var4: picture id

end
    


    
end




