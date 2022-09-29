
%{
The optimization problem is 
minimize x^2
subject to x>= a,
where a = 2
%}



currentPath = which('runCode.m');
Index_amplapi = findstr(currentPath,'\amplapi');
amplPathDir = currentPath(1:Index_amplapi);
%% add path for the AMPL repository
addpath(genpath(amplPathDir+ "\amplapi\matlab"))
run(amplPathDir + "\amplapi\matlab"+  "\setUp.m")

%% Method 1
% run AMPL
ampl = runAMPL(amplPathDir); 
% model
ampl.eval('model; param a; var x;')
ampl.eval('minimize cost: x**2;')
ampl.eval('restriction: x >= a;')
%data
ampl.eval('data; param a:=2;')
% Choose the solver
ampl.eval('option solver gurobi;')
% solve the optimization problem 
ampl.solve()
% extract the results:
[value, astatus,result,exitcode,message,expand] = ampl.getObj('cost');
x = ampl.getVarValue('x');
a = ampl.getParamValue('a');
% close AMPL
ampl.close





%% Method 2
% run AMPL
ampl = runAMPL(amplPathDir); 
% read the model
ampl.read(["Model.mod"])
% read the data 
ampl.readData(["Data.dat"])
% Choose the solver
ampl.eval('option solver gurobi;')
% solve the optimization problem 
ampl.solve()
% extract the results:
[value, astatus,result,exitcode,message,expand] = ampl.getObj('cost');
x = ampl.getVarValue('x');
a = ampl.getParamValue('a');
% close AMPL
ampl.close
