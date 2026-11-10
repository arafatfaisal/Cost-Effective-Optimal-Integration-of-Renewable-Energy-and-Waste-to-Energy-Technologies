clc                                 % To clear the command window
clear                              % To clear the workspace
close all;
rng(1)
format compact;
tic
fun = @economic_analysis;  %Objective function that calculates fitness 
lb1 = [1 1 1 1];     % lower Bounds for 4 optimization variables(wind, solar and battery units)
ub1 = [25000 100000  100000 100000];% upper bounds for...................................................


% Problem preparation 
problem.nVar = 4;         %A 4-D problem(3 variables to optimized)
problem.ub = ub1;		%upper Bounds for 3 optimization variables(wind, solar and battery units)
problem.lb = lb1;		%lower Bounds for 3 optimization variables(wind, solar and battery units)
problem.fobj =fun;		%Objective function that calculates fitness 

% PSO parameters 
noP = 4;
maxIter = 100;
visFlag = 0; % set this to 0 if you do not want visualization

RunNo  = 30; 
BestSolutions_PSO = zeros(1 , RunNo);
[ GBEST  , cgcurve ] = PSO( noP , maxIter, problem , visFlag ) ;
 
 disp('Best solution found')
 GBEST.X
 disp('Best objective value')
 GBEST.O

x=GBEST.X
figure
% Plot convergence curve
plot(cgcurve,'r-')
title('Convergence Curve')
xlabel('Iterations')
ylabel('Fitness Value')
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'Convergence Curve', 'pdf')


 [Anual_cost,Wind_cost,WTE_cost,Solar_cost,DG_cost,Battery_cost,Inverter_Tcost,Bin,Bout]=plot_statistics(x)