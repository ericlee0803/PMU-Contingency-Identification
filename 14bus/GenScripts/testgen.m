A = rand(10);
A = A - 6*eye(10);
C = zeros(5,10);
C(1:5,1:5) = eye(5);
stepsize = 0.05;
time = 7;
steps = time/stepsize;
signal = zeros(5, steps);
state = zeros(10, steps);
x0 = .2*rand(10,1);
for i = 1:steps
    t = stepsize*i;
    stateVec = expm(A*t)*x0;
    state(:,i) = stateVec;
    signal(:,i) = C*stateVec;
end
    
save('testSimple.mat','signal', 'state');
save('testSimpleMatrix.mat','C','A');
hold on;
for i = 1:3
   plot((state(i,:)));
end