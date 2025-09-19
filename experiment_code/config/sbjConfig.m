function const = sbjConfig(const)
% ----------------------------------------------------------------------
% const = sbjConfig(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Define subject configurations (initials, gender...) following BIDS
% data structure standards.
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

% Define task
const.task = const.expName;
    
if const.expStart
    
    % Define participant
    const.sjctNum = input(sprintf('\n\tParticipant number: '), 's');
    
    if isempty(const.sjctNum)
        error('Incorrect participant identifier');
    end
    
    % Check if the input is a number
    numValue = str2double(const.sjctNum);
    
    if ~isnan(numValue) && isfinite(numValue) && floor(numValue) == numValue
        % It's an integer number
        if numValue < 10
            const.sjct = sprintf('sub-0%i', numValue);
        else
            const.sjct = sprintf('sub-%i', numValue);
        end
    else
        % It's a string with letters or non-integer
        const.sjct = sprintf('sub-%s', const.sjctNum);
    end

    % Define run
    const.runNum = input(sprintf('\n\tRun number: '));
    if isempty(const.runNum)
        error('Incorrect run number');
    end

    if const.runNum > 9
        const.run = sprintf('run-%i',const.runNum);
    else
        const.run = sprintf('run-0%i',const.runNum);
    end

    % Define main modality
    if const.scanner == 1
        const.modality = 'func';
    else
        const.modality = 'beh';
    end

    % Define recording eye
    const.recEye = 1;

else
    const.sjct = 'sub-0X';
    const.sesNum = 1;
    const.session = 'ses-0X';
    const.runNum = 1;
    const.run = 'run-0X';
    const.modality = 'beh';
    const.recEye = 1;
end

% training
if const.training
    const.task = sprintf('%sTraining',const.task);
end

end