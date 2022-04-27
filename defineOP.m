function results = DefineOP(description,name,data,indexRange)
% e.g.   def("max","cost", sum' 10000/(2*N)*sum { k in 0..N-1} x[3,k])
% This function is used to define the objective function and the constraints
% for the optimization problem in ampl language
% description is either min to minimize the cost function
% max to maximize the cost function or constr to define the constraints
% e.g the give a name for the cost and the constraints
% data is the string that mathmatically decribes the cost or the constraints
% indexRange =  1 or empty of scaler data
% indexRange = x, where x>=1 for vector
% indexRange = [x1,"x2..x3",...] for multi dimensional data
% and 1 is automatically removed in multi dimenstional data
% x1, x2, and x3 are integers>1
%  e.g indexRange = 5, [1,5], [5,1] , [ 5,1,1], [1,5,1] are the same
% e.g indexRange = [2,4], [2,1,4], [1,2,1,4,1] ,  are the same
% e.g indexRange = [2,"3..6"], means tow dimensional data. first dimension
% e.g indexRange = [2,"i in 1..N", "A"];, where A is a predefined set
% and the first dimension ranges for 1 to 2
% and the second dimension ranges from 1 to N


% reference manual of the ampl,for more information, at link:
% https://ampl.com/BOOK/CHAPTERS/24-refman.pdf
%


% arguments
%     description  {mustBeMember(description,["min","max","constr"])}
%     name  char
%     data  char
% end

if ~exist('indexRange','var')
    indexRange =1;
end
    
if ~(isstring(name) || ischar(name) )
    name
    error("name must be char")
end

if ~(isstring(data) || ischar(data) )
    data
    error("data must be char")
end


% check the dataTypes
if ~(strcmp(description,"min") ||strcmp(description,"max") ||strcmp(description,"constr"))
    description;
    error("Decription must be min, max or constr ")
end

switch description
    case "min"
        detailedDescribtion = "minimize";
    case "max"
        detailedDescribtion = "maximize";
    case "constr"
        detailedDescribtion = "subject to";
end

if isvarname(name)==0
    name
   % error("Choose  valid dataNames: no comma, semicolon or special characters except underscore")
end

%% process the indexRange
createSetAsString

%% results
%amplcommand = "" ;
amplcommand =  "redeclare";



if ~isvector(data)
    data
    error('The data should be a vector ')
end 

if length(data)>1
   name =name + "_" + [1:length(data)]';  
end 

results = amplcommand +" "+ detailedDescribtion +" "+ name +" "+setAsString+": "+ data+ "; ";
results = strcat(results{:})



end