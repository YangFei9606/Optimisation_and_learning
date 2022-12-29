def can_construct_tabu(target, wordbank):
    list_can = [False] * (len(target) + 1)
    list_correspond = [None] * (len(target) + 1)
    list_can[0] = True

    for i in range(len(target) + 1):
        list_correspond[i] = target[0:i]
        if list_can[i] is True:
            for j in wordbank:
                if target[0:i + len(j)] == target[0:i] + j:
                    list_can[i + len(j)] = True

    print(list_correspond)
    print(list_can)
    return list_can[-1]

# target = "abcdef"
# wordbank = ["ab", "abc", "defg", "de"]

target = "eeeeeeeeeeeeeeef"
wordbank = ["e", "ee", "eee", "eeee"]

print(can_construct_tabu(target, wordbank))
