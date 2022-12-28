def best_sum_tabu(target, numbers):
    list_best = [None] * (target + 1)
    list_best[0] = []

    for i in range(0, target + 1):
        if list_best[i] is not None:
            for j in numbers:
                if i + j <= target:
                    if (list_best[i + j] is None) or ( (list_best[i + j] is not None) and (len(list_best[i + j]) > len(list_best[i]) + 1 ) ):
                        list_best[i + j] = list_best[i] + [j]

    return list_best[-1]

target = 200
numbers = [2, 50, 10]
print(best_sum_tabu(target, numbers))
