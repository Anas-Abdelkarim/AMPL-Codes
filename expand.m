function stringArray  =  expand(varargin)
% this function converts the matrix to the array of strings
% or expand a vector or matrix
% the input is either string or matrix
% example for the inputs as a string
% 1- 'x.T[k , 0 . . 2  ]', .T for transpose , create vector of indexes 0 ,1,2 , k is constant no thing to do with the matrix indexes
% 2- expand('Q1[0..2,m,k, 2..5 ]'), create a matrix of row indexes 0 ,1,2 and column indexes from 2 to 3  m, and k is constant no thing to do with the matrix indexes
% 3- expand('x.T[%u..%u, k]',0,2)
% 4- expand('u[1..%u, k]',1) here the output is scalar e.g. u
% 5- expand('u[1..%u, k]',1,true) here the output is vector e.g u[1];
% 6- expand('u[@, k]',[1,6]) here the output is vector e.g u[1] u[6];
% 7- expand('u_@',[1,6]) here the output is vector e.g u_1 u_2;
if isnumeric(varargin{1})
    stringArray = varargin{1};
    return
end
%% 1-check how to treat single element: as sclar or vector of size one
if   islogical(varargin{end})
    vector_flag =   varargin{end};
    varargin =  varargin(1:end-1);
else
    vector_flag = false;
end

%% 2- substitutes the variables and the sets
input = varargin{1};
if ischar(input) || isstring(input) % here we need to construct the whole stringArray
    input =string(strrep(input, ' ', '')); % remove the white spaces
    if length(input)> 1 ||(~contains(input,'{') && ~contains(input,'@') && ~contains(input,'..')&& ~contains(input,':'))
        stringArray = input;
        return
    end
    input =char(strrep(input, ' ', '')); % remove the white spaces
    if  numel(varargin) > 1 % to treat the multi input
        input = varargin{1};
        varargin(1) = [];
        input = strrep(input, '@', '{%s}');
        input = strrep(input, '%u', '%s');
        if    count(input, '%s') ~= size(varargin)
            error(input+ ': number of input argument does not match number of the substitutions')
        end
        formattedElements  = cellfun(@formatElement, varargin, 'UniformOutput', false);
        input =   sprintf(input,formattedElements{:});

    end

    %% 2-B replace , to ; inside {}
    pattern = '\{([^{}]+|(?R))*\}';  % Regular expression pattern to match nested curly brackets
    % Find matches of the pattern within the string
    matches = regexp(input, pattern, 'match');

    % Replace commas with semicolons for each match
    for i = 1:numel(matches)
        modified_match = strrep(matches{i}, ',', ';');
        input = strrep(input, matches{i}, modified_match);
    end


    %% 3- check if we need to do traspose at the end
    if contains(input,'.T') % note .T must be directly before [
        TransposeFlag= true;
        input = replaceBetween(input,'.','[', '[' ,'Boundaries','inclusive');
    else
        TransposeFlag = false;
    end



    %% convert the sets
    % find the indexs of the sets
    markPositions =  [ strfind(input,'[') strfind(input,',') strfind(input,']')];

    if length( strfind(input,'[')) ~=  length(strfind(input,']'))
        error(input  + " has a different number of opening and closing square brackets")
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if contains(input,'[')    %% 4- treat bewteen [   ]
        indexes_expand_flag = 1;
    else
        indexes_expand_flag = 0;
    end
    counter = 0;

    sets = {};
    if indexes_expand_flag
        loopLength = length(markPositions) - 1;
    else
        loopLength =numel(matches); % mataches of {}
    end

    for i = 1 : loopLength
        if i >1  && indexes_expand_flag % update mark position
            markPositions =  [ strfind(input,'[') strfind(input,',') strfind(input,']')];
        end
        % extract if there is a set
        if  indexes_expand_flag
            test_part = input(markPositions(i)+1:markPositions(i+1)-1);
            % is there is set
            test_part = strrep(test_part, '..', ':');
        else
            test_part = modified_match;
        end
        test_part = strrep(test_part, '{', '[');
        test_part = strrep(test_part, '}', ']');
        if  contains(test_part, ':') || contains(test_part, '[') ||contains(test_part, ']')
            counter = counter +1;
            if counter >2 && indexes_expand_flag
                error('up to 2D matrix and be expanded')
            end
            if numel(matches) >1 && ~indexes_expand_flag
                error('up to 1D vector and be expanded')
            end
            sets{counter} = eval(test_part);
            if isempty(sets{counter})
                error('the set is empty')
            end


            % trace
            trace = '###s';
            if indexes_expand_flag
                input = strcat(input(1:markPositions(i)),trace,...
                    num2str(counter), input(markPositions(i+1):end));
            else
                input = strrep(input,modified_match, '###s1');
            end
        end
    end


    if isempty(sets)
        warning(input + " is not expandable")
        stringArray = input;
        return;

    end


    % rows

    rowSet = sets{1};
    if counter > 1
        columnSet =  sets{2};
    else
        columnSet = 1 ;
    end

    % builind the string array of the matrix elements
    switch 2
        case 1 % with for loop
            arraySize = [  length(rowSet) , length(columnSet)];
            if counter > 1 % matrix

                unitSring = strrep(input, strcat(trace,'1'), '%d');
                unitSring = strrep(unitSring, strcat(trace,'2'), '%d');

                stringArray = strings(arraySize );
                for i = 1 : arraySize(1)
                    for j = 1 : arraySize(2)
                        stringArray{i,j}= sprintf(unitSring,rowSet(i),columnSet(j));
                    end
                end
            else  % vector
                unitSring =  strrep(input, strcat(trace,'1'), '%d');
                temp =     split(sprintf(unitSring+" ",rowSet));
                stringArray = cellstr(temp(1:end-1)) ;

            end
        case 2

            arraySize = [  length(rowSet) , length(columnSet)];
            unitSring =  strrep(input, strcat(trace,'1'), '%d');
            % first column  with all rows once
            first_column =     split(sprintf(unitSring+" ",rowSet));
            first_column =  first_column(1:end-1); % delete the empty string

            temp  =strrep(first_column, strcat(trace,'2'), '%d');
            temp = repmat(temp,[ 1 arraySize(2)]);
            temp = sprintf(join(join(temp)),repmat(columnSet,[1 length(rowSet)]));
            stringArray = split(temp);
            % reshape
            stringArray = reshape(stringArray,flip(arraySize))';
    end
    if TransposeFlag
        stringArray = stringArray';
    end

    if isscalar(stringArray) && ~vector_flag
        if  contains(stringArray,'[1,')
            stringArray =  replace(stringArray,'[1,',"[");
        elseif  contains(stringArray,',1]')
            stringArray =  replace(stringArray,',1]',"]");
        elseif  contains(stringArray,',1,')
            stringArray =  replace(stringArray,',1,',",");
        else
            stringArray =  replace(stringArray,{'[1]',',1,'},"");
        end
    end

end


    function formattedElement = formatElement(element)
        if isnumeric(element)
            if  numel(element) > 1
                formattedElement = sprintf('%s', strjoin(string(element), ';'));
            else
                formattedElement = sprintf('%d', element);
            end
        else
            error("the inmupt argument is not "+ element)
        end
    end
end
