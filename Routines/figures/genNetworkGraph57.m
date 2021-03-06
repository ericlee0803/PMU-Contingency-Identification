% Generate Network Graph for Contig 1 in 39 bus System
% Takes input PMU and plots where they are
function genNetworkGraph57(PMU)


% Run contig1.m to obtain Line information
run('contig1.m')

% Generate Adjacency Matrices for main and highlighted graphs
X1 = Line.con(:,1);
X2 = Line.con(:,2);
X3 = ones(2*length(X1),1);
Y1 = X1(1, :);
Y2 = X2(1, :);
Y3 = ones(2*length(Y1),1);
Z1 = X1(2, :);
Z2 = X2(2, :);
Z3 = ones(2*length(Z1),1);
A = sparse([X1; X2], [X2; X1], X3);
A = full(A);
B = sparse([Y1; Y2], [Y2; Y1], Y3);
B = full(B);
C = sparse([Z1; Z2], [Z2; Z1], Z3);
C = full(C);

% Bus Position Data
P = ...
[...
0.7*1.0, 3.0;       % 1      
0.7*3.0, 3.0;       % 2       
0.7*3.0, 5.0;       % 3      
0.7*3.0, 7.0;       % 4      
0.7*2.0, 9.0;       % 5      
0.7*1.0, 12.0;      % 6       
0.7*1.0, 11.0;      % 7        
0.7*1.0, 10.0;      % 8       
0.7*1.0, 8.0;       % 9      
0.7*5.0, 11.0;      %10       
0.7*4.0, 10.0;      %11       
0.7*5.0, 8.0;       %12       
0.7*6.0, 9.0;       %13      
0.7*6.0, 7.0;       %14      
0.7*6.0, 6.0;       %15      
0.7*7.0, 5.0;       %16      
0.7*5.0, 4.0;       %17       
0.7*4.0, 4.0;       %18      
0.7*7.0, 10.0;      %19       
0.7*7.0, 11.0;      %20       
0.7*9.0, 6.0;       %21      
0.7*9.0, 8.0;       %22      
0.7*9.0, 12.0;      %23       
0.7*8.0, 9.0;       %24      
0.7*4.0, 2.0;       %25      
0.7*6.0, 2.0;       %26      
0.7*6.0, 3.0;       %27      
0.7*8.0, 2.0;       %28      
0.7*9.0, 2.0;       %29      
0.7*3.0, 1.0;       %30      
0.7*2.0, 13.0;      %31        
0.7*5.0, 13.0;      %32      
0.7*8.0, 13.0;      %33      
0.7*7.0, 13.0;      %34      
0.7*9.0, 10.0;      %35      
0.7*9.0, 13.0;      %36      
0.7*4.0, 1.0;       %37      
0.7*9.0, 3.0;       %38      
0.7*1.0, 5.0;       %39       
0.7*6.5, 8.0;       %40      							
0.7*5.0, 10.0;      %41      									
0.7*3.0, 9.0;       %42      
0.7*4.0, 9.0;       %43      							
0.7*2.0, 5.0;       %44      
0.7*2.0, 7.0;       %45      
0.7*4.0, 6.0;       %46      
0.7*4.0, 5.0;       %47      
0.7*5.0, 6.0;       %48      
0.7*5.0, 5.0;       %49      
0.7*6.0, 11.0;      %50      
0.7*0.0, 11.0;      %51      
0.7*0.0, 5.0;       %52      
0.7*2.0,  0;        %53      
0.7*5.0,  0;        %54      
0.7*6.0,  0;        %55      
0.7*8.0,  0;        %56      
0.7*6.0,  0.5;      %57      
];

% Plot Graph from Adjacency Matrix
hold on
set(gca,'xtick',[])
set(gca,'ytick',[])
set(gca, 'visible', 'off') ;


% Plot Main Graph


% Plot Main Graph
gplot(A, P, '-sk');


for i = 1:size(P,1)
	if(ismember(i, PMU))
		txt = sprintf('%d (PMU)',i);
	else
		txt = sprintf('%d',i);
	end
	text(P(i,1), P(i,2), txt);
end