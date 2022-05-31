% to get the indexes of the parameter, still under development
sets= self.getParameter(paramName).getIndexingSets;


if isempty(sets)
    indexValue = 'default';
else
    for i = 1 : length(sets)
        setName = strfind(sets{i},'in')
    end
end