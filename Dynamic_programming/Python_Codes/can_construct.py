def can_construct_dp(target, wordbank, dict_can_construct):
    if target == "":
        return True
    elif len(wordbank) <= 0:
        return False
    elif dict_can_construct.get(target) is not None:
        return dict_can_construct.get(target)
    else:
        temp_result = False
        new_target = target
        for i in wordbank:
            if i[0] == target[0] and len(i)<=len(target):
                temp_check = True
                for j in range(1,len(i)):
                    if i[j] != target[j]:
                        temp_check = False
                        break

                if temp_check is True:
                    new_target = target[len(i):len(target)]
                    dict_can_construct[target] = can_construct_dp(new_target, wordbank, dict_can_construct)
                    return dict_can_construct[target]

        dict_can_construct[target] = False
        return dict_can_construct[target]


wordBank = ['e','ee','eee','a','fe','fee']
target = "aaaeeeeeeeeeeeeeeeeeeeeeeefefefeef"
dict_can_construct = {}
print(can_construct_dp(target, wordBank, dict_can_construct))
print(dict_can_construct)

