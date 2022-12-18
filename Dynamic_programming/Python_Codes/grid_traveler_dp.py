def grid_traveler_dp(row_num, col_num, dictionary):
    if row_num == 0 or col_num == 0:
        return 0, dictionary
    elif row_num == 1 or col_num == 1:
        return 1, dictionary
    elif dictionary.get(str(row_num)+","+str(col_num)) is not None:
        return dictionary.get(str(row_num)+","+str(col_num)), dictionary
    elif dictionary.get(str(col_num)+","+str(row_num)) is not None:
        return dictionary.get(str(col_num)+","+str(row_num)), dictionary
    else:
        temp_1, dictionary = grid_traveler_dp(row_num - 1, col_num, dictionary)
        temp_2, dictionary = grid_traveler_dp(row_num, col_num - 1, dictionary)
        dictionary[str(col_num)+","+str(row_num)] = temp_1 + temp_2
        return temp_1 + temp_2, dictionary

row_num = int(input("Please input the row number: \n"))
col_num = int(input("Please input the column number: \n"))
grid_dp = {}
result, grid_dp = grid_traveler_dp(row_num, col_num, grid_dp)

print("We have "+str(result)+" ways to travel.")
print(grid_dp)
