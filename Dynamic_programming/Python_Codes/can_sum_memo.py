def can_sum_dp(target, choices, dictionary):
    if dictionary.get(target) is not None:
        return dictionary.get(target), dictionary
    elif target == 0:
        return True, dictionary
    elif target < 0:
        return False, dictionary
    else:
        temp = False;
        for i in choices:
            temp, dictionary = can_sum_dp(target - i, choices, dictionary)
            if temp is True:
                break
        dictionary[target] = temp
        return temp, dictionary

target = 300
choices = [7,14]
dict_can_sum = {}
result, dict_can_sum = can_sum_dp(target, choices, dict_can_sum)

print(result)



