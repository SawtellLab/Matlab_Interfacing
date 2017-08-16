function expt = ImportExpt_Spike7(exptdir,exptfoldername)

%requires github.com/SawtellLab/Matlab_Functions to be in Matlab path

%in future, make this input a varargin to take in the specific channel:fieldnames pairing for the expt structure
c_LowGainSignal = '_Ch4';
c_CmdSignal = '_Ch2';
c_CurrentSignal = '_Ch5';
c_PositionSignal = '_Ch20';

e_0V = '_Ch7';
e_5V = '_Ch6';
e_trigOnline = '_Ch1';

sweeps_dur = 0.1;
% exptdir = 'Z:\KP\WorkingFolder\';
% exptdir = 'C:\Users\kperks\spikedata\matdata\';
% exptfoldername = '20170509_012';
% exptfoldername = [exptfoldername '\'];

% exptdir = '/Users/kperks/mnt/sawtellnas/WorkingFolder/';

cd([exptdir exptfoldername])

expt.wc.newRate = 10000;

%load and process low gain V channel (membrane potential in mV)
varname = ['V' exptfoldername(1:end-1) c_LowGainSignal];
s = ['tmp_c = ' varname ';'];
eval(s);
expt.wc.oldRate = 1/tmp_c.interval;


%load and process low gain V channel (membrane potential in mV)
varname = ['V' exptfoldername(1:end-1) e_trigOnline];
s = ['tmp_e = ' varname ';'];
eval(s);
sweeps_trig = tmp_e.times;

data = tmp_c.values';
datamat = zeros(size(sweeps_trig,1),sweeps_samps);
sweeps_samps = round(sweeps_dur / tmp_c.interval);
for isweeps = 1:size(sweeps_trig,1)
    ind = round(sweeps_trig(isweeps)/tmp_c.interval);
    if (ind+sweeps_samps-1) <= size(data,2);
    datamat(isweeps,:) = data(ind:ind+sweeps_samps-1);
    end
end
[out,dt] = dnsample_data(datamat,expt.wc.oldRate,expt.wc.newRate);
expt.wc.dt = dt;
expt.wc.Vm = out;
clear tmp_c 

%load and process command channel (electric organ electrode)
varname = ['V' exptfoldername(1:end-1) c_CmdSignal];
s = ['tmp_c = ' varname ';'];
eval(s);
data = tmp_c.values';
sweeps_samps = round(sweeps_dur / tmp_c.interval);
datamat = zeros(size(sweeps_trig,1),sweeps_samps);
for isweeps = 1:size(sweeps_trig,1)
    ind = round(sweeps_trig(isweeps)/tmp_c.interval);
    if (ind+sweeps_samps-1) <= size(data,2);
    datamat(isweeps,:) = data(ind:ind+sweeps_samps-1);
    end
end
[out,dt] = dnsample_data(datamat,(1/tmp_c.interval),expt.wc.newRate);
expt.wc.Cmd = out;
clear tmp_c

%load and process Input Current Command channel (continuously tracks holding current)
varname = ['V' exptfoldername(1:end-1) c_CurrentSignal];
s = ['tmp_c = ' varname ';'];
eval(s);
data = tmp_c.values';
sweeps_samps = round(sweeps_dur / tmp_c.interval);
sweepsdata = zeros(1,size(sweeps_trig,1));
for isweeps = 1:size(sweeps_trig,1)
    ind = round(sweeps_trig(isweeps)/ tmp_c.interval);
    if (ind+sweeps_samps-1) <= size(data,2);
        thisdata = data(ind:ind+sweeps_samps-1);
        sweepsdata(1,isweeps) = median(thisdata);
    end
end
expt.sweeps.I = sweepsdata;
clear tmp_c;


%load and process Input Current Command channel (continuously tracks holding current)
varname = ['V' exptfoldername(1:end-1) c_PositionSignal];
s = ['tmp_c = ' varname ';'];
eval(s);
data = tmp_c.values';
sweeps_samps = round(sweeps_dur / tmp_c.interval);
sweepsdata = zeros(1,size(sweeps_trig,1));
for isweeps = 1:size(sweeps_trig,1)
    ind = round(single(sweeps_trig(isweeps)/ tmp_c.interval));
     if (ind+sweeps_samps-1) <= size(data,2);
        thisdata = data(ind:ind+sweeps_samps-1);
        sweepsdata(1,isweeps) = thisdata(1);
    end
end
expt.sweeps.position = sweepsdata;
clear tmp_c


savename = [exptfoldername(1:end-1) '.mat'];
save(savename,'expt')
