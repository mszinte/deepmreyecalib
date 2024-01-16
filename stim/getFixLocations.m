function const = getFixLocations(const,scr)
% creates an array containing random coordinates inside a specified window
% on a screen. Size is n_locs*n_locs
% MN, September 2021
%adapted SK, Dec 23

% get coordinates


xy = [];
for i = 1:numel(x)
    xy = [xy; repmat(x(i), numel(y), 1), y(:)];

end


% randomize presentation order
xy = xy(randperm(length(xy)), :);


% split into frames and trials
fix_dur = round(const.fixtask.dur_sec*scr.hz); 
const.fixtask.xy_trials = arrayfun(@(i) repmat(xy(i,:), fix_dur, 1), 1:length(xy), 'uni', 0); %number of locations


%figure;
%hold on;

%for trialIdx = 1:length(const.fixtask.xy_trials)
%    scatter(const.fixtask.xy_trials{trialIdx}(:, 1), const.fixtask.xy_trials{trialIdx}(:, 2));
%end

%hold off;

%title('Scatter Plot of Generated Coordinates');
%xlabel('X-coordinate');
%ylabel('Y-coordinate');


end

