function [result, dictionary] = can_sum_dp(target, selections, dictionary)

if target == 0
    result = true;
elseif target < 0
    result = false;
else
    keys_now = keys(dictionary);
    flag = 0;
    if min(size(keys_now))>0
        for i = 1 : max(size(keys_now))
            if keys_now(i) == target
                result = dictionary(target);
                flag = 1;
                break;
            end
        end
    end
    if flag == 0
        result = false;
        for i = 1 : size(selections, 2)
            [temp, dictionary] = can_sum_dp(target - selections(i), selections, dictionary);
            if temp == true
                result = true;
                break;
            end
        end
    end

    dictionary(target) = result;
end
end

