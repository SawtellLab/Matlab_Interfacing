function expt = ImportExpt_Spike7(exptdir,exptfoldername)

% exptdir = 'Z:\KP\WorkingFolder\';
% exptfoldername = [exptfoldername '\'];

exptdir = '/Users/kperks/mnt/sawtellnas/WorkingFolder/';
exptfoldername = [exptfoldername '/'];

expt.name = exptfoldername;
cd([exptdir exptfoldername])

expt.newRate = 10000;

%load and process low gain V channel (membrane potential in mV)
varname = ['V' exptfoldername(1:end-1) '_Ch4'];
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
varname = ['V' exptfoldername(1:end-1) '_Ch2'];
exptfilename = [varname '.mat'];
m = matfile(exptfilename);
s = ['tmp = m.' varname ';'];
eval(s);
[out,dt] = dnsample_data(tmp.values,expt.newRate,expt.oldRate);
expt.Cmd = out;
clear tmp

%load and process command marker channel created manually in spike
varname = ['V' exptfoldername(1:end-1) '_Ch8'];
exptfilename = [varname '.mat'];
m = matfile(exptfilename);
s = ['tmp = m.' varname ';'];
eval(s);
expt.CmdMarker = tmp.times;
clear tmp

savename = [exptfoldername(1:end-1) '.mat'];
save(savename,'expt')