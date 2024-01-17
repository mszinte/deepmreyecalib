function const = constConfig(scr, const)
% ----------------------------------------------------------------------
% const = constConfig(scr, const)
% ----------------------------------------------------------------------
% Goal of the function :
% Define all constant configurations
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

% Randomization
[const.seed, const.whichGen] = ClockRandSeed;

% Colors
const.white = [255, 255, 255];
const.gray = [128 128 128];
const.fixation_color = const.white;
const.background_color = const.gray; 

% Time parameters
const.TR_sec = 1.2;                                                         % MRI time repetition in seconds
const.TR_frm = round(const.TR_sec/scr.frame_duration);                      % MRI time repetition in seconds in screen frames

%new stimulus time parameters
const.fixtask_dur_TR = 1;                                                       % Fixation task stimulus duration in scanner TR
const.fixtask_dur_sec = const.fixtask_dur_TR * const.TR_sec;                    % Fixation task stimulus duration in seconds, should be 1.2
const.fixtask_dur_frm = round(const.fixtask_dur_sec /scr.frame_duration);       % Total stimulus duration in screen frames

const.pursuit_dur_TR = 1;                                                       % Smooth pursuit task stimulus duration in scanner TR
const.pursuit_dur_sec = const.pursuit_dur_TR * const.TR_sec;                    % Smooth pursuit task stimulus duration in seconds, should be 1.2
const.pursuit_dur_frm = round(const.pursuit_dur_sec /scr.frame_duration);       % Total stimulus duration in screen frames

const.freeview_dur_TR = 3;                                                       % Picture free viewing task stimulus duration in scanner TR
const.freeview_dur_sec = const.freeview_dur_TR * const.TR_sec;                    % Picture free viewing task stimulus duration in seconds, should be 1.2
const.freeview_dur_frm = round(const.freeview_dur_sec /scr.frame_duration);       % Total stimulus duration in screen frames


const.fixtask_linspace(1, 50*const.fixtask_dur_frm+1, const.fixtask_dur_frm)

%const.TRs = (const.fixtask.dur_TR+const.pursuit.dur_TR+const.picTask.dur_TR+const.triang.dur_TR)*2; % TR per trials

% Stim parameters
[const.ppd] = vaDeg2pix(1, scr); % one pixel per dva
const.dpp = 1/const.ppd;         %degrees per pixel

const.window_sizeVal = 14;

% tasks
const.task_txt = {'fixation', 'pursuit', 'freeviewing'};

% fixation task
const.fixation_rows = 5;
const.fixation_cols = 5;
const.fixations_postions = const.fixation_rows * const.fixation_cols;
const.window_size = vaDeg2pix(const.window_sizeVal, scr);
const.fixations_postions_txt = {'[-7.0; -7.0]', '[-3.5; -7.0]', '[    0; -7.0]', '[+3.5; -7.0]', '[+7.0; -7.0]', ...
                                '[-7.0; -3.5]', '[-3.5; -3.5]', '[    0; -3.5]', '[+3.5; -3.5]', '[+7.0; -3.5]', ...
                                '[-7.0;    0]', '[-3.5; -3.5]', '[    0; -3.5]', '[+3.5; -3.5]', '[+7.0; -3.5]', ...
                                '[-7.0; +3.5]', '[-3.5; +3.5]', '[    0; +3.5]', '[+3.5; +3.5]', '[+7.0; +3.5]', ...
                                '[-7.0; +7.0]', '[-3.5; +7.0]', '[    0; +7.0]', '[+3.5; +7.0]', '[+7.0; +7.0]'};
const.fixation_coord_x = linspace(scr.x_mid - const.window_size/2, ...
                                  scr.x_mid + const.window_size/2, ...
                              const.fixation_cols);
                              
const.fixation_coord_y = linspace(scr.y_mid - const.window_size/2, ...
                                  scr.y_mid + const.window_size/2, ...
                              const.fixation_cols);
                          
