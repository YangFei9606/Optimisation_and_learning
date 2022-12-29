import copy
def count_construct_tabu(target, wordbank):
    list_all = [None] * (len(target) + 1)
    list_all[0] = [[]]

    for i in range(len(target) + 1):
        if list_all[i] is not None:
            for j in wordbank:
                if target[0: i + len(j)] == target[0: i] + j:
                    for k in range(len(list_all[i])):
                        if list_all[i + len(j)] is None:
                            list_all[i + len(j)] = []
                        list_all[i + len(j)] += [list_all[i][k] + [j]]

    return list_all[-1]

wordbank = ['a', 'p', 'ent', 'enter', 'ot', 'o', 't']
target = "enterapotentpot"

# wordbank = ['purp','p','ur','le','purpl']
# target = "purple"

print(count_construct_tabu(target, wordbank))
