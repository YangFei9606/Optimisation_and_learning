def can_sum_tabu(target, numbers):
    list_can = [False] * (target + 1)
    list_can[0] = True

    for i in range(0, target + 1):
        if list_can[i] is True:
            for j in numbers:
                if i+j <= target:
                    list_can[i+j] = True

    return list_can[-1]

target = 70001
numbers = [7, 14]
print(can_sum_tabu(target, numbers))
