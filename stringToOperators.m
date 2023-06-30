function output = stringToOperators(input)
input = " ( a +b + ( c+ d))"

if ischar(input)
    input = char(input)
end

k = strfind(input,'(')