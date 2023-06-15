function [results, arraySizeResult] =multiply2stringArrays(stringArray1,stringArray2,arraySize1,arraySize2)
% this function multiplies matrices of string array for ampl program
% stringArrayIn1(2) first and second stringArrays
% arraySizeIn1(2) the size of the   stringArrayIn1(2)


% check if we multiply with scalar
if max(arraySize1) == 1 ||  max(arraySize2) == 1
    results =  '((' +  stringArray1 + "*" +  '(' + stringArray2 + '))';
    arraySizeResult = max(arraySize1,arraySize2);
else



    % check the output size
    if  arraySize1(2)~= arraySize2(1)
        error( ['Incorrect dimensions for matrix multiplication. Check that the number of columns in the first matrix matches the number of rows in the second' ...
            ' matrix.'])
    end


    % the size of the resulted array
    arraySizeResult = [arraySize1(1) arraySize2(2)];

    % create empty array
    results = strings(arraySizeResult);
    % to quote the elements with parentheses
    stringArray1 = "(" + stringArray1 + ")" ;
    stringArray2 = "(" + stringArray2 + ")" ;

    stringArray1 = stringArray1+"*";
    stringArray2(1:end-1,:) = stringArray2(1:end-1,:)+"+";

    for i = 1 : arraySizeResult(1) % row loop
        for j = 1: arraySizeResult(2) %column loop
            results(i,j) = join(stringArray1(i,:)+ stringArray2(:,j)');
        end
    end
    results = "(" + results + ")";

end
end



