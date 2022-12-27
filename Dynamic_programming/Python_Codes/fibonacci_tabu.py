def fib_tabu(num):

    list_all = [0] * (num + 1)
    if num >= 1:
        list_all[1] = 1
        for i in range(2, num + 1):
            list_all[i] = list_all[i-1] + list_all[i-2]

    return list_all[num]

print(fib_tabu(0))
