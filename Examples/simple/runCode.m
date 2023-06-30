
%{
The optimization problem is 
minimize x^2
subject to x>= a,
where a = 2
%}



currentPath = which('runCode.m');
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
% run AMPL
ampl = AMPC(amplPathDir); 
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
ampl = AMPC(amplPathDir); 
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
x = ampl.getVarValue('x')
a = ampl.getParamValue('a')
% close AMPL
ampl.close

clc
ampl = AMPC(amplPathDir); 
ampl.eval("  reset; # clear previous definitions       model; # declare the model " +...
      " var x;      param a;      param b;      minimize cost: (x**2-a)^2;      s.t. constraints: x>=b;" )
ampl.eval("data; param b := -1;data; param a :=5;  option solver gurobi;solve;display x,a,b;" )