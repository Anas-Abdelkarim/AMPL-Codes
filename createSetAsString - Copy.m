%% to create set as string
if ~exist("IndexRange",'var')
    IndexRange =1;
end


setString

if ischar(IndexRange)
    setElements = IndexRange + " ";
else
    IndexRange = reshape(IndexRange,1,[]);
    
    if isstring(IndexRange)
     IndexRange(strcmp(IndexRange,"1"))= []  
    else 
    IndexRange(find(IndexRange==1))= [];
    end

    % generat the set
    lengthDataSize = length(IndexRange);

    TempStr = "";
    for i = 1 : lengthDataSize
        TempStr= TempStr + "i"+i+" in 1.."+IndexRange(i)+", ";
    end
    TempStr = char(TempStr);
    if isempty(IndexRange)
        setElements=" ";
    else
        setElements = " {" + TempStr(1:end-2) +"} ";
    end


end