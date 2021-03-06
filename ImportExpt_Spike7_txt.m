function expt = ImportExpt_Spike7_txt(exptdir,exptfoldername)
nlines_deleted = 18;
%requires github.com/SawtellLab/Matlab_Functions to be in Matlab path

%in future, make this input a varargin to take in the specific channel:fieldnames pairing for the expt structure
ch_LowGainSignal = '_Ch4';
ch_CmdSignal = '_Ch2';
ch_CurrentSignal = '_Ch5';

% exptdir = 'Z:\KP\WorkingFolder\';
% exptfoldername = [exptfoldername '\'];

% exptdir = '/Users/kperks/mnt/sawtellnas/WorkingFolder/';

cd([exptdir exptfoldername])

expt.newRate = 10000;
expt.oldRate = 20000; %careful... for now with txt export/import the rate is not included so this is hard-coded

%load and process low gain V channel (membrane potential in mV)
notcut = 0;
varname = ['V' exptfoldername(1:end-1) ch_LowGainSignal];%'V20170126_006_Ch5.txt'
exptfilename = [varname '.txt'];
if notcut ==1
    fid = fopen(exptfilename, 'r') ;              % Open source file.
    for l = 1:nlines_deleted
        fgetl(fid) ;                                  % Read/discard line.
    end
    %  fgetl(fid) ;                                  % Read/discard line.
    buffer = fread(fid, Inf) ;                    % Read rest of the file.
    fclose(fid);
    fid = fopen(exptfilename, 'w')  ;   % Open destination file.
    fwrite(fid, buffer) ;                         % Save to file.
    fclose(fid) ;
end
 values = importdata(exptfilename);
[out,dt] = dnsample_data(values,expt.newRate,expt.oldRate);
expt.dt = dt;
expt.Vm = out;
clear tmp

%load and process command channel (electric organ electrode)
notcut = 0;
varname = ['V' exptfoldername(1:end-1) ch_CmdSignal];
exptfilename = [varname '.txt'];
if notcut ==1
 fid = fopen(exptfilename, 'r') ;              % Open source file.
 for l = 1:nlines_deleted
 fgetl(fid) ;                                  % Read/discard line.
 end
%  fgetl(fid) ;                                  % Read/discard line.
 buffer = fread(fid, Inf) ;                    % Read rest of the file.
 fclose(fid);
 fid = fopen(exptfilename, 'w')  ;   % Open destination file.
 fwrite(fid, buffer) ;                         % Save to file.
 fclose(fid) ;
end
 values = importdata(exptfilename);
[out,dt] = dnsample_data(values,expt.newRate,expt.oldRate);
expt.Cmd = out;
clear tmp

%load and process Input Current Command channel (continuously tracks holding current)
notcut = 0;
varname = ['V' exptfoldername(1:end-1) ch_CurrentSignal];
exptfilename = [varname '.txt'];
if notcut ==1
 fid = fopen(exptfilename, 'r') ;              % Open source file.
 for l = 1:nlines_deleted
 fgetl(fid) ;                                  % Read/discard line.
 end
%  fgetl(fid) ;                                  % Read/discard line.
 buffer = fread(fid, Inf) ;                    % Read rest of the file.
 fclose(fid);
 fid = fopen(exptfilename, 'w')  ;   % Open destination file.
 fwrite(fid, buffer) ;                         % Save to file.
 fclose(fid) ;
end
 values = importdata(exptfilename);
%is the current already sampled down at 10K? .... it seems like it is
%halfish the size of Vm and Cmd????
 [out,dt] = dnsample_data(values,expt.newRate,expt.oldRate);
expt.I = out;
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
