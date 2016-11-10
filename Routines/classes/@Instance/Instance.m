classdef Instance
    
    properties
        metadata
        casename
        fitting_method
        analysis_method
        dynamic_data
        testbank
        PMU
        minfreq
        maxfreq
    end
    
    methods
        [listvecs, listres] = calcContig(obj)
        [ranking, scores] = calcScores(obj, method, vecs, residuals)
        [empvals, empvecs] = runN4SID(obj, modelsize)
        [numcontigs, numbuses, basefilename, timestep ...
        ,numlines, differential, algebraic] = getMetadata(obj)

    end

end