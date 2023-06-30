function flag = iszero(input) % Example value (can be a number or a string)
[n_row, n_col] = size(input);
if ~isnumeric(input) &&  (ischar(input) ||isstring(input))
    input =   str2double(input);
end
flag = false([n_row, n_col]);
for x = 1 : n_row
    for y = 1:n_col
        flag(x,y) = input(x,y) ==0;
    end
end


end