

%% If we do it in a recursive way
clc
clear
fib(20)

%% If we do it in a dynamic programming fashion
clc
clear
num = input("Please input the serial number you want: num = ");

note_book = kron((0:1:num),[1;0;0]);

[reu, note_book] = fib_dp(num,note_book);

reu

%% Now we focus on the grid traveler issue
clc
clear
row_num = input("Please input the row number you want: row = ");
col_num = input("Please input the row number you want: column = ");

% Some basic rules
% Rule: when either row number or column number is 0, the answer is 0
% Rule: when either row number or column number is 1, the answer is 0

% Note that if we want the keys to be strings, then we need to define them
% in advance
dict_grid = dictionary(string([]),[]);
[reu, dict_grid] = grid_dp(row_num, col_num, dict_grid);

reu

%% Can-Sum problem
% Given a target number and a list of possible choices. Suppose we can use an arbitrary number on "selections" for nonnegative times,
% can we get the target number?
clc
clear
target_num = 7;
selections = [2,3,4,5,6];
dict_can_sum = dictionary(double([]),boolean([]));

if target_num == 0
    reu = false;
else
    [reu, dict_can_sum] = can_sum_recursive(target_num, selections, dict_can_sum);
end

reu


