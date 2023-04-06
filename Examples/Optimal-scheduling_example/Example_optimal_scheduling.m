%  This code is an implementation for the optimization problem appears in
%  the scientific paper:
% Abdelkarim, Anas, and Ping Zhang. "Optimal Scheduling of Preventive     %
% Maintenance for Safety Instrumented Systems Based on Mixed-Integer      %
% Programming." International Symposium on Model-Based Safety and         %
% Assessment. Springer, Cham, 2020.                                       %


clear all

%%
%%%%%%%%%%%%%%%%%%%%%%% Ampl Environment  %%%%%%%%%%%%%%%%%%%%%%%%%
currentPath = which('Example_optimal_scheduling.m');
if ispc
    backslash = "\";
else
     backslash = "/";
end 
Index_amplapi = findstr(currentPath, backslash +'amplapi');
amplPathDir = currentPath(1:Index_amplapi-1);
%% add path for the AMPL repository
addpath(genpath(amplPathDir+ backslash+ "amplapi" +backslash+ "matlab"))
run(amplPathDir + backslash+ "amplapi" +backslash+ "matlab" + backslash+ "setUp.m")






%% Method 1
%read from .mod and .dat files
% ampl1 = AMPC(amplPathDir);
% ampl1.read([strcat(currentPath(1:end-29),'\Model.mod')]);
% ampl1.readData([strcat(currentPath(1:end-29),'\DATA.dat')]);
% ampl1.eval('option show_stats 1;')
% ampl1.eval('option solver CPLEX;')
% ampl1.solve
% costValue = ampl1.getValue("cost_function")
% aClass = ampl1.getVariable("a")
% a = aClass.getValues;
% a = a.toTable;
% a = cell2mat(a{:,2});
% ampl1.getObj('cost_function')
% ampl1.close



