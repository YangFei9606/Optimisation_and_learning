import array

def how_sum_dp(target, choices, dictionary_how):
    if target == 0:
        # If target is 0, we return [] to represent that we can start saving answers
        dictionary_how[0] = []
        return [], dictionary_how
    elif target < 0:
        # If target is negative, we return None to represent that we do not save this path
        return False, dictionary_how
    elif dictionary_how.get(target) is not None:
        # If the scene is calculated, then we refer to the existing results
        return dictionary_how.get(target), dictionary_how
    else:
        # If the scene is not calculated, then we analyse
        # So we start the loop
        temp_reu = False

        for i in choices:
            temp, dictionary_how = how_sum_dp(target - i, choices, dictionary_how)
            if temp is not False:
                temp_reu = temp+[i]
                break

        dictionary_how[target] = temp_reu
        return dictionary_how[target], dictionary_how

target = 7
choices = [2, 3]
dictionary_how = {}

result, dictionary_how = how_sum_dp(target, choices, dictionary_how)

print(dictionary_how.get(target))
print(dictionary_how)


