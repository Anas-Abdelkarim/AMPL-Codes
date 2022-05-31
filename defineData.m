function results = defineData(dataType,dataName,indexRange,attribute)
% e.g.   defineData("param","param1 param2",5,"integer >0")
% This function is used to define the parameters and variables  for the
% optimization problem in ampl language
% dataType is either var or param
% it is possible to define group of parameters or variables with the same
% attributes and the same dataSize
% e.g dataName = "var1", = "var1 var2 var3 var4";
% attirbute (optional) is the attribute the paramerter or teh variable, check the
% reference manual of the ampl,for more information, at link:
% https://ampl.com/BOOK/CHAPTERS/24-refman.pdf
% e.g. attribute = "integer", = "binary", "integer >= 0", " >=6"
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


% arguments
%     dataType  {mustBeMember(dataType,["var","param"])}
%     dataName  char
%     dataSize
%     attribute
% end


% check the dataTypes
if ~(strcmp(dataType,"var") ||strcmp(dataType,"param"))
    dataType
    error("dataType must be var or param")
end

if ~exist('attribute','var')
    attribute ="";
end


%% build set string
createSetAsString


%% processing the varible names
dataNames =  split(dataName);
if isempty(dataNames{end}) % to delete the last empty varible
    dataNames(end) = [];
end

% check if the data names are valid
if  min(cellfun(@isvarname,dataNames))==0
    dataNames
    error("Choose  valid dataNames: no comma, semicolon or special characters")
end

%% results
if true
    amplcommand =  "redeclare";
    results = amplcommand +" "+ dataType +" "+ dataNames + setAsString  +" "+ attribute+ "; ";
    results =  strcat(results{:});
else
    amplcommand =  "";
    results = amplcommand +" "+ dataType +" "+ dataNames + setAsString  +" "+ attribute+ "; ";
    results = "model; " + strcat(results{:});
end
%amplcommand = "" ;




end