%% Example_9_Regulation.m
%
% Regulation of an LTI System using AMPL
%
% Related Slides:         9-35 to 9-37
%
%

% Model Predictive Control
%
% Jun.-Prof. Dr.-Ing. Daniel Görges
% Juniorprofessor for Electromobility
% Department of Electrical and Computer Engineering
% University of Kaiserslautern
% www.eit.uni-kl.de/en/jem/teaching/lectures/
%
% Please report any error to goerges@eit.uni-kl.de

%% Clear
clear;
close all;


%%%%%%%%%%%%%%%%%%%%%%% Ampl Environment  %%%%%%%%%%%%%%%%%%%%%%%%%
amplPathDir = 'D:\programs\ampl.mswin64';
%% add path for the customized codes
addpath(amplPathDir+ "\amplapi\matlab\customizedCodes")
run(amplPathDir + "\amplapi\matlab"+  "\setUp.m")




%%%%%%%%%%%%%%%%%%%%%%% MPC Definition  %%%%%%%%%%%%%%%%%%%%%%%%%
% the optimization problem:
% min. sum {k= 0 : N-1}  (x[k]'Qx[k] + u[k]Ru[k]) ;
% s.t.    x[k+1] = Ax[k] + B[k]
%         x_min<x[k]<x_max
%         u_min<u[k]<u_max
%         x_initial 



%% Modeling of the LTI System
A = [1 1; 0 1];
B = [1; 0.5];
[nx nu] = size(B);

%% Definition of the Cost Function
Q = eye(nx);
R = eye(nu);

%% Definition of the Constraints
x_min = [-5; -5];
x_max = [5; 5];
u_min = -1;
u_max = 1;

%% Definition of the Model Predictive Controller
N = 50000;
N_sim = 15;


tic 
ampl = AMPL(amplPathDir);




%% Define the parameters of OP
ampl.defineParam("N",1,'integer')% define Horizon
ampl.defineParam("Q A",[2,2])         
ampl.defineParam("R u_min u_max")
ampl.defineParam("x_min x_max B x_initial", 2)


%% assign values for  the parameters in AMPL
ampl.assignParam("N R u_min u_max",[N R u_min u_max])
ampl.assignParam("x_min",x_min)
ampl.assignParam("x_max",x_max)
ampl.assignParam("Q",Q)
ampl.assignParam("A",A)
ampl.assignParam("B",B)

%% define a set k for time indexes  (optinal)
ampl.eval('redeclare set K := 0..N-1;') 

%% Define the decision variables
ampl.defineVar("x",[2,"0..N"])  % note that x indexes up to N   
ampl.defineVar("u","K") 

%% define the cost 
cost_function= strcat("sum {k in  K} ( ", ...
                       multiply("x.T[1..2, k]", 'Q[1..2, 1..2 ]', "x[ 1 .. 2 , k  ]"),...
                       " + u[k]*R*u[k]", ')'); 

ampl.defineObj('min','cost_function', cost_function )

%% define the constraints 

dynamics  =  "x[i,k+1] =  " + multiply("A.T[i,1..2]","x[1..2,k]") + '+' +"B[i]*u[k]" ;% B[i] * u[k] because u is scalar;
ampl.defineCons('dynamics', dynamics,[" i in 1..2", "k in K"] );
ampl.eval('expand dynamics; ')

ampl.defineCons('bounded_states', "x_min[i] <= x[i, k] <= x_max[i]",["i in 1..2" ,"k in 1..N"] )

ampl.defineCons('bounded_input', "u_min<=u[k] <= u_max","k in 0..N-1 ")

ampl.defineCons('x_initial_cons',  'x[i,0] = x_initial[i]',"i in 1..2 ")
%
preCalcTimeAmpl = toc;

%% simulation loop  of the closed loop
x{1} =  [1; 1.5]; % x_0
tic 
for i = 1 : N_sim 

% assing the parameters in AMPL
ampl.assignParam("x_initial",x{i})

%solve the OP
ampl.solve

% extract the decision variables and the cost value 
X{i} = ampl.getVarValue(['x']);
U{i} =  ampl.getVarValue(['u']);
[value{i}, astatus{i},result{i},exitcode{i},message{i},expandCost{i}] = ampl.getObj('cost_function');


% extract the control input
u{i} = U{i}(1);

% system 
x{i+1} = A * x{i}  + B* u{i};
 

end
CalcTimeAmpl = toc;


%% Visualization of the Closed-Loop Input and State Sequence
figure;
subplot(2,1,1)
plot(0:N_sim-1,cell2mat(u)');
xlabel('k');
ylabel('u');
subplot(2,1,2)
plot(0:N_sim,cell2mat(x)');
xlabel('k');
ylabel('x');



preCalcTimeAmpl
CalcTimeAmpl

