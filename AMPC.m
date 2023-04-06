%{
This is a child class designed to extend the functionality of AMPL to support matrices and vectors.
To use this class, it's important to ensure that the following steps are taken:
1) Add this file to the MATLAB's search path so that it can be accessed by other programs.
2) Ensure that the AMPL class exists in a folder located one level back from the AMPC folder. This will allow the child class to properly interface with the AMPL class and provide the desired matrix and vector support.
%}
classdef AMPC < AMPL


    methods

        function obj = AMPC(path)
            obj@AMPL(path)
        end


        function show(self, varargin)
            if size(varargin) > 0
                c = toJava('com.ampl.Entity', varargin{:});
                self.impl.show(c)
            else
                error('Not enough arguments')
            end
        end

        function expand(self, varargin)
            if size(varargin) > 0
                c = toJava('com.ampl.Entity',varargin{:});
                self.impl.expand(c)
            else
                error('Not enough arguments')
            end
        end

        function display(self, varargin)
            if ((size(varargin) > 0) & (~strcmp(varargin{1} ,'ampl')))
                c = toJava('java.lang.Object', varargin{:});
                self.impl.display(c)
            else
                self.impl.getOption('version')
            end
        end



        function result = getData(self, varargin)
            % Get data in a DataFrame
            %
            % **Syntax**
            % ``df = getData(displayExpressions)``
            %
            % **Description**
            % ``df = getData(displayExpression)``  Get the data corresponding to the display statements in a :mat:class:`DataFrame`.
            % The statements can be AMPL expressions or entities. It captures the equivalent of the command:
            % ``display ds1, ..., dsn;`` where ``ds1, ..., dsn`` are the members of the cell array passed to the function.
            % As only one DataFrame is returned, the operation will fail if the results of the display statements cannot be indexed
            % over the same set. As a result, any attempt to get data from more than one set, or to get data for multiple parameters
            % with a different number of indexing sets will fail.
            if size(varargin) > 0
                result = DataFrame(-1, self.impl.getData(varargin));
            else
                error('Not enought arguments')
            end
        end

        function result = getValue(self, tString1)
            % GETVALUE Get data of a scalar expression
            %   result = getValue(self, tString1) get the value of the AMPL
            %             expression in the string tString1
            result = self.impl.getValue(tString1);
        end


        function result = cd(self, varargin)
            if(size(varargin)>1)
                error('Too many arguments')
            end
            if size(varargin) > 0
                result = self.impl.cd(varargin(1));
            else
                result = self.impl.cd();
            end
        end

        function result = getConstraint(self, name)
            v = self.impl.getConstraint(name);
            if(isempty(v))
                result = [];
            else
                result = string(v);
                try
                    result = evalc(sprintf("self.eval('expand %s;')", name))+...
                        """"""""""""""""""""""""""""""""""""""""""""""""""""""+...
                        newline+ result+ newline+...
                        """"""""""""""""""""""""""""""""""""""""""""""""""""""






                end
            end
        end

        function result = getVariable(self, name)
            v = self.impl.getVariable(name);
            if(isempty(v))
                result = [];
            else
                result = Variable(v);
            end
        end

        function result = getObjective(self, name)
            v = self.impl.getObjective(name);
            if(isempty(v))
                result = [];
            else
                result = Objective(v);
            end
        end

        function result = getSet(self, name)
            v = self.impl.getSet(name);
            if(isempty(v))
                result = [];
            else
                result = Set(v);
            end
        end

        function result = getParameter(self, name)
            v = self.impl.getParameter(name);
            if(isempty(v))
                result = [];
            else
                result = Parameter(v);
            end
        end

        function result = getEntity(self, name)
            v = self.impl.getEntity(name);
            if(isempty(v))
                result = [];
            else
                if(isa(v, 'com.ampl.Parameter'))
                    result = Parameter(v);
                else if(isa(v, 'com.ampl.Set'))
                        result = Set(v);
                else if(isa(v, 'com.ampl.Variable'))
                        result = Variable(v);
                else  if(isa(v, 'com.ampl.Constraint'))
                        result = Constraint(v);
                else if(isa(v, 'com.ampl.Objective'))
                        result = Objective(v);
                end
                end
                end
                end
                end
            end

        end


        function result = getConstraints(self)
            v = self.impl.getConstraints;
            result = EntityMap(v);
        end

        function result = getVariables(self)
            v = self.impl.getVariables;
            result = EntityMap(v);
        end

        function result = getObjectives(self)
            v = self.impl.getObjectives;
            result = EntityMap(v);
        end

        function result = getParameters(self)
            v = self.impl.getParameters;
            result = EntityMap(v);
        end

        function result = getSets(self)
            v = self.impl.getSets;
            result = EntityMap(v);
        end


        function setData(self, varargin)
            % SETDATA  sets the data from a DataFrame to the corresponding AMPL
            % entities
            % SETDATA(df) sets the data in the DataFrame df to the
            % corresponding entities. Does not assign the values in the
            % indexing columns.
            % SETDATA(df, 'setname')  sets the data in the DataFrame df to the
            % corresponding entities, including the indexing columns which
            % will be joined in a tuple and assigned to the AMPL set
            % "setName".

            try
                if(nargin > 3)
                    error('Too many arguments')
                end
                if nargin > 2
                    self.impl.setData(varargin{1}.impl, varargin{2});
                else
                    self.impl.setData(varargin{1}.impl);
                end
            catch e
                HandleException(e, 'AMPLAPI:AMPL:setData');
            end
        end
        %% customized codes
        function defineVar(self, dataName, indexRange, attribute)
            % e.g. ampl.defineVar(dataName,indexRange,attribute)
            % This function is used to define the variables  for the
            % optimization problem in ampl language
            % for more information, use the command:   help DenfineData
            dataType = "var";
            if ~exist('attribute','var')
                attribute = "";
            end
            if ~exist("indexRange",'var')
                indexRange = 1;
            end
            results  = defineData(dataType, dataName, indexRange, attribute);
            printResultsFlag = true; % print on the screen
            if printResultsFlag
                fprintf(results)
                fprintf(newline)

            end
            self.eval(results)
        end

        function defineParam(self,dataName,indexRange,attribute)
            % e.g. ampl.defineParam(dataName,indexRange,attribute)
            % This function is used to define the parameters for the
            % optimization problem in ampl language
            % for more information, use the command:   help DenfineData
            dataType = "param";
            if ~exist('attribute','var')
                attribute = "";
            end
            if ~exist("indexRange",'var')
                indexRange = 1;
            end
            results  = defineData(dataType, dataName, indexRange, attribute);
            printResultsFlag = true; % print on the screen
            if printResultsFlag
                fprintf(results)
                fprintf(newline)

            end
            self.eval(results)
        end


        function defineSet(self, setName, setMembers, attributes)
            % e.g ampl.defineSet('k','1..4 by 2') % k = {1, 3}
            % e.g ampl.defineSet('k', [1,5,6]) % k = {1, 5, 6};
            % this function create a set with a give name and
            % attributes : ordered
            if ~exist('attributes','var')
                attributes = "";
            end
            if isnumeric(setMembers)
                setMembers = string(setMembers);
                setMembers(1:end-1) = setMembers(1:end-1) +',';
                setMembers = "{" + strjoin(setMembers)+ "}";
            end
            results = "redeclare set "+ setName + ":= " +...
                setMembers+ " " + attributes + ";";
            printResultsFlag = true; % print on the screen
            if printResultsFlag
                fprintf(results)
                fprintf(newline)

            end
            self.eval(results)

        end



        function defineCons(self, consName, data, indexRange)
            % e.g. ampl.defineCons(consName,data,indexRange)
            % This function is used to define the constraints for the
            % optimization problem in ampl language
            % for more information, use the command:   help DenfineOp
            description = "constr";
            if ~exist("indexRange",'var')
                indexRange = 1;
            end
            results = defineOP(description, consName, data, indexRange);
            printResultsFlag = true; % print on the screen
            if printResultsFlag
                fprintf(results)
                fprintf(newline)

            end
            self.eval(results)
        end


        function defineObj(self, description, objName, data, indexRange)
            % e.g ampl.defineObj(description,objName,data,indexRange)
            % This function is used to define the Objective function for the
            % optimization problem in ampl language
            % for more information, use the command:   help DenfineOp
            if ~exist("indexRange",'var')
                indexRange = 1;
            end
            results = defineOP(description, objName, data, indexRange);
            printResultsFlag = true; % print on the screen
            if printResultsFlag
                fprintf(results)
                fprintf(newline)

            end
            self.eval(results)
        end

        function assignParam(self, paramName, data, indexValue)
            % e.g. ampl.assignParam(paramName,data)
            % This function is used to assign the value of the parameter in
            % the optimization problem
            % for more information, use the command:   help assignParam
            if ~exist("indexValue","var")
                indexValue = 'default';
            end

            if strcmp(indexValue,"auto") % to exatract the sets of the paramerter for auto mode
                sets= self.getParameter(paramName).getIndexingSets;
                if isempty(sets)
                    indexValue = 'default';
                else
                    indexValue = strings(1,length(sets));
                    for i = 1 : length(sets)
                        inIndex = strfind(sets{i},' in ');
                        if isempty(inIndex)
                            setName = sets{i};
                        else
                            setName = extractAfter(sets{i},' in ');
                        end
                        setValues =evalc(sprintf("self.display('%s')",setName));
                        setValues = extractAfter(setValues,'=');
                        setValues = strrep(setValues,';',' ');
                        setValues = strrep(setValues,newline,' ');
                        setValues = eval("[" + string(setValues) + "]");
                        setValues = sort(reshape(setValues,1,[]));
                        indexValue(i) = "[" + join(string(setValues)) + "]";
                    end
                end
            end

            results = assignParam(paramName, data, indexValue);

            printResultsFlag = true; % print on the screen
            if printResultsFlag
                fprintf(results)
                fprintf(newline)
            end
            self.eval(results)
            % check if the assigned values within its constraints
            check_message = evalc(sprintf("self.display('%s')",paramName));
            if  contains( check_message , 'failed check' )
                error(check_message)
            end
        end

        function [myValue, myIndex, dataStringRow] = getParamValue(self, paramName)
            % e.g. [myValue, myIndex,dataStringRow]= ampl.getParamValue(paramName)
            data = self.getParameter(paramName);
            dataExtractFunc
        end

        function [values row_data] = getSetValue(self, setName)
            % e.g. [myValue]= ampl.getVarValue(varName)
            data = self.getSet(setName);
            if isempty(data)
                resutls = [];
            else
                row_data = data.getValues.toString;
                dataSplit = split(row_data);
                dataSplit = dataSplit(strlength(dataSplit)>0); % discard the empty cells
                dataSplit = dataSplit(2:end);
                if isempty(dataSplit)
                    values = "empty set";
                else
                    values = string(dataSplit);
                    values(1:end-1) = values(1:end-1)+", ";
                    values = join(values');
                end
            end


        end

        function [myValue, myIndex,dataStringRow] = getVarValue(self, varName)
            % e.g. [myValue, myIndex,dataStringRow]= ampl.getVarValue(varName)
            data = self.getVariable(varName);
            dataExtractFunc
        end

        function [value, astatus, result, exitcode, message, expandCost] = getObj(self, objName)
            % e.g. [value, astatus,result,exitcode,message,expandCost] = ampl.getObj(varName)
            objClass = self.getObjective(objName);
            value = objClass.value ;
            result = objClass.result;
            astatus = objClass.getValues('astatus');
            exitcode = objClass.exitcode ;
            message  = objClass.message ;
            expandCost =  objClass.get ;
        end

        function [results names]= expandSets(self)
            % e.g. [results names]= ampl.expandSets()
            Temp = self.getSets;
            names = Temp.toString ;
            names = extractAfter(names, ":");
            if isempty(names)
                results = names;
            else
                namesSplit = split(names);
                namesSplit = namesSplit(strlength(namesSplit)>0);
                results = "";
                for c = 1 : length(namesSplit)
                    Temp2 = self.getSet(namesSplit{c}).toString;
                    Temp3 = self.getSetValue(namesSplit{c})+newline;
                    results = [results; '------------------------------------------------------------------------------------------------------'; ...
                        newline; string(Temp2); newline; string(Temp3); ];
                end
            end
            results = join(results);
        end

        function [results names]= expandObjs(self)
            % e.g. [results names]= ampl.expandObjs()
            Temp = self.getObjectives;
            names = Temp.toString;
            marker = strfind(names, ":");
            if isempty(marker)
                results = names;
            else
                names = split(names(marker+3:end-1));
                results = string(newline);
                for c = 1 : length(names)
                    Temp2 = self.getObjective(names{c});
                    results = [results; '------------------------------------------------------------------------------------------------------'; ...
                        newline; string(Temp2.toString); newline; string(Temp2.get.toString)];
                end
            end
            results = join(results);
        end


        function [results names]= expandCons(self)
            % e.g. [results names]= ampl.expandCons()
            Temp = self.getConstraints;
            names = Temp.toString ;
            marker = strfind(names, ":");
            if isempty(marker)
                results = names;
            else
                names =split(names(marker + 3 : end - 1));
                results = string(newline);
                for c = 1 : length(names)
                    Temp2 = string(self.impl.getConstraint(names{c}));
                    Temp3 = evalc(sprintf("self.eval('expand %s;')", names{c}));
                    results = [results; '------------------------------------------------------------------------------------------------------'; ...
                        newline+ Temp2+ newline+ newline+ string(Temp3)];
                end
            end
            results = join(results);
        end


        function [results names]= expandParams(self)
            % e.g. [results names]= ampl.expandParams()
            Temp = self.getParameters;
            names = Temp.toString;
            marker = strfind(names, ":");
            if isempty(marker)
                results = names;
            else
                names = split(names(marker + 3 : end - 1));
                results = string(newline);
                for c = 1 : length(names)
                    try
                        Temp2 = self.getParameter(names{c}).toString;
                        [~,~,Temp3] = self.getParamValue(names{c});
                    catch ME
                        Temp3 =  splitlines(getReport(ME));
                        Temp3 = Temp3{2} + string(newline);
                    end
                    results = [results; '-------------------------------------------------------------------------------------------------------';...
                        newline ;   string(Temp2);     newline ;string(Temp3);];
                end
            end
            results = join(results);
        end



        function [results names]= expandVars(self)
            % e.g. [results names]= ampl.expandVars()
            Temp = self.getVariables;
            names = Temp.toString ;
            marker = strfind(names, ":");
            if isempty(marker)
                results = names;
            else
                names =split(names(marker + 3 : end - 1));
                results = string(newline);
                for c = 1 : length(names)
                    try
                        Temp2 = self.getVariable(names{c}).toString;
                        [~,~, Temp3] = self.getVarValue(names{c});
                    catch ME
                        Temp3 =  splitlines(getReport(ME));
                        Temp3 = Temp3{2} + string(newline);
                    end
                    results = [results; '------------------------------------------------------------------------------------------------------';...
                        newline ;string(Temp2); newline ;string(Temp3);];
                end
            end
            results = join(results);
        end

        function results = expandAll(self,filename)
            % e.g, results = expandAll(self,filename)
            results = [self.expandSets;self.expandParams;
                self.expandObjs;self.expandCons;
                self.expandVars];
            printResultsFlag = false; % print on the screen
            if printResultsFlag
                disp(results)
                disp(newline)
            end
            results = join(results);
            if ~exist('filename','var')
                filename = 'expandAll';
            else
                filename = "expandAll_"+filename;
            end
            fileID = fopen(filename + ".txt",'w');
            fprintf(fileID, results);
            fclose(fileID);
        end

        %

        %  exitcode = ;
        %  message = ;



    end

    %%


end
