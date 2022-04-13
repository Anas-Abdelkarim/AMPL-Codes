% to extract data from the string containing the indexes and the data
if isempty(data)
        myValue =[];
        myIndex =  [];
        rowData = [];
else

    dataString = split(data.getValues.toString);
    dataString = dataString(strlength(dataString)>0); % discard the empty cells

    dataLength = length(dataString);


    if dataLength==2
        myValue = dataString{2};
        myIndex =  1;
        rowData = myIndex;
    else
        % find first "|"
        markIndex = find(strcmp(dataString,'|'));
        rowDataLength = markIndex(1);
        rowData(:,rowDataLength) =  dataString(markIndex+1);
        for l = 1 : rowDataLength-1
            rowData(:,l) =  dataString(markIndex-(markIndex(1)-l));
        end

         myValue =str2num(char(rowData(2:end,end))); % to convert to the matrix

        % process the remaining columns of myIndexes
        reshapeMatrix = zeros(1,rowDataLength-1);
        for l = 1 : rowDataLength-1
            myIndex{l} =unique(rowData(2:end,l));
            reshapeMatrix(l) = length(myIndex{l});
        end

        try
            myValue = reshape(myValue,flip(reshapeMatrix))'; %flip transpose was need because reshape fills virtically 
        end
    end

end




%{
% extract the parameters and the variables from the table
TableVariableNames  = myTable.Properties.VariableNames;

if length(TableVariableNames)==1
    myValue = cell2mat(myTable.Variables);
    myIndex =  1;
elseif length(TableVariableNames)==2
    myCell = myTable.Variables;
    myValue = [myCell{:,2}]';
    myIndex  = myTable.index0;
else 
    myCell = myTable.Variables; % convert the table to cell
    myValue = [myCell{:,end}]'; % extract the values as vector
    myIndexes = {};
    for k = 0: length(TableVariableNames)-2 % extract the indexes
        myIndexes =[myIndexes eval("(myTable.index"+k+")")]; 
    end
    % to reshape the value as matrix if possible
    % convert all cells to char
    myIndexesChar = cellfun(@(x) num2str(:,:), myIndexes)
    myIndexesSize = size(myIndexes); 
    temp = cell(myIndexesSize);
    reshapeMatrix = zeros(1,myIndexesSize(2));

    % process the remaining columns of myIndexes
    for l = 1 : myIndexesSize(2)
        try % if the cells are char works
        uniqueColumn =unique(myIndexes(:,l)); 
        catch

        end
        reshapeMatrix(l) = length(uniqueColumn);
        temp(1:reshapeMatrix(l),l) = uniqueColumn;
    end
    try 
    myValue = reshape(myValue,reshapeMatrix);
    myIndexes = temp; 
    end    
end
%}
