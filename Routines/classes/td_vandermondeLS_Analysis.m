% td_kroneckerLS_Analysis stands for frequency domain least squares analysis. 
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
% ~~~~~~~~~~~~~ Class Properties~~~~~~~~~~~~~~~~ %
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
% noise = amount of noise injected


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
% ~~~~~~~~~~~~~~~~~ CLASSDEF ~~~~~~~~~~~~~~~~~~~ % 
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %

classdef td_vandermondeLS_Analysis < Analysis
	properties (Access = public)
		name = 'fd_LS_Analysis';
		noise
	end

	methods (Access = public)
		function obj = td_vandermondeLS_Analysis(noise)
			obj.noise = noise;
		end

		function [scores, ranking] = calcContig(obj, objInstance)
			[scores, ~] = calcContigInner(obj, objInstance);
			[~, ranking] = sort(scores);
		end

	end
end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
% ~~~~~~~~~~~~~~~ calcContig Def ~~~~~~~~~~~~~~~ % 
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %

function [scores, num_eigenfits] = calcContigInner(obj, objInstance)
	load metadata.mat
	for i = 1:numcontigs
	    % Solve LS problem and return residual
	    scores(i) = LSfit(objInstance, i);

	end
	num_eigenfits = 0;
end

% LSfit calculates a least squares fit of a DAE to a signal by forming the
% matrix M consisting of elements (e^lambda*t)*v where (lambda, v) are
% eigenpairs of the DAE. 

% So LSfit first calculates the eigenpairs (lambda, v), forms the matrix M,
% and then calculates c = M\S where S is the signal and c is a vector of
% coefficients

% ~~~~~~~~~INPUTS~~~~~~~~~ %

% obj = instance object
% contignum = contingency to identify

% ~~~~~~~~~OUTPUTS~~~~~~~~~ %

% results = size of residual after fitting

function results = LSfit(obj, contignum)
	% Get Metadata and reshape signal into proper format
	load metadata.mat
	signal = obj.PMU_data;
	[numtimesteps, signalsize] = size(signal);
	for i = 1:signalsize
	    signal(:,i) = signal(:,i) - mean(signal(floor(numtimesteps/3):end,i)); %Shift by steady state to avoid fitting zero eigenpairs
	end
	signal = signal(1:floor(numtimesteps/2), :);
	signal = signal'; % signal currently in column format
	dataoffset = 20*timestep;
	n = differential;
	signal = reshape(signal, [], 1);

	% Grab model, form Schur Complement SCH
	[A,E] = obj.retrieveModel(contignum);

	% Calc and Filter Eigenpairs
	[vecs, vals] = eig(full(A), E);
	vecs = vecs(obj.win, :);
	vals = diag(vals);
	vals(abs(vals) < 1e-8) = 0;
	mode = 'freq';
	[fvecs, fvals] = filter_eigpairs(0, 20, vals, vecs, mode);
	mode = 'damp';
	[eigvecs, eigvals] = filter_eigpairs(0, 40, fvals, fvecs, mode);

	results = LSfit_inner(signal, signalsize, timestep, dataoffset, eigvals, eigvecs);
end

% LSfit_inner calculates a least squares fit  of a signal by forming the
% matrix M consisting of elements (e^lambda*t)*v where (lambda, v) are
% eigenpairs supplied.

% So LSfit first calculates the eigenpairs (lambda, v), forms the matrix M,
% and then calculates c = M\S where S is the signal and c is a vector of
% coefficients

% ~~~~~~~~~INPUTS~~~~~~~~~ %

% signal: the signal itself, should be in the form of a column vector
% signalsize: denotes the dimensions of the signal per timestep.
% signaltimestep: denotes the timestep between signals.
% eigvals: eigenvalues to fit.
% eigvecs: eigenvectors to fit.

% ~~~~~~~~~OUTPUTS~~~~~~~~~ %

% results: simply norm of the residual to the LS fit. 

function results = LSfit_inner(signal, signalsize, signaltstep, signalstart, eigvals, eigvecs)

	% Get Metadata and initialize some variables
	tstep = signaltstep;
	[~, nummodes] = size(eigvecs);

	% Form matrix M
	M = zeros(length(signal), nummodes);
	numsteps = length(signal)/signalsize;
	for i = 1:numsteps
	    for j = 1:nummodes
	        front_offset = (i-1)*signalsize + 1;
	        back_offset = i*signalsize;
	        time = (signalstart + (i-1)*tstep);
	        M(front_offset:back_offset, j) = exp(eigvals(j)*time)*eigvecs(:,j);
	    end
	end


	% Calc Solution + Iterative Refinement
	R = triu(qr(M));
	x = R\(R'\(M'*signal));
	res = signal - M*x;
	e = R\(R'\(M'*res));
	x = x + e;
	res = signal - M*x;
	results = norm(res);

end