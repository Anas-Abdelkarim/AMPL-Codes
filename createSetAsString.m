%% to create set as string
if ~exist("indexRange",'var')
    indexRange =1;
end

% double check the indexRange defined correct
if ~(isnumeric(indexRange)||isstring(indexRange)||ischar(indexRange))
    indexRange
    error('indexRange must be numeric e.g. 5, [5,6] or string e.g [5, "1..6"], "2..4" ')
end

indexRange = string(indexRange);% make it strings if it is numeric

indexRange = reshape(indexRange,1,[]);

setAsString = "";
for i = 1 : length(indexRange)      
    indexAsChar = char(indexRange(i)); % convert to char
    %indexAsChar = indexAsChar(~isspace(indexAsChar)); % remove spaces
    if sum(~isstrprop(indexAsChar ,'digit')) == 0 % means indexAsChar is number
        if strcmp(indexAsChar,'1') || strlength(indexAsChar) == 0; % to discard set of 1
            continue
        end
        setAsString = setAsString+ ' i'+ i + ' in 1..'+indexAsChar+",";
    elseif   contains(indexAsChar,'..') && ~contains(indexAsChar,'in')
        setAsString = setAsString+ ' i'+ i + ' in ' + indexAsChar+ ",";
    else
        setAsString = setAsString+" " +indexAsChar+",";

    end
end

    if strlength(setAsString)>0
        setAsString = char(setAsString);
        setAsString = " {" + setAsString(2:end-1) +"} ";
    end

 
