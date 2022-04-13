
function [ stringArray, arraySize]  =  expand(input)
% this function converts the matrix to the array of strings
% or epand a vector or matrix
% the input is either string or matrix
% example for the inputs as a string
% 1- 'x.T[k , 0 . . 2  ]', .T for transpose , create vector of indexes 0 ,1,2 , k is constant no thing to do with the matrix indexes
% 2- 'Q1[0..2,m,k, 2..5 ]', create a matrix of row indexes 0 ,1,2 and column indexes from 2 to 3  m, and k is constant no thing to do with the matrix indexes
% m where m is a numeric array


if ischar(input) || isstring(input) % here we need to construct the whole stringArray
    input = char(input);

    input = input(~isspace(input)); % remove spaces

    % Transpose flag
    if contains(input,'.T')
        TransposeFlag= true;
        input = replaceBetween(input,'.','[', '[' ,'Boundaries','inclusive');
    else
        TransposeFlag = false;
    end

    %% find the indexs of the sets
    setsPositions = strfind(input,'..');
    markPositions =  [ strfind(input,'[') strfind(input,',') strfind(input,']')];

    % rows
    rowIndexfirst = markPositions(markPositions< setsPositions(1));
    rowIndexfirst = rowIndexfirst(end)+1;

    rowIndexlast = markPositions(markPositions> setsPositions(1));
    rowIndexlast = rowIndexlast(1)-1;

    rowSetString = input(rowIndexfirst:rowIndexlast);
    rowSet = eval(replace(rowSetString,'..',':'));

    if isempty(rowSet)
        input(rowIndexfirst:rowIndexlast)
        error('set shoud be in the form x..y where x<=y integers')

    end

    % columns
    if ~isscalar(setsPositions)
        columnsIndexfirst = markPositions(markPositions< setsPositions(2));
        columnsIndexfirst = columnsIndexfirst(end)+1;

        columnsIndexlast = markPositions(markPositions> setsPositions(2));
        columnsIndexlast = columnsIndexlast(1)-1;

        columnSetString = input(columnsIndexfirst:columnsIndexlast);
        columnSet = eval(replace(columnSetString,'..',':'));

        if isempty(columnSet)
            input(columnsIndexfirst:columnsIndexlast)
            error('set shoud be in the form x..y where x<=y integers')
        end

    else
        columnSetString = '......'; % random
        columnSet = 1 ;
    end

    % builind the string array of the matrix elements
    switch 2
        case 1 % with for loop

            arraySize = [  length(rowSet) , length(columnSet)];
            if ~isscalar(setsPositions) % matrix
                unitSring = replaceBetween(input,columnsIndexfirst,columnsIndexlast,'%d');
                unitSring =  replaceBetween(unitSring,rowIndexfirst,rowIndexlast,'%d');

                stringArray = strings(arraySize );
                for i = 1 : arraySize(1)
                    for j = 1 : arraySize(2)
                        stringArray{i,j}= sprintf(unitSring,rowSet(i),columnSet(j));
                    end
                end
            else  % vector
                unitSring =  replaceBetween(input,rowIndexfirst,rowIndexlast,'%d');
                temp =     split(sprintf(unitSring+" ",rowSet));
                stringArray = cellstr(temp(1:end-1)) ;

            end
        case 2

            arraySize = [  length(rowSet) , length(columnSet)];
            unitSring =  replaceBetween(input,rowIndexfirst,rowIndexlast,'%d');
            % first column  with all rows once
            first_column =     split(sprintf(unitSring+" ",rowSet));
            first_column =  first_column(1:end-1); % delete the empty string

            temp = replace(first_column,columnSetString,'%d');
            temp = repmat(temp,[ 1 arraySize(2)]);
            temp = sprintf(join(join(temp)),repmat(columnSet,[1 length(rowSet)]));
            stringArray = split(temp);
            % reshape
            stringArray = reshape(stringArray,flip(arraySize))';
    end
    if TransposeFlag
        stringArray = stringArray';
        arraySize = flip(arraySize);
    end
else
    precision = 1000;
    arraySize = size(input);
    string =  mat2str(input, precision);
    StringCell = split(string, {'[', ']',',',';',' '})';
    StringCell = StringCell(strlength(StringCell) > 0); % discar the empty strings
    stringArray =  convertCharsToStrings(StringCell(:));
    stringArray =  reshape(stringArray,flip(arraySize))';

end
end