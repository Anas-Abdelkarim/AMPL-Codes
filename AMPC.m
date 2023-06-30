%{
This is a child class designed to extend the functionality of AMPL to support matrices and vectors.
To use this class, it's important to ensure that the following steps are taken:
1) Add this file to the MATLAB's search path so that it can be accessed by other programs.
2) Ensure that the AMPL class exists in a folder located one level back from the AMPC folder. This will allow the child class to properly interface with the AMPL class and provide the desired matrix and vector support.
%}
classdef AMPC < AMPL  & POPA
    properties
        Editor_flag = 0; % 1 means do not initiate AMPL flag

    end


    methods

        function obj = AMPC(path,POPA_obj)
            obj@AMPL(path)


            obj.AMPL_available = 1; % we are connected to AMPL

            if exist('POPA_obj','var')
                obj.OP = POPA_obj.OP;
                obj.counter = POPA_obj.counter;

                if false          % true for diagnosis mode
                    for k = 1 : length(obj.OP)
                        if k ~= 0                   % start with k~=6
                            try
                                obj.eval(obj.OP(k))                             
                            catch
                                display(obj.OP(k))
                                display("syntax error at k = "+k)
                            end
                        end
                    end

                else
                    obj.eval(join(obj.OP))
                end
            end





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

        function reset(self)
            self.OP = "";
            self.counter = 0;
            self.eval('reset;')
        end


    end

    %%


end
