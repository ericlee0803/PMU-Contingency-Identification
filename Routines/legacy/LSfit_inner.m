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

% ~~~ PROBABLY NOT NECESSARY ~~~ %
% % Dump Rank Deficiencies
% [~, R, E] = qr(M);
% M = M*E;
% idx = (abs(diag(R)) < 1e-8) == 1;
% M(:, idx) = [];


% Calc Solution + Iterative Refinement
R = triu(qr(M));
x = R\(R'\(M'*signal));
res = signal - M*x;
e = R\(R'\(M'*res));
x = x + e;
res = signal - M*x;
results = norm(res);

