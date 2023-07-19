
%{
The optimization problem is 
minimize x^2
subject to x>= a,
where a = 2
%}


currentPath = mfilename('fullpath') ;
APIfolderName =  'amplapi';
Index_amplapi = strfind(currentPath,APIfolderName);
amplPathDir = currentPath(1:Index_amplapi-1);
%% add path for the AMPL repository
matlab_api_path = fullfile(amplPathDir,APIfolderName,"matlab")
addpath(genpath(matlab_api_path))
run(fullfile(matlab_api_path,"setUp.m"))



%% Method 0
% run AMPL
% model
findOptimal(amplPathDir,2,3)
findOptimal(amplPathDir,5,-1)



function result = findOptimal(amplPathDir, a,b)
   ampl = POPA;
   ampl = ampl.runAMPL;
    OP = join([
        " reset;"...
        " model; "...
        " var x;"...
        " param a; "...
        "  param b;"...
        "  minimize cost: (x-a)**2;"...
        "  s.t. constraints: x>=b;" ...
        ]);
    
    ampl.eval(OP)
    
    data = join([
        "data; ",...
        "param a :=  %f;" ,...
        "param b :=  %f;" ,...
                   ]);
    data = sprintf(data,a,b);
    
    ampl.eval(data)
    ampl.eval("option solver gurobi;")
    ampl.solve() % solve
    ampl.display('x') % display solution
    result = ampl.getVariable('x').value   
 end


