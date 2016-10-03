function [Acan, Ecan] = DAEcanonical(A, E, n)

% transforms the DAE 
% [A,E] = [(A11, A12; A21, A22), (I, 0; 0, 0)] to
% [Acan, Vcan] = [(D, inv(V)*A12; A21*V, A22), (I, 0; 0, 0)]
% where A11 = V*D*inv(V)

A11 = A(1:n, 1:n); A12 = A(1:n, (n+1):end);
A12 = A((n+1):end, 1:n); A22 = A((n+1):end, (n+1):end);

[V, D] = eig(A11);
Acan = [D, V\A12; A21*V, A22];
Ecan = E;


