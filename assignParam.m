function results = paramSet(paramName,data,vector_flag)
% This function is used to feed the parameters values  for the
% optimization problem in ampl language
% variable_name should match with the name defined in the model part
% it is possible to feed the values for a group of scalar parameters
% to do so, define the variable_name as array vector and the data as well
% vector flag is optional to force defining a scalar as a  vector by
% keeping an index for the  parameter
% e.g. variable_name = ['param1 param2']; data = [1,2] 
% ---> results = paramSet(variable_name,data)
% e.g,  results = paramSet('Ts',5)
% e.g,  results = paramSet('A',[1 2 ; 5 6])
% e.g, results = paramSet('A[2,2]',5) to change only one element in the vector 
% e.g, results = paramSet('B',2,true) this to indicate the B has index 1; 

if ~exist("vector_flag","var")
    vector_flag = false;
elseif ~islogical(vector_flag)
    error('vector_flag takes values only false or true')
end 
 

data_precision = 1000;

paramName =  split(paramName);
if isempty(paramName{end}) % to delete the last empty varible
    paramName(end) = [];
end


if  length(paramName) ==1 % means it constains names of multiple paramerters names
    multipleNamesFlag = false;
else
    multipleNamesFlag = true;
    if isrow(data)
        data =data';  % to treat the vector as matrix
    end  
end
if iscolumn(data) & ~multipleNamesFlag
    data =data';  % to treat the vector as matrix
end

dataSize = size(data);
amplCommand1 = "data ; param "; % this can be use only one time for non assigned parameters 
amplCommand2 = "let "; % this can be used to scalar  values
% note for let command it can use for indexes as follow 'let {i in 1..2, j
% in 2 ..3} Q[i,j]:= 5;' it will assign  all elements as 5
amplCommand3 = strcat(" update data",paramName,';',"data; param "); % to update the variable name (it seems that the ampl can remember the old assigment)
amplCommand4 = strcat(" reset data ",paramName,';',"data; param "); % delete all assigment of the variables


amplCommand =  amplCommand4;



if length(dataSize) <= 2

    if (max(dataSize)==1 || multipleNamesFlag) && ~vector_flag
        results = strcat(amplCommand,paramName, ' := ', num2str(data), ';' );
        if multipleNamesFlag
            results =  strcat(results{:});
        end 
    else
        row_indexes = 1:dataSize(1);
        column_indexes = 1:dataSize(2);
        column_indexes_str = mat2str(column_indexes);
        column_indexes_str = column_indexes_str(2:end-1);
        if isempty(column_indexes_str);
            column_indexes_str = '1';
        end
        Temp1 = [row_indexes' data ];% add the row_indexes to the data and convert to string
        Temp2 = mat2str(Temp1) ;   % convert to string
        Temp3 = replace(Temp2(2:end-1),';'," ");
        results =  strcat(amplCommand,paramName, " : ",  column_indexes_str,' := ',Temp3, ';' ) ;
    end

elseif length(dataSize) == 3
    data_str = "";
    for i = 1 : dataSize(1)
        for j = 1 : dataSize(2)
            for k = 1 : dataSize(3)
                data_str = strcat(data_str," ",   ...
                                  num2str(i)," ", ...
                                  num2str(j)," ", ...
                                  num2str(k)," ", ...
                                  num2str(data(i,j,k)));
            end
        end
    end
    results =  strcat(amplCommand,paramName, ' := ',data_str, ';' ) ;

elseif length(dataSize) == 4
    data_str = "";
    for i = 1 : dataSize(1)
        for j = 1 : dataSize(2)
            for k = 1 : dataSize(3)
                for l = 1 : dataSize(4)
                    data_str = strcat(data_str  ," ", ...
                                      num2str(i)," ", ...
                                      num2str(j)," ", ...
                                      num2str(k)," ", ...
                                      num2str(l)," ", ...
                                      num2str(data(i,j,k,l)));
                end
            end
        end
    end
    results =  strcat(amplCommand,paramName, ' := ',data_str, ';' ) ;


else
    error('Data dimention is more than  4; set the paramerter manually or modify the aasignParam code to include higher dimentions')

end
end