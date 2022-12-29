def count_construct_tabu(target, wordbank):
    list_count = [0] * (len(target) + 1)
    list_count[0] = 1

    for i in range(len(target) + 1):
        if list_count[i] > 0:
            for j in wordbank:
                if target[0: i + len(j)] == target[0: i] + j:
                    list_count[i + len(j)] += list_count[i]

    return list_count[-1]

# wordbank = ['a', 'p', 'ent', 'enter', 'ot', 'o', 't']
# target = "enterapotentpot"

wordbank = ['purp','p','ur','le','purpl']
target = "purple"

print(count_construct_tabu(target, wordbank))
