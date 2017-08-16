function SweepsMat = MakeSweeps(ContinuousData,TriggerData,sweeps_samps)

%structures the data into sweeps initiated by each trigger of equal length
%stores info like time until next trigger so can, for example filter EOD sweeps
%separated by a minimum duration etc... 

% 
% ContinuousData = lowgain.values';
% TriggerData = sweeps_trig;


SweepsMat = zeros(size(TriggerData,1),sweeps_samps);

for isweeps = 1:size(TriggerData,1)
   
    if (TriggerData(isweeps)+sweeps_samps-1) <= size(ContinuousData,2);
    SweepsMat(isweeps,:) = ContinuousData(TriggerData(isweeps):TriggerData(isweeps)+sweeps_samps-1);
    end
end
