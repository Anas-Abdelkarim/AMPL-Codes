function results = mat2string(input)
% convert the matrix to string
% example x = mat2string([1 2 ; 6 9 ]
if isnumeric(input)
    precision = 15;
    arraySize = size(input);
    string1 =  mat2str(input, precision);
    StringCell = split(string1, {'[', ']',',',';',' '})';
    StringCell = StringCell(strlength(StringCell) > 0); % discar the empty strings
    stringArray =  convertCharsToStrings(StringCell(:));
    results =  reshape(stringArray,flip(arraySize))';
else
    results = string(input);
end
end
