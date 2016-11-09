% run_n4sid simply runs n4sid and then calculates the empirical eigenpairs

% ~~~~~~~~~INPUTS~~~~~~~~~ %

% method = method type number one would like to use
% noise = percentage of max amplitude to add as gaussian noise
% window = percentage of PMUs visible

% ~~~~~~~~~OUTPUTS~~~~~~~~~ %

% predcontig = the cotingency the chosen method predicts
% actualcontig = the contingency that was actually simulated
% confidence = the confidence levels for correctly identified contigs

function [empvecs, empvals] = runN4SID(obj, modelsize)
n = modelsize;
[numcontigs, numbuses, filename, timestep, numlines, differential, algebraic] = getMetadata(obj);
data = obj.dynamic_data;
maxfreq = obj.maxfreq;
minfreq = obj.minfreq;
len = size(data,1);

z = iddata(data,zeros(len,1),timestep);
% set model order
modelorder = 40;
m = n4sid(z, modelorder,'Form','modal','DisturbanceModel','none');


%% Calculate Eigenvalue and Eigenvector Predictions from N4SID
[ mx, md] = eig(m.A);
empvals = (log(md)/timestep);
empvecs = m.C*mx;


end