function reu = find_str_array(array, element)
reu = [0,0];
for i = 1:size(array,1)
    for j = 1:size(array,2)
        if array(i,j) == element
            reu = [i,j];
            break;
        end
    end
end

end

