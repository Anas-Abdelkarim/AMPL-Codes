function results = multiply2Arrays(array1,array2)
% this function multiplies matrices of array for ampl program
% the output is string Array
% stringArrayIn1(2) first and second stringArrays

if isnumeric(array1) && isnumeric(array2) % here we use matlab multiplication
    results = array1*array2;
    return
else
    array1 = mat2string(array1); % convert the array to string array
    array2 = mat2string(array2); % convert the array to string array
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
        results =  "(" +  array1 + ')'+ "*" +  '(' + array2 + ')';

    case  strcmp('matrix_multiplication',case_flag)%   we multiply nonscalar matrices

        % create empty array
        results = strings(arraySizeResult);
        % to quote the elements with parentheses
        array1 = "(" + array1 + ")" ;
        array2 = "(" + array2 + ")" ;

        array1 = array1+"*";
        array2(1:end-1,:) = array2(1:end-1,:)+"+";

        for i = 1 : arraySizeResult(1) % row loop
            for j = 1: arraySizeResult(2) %column loop
                results(i,j) = join(array1(i,:)+ array2(:,j)');
            end
        end




end

%% matrix simplifcation for more storage space
% treat zero multiplication
multi_with_zero = endsWith(results, "*(0)") | startsWith(results, "(0)*");
results(multi_with_zero) = "0";

% one (left multiplication)
multi_with_one_left= find(endsWith(results, "*(1)")) ;
for i = 1 : length(multi_with_one_left)
    index = multi_with_one_left(i);
    newchar = char(results(index));
    results(index) =newchar(3:end-6);
end

% one (right multiplication)
multi_with_one_right= find(startsWith(results, "(1)*")) ;
for i = 1 : length(multi_with_one_right)
    index = multi_with_one_right(i);
    newchar = char(results(index));
    results(index) =newchar(7:end-2);
end

%{
% check if can bring it back to numberical
r__e_s_u_l_t_s_u_n_i_q_ue_N_A_M_E_A_S_M_Uch_A_s_P_o_s_sible___ = results;
clearvars -except r__e_s_u_l_t_s_u_n_i_q_ue_N_A_M_E_A_S_M_Uch_A_s_P_o_s_sible___


for i = 1: size(r__e_s_u_l_t_s_u_n_i_q_ue_N_A_M_E_A_S_M_Uch_A_s_P_o_s_sible___,1)
    for j = 1 : size(r__e_s_u_l_t_s_u_n_i_q_ue_N_A_M_E_A_S_M_Uch_A_s_P_o_s_sible___,2)
        try
            temp =  eval(r__e_s_u_l_t_s_u_n_i_q_ue_N_A_M_E_A_S_M_Uch_A_s_P_o_s_sible___(i,j));  % Evaluate the expression
            r__e_s_u_l_t_s_u_n_i_q_ue_N_A_M_E_A_S_M_Uch_A_s_P_o_s_sible___(i,j) = mat2string(temp);
        end
    end
end


results =  r__e_s_u_l_t_s_u_n_i_q_ue_N_A_M_E_A_S_M_Uch_A_s_P_o_s_sible___;


%}






end









