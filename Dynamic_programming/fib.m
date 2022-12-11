function reu = fib(num)
    if num<= 2
        reu = 1;
    else
        reu=fib(num-1) + fib(num-2);
    end
end