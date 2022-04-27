%% Example_9_Tracking_Mass_Spring_Damper_System.m
%
% Tracking Control of a Mass-Spring-Damper System
%
% Related Slides:         9-23
% Related Simulink Model: none
%
% Experiments:            Investigate the influence of the state weighting matrix
%
% Remarks:                Requires MPT (people.ee.ethz.ch/~mpt/3/)
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
%{
%% Modeling of the Mass-Spring-Damper System
h = 0.5;                               % sampling period
m = 4;                                 % mass
alpha = 1/m;                           % parameter
beta = 1/m^2;                          % parameter
c = 2;                                 % stiffness constant
b = 1;                                 % damping constant
A = [1 h; -c*h*alpha 1-b*h*alpha];
B = [h^2/2*alpha; h*alpha-b*h^2/2*beta];
Ts = 1;
sys = LTISystem('A',A,'B',B,'Ts',Ts)
x_0 = [0; 0];

tic 
sys.initialize(x_0)

%% Definition of the Cost Function
Q = diag([10000 1]);
sys.x.penalty = QuadFunction(Q);
R = eye(sys.nu);
sys.u.penalty = QuadFunction(R);

%% Definition of the Constraints
sys.x.min = [-1; -0.5];
sys.x.max = [1; 0.5];
sys.u.min = -1.5;
sys.u.max = 1.5;

%% Definition of the Terminal Cost
P = sys.LQRPenalty;
sys.x.with('terminalPenalty');
sys.x.terminalPenalty = P;

%% Definition of the Terminal Constraint Set
X_N = sys.LQRSet;
sys.x.with('terminalSet');
sys.x.terminalSet = X_N;

%% Definition of a Time-Varying State Reference
sys.x.with('reference');
sys.x.reference = 'free';

%% Definition of the Model Predictive Controller
N = 5;
ctrl = MPCController(sys,N)

%% Definition of the Closed-Loop System
loop = ClosedLoop(ctrl,sys)

%% Computation of the Closed-Loop Input and State Sequence
N_sim = 50;
x_ref = 0.5*[zeros(1,10) ones(1,20) zeros(1,N_sim-10-20); zeros(1,N_sim)];
data = loop.simulate(x_0,N_sim,'x.reference',x_ref)

%% Visualization of the Closed-Loop Input and Input Sequence and the Reference Sequence
figure;
subplot(2,1,1);
plot(0:length(data.U)-1,data.U);
ylabel('u');
subplot(2,1,2);
hold on;
plot(0:length(data.X)-1,data.X);
stairs(0:length(x_ref(1,:))-1,x_ref(1,:),'b:');
ylabel('x');
legend('x_1','x_2','x_{1,ref}');
xlabel('t');

time_toolbox = toc;
%}
clc
clear all  

%%%%%%%%%%%%%%%%%%%%%%% Ampl Environment  %%%%%%%%%%%%%%%%%%%%%%%%%
amplPathDir = 'D:\programs\ampl.mswin64';
%% add path for the customized codes
addpath(amplPathDir+ "\amplapi\matlab\customizedCodes")
run(amplPathDir + "\amplapi\matlab"+  "\setUp.m")

tic


%%% using Ampl
N = 5000;
nx = 2; % number of states
nu = 1; % number of inputs
pr = 1; % number of outputs
Cr = [1 0] ;
C = [1 0; 0 1]; 
A = [1,0.5;-0.25,0.875]; % discrete and sampling time was .5 s  
B = [0.03125;0.1171875]; 
Q = diag([10000 1]);
R = eye(nu);
x_min = [-1; -0.5];
x_max = [1; 0.5];
u_min = -1.5;
u_max = 1.5;
Qss = 20;
Rss = R;



%% Definition of the Terminal Cost and Constraint Set 
P = [12651.7619189282,824.244239381239;824.244239381239,308.678720205608];
A_iq_trem_ = [25.7305105740231,5.71539642148211;-25.7305105740231,-5.71539642148211;-20.1629699561501,-12.7022075450372;20.1629699561501,12.7022075450372];
b_iq_trem_ = [1.5;1.5;1.5;1.5];


%% the reference
N_sim = 50;
x_ref = 0.5*[zeros(1,10) ones(1,20) zeros(1,N_sim-10-20); zeros(1,N_sim)];





%%%%%%%%%%%%%%%%%%%%%%%% Preparing the OP in AMPL %%%%%%%%%%%%%%%%%%%%%%

