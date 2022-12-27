import copy
def all_construct(target, wordbank, dict_all_construct):
    if target == "":
        return [[]]
    elif len(wordbank) <= 0:
        return []
    elif dict_all_construct.get(target) is not None:
        return dict_all_construct.get(target)
    else:
        flag = 0
        for i in wordbank:
            if target.find(i) == 0:
                temp = copy.copy(all_construct(copy.copy(target[len(i):len(target)]), wordbank, dict_all_construct))
                if len(temp) > 0:
                    flag = 1
                    for j in range(0, len(temp)):
                        temp[j] = [i] + temp[j]
                    if dict_all_construct.get(target) is None:
                        dict_all_construct[target] = copy.copy(temp)
                    else:
                        dict_all_construct[target] = copy.copy(dict_all_construct[target] + temp)


        if flag == 0:
            dict_all_construct[target] = []
            return []
        else:
            return copy.copy(dict_all_construct.get(target))

target = "Potatotatoto"
wordBank = ["Po", "tato", "ta", "to"]
dictionary = {}

print(all_construct(target, wordBank, dictionary))
print(dictionary)
