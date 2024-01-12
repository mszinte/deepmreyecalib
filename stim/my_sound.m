function my_sound(t, aud)
% ----------------------------------------------------------------------
% my_sound(t, aud)
% ----------------------------------------------------------------------
% Goal of the function :
% Play a wave file a specified number of time.
% ----------------------------------------------------------------------
% Input(s) :
% t => select prepare beep frequency and duration
% aud = sound configuration
% ----------------------------------------------------------------------
% Output(s):
% (none)
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

if t == 1
    stimFreq = 2000;
    stimDur = 0.1;
elseif t == 2
    stimFreq = 2500;
    stimDur = 0.1;
elseif t == 3
    stimFreq = 3000;
    stimDur = 0.1;
elseif t == 4
    stimFreq = [900;200];
    stimDur = [0.2;0.2];    
end

stimNb = size(stimFreq,1);

% Compute ramped sound and modulator
stimAll = [];
rampAll = [];
for tStim = 1:stimNb
    for i = 1:aud.master_nChannels
        stim(i,:) = MakeBeep(stimFreq(tStim), stimDur(tStim), aud.master_rate);
        ramp(i,:) = [aud.rampOffOn,ones(1,size(stim(i,:),2)-size(aud.rampOffOn,2)-size(aud.rampOnOff,2)),aud.rampOnOff];
    end
    stimAll = [stimAll,stim];stim =[];
    rampAll = [rampAll,ramp];ramp =[];
end

PsychPortAudio('FillBuffer' ,aud.stim_handle, stimAll.*rampAll);
PsychPortAudio('Start', aud.stim_handle, aud.slave_rep, aud.slave_when, aud.slave_waitforstart);

end
