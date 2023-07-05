classdef   POPA   < handle      % prepare the OP for AMPL

    properties
        AMPL_available = 0;
        create_symbolic_flag =0;
        printResultsFlag = 0; % if want to print on the screen
        left_bracket_symbol = '_LL_';
        right_bracket_symbol = '_JJ';
        comma_sympol = '_I_';
        logging_flag = 1;
        log  = [];   % data log
        OP_log_counter = 0;
        OP_log = "";




    end


    methods



        %% at management level
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function self = update(self,command)
            % update the diary
            self.OP_log_counter = self.OP_log_counter + 1;
            self.OP_log(self.OP_log_counter) = command;
        end

        function reset(self)
            % reset the diary
            self.OP_log = "";
            self.OP_log_counter = 0;
        end


        function save(self,filename)
            % save the diary, the filename is optional
            if ~exist('filename','var')
                filename = 'OP';
            else
                filename = "OP_"+filename;
            end

            fileID = fopen(filename + ".txt","w");
            for i = 1 : length(self.OP_log)
                fprintf(fileID,self.OP_log(i) + "\n", filename);

            end
            fclose(fileID);
        end



        function  self = runAMPL(self)

            temp = AMPC(self);
            self = temp;
            clearvars temp

        end





        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%% Offline %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % define functions
        function results = defineVar(self, dataName, indexRange, attribute,create_symbolic_flag)
            % e.g. ampl.defineVar(dataName,indexRange,attribute)
            % This function is used to define the variables  for the
            % optimization problem in ampl language
            % for more information, use the command:   help DenfineData
            % create_symbolic_flag: 1 to make symbolic variable

          
            if nargin < 3 || isempty(indexRange)
                indexRange = 1;
            end

            if nargin < 4 || isempty(attribute)
                attribute = "";
            end

            if nargin < 5 || isempty(create_symbolic_flag)
                create_symbolic_flag = 0;
            end
           
            dataType = "var";


            self.checkname(dataName)
            results = defineData(dataType, dataName, indexRange, attribute);


            if self.AMPL_available
                self.eval(results)
            end


            if self.logging_flag
                self.addLog(dataName,indexRange)
            end


            if self.printResultsFlag
                fprintf(results)
                fprintf(newline)

            end


            % save the results in OP
            results = self.update(results);

            if (self.create_symbolic_flag || create_symbolic_flag) && numel(indexRange) <= 2  % create symbolic
                temp = self.sym(dataName,indexRange);
                if ~isempty(temp)
                    results = temp;
                end
            end


        end

        function results = defineParam(self,dataName,indexRange,attribute,create_symbolic_flag)
            % e.g. ampl.defineParam(dataName,indexRange,attribute)
            % This function is used to define the parameters for the
            % optimization problem in ampl language
            % for more information, use the command:   help DenfineData
            % create_symbolic_flag: 1 to make symbolic variable
            dataType = "param";
  
            if nargin < 3 || isempty(indexRange)
                indexRange = 1;
            end

            if nargin < 4 || isempty(attribute)
                attribute = "";
            end

            if nargin < 5 || isempty(create_symbolic_flag)
                create_symbolic_flag = 0;
            end
           
        

            if ~exist("create_symbolic_flag",'var')
                create_symbolic_flag = 0;
            end

            self.checkname(dataName)
            results  = defineData(dataType, dataName, indexRange, attribute);


            if self.AMPL_available
                self.eval(results)
            end

            if self.logging_flag
             self.addLog(dataName,indexRange);
            end


            if self.printResultsFlag
                fprintf(results)
                fprintf(newline)

            end


            % save the results in OP
            results = self.update(results);


            if (self.create_symbolic_flag || create_symbolic_flag) && numel(indexRange) <= 2   % create symbol
                temp = self.sym(dataName,indexRange);
                if ~isempty(temp)
                    results = temp;
                end
            end

        end


        function results = defineSet(self, setName, setMembers, attributes,create_symbolic_flag)
            % e.g ampl.defineSet('k','1..4 by 2') % k = {1, 3}
            % e.g ampl.defineSet('k', [1,5,6]) % k = {1, 5, 6};
            % this function create a set with a give name and
            % attributes : ordered
            % create_symbolic_flag: 1 to make symbolic variable

              if nargin < 4 || isempty(attributes)
                  attributes = "";
              end

              if nargin < 5 || isempty(create_symbolic_flag)
                 create_symbolic_flag = 0;
               end

          
            if isnumeric(setMembers)
                eval("self.log." + setName + "=" + "setMembers") % add to the log
                setMembers = string(setMembers);
                setMembers(1:end-1) = setMembers(1:end-1) +',';
                setMembers = "{" + strjoin(setMembers)+ "}";

            end

            self.checkname(setName)
            results = "redeclare set "+ setName + ":= " +...
                setMembers+ " " + attributes + ";";

            if self.AMPL_available
                self.eval(results)
            end



            if self.printResultsFlag
                fprintf(results)
                fprintf(newline)

            end




            % save the results in OP
            results = self.update(results);

            if self.create_symbolic_flag || create_symbolic_flag   % create symbolic
                results = self.sym(dataName,1);
            end


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

            if  isa(data, 'sym')
                data = self.sym2str(data);
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
            if isa(costFunction, 'sym')
                costFunction = self.sym2str(costFunction);
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
            if isa(data, 'sym')
                data = self.sym2str(data);
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

        function checkname(self,name)
            % to check if the variable or parameter name has the patterns
            %     '_LL_','_JJ' , or '_I_'    for left_bracket_symbol
            %  right_bracket_symbol  or  comma_sympol, respectively

            text = " can not be a valid name because it contains the pattern: ";

            if contains(name, self.left_bracket_symbol)
                error(name + text +  self.left_bracket_symbol)
            end

            if contains(name, self.right_bracket_symbol)
                error(name + text +  self.right_bracket_symbol)
            end

            if contains(name, self.comma_sympol)
                error(name + text +  self.comma_sympol)
            end

        end

        function addLog(self,name,idxes)
            % to check if the variable or parameter name has the patterns
            %     '_LL_','_JJ' , or '_I_'    for left_bracket_symbol
            %  right_bracket_symbol  or  comma_sympol, respectively
            for i = 1 : length(idxes)
                if isnumeric(idxes(i))  ||  all(isstrprop(idxes(i), 'digit'))
                    eval("self.log." + name + ".size_"+ i + "= idxes(i);") % add to the log
                end
            end


        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





        %%
        %%%%%%%%%%% MATHMATICAL OPERATIONS %%%%%%%%%%%%%
        function  results = multiply(self,varargin)
            % e.g  results = POPA.multiply("x.T[1..2, k]", 'Q1[1..2, 1..2 ]', "x[ 1..2, k]")
            % e.g  results = POPA.multiply("x.T[%u..%u, k]",1,2, 'Q1[1..%u, %u..2 ]',2,1, "x[ 1..2, k]")

            % this function multiplies matrices of string array for ampl program
            % example for the inputs arguments
            % 1- 'R' for scalar %  do not use 'R[1..1]' if R has no indexes in AMPL
            % 1- 'x.T[k , 0 . . 2  ]', .T for transpose , create vector of indexes 0 ,1,2 , k is constant no thing to do with the matrix indexes
            % 2- 'Q1[0..2,m,k, 2..5 ]'  create matrix of row indexes 0 ,1,2 and column indexes from 2 to 3  m, and k is constant no thing to do with the matrix indexes
            % m where m is a numeric array

            inputs = self.premathop(varargin{:});

            numInputs = numel(inputs);
            for k = 1 : numInputs - 1
                if k == 1
                    results = multiply2Arrays(inputs{k},inputs{k+1});
                else
                    results = multiply2Arrays(results,inputs{k+1});
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

            mathOperator = '+';

            inputs = self.premathop(varargin{:});
            numInputs = numel(inputs);
            for k = 1 : numInputs - 1
                if k == 1
                    results= self.ElementWiseOperation(mathOperator, inputs{k},inputs{k+1});
                else
                    results = self.ElementWiseOperation(mathOperator,results,inputs{k+1});
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
            mathOperator = '-';

            inputs = self.premathop(varargin{:});
            numInputs = numel(inputs);
            for k = 1 : numInputs - 1
                if k == 1
                    results= self.ElementWiseOperation(mathOperator, inputs{k},inputs{k+1});
                else
                    results = self.ElementWiseOperation(mathOperator,results,inputs{k+1});
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
            mathOperator = '/';

            inputs = self.premathop(varargin{:});
            numInputs = numel(inputs);
            for k = 1 : numInputs - 1
                if k == 1
                    results= self.ElementWiseOperation(mathOperator, inputs{k},inputs{k+1});
                else
                    results = self.ElementWiseOperation(mathOperator,results,inputs{k+1});
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
            mathOperator = '*';


            inputs = self.premathop(varargin{:});
            numInputs = numel(inputs);
            for k = 1 : numInputs - 1
                if k == 1
                    results= self.ElementWiseOperation(mathOperator, inputs{k},inputs{k+1});
                else
                    results = self.ElementWiseOperation(mathOperator,results,inputs{k+1});
                end
            end


        end


        function varargin = premathop(~,varargin) %preprocessing the input before mathematical operations
            % e.g  results = premathop("x.T[1..2, k]", 'Q1[1..2, 1..2 ]', "x[ 1..2, k]")
            % e.g  results = premathop("x.T[%u..%u, k]",1,2, 'Q1[1..%u, %u..2 ]',2,1, "x[ 1..2, k]")
            % e.g  results = premathop('x[%u,@]',1, [2, 3], 'Q1[1..%u, %u..2 ]',2,1, "x[ 1..2, k]")

            % this function prepare the input of the function operator
            % example for the inputs arguments
            % 1- 'R' for scalar %  do not use 'R[1..1]' if R has no indexes in AMPL
            % 1- 'x.T[k , 0 . . 2  ]', .T for transpose , create vector of indexes 0 ,1,2 , k is constant no thing to do with the matrix indexes
            % 2- 'Q1[0..2,m,k, 2..5 ]'  create matrix of row indexes 0 ,1,2 and column indexes from 2 to 3  m, and k is constant no thing to do with the matrix indexes

            % m where m is a numeric array


            numInputs =  length(varargin);
            expand_flag = ones(numInputs,1);

            %% substitute the numbers based on (%) sign and @
            i = 1;
            while  numInputs   > 0
                numSubstitutions = 0;
                if  (isstring( varargin{i}) && isscalar( varargin{i})) || (ischar( varargin{i}) && isscalar( varargin{i}+""))
                    varargin{i} =  char(strrep(varargin{i}, ' ', '')); % remove the
                    input =char(varargin{i});
                    numSubstitutions =   count( input, '@') +  count( input, '%u');
                    if numSubstitutions>0
                        input = strrep(input, '@', '{%s}');
                        input = strrep(input, '%u', '%s');
                        substitutions = varargin(i +1 : i + numSubstitutions);
                        varargin(i +1 : i + numSubstitutions) = [];
                        formattedElements  = cellfun(@formatElement,substitutions, 'UniformOutput', false);
                        varargin{i} =   sprintf(input,formattedElements{:});

                    end
                else
                    expand_flag(i) = false;
                end
                numInputs = numInputs - 1 -numSubstitutions;
                i = i + 1;
            end

            %% expand the inputs if possible

            for k = 1 : numel(varargin)
                if expand_flag == false
                    continue
                end

                error_flag = 0;
                try  % if it is alread expaned
                    temp = expand(varargin{k});
                catch
                    error_flag = 1;
                end

                if error_flag == false % if
                    varargin{k} = temp;
                end


            end

            function formattedElement = formatElement(element)
                % this function replace numeric to string
                if isnumeric(element)
                    if  numel(element) > 1
                        formattedElement = sprintf('%s', strjoin(string(element), ';'));
                    else
                        formattedElement = sprintf('%d', element);
                    end
                else
                    error("the input argument is not numeric, see "+ element)
                end
            end

        end


        function results =ElementWiseOperation(~,mathOperator,array1,array2)
            % the operations can be +  - * /
            % this function operates  matrices of string array for ampl program
            % stringArrayIn1(2) first and second stringArrays
            % arraySizeIn1(2) the size of the   stringArrayIn1(2)

            if isnumeric(array1) && isnumeric(array2) % here we use matlab multiplication
                if strcmp(mathOperator,'*') ||strcmp(mathOperator,'/')
                    mathOperator = "." + mathOperator;
                end
                results = eval("array1"+mathOperator+"array2");
                return
            else
                array1 = mat2string(array1); % convert the array to string array
                array2 = mat2string(array2); % convert the array to string array
                array1size = size(array1);
                array2size = size(array2);
                if  array1size~= array2size(1) % double check sizes
                    error('Incorrect dimensions. Both should have the same dimensions')
                end
                results =  "(" +  array1 + ')'+ mathOperator +  '(' + array2 + ')';

            end


        end

        function results = sumI(self,varargin)
            % this function is for sigam_summation
            % self.sumI('k',"1..3", x[k])= x[1] + x[2] + x[3]
            % self.sumI('a',"1..2",'k',1:2,x[a,k]) =  self.sumI('a',1:2,self.sumI('k',1:2,x[a,k]))
            % not the set is AMPL set or indexes
            num_input = numel(varargin);

            if num_input<3 || rem(num_input-1,2) ~=0
                error('number of input must be comply to 2*i+1 for any integer')
            end

            if isa(varargin{end}, 'sym')
                results = self.sym2str(varargin{end});
            elseif isstring(varargin{end})
                results = varargin{end};
            else
                error((varargin{end} + " must be string"))
            end


            for i = num_input : -2 : 3
                if isnumeric(varargin{i-1})
                    setMembers = string(varargin{i-1});
                    setMembers(1:end-1) = setMembers(1:end-1) +',';
                    setMembers = "{" + strjoin(setMembers)+ "}";
                elseif isa(varargin{i-1},'sym')
                    setMembers = string(varargin{i-1});
                else
                    setMembers = varargin{i-1};
                end

                results = strcat("sum{",varargin{i-2}, " in ", setMembers ,'}(', results,')');
            end







        end
        %%%%%%%%%%%%%%% MATHMATICAL OPERATIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%% using symbolic varaibles%%%%%%%%%%%%%%%%%%

        function results = expand_sym(self, varargin)
            % produce the symbolic variables % the input is like exapnd
            % self.sym("L[@,@],set_of_first index,set_of_second_index)

            tmp = expand(varargin{:});
            results = self.str2sym(tmp);
        end

        function results = sym(self,dataName,indexRange)
            % it creates symoblic variable based on the name and size
            % maximum 2 dimentions
            % for example  sym("L",[1 2])
            % or sym("L[@,k,@]", [1,2])
            % sym("U[k]") convert it to symbolic
            results = [];
            if ~exist("indexRange",'var')
                results = self.str2sym(dataName); 
                return
            end
            dimension = numel(indexRange);
            stop = 0;

            if isnumeric(indexRange(1))  ||  all(isstrprop(indexRange(1), 'digit'))
                idx1 = 1:indexRange(1);
            else
                stop = 1;
            end

            if ~stop && dimension == 2
                if isnumeric(indexRange(2))  ||  all(isstrprop(indexRange(2), 'digit'))
                    idx2 = 1:indexRange(2);
                    if ~contains(dataName,"[")
                        dataName= dataName+"[@,@]";
                    end
                    results = self.expand_sym(dataName,idx1, idx2);
                    stop = 1;
                else
                    stop = 1;
                end
            end

            if ~stop     % here means the dimension = 1
                if ~contains(dataName,"[")
                    dataName = dataName+"[@]";
                end
                results = self.expand_sym(dataName,idx1);
            end
        end


        function results = str2sym(self, stringArray)
            % replace [ --> _LL_
            % replace ] --> _JJ
            % replace , --> _I_
            if ~(isstring(stringArray)||ischar(stringArray))
                display(stringArray)
                error('to convert from string to symbolic the input must be string')
            end

            stringArray = strrep(stringArray,'[',self.left_bracket_symbol);
            stringArray = strrep(stringArray,']',self.right_bracket_symbol) ;
            stringArray = strrep(stringArray,',',self.comma_sympol);
            stringArray = strrep(stringArray,'^','**');


            results = sym(stringArray, 'real');

        end

        function results = sym2str(self, symArray)
            % replace  _LL_  -->  [
            % replace  _JJ   -->  ]
            % replace , --> _I_
            % replace  ^  -->  **
            if isstring(symArray)
                results = symArray;
                return
            end

            if ~isa(symArray, 'sym')
                display(symArray)
                error('to convert from string to symbolic the input must be string')
            end


            results = string(symArray);

            results = strrep(results,self.left_bracket_symbol,'[') ;
            results = strrep(results,self.right_bracket_symbol,']') ;
            results = strrep(results,self.comma_sympol,',');
            results = strrep(results,'^','**');
            results = strrep(results,'==','=');
            
            if regexp(results(1),'\(.*\) <=') % check  ((2 <= x1 + 4) <= 4)
                for i = 1 : numel(results)
                    temp = char(regexp(results(i),'\(.*\) <=','match'));
                    results(i) = strrep(results(i),temp,temp(2:end-4)+" <=");
                end 

            end




        end




        %%



    end
end