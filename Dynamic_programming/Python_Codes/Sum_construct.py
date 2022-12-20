def can_construct_dp(target, wordbank, dict_can_construct):
    if target == "":
        return 1
    elif len(wordbank) <= 0:
        return 0
    elif dict_can_construct.get(target) is not None:
        return dict_can_construct.get(target)
    else:
        temp_result = 0
        for i in wordbank:
            if len(i)<=len(target):
                temp_check = True
                for j in range(0,len(i)):
                    if i[j] != target[j]:
                        temp_check = False
                        break
                if temp_check is True:
                    new_target = target[len(i):len(target)]
                    temp_result = temp_result + can_construct_dp(new_target, wordbank, dict_can_construct)

        dict_can_construct[target] = temp_result
        return dict_can_construct[target]


# wordBank = ['e','ee','eee','a','feee']
# target = "aaaeeeeeeeeeeeeeeeeeeeeeeefefefee"

wordBank = ['a','p','ent','enter','ot','o','t']
target = "enterapotentpot"

# wordBank = ['purp','p','ur','le','purpl']
# target = "purple"


dict_can_construct = {}
print(can_construct_dp(target, wordBank, dict_can_construct))
print(dict_can_construct)