const.fixation_coords = [];
for fix_cols = 1:const.fixation_cols
    for fix_rows = 1:const.fixation_rows
        
        const.fixation_coords = [const.fixation_coords;...
                                 const.fixation_coord_x(fix_rows), ...
                                 const.fixation_coord_y(fix_cols)];
    end
end

% pursuit task
const.pursuit_ampVal = [3, 5, 7];

const.pursuit_amp = vaDeg2pix(const.pursuit_ampVal, scr);
const.pursuit_amps = length(const.pursuit_ampVal);
const.pursuit_amps_txt = {'3.0 dva', '5.0 dva', '7.0 dva'};

const.pursuit_angles_steps = 20;
const.pursuit_angles = [0:const.pursuit_angles_steps:359];
const.pursuit_angles_txt = {'0 deg', '20 deg', '40 deg', '60 deg', ...
                            '80 deg', '100 deg', '120 deg', '140 deg', ...
                            '160 deg', '180 deg', '200 deg', '220 deg', ...
                            '240 deg', '260 deg', '280 deg', '300 deg', ...
                            '320 deg', '340 deg'};

% freeview task
const.freeview_pics = 10;
const.freeview_path2pics = '.\stim\images';
const.freeview_pics_txt = {'water_drops', 'coffee', 'finger', 'astronaut', ...
                           'flat_iron', 'road', 'landscape', 'black swan', ...
                           'dog', 'balloon'};

% get image paths
path2pics = dir(fullfile(const.freeview_path2pics, 'image*'));
% Check if path2pics is empty
if isempty(path2pics)
    error('No images found in the specified folder.');
