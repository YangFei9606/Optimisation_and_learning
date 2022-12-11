function [reu, note_book] = fib_dp(num, note_book)

    if note_book(3,num) == 1
        reu = note_book(2,num);
    else
        if num<=2
            note_book(2,num) = 1;
            reu = 1;
            note_book(3,num) = 1;
        else
            [temp_2, note_book] = fib_dp(num-2, note_book);
            [temp_1, note_book] = fib_dp(num-1, note_book);
            reu = temp_1 + temp_2;
            note_book(2, num) = reu;
            note_book(3, num) = 1;
        end

    end

end
