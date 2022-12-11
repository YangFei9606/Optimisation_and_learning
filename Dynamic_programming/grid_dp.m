function [result, dict_grid] = grid_dp(row_num, col_num, dict_grid)

if row_num * col_num == 0
    result = 0;
elseif row_num == 1 || col_num == 1
    result = 1;
else
    keys_temp_1 = append(num2str(row_num),",",num2str(col_num));
    keys_temp_2 = append(num2str(col_num),",",num2str(row_num));
    if sum(find_str_array(keys(dict_grid), keys_temp_1)) > 0
        result = dict_grid(keys_temp_1);
    elseif sum(find_str_array(keys(dict_grid), keys_temp_2)) > 0
        result = dict_grid(keys_temp_2);
    else
        % The circumstance is new
        [reu_1, dict_grid] = grid_dp(row_num-1, col_num, dict_grid);
        [reu_2, dict_grid] = grid_dp(row_num, col_num-1, dict_grid);
        result = reu_1 + reu_2;
        dict_grid(keys_temp_1) = result;
    end
end

