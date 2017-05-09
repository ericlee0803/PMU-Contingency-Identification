% function [scores, ranking, num_eigenfits] = runInstance(method, contignum, PMU, noise, modelorder)
% ~~~~~~~~~INPUTS~~~~~~~~~ %
% method = whether to filter or not. 
% contignum = contingency number
% PMU = Indices of PMU Locations (indices relative to BUS NUMBERS)
% noise = percentage of noise to add to dynamic data
% modelorder = order of model to fit to n4sid
%
% ~~~~~~~~~OUTPUTS~~~~~~~~~ %
%
% scores = fit scores with filtering
% ranking = ranking of contingencies in terms of likehood
% eigenfits = number of fitted vectors 

function [scores, ranking] = runInstance(method, contignum, PMU, noise, modelorder)

% Get PMU Matrix Indices from PMU System Indices
win = place_PMU(contignum, PMU);

% Inst of class Instance containing problem data (PMU, dynamics, etc)
Inst = loadInstance('nonlinear', contignum, win);

% Ana of class Analysis used to calculate contingency
%Ana = td_vandermondeLS_Analysis(noise);
Ana = fd_LS_Analysis(modelorder, noise);

% Run Contingency Identification 
[scores, ranking] = Ana.calcContig(Inst);

fprintf('Contingency Identified: Contig %d\n', ranking(1));


end