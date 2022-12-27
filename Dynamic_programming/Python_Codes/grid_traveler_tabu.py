def grid_traveler_tabu(row_num, col_num):
    list_all = [[0] * col_num] * row_num

    if row_num == 0 or col_num == 0:
        return 0
    else:
        for i in range(0, row_num):
            for j in range(0, col_num):
                if i == 0 or j == 0:
                    list_all[i][j] = 1
                else:
                    list_all[i][j] = list_all[i-1][j] + list_all[i][j-1]

        return list_all[row_num - 1][col_num - 1]

row_num = 18
col_num = 18
print(grid_traveler_tabu(row_num, col_num))
