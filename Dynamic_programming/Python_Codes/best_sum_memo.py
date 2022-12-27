
def best_sum_dp(target, choices, dictionary_best):
    if target == 0:
        # If target is 0, we return [] to represent that we can start saving answers
        dictionary_best[0] = []
        return [], dictionary_best
    elif target < 0:
        # If target is negative, we return None to represent that we do not save this path
        return False, dictionary_best
    elif dictionary_best.get(target) is not None:
        # If the scene is calculated, then we refer to the existing results
        return dictionary_best.get(target), dictionary_best
    else:
        # If the scene is not calculated, then we analyse
        # So we start the loop
        temp_reu = False
        best_combine = []

        for i in choices:
            temp, dictionary_best = best_sum_dp(target - i, choices, dictionary_best)
            if temp is not False:
                temp_reu = temp+[i]
                if len(best_combine) == 0 or (len(best_combine) > 0 and len(best_combine) > len(temp_reu)):
                    best_combine = temp_reu

        if temp_reu is not False:
            dictionary_best[target] = best_combine
        else:
            dictionary_best[target] = temp_reu

        return dictionary_best[target], dictionary_best

target = 100
choices = [1, 2, 5, 25]
dictionary_best = {}

result, dictionary_best = best_sum_dp(target, choices, dictionary_best)

print(dictionary_best.get(target))
print(dictionary_best)


