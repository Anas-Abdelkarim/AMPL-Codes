function result = multiply(array1,array2)
% this function multiplies matrices of array for ampl program
% the output is string Array
% stringArrayIn1(2) first and second stringArrays

if isnumeric(array1) && isnumeric(array2) % here we use matlab multiplication
    result = array1*array2;
    return
else
    %array1 = mat2string(array1); % convert the array to string array
    %array2 = mat2string(array2); % convert the array to string array
    array1size = size(array1);
    array2size = size(array2);
    if  max(array1size) == 1 ||  max(array2size) == 1
        case_flag = 'scalar_multiplication';
    else
        if  array1size(2)~= array2size(1) % double check sizes
            error( ['Incorrect dimensions for matrix multiplication. Check that the number of columns in the first matrix matches the number of rows in the second' ...
                ' matrix.'])
        end
        arraySizeResult = [array1size(1) array2size(2)];
        case_flag = 'matrix_multiplication';

    end
end




switch true

    case  strcmp('scalar_multiplication',case_flag)
        if max(array1size) == 1
            scaler = array1;
            matrix = array2;
            arraySizeResult = size(matrix);
        else
            scaler  = array2;
            matrix = array1;
            arraySizeResult = size(matrix);
            result = zeros(arraySizeResult);
        end
        scaler = simplify(scaler);
        scaler = string(num2str(scaler,1000));
        
        for i = 1 : arraySizeResult(1)
            for j = 1 :  arraySizeResult(2)
                result(i,j) = multiAndSimp(scaler,matrix(i,j) );
            end
        end
        


    case  strcmp('matrix_multiplication',case_flag)%   we multiply nonscalar matrices



        % Create an empty result matrix of size n-by-l
        result = zeros(arraySizeResult);

        % Perform matrix multiplication using nested for loops
        for i = 1 : arraySizeResult(1)
            for j = 1 :  arraySizeResult(2)
                for k = 1:array1size(2)
                    result(i, j) = result(i, j) + multiAndSimp(array1(i, k), array2(k, j));
                end
            end
        end

end
if ~isnumeric(result)
    temp =  str2double(result);

    if sum(sum(isnan(temp))) == 0
        result= temp;
    end
end

    function result = multiAndSimp(a,b)
        % multiply and simplify
        a = simplify(a);
        b = simplify(b);
        precision = 1000;
        a = string(num2str(a,precision));
        b = string(num2str(b,precision));
        
        if  str2double(a) ==0 || str2double(b) ==0
            result = 0;
            return
        end
        if str2double(a) ==1
            result = b;
            return
        end
        if str2double(b) ==1
            result = a;
            return
        end 

      result =  "(" +  a + ')'+ "*" +  '(' + b + ')';
      result = simplify(result);

    end

    function r__e_s_u_l_t_s_u_n_i_q_ue_N_A_M_E_A_S_M_Uch_A_s_P_o_s_sible = simplify(r__e_s_u_l_t_s_u_n_i_q_ue_N_A_M_E_A_S_M_Uch_A_s_P_o_s_sible)
        try
            r__e_s_u_l_t_s_u_n_i_q_ue_N_A_M_E_A_S_M_Uch_A_s_P_o_s_sible =  eval(r__e_s_u_l_t_s_u_n_i_q_ue_N_A_M_E_A_S_M_Uch_A_s_P_o_s_sible);  % Evaluate the expression
        catch
            r__e_s_u_l_t_s_u_n_i_q_ue_N_A_M_E_A_S_M_Uch_A_s_P_o_s_sible =  r__e_s_u_l_t_s_u_n_i_q_ue_N_A_M_E_A_S_M_Uch_A_s_P_o_s_sible;  % Evaluate the expression

        end
    end









end