%% Method 2
% model mode
% define the parameters
ampl = AMPC(amplPathDir);
ampl.defineParam("N",1,"integer") % definde N equivalent to ampl.eval('model; param N integer;)
ampl.defineParam("Ts n_full_maintenance n_partial_maintenance") % scalar and no attributes
ampl.defineParam("Q Ma  Mb ",[6,6]) % matrices with size of 6*6 (index ranges from 1..6, 1..6), no attributes
ampl.defineParam("initial_values ",6) % vector with size of 6 (index ranges from 1..6), no attributes


% define the variables
ampl.defineVar("x",[6,"0..N"],">=0") % because the index range
% for the variables, a f p, do not start from 1,i.e, start from 0,
% note N is defined earlier as parameter
% check for example ampl.getValue('x[1,0]')
ampl.defineVar("a f  p ","0..N","binary")

%%
% the objective function
cost_function = ['10000/(2*N)*sum { k in 0..N-1} (             ' ...
                 'x[3,k]  +  x[3,k+1] + x[4,k]  +  x[4,k+1] +  ' ...
                 'x[5,k]  +  x[5,k+1] +  x[6,k]  + x[6,k+1] )  '];
ampl.defineObj("min","cost_function",cost_function);



%% constraints
% dynamics
% to write the dynamics there are many ways and all are equivallent
wayNumber  = 1;
switch wayNumber
    case 1 % first way % pure AMPL commands
        dynamics = [' x[i,k+1] =                                                 ' ...
            ' (a[k] * sum { c in 1..6} Q[i,c]  * x[c,k]) +                       ' ...
            ' (f[k] * sum { c in 1..6} Q[i,c]*sum { j in 1..6}  Ma[c,j]*x[j,k])+ ' ...
            ' (p[k] * sum { c in 1..6} Q[i,c]*sum { j in 1..6}  Mb[c,j]*x[j,k])  ' ];
        ampl.defineCons("dynamics",dynamics,"i in 1..6, k in 0..N-1" );
        
    case 2   % second way % we use multiply function
        dynamics  =  "x[i,k+1] =  " +...
            "  a[k] *" + multiply("Q.T[i,1..6]","x[1..6,k]")+ ...
            "+ f[k] *" + multiply("Q.T[i,1..6]"," Ma[1..6,1..6]","x[1..6,k]")+...
            "+ p[k] *" + multiply("Q.T[i,1..6]"," Mb[1..6,1..6]","x[1..6,k]");
        ampl.defineCons("dynamics",dynamics,"i in 1..6, k in 0..N-1" ); %we need to clarify what i and k in constraints indexRange
        
    case 3  % Thrid way % we use both multiply and expand functions
        dynamics = expand("x[1..6,k+1] = ") +...
            "  a[k] *" + multiply("Q[1..6,1..6]","x[1..6,k]")+ ...
            "+ f[k] *" + multiply("Q[1..6,1..6]"," Ma[1..6,1..6]","x[1..6,k]")+ ...
            "+ p[k] *" + multiply("Q[1..6,1..6]"," Mb[1..6,1..6]","x[1..6,k]");  %we need to clarify what i and k in constraints indexRange
        ampl.defineCons("dynamics",dynamics,"k in 0..N-1" );
    case 4  % replace every k in dynamics in case 3  to 1..N-1; being N-1 a value
        dynamics = [];
        N = 30; % where 3 is N-1
        for k = 1 : N-1
            dynamics = [dynamics; expand(sprintf("x[1..6,%u]=",k+1)) +...
                sprintf(  "a[%u]*",k) + multiply("Q[1..6,1..6]",sprintf("x[1..6,%u]",k))+ ...
                sprintf("+ f[%u]*",k) + multiply("Q[1..6,1..6]"," Ma[1..6,1..6]",sprintf("x[1..6,%u]",k))+ ...
                sprintf("+ p[%u]*",k) + multiply("Q[1..6,1..6]"," Mb[1..6,1..6]",sprintf("x[1..6,%u]",k))];
        end
        ampl.defineCons("dynamics",dynamics);
    case 5  % feed the constants directly
        dynamics = [];
        N = 30; % where 3 is N-1
        Q = [0.99999967075480389    0.0049875199849479255   0.000999500001931637     0 0 0;  2.9925119909687547E-7  0.99501247994018693     1.4970037065390959E-10   0 0 0;         1.1994000023179647E-8  2.9940074130781927E-11  0.999000499839371        0 0 0;        8.6399985765747359E-9  2.1564042584720887E-11  4.3185598853904993E-12   1 0 0;         5.7599990510498259E-9  1.4376028389813928E-11  2.8790399235936667E-12   0 1 0;         3.599999406906139E-9   8.9850177436337E-12     1.7993999522460411E-12   0 0 1;];
        Ma = [1  0  0  0  0  0;          0  1  0  0  0  0;          0  0  1  1  1  0;          0  0  0  0  0  0;       0  0  0  0  0  0;          0  0  0  0  0  1];
        Mb = [1  0  0  0  0  0;          0  1  0  0  0  0;          0  0  1  1  0  0;          0  0  0  0  0  0;          0  0  0  0  1  0;          0  0  0  0  0  1];
        for k = 1 : N-1
            dynamics = [dynamics; expand(sprintf("x[1..6,%u]=",k+1)) +...
                sprintf(  "a[%u]*",k) + multiply(Q,sprintf("x[1..6,%u]",k))+ ...
                sprintf("+ f[%u]*",k) + multiply(Q, Ma,sprintf("x[1..6,%u]",k))+ ...
                sprintf("+ p[%u]*",k) + multiply(Q,Mb,sprintf("x[1..6,%u]",k))];
        end
        ampl.defineCons("dynamics",dynamics);
end




int = 'a[0]=1 ';
ampl.defineCons("int",int);

system_active = ['sum { j in 0..N-1} a[j] =  N - ' ...
                 '(n_full_maintenance + n_partial_maintenance )'];
ampl.defineCons("system_active",system_active)

full_maintenance_active= 'sum { j in 0..N-1} f[j] =  n_full_maintenance';
ampl.defineCons("full_maintenance_active",full_maintenance_active)

Partial_maintenance_active = 'sum { j in 0..N-1} p[j] =  n_partial_maintenance';
ampl.defineCons("Partial_maintenance_active",Partial_maintenance_active)

one_active = ' a[j] + f[j] + p[j] = 1 ';
ampl.defineCons("one_active",one_active,"j in 0..N")

initial_values_constraints = 'x[i,0] = initial_values[i]'    ;
ampl.defineCons("initial_values_constraints",initial_values_constraints,"i in 1..6")


% set values
if ~exist('N','var')
    N = 30;
end

n_full_maintenance   =  1;
n_partial_maintenance = 2;
Ts = 1; %  one hour
initial_values        = [  1 0 0 0 0 0] ;%  intial values


if ~exist('Q','var')
    Q = [0.99999967075480389    0.0049875199849479255   0.000999500001931637     0 0 0
         2.9925119909687547E-7  0.99501247994018693     1.4970037065390959E-10   0 0 0
         1.1994000023179647E-8  2.9940074130781927E-11  0.999000499839371        0 0 0
         8.6399985765747359E-9  2.1564042584720887E-11  4.3185598853904993E-12   1 0 0
         5.7599990510498259E-9  1.4376028389813928E-11  2.8790399235936667E-12   0 1 0
         3.599999406906139E-9   8.9850177436337E-12     1.7993999522460411E-12   0 0 1];
    
    Ma = [1  0  0  0  0  0
          0  1  0  0  0  0
          0  0  1  1  1  0
          0  0  0  0  0  0
          0  0  0  0  0  0
          0  0  0  0  0  1];
    
    Mb = [1  0  0  0  0  0
          0  1  0  0  0  0
          0  0  1  1  0  0
          0  0  0  0  0  0
          0  0  0  0  1  0
          0  0  0  0  0  1];
end

% defind the data
ampl.assignParam("N  n_full_maintenance n_partial_maintenance Ts",[N n_full_maintenance n_partial_maintenance Ts])
ampl.assignParam("initial_values",initial_values)
ampl.assignParam("Ma",Ma)
ampl.assignParam("Mb",Mb)
ampl.assignParam("Q",Q)

%% solve the optimization problem
ampl.eval('option show_stats 1;')
ampl.eval('option solver CPLEX;')
ampl.solve

%% Harvest the results
% check the value of N
ampl.getParamValue("N")
ampl.getParamValue("initial_values")
ampl.getParamValue("Ma")
[a, index,rowdata] = ampl.getVarValue("a");
f = ampl.getVarValue("f");
p = ampl.getVarValue("p");
x = ampl.getVarValue("x");
x1 = x(1,:)';


% objective function
[value, astatus,result,exitcode,message,expandCost] = ampl.getObj('cost_function')


[a f p ] 
value