end
const.path2pics = fullfile(path2pics(1).folder, {path2pics(:).name}');

const.freeview_pic_z = const.window_size;
const.freeview_picCoords = [scr.x_mid-const.freeview_pic_z/2 scr.y_mid-const.freeview_pic_z/2, scr.x_mid+const.freeview_pic_z/2 scr.y_mid+const.freeview_pic_z/2];

% Trial settings
const.nb_repeat_fixation = 2;
const.nb_trials_fixation = const.fixation_rows * const.fixation_cols ...
    * const.nb_repeat_fixation;

const.nb_repeat_pursuit = 1;
const.nb_trials_pursuit = length(const.pursuit_ampVal) * ...
    length(const.pursuit_angles) * const.nb_repeat_pursuit;

const.nb_repeat_freeview = 1;
const.nb_trials_freeview = const.freeview_pics;

const.nb_trials = const.nb_trials_fixation + const.nb_trials_pursuit + ...
    const.nb_trials_freeview;



% %Fixation Task (Calib Matthias)
% const.fixtask.win_sz                                 =    10; %in degrees of visual angle 
% const.fixtask.win_sz_px                              =    vaDeg2pix(const.fixtask.win_sz, scr);  %will return x y pixels
% const.fixtask.n_locs                                 =    [5 5]; % n fixation locations [horizontal, vertical] [10 10]
% const                                                =    getFixLocations(const,scr); %create coordinates for fixation locations
% 
% %Smooth Pursuit Task (Calib Matthias) 
% const.pursuit.win_sz         =    14;
% const.pursuit.win_sz_px      =    vaDeg2pix(const.pursuit.win_sz, scr);
% const.pursuit.angles         =    [0:20:359];
% const.pursuit.mov_amp        =    [3 5 7];
% % valid = 0; while ~valid
% %     [const, valid]           =    getFixLocations_pursuit(const,scr,valid); end % create trajectories for smoooth pursuit
% 
% %Picture Free Viewing Task (Calib Matthias) 
% const.picTask.pic_sz         =   14;
% const.picTask.pic_sz_px      =   vaDeg2pix(const.picTask.pic_sz, scr);
% const.picTask.path2pics      =   fullfile('./stim/images'); 
% const.picTask.n_pics         =   10; % how many of the pictures in the folder should be shown (random selection)? (10)



% define total TR numbers and scan duration
if const.scanner
    const.TRs_total = const.nb_trials*const.TRs;
    fprintf(1,'\n\tScanner parameters: %1.0f TRs of %1.2f seconds for a total of %s\n',...
        const.TRs_total, const.TR_sec, ...
        datestr(seconds((const.TRs_total*const.TR_sec...
        )),'MM:SS'));
end

% Bullseye configs
const.fix_out_rim_radVal = 0.25;                                            % radius of outer circle of fixation bull's eye in dva
const.fix_rim_radVal = 0.75*const.fix_out_rim_radVal;                       % radius of intermediate circle of fixation bull's eye in dva
const.fix_radVal = 0.25*const.fix_out_rim_radVal;                           % radius of inner circle of fixation bull's eye in dva
const.fix_out_rim_rad = vaDeg2pix(const.fix_out_rim_radVal, scr);           % radius of outer circle of fixation bull's eye in pixels
const.fix_rim_rad = vaDeg2pix(const.fix_rim_radVal, scr);                   % radius of intermediate circle of fixation bull's eye in pixels
const.fix_rad = vaDeg2pix(const.fix_radVal, scr);                           % radius of inner circle of fixation bull's eye in pixels

% Personalised eyelink calibrations
angle = 0:pi/3:5/3*pi;
 
% compute calibration target locations
const.calib_amp_ratio = 0.5;
[cx1, cy1] = pol2cart(angle, const.calib_amp_ratio);
[cx2, cy2] = pol2cart(angle + (pi / 6), const.calib_amp_ratio * 0.5);
cx = round(scr.x_mid + scr.x_mid * [0 cx1 cx2]);
cy = round(scr.y_mid + scr.x_mid * [0 cy1 cy2]);
 
% order for eyelink
const.calibCoord = round([cx(1), cy(1),...                                  % 1. center center
    cx(9), cy(9),...                                                        % 2. center up
    cx(13),cy(13),...                                                       % 3. center down
    cx(5), cy(5),...                                                        % 4. left center
    cx(2), cy(2),...                                                        % 5. right center
    cx(4), cy(4),...                                                        % 6. left up
    cx(3), cy(3),...                                                        % 7. right up
    cx(6), cy(6),...                                                        % 8. left down
    cx(7), cy(7),...                                                        % 9. right down
    cx(10), cy(10),...                                                      % 10. left up
    cx(8), cy(8),...                                                        % 11. right up
    cx(11), cy(11),...                                                      % 12. left down
    cx(12), cy(12)]);                                                       % 13. right down

% compute validation target locations (calibration targets smaller radius)
const.valid_amp_ratio = const.calib_amp_ratio * 0.8;
[vx1, vy1] = pol2cart(angle, const.valid_amp_ratio);
[vx2, vy2] = pol2cart(angle + pi /6, const.valid_amp_ratio * 0.5);
vx = round(scr.x_mid + scr.x_mid*[0 vx1 vx2]);
vy = round(scr.y_mid + scr.x_mid*[0 vy1 vy2]);

% order for eyelink
const.validCoord =round([vx(1), vy(1),...                                   % 1. center center
    vx(9), vy(9),...                                                        % 2. center up
    vx(13), vy(13),...                                                      % 3. center down
    vx(5), vy(5),...                                                        % 4. left center
    vx(2), vy(2),...                                                        % 5. right center
    vx(4), vy(4),...                                                        % 6. left up
    vx(3), vy(3),...                                                        % 7. right up
    vx(6), vy(6),...                                                        % 8. left down
    vx(7), vy(7),...                                                        % 9. right down
    vx(10), vy(10),...                                                      % 10. left up
    vx(8), vy(8),...                                                        % 11. right up
    vx(11), vy(11),...                                                      % 12. left down
    vx(12), vy(12)]);                                                       % 13. right down
end