%% calc_contig (Filtered Version)

% ~~~~~~~~~INPUTS~~~~~~~~~ %
% obj = instance object
% noise = amount of noise injected
% modelorder = order of model for N4SID to fit
%

% ~~~~~~~~~OUTPUTS~~~~~~~~~ %
% scores = scores with filtering
% eigenfits = number of eigenvectors fitted before scoring.

function [scores, eigenfits] = calcContig(obj, noise, modelorder, numevals)

load metadata.mat
fitting_method = obj.fitting_method;
evaluation_method = obj.evaluation_method;
PMU = obj.PMU;
maxfreq = obj.maxfreq;
minfreq = obj.minfreq;

if(report)
    noiseparam = 0;
    ampparam = 0.0;
    %[empvecsClean, empvalsClean, ~]  = runN4SID(obj.PMU_data, modelorder, noiseparam);
    fname = sprintf('n4sidDataNoise0Contig%d.mat',obj.correctContig);
    load(fname);
    mode = 'freq';
    [empvecsClean, empvalsClean] = filter_eigpairs(minfreq, maxfreq, empvalsClean, empvecsClean, mode);
    mode = 'amp';
    [empvecsClean, empvalsClean] = filter_eigpairs(ampparam, [], empvalsClean, empvecsClean, mode);
    mode = 'damp';
    [empvecsClean, empvalsClean] = filter_eigpairs(0, 20, empvalsClean, empvecsClean, mode);
end

try
    fname = sprintf('n4sidDataNoise%dContig%d.mat',noise*100,  obj.correctContig);
    load(fname);
catch
    noiseparam = 0;
    ampparam = 0.0;
    disp('The Amount of Error Added is not supported when loading N4SID Data... running N4SID in real time');
    [empvecs, empvals, ~]  = runN4SID(obj.PMU_data, modelorder, noiseparam);
    mode = 'freq';
    [empvecs, empvals] = filter_eigpairs(minfreq, maxfreq, empvals, empvecs, mode);
    mode = 'amp';
    [empvecs, empvals] = filter_eigpairs(ampparam, [], empvals, empvecs, mode);
    mode = 'damp';
    [empvecs, empvals] = filter_eigpairs(0, 20, empvals, empvecs, mode);
end 

% Smooth Data
%obj.dynamic_data = smoothData(obj.dynamci_data, 2, 1/30, 'gaussfilter');

% Filter N4SID Data that has just been loaded
ampparam = 0.0;
mode = 'freq';
[empvecs, empvals] = filter_eigpairs(minfreq, maxfreq, empvals, empvecs, mode);
mode = 'amp';
[empvecs, empvals] = filter_eigpairs(ampparam, [], empvals, empvecs, mode);
mode = 'damp';
[empvecs, empvals] = filter_eigpairs(0, 20, empvals, empvecs, mode);

% Weights for fitting
weightsFit = ones(size(empvecs,1),1);

% Fill weightsScore with amplitudes
weightsScore = zeros(length(empvals), 1);
for i = 1:length(empvals)
    weightsScore(i) = norm(empvecs(:,i));
end
weightsScore = weightsScore/norm(weightsScore);
if numevals == 0
    numevals = sum(weightsScore > .05);
end
% Sort empvecs, empvals properly
[weightsScore, idx] = sort(weightsScore, 'descend');
empvecs = empvecs(:, idx);
empvals = empvals(idx);


% Normalize eigenvectors
empvecs = normalizematrix(empvecs);

% Get contig eval order
if strcmp(evaluation_method, 'filtered');
    evalorder = calcEvalOrder(obj);
else
    evalorder = 1:numcontigs;
end

%allocate outputs
eigenfits = zeros(1, numcontigs);
scores = zeros(1, numcontigs);
min = inf;
histWeighted = zeros(numcontigs, numevals);
histUnweighted = zeros(numcontigs, numevals);

format long
for k = 1:numcontigs
    % Read in matrix
    contig = evalorder(k);
    [A,E] = obj.retrieveModel(contig);
    switch evaluation_method
        case 'all'
            % Run fitting via assessContig
            [fittedRes, ~] = assessContig(A, E, fitting_method, empvals, empvecs, PMU, numevals, weightsFit);
            
            % Calculate Score via Weighted Sum
            score = 0;
            for j = 1:numevals
                nfr = norm(fittedRes(:,j));
                score = score + weightsScore(j)*nfr;
                histWeighted(k,j) = weightsScore(j)*nfr;
                histUnweighted(k,j) = nfr;
            end
            scores(contig) = score;
            eigenfits(contig) = numevals;
            
        case 'stable'
            % Run fitting via assessContig
            [fittedRes, ~] = assessContigStable(A, E, fitting_method, empvals, empvecs, PMU, numevals, weightsFit);
            
            % Calculate Score via Weighted Sum
            score = 0;
            for j = 1:numevals
                nfr = norm(fittedRes(:,j));
                score = score + weightsScore(j)*nfr;
                histWeighted(k,j) = weightsScore(j)*nfr;
                histUnweighted(k,j) = nfr;
            end
            scores(contig) = score;
            eigenfits(contig) = numevals;
            
        case 'filtered'
            % Calculate Backward Error (cutoff right now is 2*min)
            [score, numfits] = assessContigFiltered(A, E, fitting_method, empvals, empvecs, PMU, 1.1*min, weightsScore, numevals);
            if score < min
                min = score;
            end
            scores(contig) = score;
            eigenfits(contig) = numfits;
    end
end


% Plot graphs for report if needed
if(report)
    
    % Clean up Data
    [~, idx] = sort(abs(empvals), 'descend');
    empvals = empvals(idx);
    [~, idxClean] = sort(abs(empvalsClean), 'descend');
    empvalsClean = empvalsClean(idxClean);
    empvecs = empvecs(:, idx);
    empvecsClean = empvecsClean(:, idxClean);
    plotEigvals(empvalsClean, empvals);
    plotEigvecs(empvecsClean, empvecs);
    [~, idx] = sort(scores);

    % Make Unweighted Bar Graph
    numbars = 20;
    x = [1, 3:(numbars+2)];
    y = [histUnweighted(obj.correctContig,:); histUnweighted(idx(1:numbars),:)];
    figure('Visible','off');
    bar(x, y, 'stacked');
    fname = 'reporting/histUnweighted.jpeg';
    saveas(gcf, fname);
    
    % Make Weighted Bar Graph
    numbars = 20;
    x = [1, 3:(numbars+2)];
    y = [histWeighted(obj.correctContig,:); histWeighted(idx(1:numbars),:)];
    figure('Visible','off');
    bar(x, y, 'stacked');
    fname = 'reporting/histWeighted.jpeg';
    saveas(gcf, fname);
    
end


end
