% Checks correctness of id_contig.m
function [scores, ranking, vecs, res] = unit_test_id_contig3(contignum)


%% Run Test Instance

test = load_problem('14bus', contignum, 'Weighted', 'Projection', 64:77);
[scores, ranking, vecs, res] = run_problem(test);
fprintf('Contingency Identified: Contig %d\n', ranking(1));
evecs_fitted  = vecs{ranking(1)};





%% Linearized System
[A,E] = test.retrieve_testbank(contignum);
minfreq = test.minfreq;
maxfreq = test.maxfreq;
[v2, d2] = eig(A,E);
[v2_subset, d2_subset] = filter_eigpairs(minfreq, maxfreq, diag(d2), v2);
    
plot_eigvecs(v2_subset, evecs_fitted);



end