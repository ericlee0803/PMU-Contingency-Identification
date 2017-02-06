% Runs contig identification on all contingencies
function [results, results3, confidence] = testsparse()

% Load metadata, initialize results vectors
load metadata.mat
numtrials = 10;
results = zeros(1,numtrials);
results3 = zeros(1,numtrials);
confidence = zeros(1,numtrials);
noise = .01;
modelorder = 20; 
PMUidx = [16 1 13 28 31 22 23 37 5 9];

% Run contingency identification for all possible contigs (numcontigs)
for i = 1:numtrials
    for j = 1:numcontigs
        contig = j;
        PMU = place_PMU(contig, PMUidx(1:i));
        [scores, ranking, ~, ~] = testinstanceFiltered(contig, PMU, noise, modelorder);
        if(contig ==  ranking(1)) results(i) = results(i) + 1; end
        if(ismember(contig, ranking(1:3))) results3(i) = results3(i) + 1; end
        confidence(i) = confidence(i) + abs(scores(1) - scores(2))/scores(1);
    end
end

% Plot Results
plot(results/numcontigs, '-ob');
hold on
plot(results3/numcontigs, '-*r');
ylabel('Percentage of Correct Diagnoses')
xlabel('Number of PMUs')
legend('Top 1', 'Top 3')
axis([1 10 0 1.5])

end

