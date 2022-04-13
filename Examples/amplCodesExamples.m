% vist the url: https://ampl.com/api/latest/matlab/classes/matlabAMPL.html#AMPL.getVariables
clear all

amplPathDir = 'D:\programs\ampl.mswin64';
run(amplPathDir + "\amplapi\matlab"+  "\setUp.m")
ampl = AMPL(amplPathDir);

switch 1
    case 1
        ampl.read(['D:\programs\AMPL\Optimal-scheduling_example/Model2.mod']);
        ampl.readData(['D:\programs\AMPL\Optimal-scheduling_example/DATA2.dat']);
    case 2
        ampl.read(['D:\programs\ampl.mswin64\amplapi\examples\models\diet\diet.mod']);
        ampl.readData(['D:\programs\ampl.mswin64\amplapi\examples\models\diet\diet.dat']);
    case 3
        ampl.eval('var x{i in 1..2} <= i;');
        ampl.eval('maximize z{i in 1..2}: x[i];');
        z = ampl.getObjective('z');
        instance = z.get(1);
        ampl.solve;
        instance.value
        instance.result
        instance.message

end
tic 
ampl.solve
toc
totalcost_results = ampl.getValue('cost_function')
y = ampl.getParameter('initial_values')
y.getValues
y.impl.hasIndexing
% objective
% method 1
ObjectiveNames  = ampl.getObjectives();

ObjectiveFucntion = ampl.getObjective('cost_function'); % to read the objective function 
%totalcost_results = ObjectiveFucntion.value('z[1]');
%totalcost_results = ObjectiveFucntion.get(1);
df = ObjectiveFucntion.getValues('val', 'astatus', 'result', 'exitcode','message');

% method 2
totalcost_results = ampl.getValue('Total_Cost'); % to get the objective function value (scalar)
% in general
ampl.display(ObjectiveFucntion) % only to display it on the consule
ampl.display('cost_function') % only to display it on the consule

% to expand the cost function
ampl.expand(ObjectiveFucntion)
ampl.eval('expand cost_function; ')
% constraints
ampl.getParameters()


% paramaters
allParametersNames =  ampl.getParameters(); % the names of all variables



% variables
allVaribalesNames =  ampl.getVariables(); % the names of all variables
buy = ampl.getVariable('a');
df = buy.getValues;
dataDefine("param","t dsf df ",1,"sfa")
allSetsNames =  ampl.getSets(); % the names of all sets 

% how to set the paramets:
% to set the value for the first time 
ampl.eval("data; param N := 8;")
N_ampl = ampl.getParameter('N')
N_ampl_dataFrame = N_ampl.getValues
ampl.setData(y)

N_ampl = ampl.getVariable('a')
N_ampl_dataFrame = N_ampl.getValues

%ampl.close