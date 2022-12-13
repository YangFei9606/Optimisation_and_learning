function [result, dictionary] = can_sum_recursive(target, selections, dictionary)

if target == 0
    result = true;
elseif target < 0
    result = false;
else
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
