function expt = ImportExpt_Spike7(exptdir,exptfoldername)

%requires github.com/SawtellLab/Matlab_Functions to be in Matlab path

%in future, make this input a varargin to take in the specific channel:fieldnames pairing for the expt structure
ch_LowGainSignal = '_Ch4';
ch_CmdSignal = '_Ch2';
ch_CmdMarker = '_Ch8';

% exptdir = 'Z:\KP\WorkingFolder\';
% exptfoldername = [exptfoldername '\'];

% exptdir = '/Users/kperks/mnt/sawtellnas/WorkingFolder/';

cd([exptdir exptfoldername])

expt.newRate = 10000;

%load and process low gain V channel (membrane potential in mV)
varname = ['V' exptfoldername(1:end-1) ch_LowGainSignal];
exptfilename = [varname '.mat'];
m = matfile(exptfilename);
% load([exptdir exptfoldername exptfilename])
s = ['tmp = m.' varname ';'];
eval(s);
expt.oldRate = 1/tmp.interval;
[out,dt] = dnsample_data(tmp.values,expt.newRate,expt.oldRate);
expt.dt = dt;
expt.Vm = out;
clear tmp

%load and process command channel (electric organ electrode)
varname = ['V' exptfoldername(1:end-1) ch_CmdSignal];
exptfilename = [varname '.mat'];
m = matfile(exptfilename);
s = ['tmp = m.' varname ';'];
eval(s);
[out,dt] = dnsample_data(tmp.values,expt.newRate,expt.oldRate);
expt.Cmd = out;
clear tmp

%Ch2 Command signal
%load and process command marker channel created manually in spike
%varname = ['V' exptfoldername(1:end-1) ch_CmdMarker];
%exptfilename = [varname '.mat'];
%m = matfile(exptfilename);
%s = ['tmp = m.' varname ';'];
%eval(s);
%expt.CmdMarker = tmp.times;
%clear tmp

savename = [exptfoldername(1:end-1) '.mat'];
save(savename,'expt')
