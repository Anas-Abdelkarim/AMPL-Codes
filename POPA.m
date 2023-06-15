classdef   POPA   < handle% prepare the OP for AMPL

    properties
        OP = "";
        counter = 0;
        AMPL_available = 0;
        printResultsFlag = 0; % if want to print on the screen

    end


    methods



        %% customized codes
        function self = update(self,command)
            self.counter = self.counter + 1;
            self.OP(self.counter) = command;

        end

        function results = defineVar(self, dataName, indexRange, attribute)
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
            results = defineData(dataType, dataName, indexRange, attribute);

            if self.printResultsFlag
                fprintf(results)
                fprintf(newline)

            end

            if self.AMPL_available
                self.eval(results)
            end

            % save the results in OP
            results = self.update(results);
        end

        function results = defineParam(self,dataName,indexRange,attribute)
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

            if self.printResultsFlag
                fprintf(results)
                fprintf(newline)

            end


            if self.AMPL_available
                self.eval(results)
            end

            % save the results in OP
            results = self.update(results);

        end


        function results = defineSet(self, setName, setMembers, attributes)
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

            if self.printResultsFlag
                fprintf(results)
                fprintf(newline)

            end



            if self.AMPL_available
                self.eval(results)
            end

            % save the results in OP
            results = self.update(results);

        end



        function results = defineCons(self, consName, data, indexRange)
            % e.g. ampl.defineCons(consName,data,indexRange)
            % This function is used to define the constraints for the
            % optimization problem in ampl language
            % for more information, use the command:   help DenfineOp
            description = "constr";
            if ~exist("indexRange",'var')
                indexRange = 1;
            end
            results = defineOP(description, consName, data, indexRange);

            if self.printResultsFlag
                fprintf(results)
                fprintf(newline)

            end


            if self.AMPL_available
                self.eval(results)
            end

            % save the results in OP
            results = self.update(results);

        end


        function results = defineObj(self, description, objName, costFunction, indexRange)
            % e.g ampl.defineObj(description,objName,data,indexRange)
            % This function is used to define the Objective function for the
            % optimization problem in ampl language
            % for more information, use the command:   help DenfineOp
            if ~exist("indexRange",'var')
                indexRange = 1;
            end
            results = defineOP(description, objName, costFunction, indexRange);

            if self.printResultsFlag
                fprintf(results)
                fprintf(newline)

            end


            if self.AMPL_available
                self.eval(results)
            end

            % save the results in OP
            results = self.update(results);
        end

        function results = assignParam(self, paramName, data, indexValue)
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


            if self.printResultsFlag
                fprintf(results)
                fprintf(newline)
            end
            if self.AMPL_available
                self.eval(results)
                % check if the assigned values within its constraints
                check_message = evalc(sprintf("self.display('%s')",paramName));
                if  contains( check_message , 'failed check' )
                    error(check_message)
                end
            end

            % save the results in OP
            results = self.update(results);
        end


        %%%%%%%%%%% MATHMATICAL OPERATIONS %%%%%%%%%%%%%
        function  results = multiply(self,varargin)
            % e.g  results = ampl.multiply("x.T[1..2, k]", 'Q1[1..2, 1..2 ]', "x[ 1..2, k]")
            % e.g  results = ampl.multiply("x.T[%u..%u, k]",1,2, 'Q1[1..%u, %u..2 ]',2,1, "x[ 1..2, k]")

            % this function multiplies matrices of string array for ampl program
            % example for the inputs arguments
            % 1- 'R' for scalar %  do not use 'R[1..1]' if R has no indexes in AMPL
            % 1- 'x.T[k , 0 . . 2  ]', .T for transpose , create vector of indexes 0 ,1,2 , k is constant no thing to do with the matrix indexes
            % 2- 'Q1[0..2,m,k, 2..5 ]'  create matrix of row indexes 0 ,1,2 and column indexes from 2 to 3  m, and k is constant no thing to do with the matrix indexes
            % m where m is a numeric array

            [stringArray, arraySize, numInputs] = self.premathop(varargin{:})


            for k = 1 : numInputs - 1
                if k == 1
                    [results resutlsSize] = multiply(stringArray{k},stringArray{k+1},arraySize{k},arraySize{k+1});
                else
                    [results resutlsSize] = multiply(results,stringArray{k+1},resutlsSize,arraySize{k+1});
                end
            end




        end

        function  results = sum(self,varargin)
            % sum
            % e.g  results = ampl.sum("x.T[1..2, k]", 'Q1[1..2, 1..2 ]', "x[ 1..2, k]")
            % e.g  results = ampl.sum("x.T[%u..%u, k]",1,2, 'Q1[1..%u, %u..2 ]',2,1, "x[ 1..2, k]")

            % this function sums matrices of string array for ampl program
            % example for the inputs arguments
            % 1- 'R' for scalar %  do not use 'R[1..1]' if R has no indexes in AMPL
            % 1- 'x.T[k , 0 . . 2  ]', .T for transpose , create vector of indexes 0 ,1,2 , k is constant no thing to do with the matrix indexes
            % 2- 'Q1[0..2,m,k, 2..5 ]'  create matrix of row indexes 0 ,1,2 and column indexes from 2 to 3  m, and k is constant no thing to do with the matrix indexes
            % m where m is a numeric array

            [stringArray, arraySize, numInputs] = self.premathop(varargin{:})

            mathOperator = '+';
            for k = 1 : numInputs - 1
                if k == 1
                    [results resutlsSize] = self.ElementWiseOperation(mathOperator, stringArray{k},stringArray{k+1},arraySize{k},arraySize{k+1});
                else
                    [results resutlsSize] = self.ElementWiseOperation(mathOperator,results,stringArray{k+1},resutlsSize,arraySize{k+1});
                end
            end

        end

        function  results = subt(self,varargin)
            % subtract
            % e.g  results = ampl.subt("x.T[1..2, k]", 'Q1[1..2, 1..2 ]', "x[ 1..2, k]")
            % e.g  results = ampl.subt("x.T[%u..%u, k]",1,2, 'Q1[1..%u, %u..2 ]',2,1, "x[ 1..2, k]")

            % this function subracts matrices of string array for ampl program
            % example for the inputs arguments
            % 1- 'R' for scalar %  do not use 'R[1..1]' if R has no indexes in AMPL
            % 1- 'x.T[k , 0 . . 2  ]', .T for transpose , create vector of indexes 0 ,1,2 , k is constant no thing to do with the matrix indexes
            % 2- 'Q1[0..2,m,k, 2..5 ]'  create matrix of row indexes 0 ,1,2 and column indexes from 2 to 3  m, and k is constant no thing to do with the matrix indexes
            % m where m is a numeric array

            [stringArray, arraySize, numInputs] = self.premathop(varargin{:})

            mathOperator = '-';
            for k = 1 : numInputs - 1
                if k == 1
                    [results resutlsSize] = self.ElementWiseOperation(mathOperator, stringArray{k},stringArray{k+1},arraySize{k},arraySize{k+1});
                else
                    [results resutlsSize] = self.ElementWiseOperation(mathOperator,results,stringArray{k+1},resutlsSize,arraySize{k+1});
                end
            end

        end


        function  results = Ediv(self,varargin)
            % Element wise division
            % e.g  results = ampl.Ediv("x.T[1..2, k]", 'Q1[1..2, 1..2 ]', "x[ 1..2, k]")
            % e.g  results = ampl.Ediv("x.T[%u..%u, k]",1,2, 'Q1[1..%u, %u..2 ]',2,1, "x[ 1..2, k]")

            % this function Element wise divide  matrices of string array for ampl program
            % example for the inputs arguments
            % 1- 'R' for scalar %  do not use 'R[1..1]' if R has no indexes in AMPL
            % 1- 'x.T[k , 0 . . 2  ]', .T for transpose , create vector of indexes 0 ,1,2 , k is constant no thing to do with the matrix indexes
            % 2- 'Q1[0..2,m,k, 2..5 ]'  create matrix of row indexes 0 ,1,2 and column indexes from 2 to 3  m, and k is constant no thing to do with the matrix indexes
            % m where m is a numeric array

            [stringArray, arraySize, numInputs] = self.premathop(varargin{:})

            mathOperator = '/';
            for k = 1 : numInputs - 1
                if k == 1
                    [results resutlsSize] = self.ElementWiseOperation(mathOperator, stringArray{k},stringArray{k+1},arraySize{k},arraySize{k+1});
                else
                    [results resutlsSize] = self.ElementWiseOperation(mathOperator,results,stringArray{k+1},resutlsSize,arraySize{k+1});
                end
            end

        end

        function  results = Emulti(self,varargin)
            % Element wise multiplication
            % e.g  results = ampl.Emulti("x.T[1..2, k]", 'Q1[1..2, 1..2 ]', "x[ 1..2, k]")
            % e.g  results = ampl.Emulti("x.T[%u..%u, k]",1,2, 'Q1[1..%u, %u..2 ]',2,1, "x[ 1..2, k]")

            % this function Element wise multiplies matrices of string array for ampl program
            % example for the inputs arguments
            % 1- 'R' for scalar %  do not use 'R[1..1]' if R has no indexes in AMPL
            % 1- 'x.T[k , 0 . . 2  ]', .T for transpose , create vector of indexes 0 ,1,2 , k is constant no thing to do with the matrix indexes
            % 2- 'Q1[0..2,m,k, 2..5 ]'  create matrix of row indexes 0 ,1,2 and column indexes from 2 to 3  m, and k is constant no thing to do with the matrix indexes
            % m where m is a numeric array

            [stringArray, arraySize, numInputs] = self.premathop(varargin{:})

            mathOperator = '*';
            for k = 1 : numInputs - 1
                if k == 1
                    [results resutlsSize] = self.ElementWiseOperation(mathOperator, stringArray{k},stringArray{k+1},arraySize{k},arraySize{k+1});
                else
                    [results resutlsSize] = self.ElementWiseOperation(mathOperator,results,stringArray{k+1},resutlsSize,arraySize{k+1});
                end
            end

        end


        function [stringArray,arraySize, numInputs] = premathop(self, varargin) %preprocessing the input before mathematical operations
            % e.g  results = premathop("x.T[1..2, k]", 'Q1[1..2, 1..2 ]', "x[ 1..2, k]")
            % e.g  results = premathop("x.T[%u..%u, k]",1,2, 'Q1[1..%u, %u..2 ]',2,1, "x[ 1..2, k]")

            % this function prepare the input of the function operator
            % example for the inputs arguments
            % 1- 'R' for scalar %  do not use 'R[1..1]' if R has no indexes in AMPL
            % 1- 'x.T[k , 0 . . 2  ]', .T for transpose , create vector of indexes 0 ,1,2 , k is constant no thing to do with the matrix indexes
            % 2- 'Q1[0..2,m,k, 2..5 ]'  create matrix of row indexes 0 ,1,2 and column indexes from 2 to 3  m, and k is constant no thing to do with the matrix indexes
            % m where m is a numeric array


            numInputs =  length(varargin);
            % substitute the numbers based on (%) sign
            for i = 1 : numInputs
                try
                    while  contains( varargin{i} , '%u')
                        varargin{i} =char(varargin{i});
                        indexes = findstr(varargin{i},'%u');
                        varargin{i} =strcat(varargin{i}(1:indexes(1)-1),num2str(varargin{i+1}),varargin{i}(indexes(1)+2:end)) ;
                        varargin(i+1) =[];
                        numInputs = numInputs - 1;

                    end
                end
            end


            for k = 1 : numInputs
                try  % if it is alread expaned
                    [stringArray{k}, arraySize{k}]  =  expand(varargin{k});
                catch
                    stringArray{k} = string(varargin{k});
                    arraySize{k} =size(stringArray{k} );
                end

            end



        end


        function [results, arraySizeResult] =ElementWiseOperation(self,mathOperator,stringArray1,stringArray2,arraySize1,arraySize2)
            % the operations can be +  - * /
            % this function operates  matrices of string array for ampl program
            % stringArrayIn1(2) first and second stringArrays
            % arraySizeIn1(2) the size of the   stringArrayIn1(2)

            % check if we sum with scalar
            if max(arraySize1) == 1 ||  max(arraySize2) == 1
                results =  strcat(    '(', '(' , stringArray1, ')', mathOperator,'(', stringArray2,')',')'    );
                arraySizeResult = max(arraySize1,arraySize2);
            else

                % check the output size
                if  arraySize1(1)~= arraySize2(1) || arraySize1(2)~= arraySize2(2)
                    error( ['Incorrect dimensions for matrix multiplication. Check that the number of columns in the first matrix matches the number of rows in the second' ...
                        ' matrix.'])
                end

                % the size of the resulted array
                arraySizeResult = arraySize1;
                results = "(" +"("+ stringArray1+")" + mathOperator +"(" + stringArray2+"))";

            end


        end

        %%%%%%%%%%% MATHMATICAL OPERATIONS %%%%%%%%%%%%%
        function save(self,filename)
            if ~exist('filename','var')
                filename = 'OP';
            else
                filename = "OP_"+filename;
            end

            fileID = fopen(filename + ".txt","w");
            for i = 1 : length(self.OP)
                fprintf(fileID,self.OP(i) + "\n", filename);

            end
            fclose(fileID);





        end
        function reset(self)
           self.OP = "";
           self.counter = 0;        
        end


    end
end