TC = runAMPL(amplPathDir); % OP of traget calculation
MPC = runAMPL(amplPathDir); % OP for MPC



%% OP 7.9 (Traget Calculation)


%% data definition
% decision variables
TC.defineVar('x_ss',nx); 
TC.defineVar('u_ss',nu);

% parameters 
TC.defineParam('r',pr);
TC.defineParam('u_ss_unc');




%% Construct the cost function
% Temp1 = (Cr*x_ss - r)   
Temp1 = strcat(... 
                  '(', ...
                            multiply(Cr,'x_ss[1..'+string(nx)+']'), ...  % is equivalent to sprintf('x_ss[1..%u]',nx) or we could use expand('x_ss[1..%u]',nx)
                            '-' , expand('r[1..%u]',nu),... 
                            ')'...                                  % do not forget to close the parentheses
                                                               ); 
% Temp2 = (u_ss - u_ss_unc)
Temp2 = "(" + expand('u_ss[1..%u]',nu) + " - " +  ...
              expand('u_ss_unc[1..%u]',nu) + ")"; % all are scaler
% cost_function1 = .5*(Temp1'*Qss*Temp1 + Temp2'*Rss*Temp2);
cost_function1 = strcat(...
                       ".5*(",...
                               multiply(Temp1',Qss,Temp1),...
                               '+' , multiply( Temp2',Rss, Temp2),...    % Note Temp2 must be string because I make transpose 
                                                                   ")" ...
                                                                    ); 
TC.defineObj('min','cost_function', cost_function1);

%% the constraints 

% the system constraints: [ eye(nx)-A -B     ]   *  [  x_ss ]  = [ zeros(nx,1)]
%                          [ Cr zeros(pr,nu)  ]      [  u_ss ]    [      r     ]
%
%
% the system constraints
Temp3 = expand([eye(nx)-A -B ; Cr zeros(pr,nu)]); % expand  here used to convert the numeric array to string array
% Temp3 = [expand(eye(2)-A_) expand(-B_) ; expand(Cr) expand(zeros(2,nu))]; % similar to the previous line 
Temp4 = [expand('x_ss[1..%u]',nx);'u_ss'];
Temp5 = [expand(zeros(nx,1));expand('r[1..%u]',pr)];
TC.defineCons('system',strcat( multiply(Temp3,Temp4), '=',Temp5))   

% the input constraint: u_min<= u_ss <= u_max
TC.defineCons('input_contraints', expand(u_min) +'<='+  expand('u_ss[1..%u]',nu) + '<=' +expand(u_max)) 


% the output constraints   y_min<C*x_ss y_max
y_min = x_min(1:pr);
y_max = x_max(1:pr);
output_constraints1 = strcat(  expand(y_min) ,  '<=',  multiply(Cr, sprintf('x_ss[1..%u]',nx)), ' <=',expand(y_max) );  
TC.defineCons('output_constraints',output_constraints1);   



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Solve for 7.8 (MPC)
%% data definition
% the parameters
MPC.defineParam('N');
MPC.defineParam('x_ss x_initial',nx); 
MPC.defineParam('u_ss' );
% the decision variables
MPC.defineVar('x_tilde',[nx,"0..N"]); 
MPC.defineVar('u_tilde',"0..N-1");

% assign the constant parameters
MPC.assignParam('N',N );



% cost_function: x_tilde(N)'*P*x_tilde(N) + sum {k = 0 to N-1 } (x_tilde(k)'*Q*x_tilde(k) + u_tilde(k)'*R*u_tilde(k)) 
cost_function = strcat(...
                           multiply('x_tilde.T[1..'+string(nx)+',N]',P,'x_tilde[1..'+string(nx)+',N]')      ,...
                           '+', 'sum {k in 0..N-1 by 1}'                           , ...
                           ' ('                                                    ,...
                           multiply(expand('x_tilde.T[1..%u,k]',nx),Q,sprintf('x_tilde[1..%u,k]',nx))      ,...
                           '+',multiply("u_tilde.T[1.."+string(nu)+",k]",R,"u_tilde[1.."+string(nu)+",k]")              ,... note         multiply("u_tilde.T[k]",R_,'u_tilde[k]') for scalar  is okay
                                                                        ' )'       ); 
MPC.defineObj('min','cost_function', cost_function);

%% the constraints 

% the dynamics constraints: x_tilde(k+1) = A*x_tilde(k) + B*u_tilde(k)
dynamics = expand('x_tilde[1..%u,k+1]',nx)+ '=' + multiply(A,'x_tilde[1..'+string(nx)+',k]') + '+' + multiply(B,"u_tilde[1.."+string(nu)+",k]");
MPC.defineCons('dynamics',dynamics,"k in 0..N-1")

% the output constraints: x_min <=x_tilde+x_ss <= x_max
Temp7 = "(" + expand('x_tilde[1..%u,k]',nx) + ' + ' + expand('x_ss[1..%u]',nx)+ ' )';
output_constraints = expand(x_min) + '  <= ' + multiply(C,Temp7) + '<=' + expand(x_max)   ;
MPC.defineCons('output_constraints',output_constraints," k in 1..N");   

% the input constraint  u_min <=u_tilde+u_ss <= u_max
Temp8 = "(" + expand('u_tilde[1..%u,k]',nu) + ' + ' + expand('u_ss[1..%u]',nu)+ ' )';
input_constraints = expand(u_min) + '  <= ' + Temp8 + '<=' + expand(u_max)   ;

MPC.defineCons('input_constraints',input_constraints,"k in 0..N-1");   

% initial values
MPC.defineCons('x_initial_cons',  'x_tilde [i,0] = x_initial[i] - x_ss[i]',"i in 1..2 ")


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Simultion %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x{1} =  [0; 0]; % x_0

for i = 1 : N_sim


%%%%%%%%%%%%%%%%%%%%%%%%%%  STEP 1   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1- find u_ss_unc (solution 7.4)

r = x_ref(1,i);
traget_pair_unc = linsolve([eye(nx)-A -B ; Cr zeros(pr,nu)], [zeros(nx,1) ; r]);
x_ss_unc{i} = traget_pair_unc(1:nx);
u_ss_unc{i} = traget_pair_unc(nx+1,end);

%%%%%%%%%%%%%%%%%%%%%%%%%%  STEP 2   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% solution of 7.9 (Traget Calculation)

% assign the variable constants 
TC.assignParam('u_ss_unc',u_ss_unc{i})
TC.assignParam('r',r)

% solve the OP
TC.solve


% extract  the decision variabels x_ss and u_ss and the cost 
x_ss{i} = TC.getVarValue('x_ss');
u_ss{i} = TC.getVarValue('u_ss');
%[value_OP_TC{i}, astatus_OP_TC{i},result_OP_TC{i}, ...
% exitcode_OP_TC{i},message_OP_TC{i},expand_OP_TC{i}]...
%                               = OP_TC.getObj('cost_function');



%x_ss{i} = x_ss_unc{i};
%u_ss{i} = u_ss_unc{i};


%%%%%%%%%%%%%%%%%%%%%%%%%%  STEP 3   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Solve for 7.8 (MPC)
% assign the variable constants 
MPC.assignParam('u_ss',u_ss_unc{i})
MPC.assignParam('x_ss',x_ss_unc{i})
MPC.assignParam('x_initial',x{i})


MPC.assignParam("x_initial",x{i})
% solve the OP
MPC.solve

% extract  the decision variabels X_tilde and U_tilde and the cost 
X_tilde{i} = MPC.getVarValue('x_tilde');
U_tilde{i} = MPC.getVarValue('u_tilde');
%[value_OP_MPC{i}, astatus_OP_TC{i},result_OP_TC{i}, ...
% exitcode_OP_MPC{i},message_OP_MPC{i},expand_OP_MPC{i}]...
%                               = OP_TC.getObj('cost_function');


X{i} = X_tilde{i} + x_ss{i};
U{i} = U_tilde{i} + u_ss{i};

% extract the control input
u{i} = U{i}(1);

% system model 
x{i+1} = A * x{i}  + B* u{i};
 

end

  



%% Visualization of the Closed-Loop Input and Input Sequence and the Reference Sequence
figure;
subplot(2,1,1);
plot(0:N_sim-1,cell2mat(u));
ylabel('u');
subplot(2,1,2);
hold on;
plot(0:N_sim,cell2mat(x));
stairs(0:length(x_ref(1,:))-1,x_ref(1,:),'b:');
ylabel('x');
legend('x_1','x_2','x_{1,ref}');
xlabel('t');

time_ampl = toc;




time_ampl
time_toolbox



