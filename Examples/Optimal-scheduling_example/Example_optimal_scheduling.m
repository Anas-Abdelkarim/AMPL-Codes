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
Index_amplapi = findstr(currentPath,'\amplapi');
amplPathDir = currentPath(1:Index_amplapi);
%% add path for the AMPL repository
addpath(genpath(amplPathDir+ "\amplapi\matlab"))
run(amplPathDir + "\amplapi\matlab"+  "\setUp.m")
amplPathDir = 'D:\programs\ampl.mswin64';



%% add path for the customized codes
ampl1 = runAMPL(amplPathDir);
%ampl = AMPL(amplPathDir);
ampl = runAMPL(amplPathDir);


%% Method 1
%read from .mod and .dat files
clearvars ampl1
ampl1 = runAMPL(amplPathDir);
ampl1.read([strcat(currentPath(1:end-29),'\Model.mod')]);
ampl1.readData([strcat(currentPath(1:end-29),'\DATA.dat')]);
ampl1.eval('option show_stats 1;')
ampl1.solve
costValue = ampl1.getValue("cost_function")
aClass = ampl1.getVariable("a")
a = aClass.getValues;
a = a.toTable;
a = cell2mat(a{:,2});
ampl1.getObj('cost_function')
ampl1.close

%% Method 2
% model mode
% define the parameters
ampl.defineParam("N",1,"integer") % definde N equivalent to ampl.eval('model; param N integer;)
ampl.defineParam("Ts n_full_maintenance n_partial_maintenance") % scalar and no attributes
ampl.defineParam("Q Ma  Mb ",[6,6]) % matrices with size of 6*6 (index ranges from 1..6), no attributes
ampl.defineParam("initial_values ",6) % matrices with size of 6*6 (index ranges from 1..6), no attributes
 

% define the variables
ampl.defineVar("x",[6,"0..N"],">=0") % because the index range
% for the variables, a f p, do not start from 1,i.e, start from 0,
% note N is defined earlier as parameter
% check for example ampl.getValue('x[1,0]')
ampl.defineVar("a f  p ","0..N","binary")

%%
% the objective function
cost_function = [' 10000/(2*N)*sum { k in 0..N-1} (                    ' ...
    ' x[3,k]  +  x[3,k+1] + x[4,k]  +  x[4,k+1] +         ' ...
    ' x[5,k]  +  x[5,k+1] +  x[6,k]  + x[6,k+1] )         ' ];

ampl.defineObj("min","cost_function",cost_function);

% constraints

dynamics = [' x[i,k+1] =                                             ' ...
    ' (a[k] * sum { c in 1..6}  Q[i,c]  * x[c,k]) +          ' ...
    ' (f[k] * sum { c in 1..6} Q[i,c]*sum { j in 1..6}  Ma[c,j]*x[j,k])+  ' ...
    ' (p[k] * sum { c in 1..6} Q[i,c]*sum { j in 1..6}  Mb[c,j]*x[j,k])' ];
int = 'a[0]=1 ';
system_active = ['sum { j in 0..N-1} a[j] =  N - ' ...
                  '(n_full_maintenance + n_partial_maintenance )'];
full_maintenance_active= 'sum { j in 0..N-1} f[j] =  n_full_maintenance';
Partial_maintenance_active = 'sum { j in 0..N-1} p[j] =  n_partial_maintenance';
one_active = ' a[j] + f[j] + p[j] = 1 ';
initial_values_constraints = 'x[i,0] = initial_values[i]'    ;



ampl.defineCons("dynamics",dynamics,"i in 1..6, k in 0..N-1" );
ampl.defineCons("int",int);
ampl.defineCons("system_active",system_active)
ampl.defineCons("full_maintenance_active",full_maintenance_active)
ampl.defineCons("Partial_maintenance_active",Partial_maintenance_active)
ampl.defineCons("one_active",one_active,"j in 0..N-1")
ampl.defineCons("initial_values_constraints",initial_values_constraints,"i in 1..6")


% set values
 N = 10 ;
 n_full_maintenance   =  1  ;
 n_partial_maintenance =  2;
 Ts = 1; %  one hour  
 initial_values        = [  1 0 0 0 0 0] ;%  intial values

 Q =  [0.99999967075480389    0.0049875199849479255   0.000999500001931637     0 0 0 
       2.9925119909687547E-7  0.99501247994018693     1.4970037065390959E-10   0 0 0
       1.1994000023179647E-8  2.9940074130781927E-11  0.999000499839371        0 0 0   
       8.6399985765747359E-9  2.1564042584720887E-11  4.3185598853904993E-12   1 0 0
       5.7599990510498259E-9  1.4376028389813928E-11  2.8790399235936667E-12   0 1 0
       3.599999406906139E-9   8.9850177436337E-12     1.7993999522460411E-12   0 0 1];
						  	  
			  
 Ma  = [      1  0  0  0  0  0 
	          0  1  0  0  0  0 
	          0  0  1  1  1  0
	          0  0  0  0  0  0  
	          0  0  0  0  0  0 
	          0  0  0  0  0  1];
										  
										  
 Mb =   [    1  0  0  0  0  0 
             0  1  0  0  0  0 
	         0  0  1  1  0  0
	         0  0  0  0  0  0  
	         0  0  0  0  1  0 
	         0  0  0  0  0  1]; 

 % defind the data
ampl.assignParam("N  n_full_maintenance n_partial_maintenance Ts",[N n_full_maintenance n_partial_maintenance Ts])
ampl.assignParam("initial_values",initial_values)
ampl.assignParam("Ma",Ma)
ampl.assignParam("Mb",Mb)
ampl.assignParam("Q",Q)s

%% solve the optimization problem 
ampl.eval('option show_stats 1;')
ampl.solve

%% Harvest the results 
% check the value of N
ampl.getParamValue("N")
ampl.getParamValue("initial_values")
ampl.getParamValue("Ma")
[a, index,rowdata] = ampl.getVarValue("a");
f = ampl.getVarValue("f");
x = ampl.getVarValue("x");
x1 = x(1,:)';


% objective function 
 [value, astatus,result,exitcode,message,expandCost] = ampl.getObj('cost_function')
