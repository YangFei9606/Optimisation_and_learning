def how_sum_tabu(target, numbers):
    list_how = [None] * (target + 1)
    list_how[0] = []

    for i in range(0, target + 1):
        if list_how[i] is not None:
            for j in numbers:
                if i + j <= target:
                    list_how[i + j] = list_how[i] + [j]

    return list_how[-1]

target = 1000
numbers = [21, 14]

print(how_sum_tabu(target, numbers))
