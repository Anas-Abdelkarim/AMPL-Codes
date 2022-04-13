function  results = multiply(varargin)
% e.g  results = multiply("x.T[1..2, k]", 'Q1[1..2, 1..2 ]', "x[ 1..2, k]")
% this function multiplies matrices of string array for ampl program
% example for the inputs arguments
% 1- 'R' for scalar %  do not use 'R[1..1]' if R has no indexes in AMPL
% 1- 'x.T[k , 0 . . 2  ]', .T for transpose , create vector of indexes 0 ,1,2 , k is constant no thing to do with the matrix indexes
% 2- 'Q1[0..2,m,k, 2..5 ]', create matrix of row indexes 0 ,1,2 and column indexes from 2 to 3  m, and k is constant no thing to do with the matrix indexes
% m where m is a numeric array 



% number of inputs
numInputs =  length(varargin);

for k = 1 : numInputs
    try  % if it is alread expaned
    [stringArray{k}, arraySize{k}]  =  expand(varargin{k});
    catch
      stringArray{k} = varargin{k};
      arraySize{k} =size(varargin{k});
    end

end

for k = 1 : numInputs - 1
    if k == 1
        [results resutlsSize] = multiply2stringArrays(stringArray{k},stringArray{k+1},arraySize{k},arraySize{k+1});
    else
        [results resutlsSize] = multiply2stringArrays(results,stringArray{k+1},resutlsSize,arraySize{k+1});
    end
end

end


function [results arraySizeResult] =multiply2stringArrays(stringArray1,stringArray2,arraySize1,arraySize2)
% this function multiplies matrices of string array for ampl program
% stringArrayIn1(2) first and second stringArrays
% arraySizeIn1(2) the size of the   stringArrayIn1(2)


% check the output size
if  arraySize1(2)~= arraySize2(1)
    error( ['Incorrect dimensions for matrix multiplication. Check that the number of columns in the first matrix matches the number of rows in the second' ...
        ' matrix.'])
end


% the size of the resulted array
arraySizeResult = [arraySize1(1) arraySize2(2)];

% create empty array
results = strings(arraySizeResult);
stringArray1 = stringArray1+"*";
stringArray2(1:end-1,:) = stringArray2(1:end-1,:)+"+";

for i = 1 : arraySizeResult(1) % row loop
    for j = 1: arraySizeResult(2) %column loop
        results(i,j) = join(stringArray1(i,:)+ stringArray2(:,j)');
    end
end
results = "(" + results + ")";

end



