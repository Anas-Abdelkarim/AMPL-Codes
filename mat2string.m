function results = mat2string(input)
if isnumeric(input)
precision = 10000;
    arraySize = size(input);
    string1 =  mat2str(input, precision);
    StringCell = split(string1, {'[', ']',',',';',' '})';
    StringCell = StringCell(strlength(StringCell) > 0); % discar the empty strings
    stringArray =  convertCharsToStrings(StringCell(:));
    results =  reshape(stringArray,flip(arraySize))';
else
    results = string(input);
end 