
function [scores, ranking, vecs, res] = run_problem(instance)


% calc fit data
[vecs, res] = calcContig(instance);

% predict contingency
analysis_method = instance.analysis_method;
[ranking, scores] = calcScores(instance, analysis_method, vecs, res);

end