str = 'Hello (world (of (MATLAB)))!';
nestedParentheses = extractNestedParentheses(str);
if  countOpeningParentheses(str) ~= countClosingParentheses(str)
    error('number of opening and closing parentheses must be the same')
end

str = '2 *3 - 1.5 + 4 ^7 /9 + Y^y[11] * yA[1,k] / MyfdK [1,k,5.7] + 5e10';
cell = expressionSplit(str)
re = notationToFunctions(cell);

% Display the extracted nested parentheses
for i = 1:numel(nestedParentheses)
    fprintf('%d: %s\n', i, nestedParentheses{i});
end
function nestedParentheses = extractNestedParentheses(str)
% Use regular expression to match the contents inside nested parentheses
pattern = '\((?>[^()]+|(?R))*\)';
matches = regexp(str, pattern, 'match');

% Remove the outermost parentheses from each match
nestedParentheses = cellfun(@(x) x(2:end-1), matches, 'UniformOutput', false);
end


function count = countOpeningParentheses(str)
count = numel(strfind(str, '('));
end

function count = countClosingParentheses(str)
count = numel(strfind(str, ')'));
end

function result = expressionSplit(str)

% Remove any spaces from the string
str = strrep(str, ' ', '');

% Split the string using regular expressions
result = regexp(str, '(\d+(\.\d+)?e\d+|\d+(\.\d+)?|\+|\-|\*|\/|\^|[a-zA-Z]+\[[\w.,]+\]|[a-zA-Z]+)', 'match');
%result = regexp(str, '[^\s\[\]\^\*\+]+|\*\*|\^+|\[.*?\]', 'match');

end


function result = notationToFunctions(cell)

if strcmp(cell{1},'+') | strcmp(cell{1},'-')
cell{1} = cell{1} +"" + cell{2};
cell(2) = [];

end
   
result = updateExperssion("power(",cell)
result = updateExperssion("multiply(",result)
result = updateExperssion("Ediv(",result)
result = updateExperssion("Emulti(",result)
result = updateExperssion("sum(",result)
result = updateExperssion("subt(",result)
result =result{1};
end

function cell = updateExperssion(function_name,cell)

while true
    switch function_name
        case "power("
            index = find(strcmp(cell, '^') | strcmp(cell, '**'),1);
        case "multiply("
            index = find(strcmp(cell,'*' ),1);

        case "Ediv("
            index = find(strcmp(cell, '/') | strcmp(cell, './'),1);
             if strcmp(cell(index), '/')
                 warning('the operator / is element wise division')
             end 

        case "Emulti("
            index = find(strcmp(cell,'.*' ),1);

        case "sum("
            index = find(strcmp(cell,'+' ),1);
        case "subt("
            index = find(strcmp(cell,'-' ),1);
    end


    if ~isempty(index)
        exp = {function_name+cell{index-1}+','+cell{index+1}+')'};
        cell{index-1} = exp{1};
        cell(index:index+1) =[];
   
    else
        break
    end
end




end


