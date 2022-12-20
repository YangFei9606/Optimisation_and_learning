def can_construct_dp(target, wordbank, dict_can_construct):
    if target == "":
        return True
    elif len(wordbank) <= 0:
        return False
    elif dict_can_construct.get(target) is not None:
        return dict_can_construct.get(target)
    else:
        temp_result = False
        for i in wordbank:
            if len(i)<=len(target):
                temp_check = True
                for j in range(0,len(i)):
                    if i[j] != target[j]:
                        temp_check = False
                        break
                if temp_check is True:
                    new_target = target[len(i):len(target)]
                    temp_result = temp_result or can_construct_dp(new_target, wordbank, dict_can_construct)

            if temp_result is True:
                dict_can_construct[target] = True
                return True

        dict_can_construct[target] = False
        return dict_can_construct[target]


wordBank = ['e','ee','eee','a','feee']
target = "aaaeeeeeeeeeeeeeeeeeeeeeeefefefee"

# wordBank = ['a','p','ent','enter','ot','o','t']
# target = "enterapotentpot"


dict_can_construct = {}
print(can_construct_dp(target, wordBank, dict_can_construct))
print(dict_can_construct)

