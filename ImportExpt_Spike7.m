function expt = ImportExpt_Spike7(exptdir,exptfoldername,sweeps_dur)
%requires github.com/SawtellLab/Matlab_Functions to be in Matlab path
%sweeps_dur = 0.16;
% exptdir = 'C:\Users\kperks\spikedata\matdata\';
% exptfoldername = '20170509_012';
exptfoldername = [exptfoldername '\'];

expt.name = exptfoldername(1:end-1);

%%%%%%%%%%%%%%%%%%
% these are the channel names i use and whether they are cont or event data
%in future, make this input a varargin to take in the specific channel:fieldnames pairing for the expt structure
c_lowgain = 'lowgain';
c_command = 'command';
c_current = 'current';
c_dac0 = 'dac0';

e_trigevt = 'trigevt';
e_CmdTrig = 'CmdTrig';
e_ArtTrig = 'ArtTrig';
e_Spikes = 'Spikes';

cd([exptdir exptfoldername(1:end-1)])
load([exptfoldername(1:end-1) '_SPK.mat']);

%upon exporting, all sampling rate is matched to lowgain at 20k
expt.meta.rate = round(1/lowgain.interval);
expt.meta.dt = lowgain.interval;
expt.meta.sweeps_dur = sweeps_dur;

sweeps_samps = sweeps_dur * expt.meta.rate;

%%%%%%%%%%%%%%%%%%
% event channels
sweeps_trig = find(trigevt.values);
nsweeps = size(sweeps_trig,1);


%%%%%%%%%%%%%%%%%%
% getting continuous data in .wc field
a = exist('Spikes');
if a ~= 0
    
    SweepsMat = MakeSweeps(Spikes.values',sweeps_trig,sweeps_samps);
    expt.wc.Spikes = SweepsMat;
end

SweepsMat = MakeSweeps(lowgain.values',sweeps_trig,sweeps_samps);
expt.wc.Vm = SweepsMat;

SweepsMat = MakeSweeps(command.values',sweeps_trig,sweeps_samps);
expt.wc.command = SweepsMat;

a = exist('dac0');
if a ~= 0
    SweepsMat = MakeSweeps(dac0.values',sweeps_trig,sweeps_samps);
    expt.wc.dac0 = SweepsMat;
end

%%%%%%%%%%%%%%%%%%
% gathering sweeps info
%%%%%%%%%%%%%%%%%%
% ind = sweep number
expt.sweeps.trial = [1:size(sweeps_trig,1)]';
expt.sweeps.trialindices=[1:size(expt.sweeps.trial,1)]';

% time = time at beginning of sweep
t = trigevt.times(find(trigevt.values));
expt.sweeps.time = t;

% for each sweep, determine if a cmd trig or internal trigger
cmdtrig = zeros(nsweeps,1);
clocktrig = zeros(nsweeps,1);
jitter = 0.002/expt.meta.dt ; %in samples
for itrig = 1:nsweeps
    ind = sweeps_trig(itrig);
    win = [max([ind - jitter, 1]) : ind + jitter];
    cmdwin = CmdTrig.values(win);
    
    if ~isempty(find(cmdwin)) % if there was a cmd event in this window then this was a cmd trig
        cmdtrig(itrig) = 1;
    end
    
    if isempty(find(cmdwin)) % if there was a cmd event in this window then this was a cmd trig
        clocktrig(itrig) = 1;
    end
end
expt.sweeps.cmdtrig = cmdtrig;
expt.sweeps.clocktrig = clocktrig;

% stim_latency = delay between EMN volley and stimulus artifact (critical for latency decoding expt and long delay used to decouple the two)
%THIS IS MESSY when stimulus amplitude or polarity changes because time of stim is
%taken off of "level crossing" of artifact in Spike2
%should be reliable when stim stays exactly the same
stim_mat = MakeSweeps(ArtTrig.values',sweeps_trig,sweeps_samps);
for isweep = 1:nsweeps
    trigind = find(stim_mat(isweep,:));
    
    if ~isempty(trigind) %if there is a stim on this sweep
        trigind = trigind(1);
        latency(isweep,1) = trigind / expt.meta.rate;
    end
    
    if isempty(trigind) %if there was no stim then latency = nan
        latency(isweep,1) = nan;
    end
end
expt.sweeps.latency = latency;

a = exist('dac0');
if a ~= 0
    % position = position of object at time of stimulus artifact
    dac0_mat = MakeSweeps(dac0.values',sweeps_trig,sweeps_samps);
    stim_mat = MakeSweeps(ArtTrig.values',sweeps_trig,sweeps_samps);
    for isweep = 1:nsweeps
        trigind = find(stim_mat(isweep,:));
        if ~isempty(trigind) %if there is a stim on this sweep
            trigind = trigind(1);
            expt.sweeps.position(isweep,1) = dac0_mat(isweep,trigind);
        end
        if isempty(trigind) %if there was no stim then position = position at onset of sweep
            expt.sweeps.position(isweep,1) = dac0_mat(isweep,1);
        end
    end
end

% current = median  holding current during sweep
SweepsMat = MakeSweeps(current.values',sweeps_trig,sweeps_samps);
expt.sweeps.current = round(median(SweepsMat,2));

%%%%%%%%%%%%%%%%%%%
%sweeps data that I need to log manually and import from spreadsheet
%%%%%%%%%%%%%%%%%%%
%columns exported from exsize(varbames,2)cel spreadsheet for cell:
% start_time;
% end_time;
% Global;
% Local;
a = exist([exptfoldername(1:end-1) '.xlsx'], 'file')
if  a ~=0
    [num,txt,raw] = xlsread([exptfoldername(1:end-1) '.xlsx'],1);
    varnames = txt(1,1:size(num,2));
    for ivar = 1:size(varnames,2)
        s = [varnames{ivar} '= num(:,' num2str(ivar) ');'];
        eval(s)
    end
    windows = [start_time,end_time];
    
    % global and local mimic amplitude
    a = exist('Global');
    if a ~= 0
        tmpG = NaN(nsweeps,1);
        t = expt.sweeps.time;
        for iwin = 1:size(windows,1)
            inds = intersect(find(t>=windows(iwin,1)),find(t<=windows(iwin,2)));
            tmpG(inds) = Global(iwin);
        end
        expt.sweeps.global = tmpG;
        %assume that if exists global then will exist local
        tmpL = NaN(nsweeps,1);
        t = expt.sweeps.time;
        for iwin = 1:size(windows,1)
            inds = intersect(find(t>=windows(iwin,1)),find(t<=windows(iwin,2)));
            tmpL(inds) = Local(iwin);
        end
        expt.sweeps.local = tmpL;
    end
    
    a = exist('Electrode');
    if a ~= 0
        tmpE = NaN(nsweeps,1);
        t = expt.sweeps.time;
        for iwin = 1:size(windows,1)
            inds = intersect(find(t>=windows(iwin,1)),find(t<=windows(iwin,2)));
            tmpE(inds) = Electrode(iwin);
        end
        expt.sweeps.electrode = tmpE;
    end
end

%%%%%%%%%%%
%save expt
%%%%%%%%%%%
savename = [exptfoldername(1:end-1) '.mat'];
save(savename,'expt')

