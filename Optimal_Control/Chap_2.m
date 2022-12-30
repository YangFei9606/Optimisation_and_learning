% This file contains some of the test codes I have for Chapter 2
% The penelty function one still requires correction (Something wrong)

%% 2-8 Gradient decent
%% Method 1: Hand-written derivatives
clc
clear
x_1 = 0.75;
x_2 = -1.25;

f_x = x_1^4 + x_1 * x_2 + (x_2+1)^2;
grad_f = [4 * x_1^3 + x_2; x_1 + 2 * x_2 + 2];
H_x = [12 * x_1^2, 1; 1, 2];
x_now = [x_1;x_2];

i = 0;
threshold = - grad_f;
epsilon = 10^(-3);

while norm(threshold) > epsilon
    step = grad_f' * grad_f/(grad_f' * H_x * grad_f);
    x_next = x_now - step * grad_f;
    x_1 = x_next(1);
    x_2 = x_next(2);

    f_x = x_1^4 + x_1 * x_2 + (x_2+1)^2;
    grad_f = [4 * x_1^3 + x_2; x_1 + 2 * x_2 + 2];
    H_x = [12 * x_1^2, 1; 1, 2];
    threshold = - grad_f;
    i = i + 1;
    x_now = x_next;
end

x_now
f_now

%% Method 2: MATLAB calculated
clc
clear
syms x_1 x_2
x_now = [0.75;-1.25];
epsilon_1 = 10^(-4);

f_now = x_1^4 + x_1 * x_2 + (x_2+1)^2;
grad_now = jacobian(f_now,[x_1,x_2]);
h_x_now = jacobian(grad_now,[x_1,x_2]);

grad_temp = double(subs(grad_now,[x_1,x_2],x_now'));
i_1 = 0;

while norm(grad_temp) > epsilon_1
    h_x_temp = double(subs(h_x_now,[x_1,x_2],x_now'));
    step = grad_temp * grad_temp'/(grad_temp * h_x_temp * grad_temp');
    x_now = x_now - step * grad_temp';

    f_now = double(subs(f_now,[x_1,x_2],x_now'));
    grad_temp = double(subs(grad_now,[x_1,x_2],x_now'));
    i_1 = i_1 + 1;

    if step > 100
        break;
    end
end

x_now
f_now

%% 2-9 Gradient decent
x_1 = -2;
x_2 = 4;

f_x = 1.5 * x_1^2 + 0.5 * x_2^2 - x_1 * x_2 - 2 * x_1;
grad_f = [3 * x_1 - x_2 - 2; x_2 - x_1];
H_x = [3, -1; -1, 1];
x_now = [x_1;x_2];

i = 0;
threshold = - grad_f;
epsilon = 10^(-3);

while norm(threshold) > epsilon
    step = grad_f' * grad_f/(grad_f' * H_x * grad_f);
    x_next = x_now - step * grad_f;
    x_1 = x_next(1);
    x_2 = x_next(2);

    f_x = 1.5 * x_1^2 + 0.5 * x_2^2 - x_1 * x_2 - 2 * x_1;
    grad_f = [3 * x_1 - x_2 - 2; x_2 - x_1];
    threshold = - grad_f;
    i = i + 1;
    x_now = x_next;
end

%% 2-13 Penalty function
% Something is wrong with this, needs correction.....
clear;
clc;
syms x_1 x_2 rho
alpha = 0.1;
epsilon_1 = 10^(-3);

x_now = [0;1];
rho_now = 100;

f_now = (x_1 - 2)^2 + (x_2 - 1)^2;
% cost_1 = rho * log(-x_1^2+x_2);
% cost_2 = rho * log(-x_1-x_2+2);

cost_1 = rho * (x_1^2-x_2)^(-1);
cost_2 = rho * (x_1+x_2-2)^(-1);
g_now = f_now + (cost_1 + cost_2);
grad_now = jacobian(g_now,[x_1,x_2]);
h_x_now = jacobian(grad_now,[x_1,x_2]);

i_1 = 0;
i_2 = 0;
epsilon_2 = 10^(-3);

x_all = x_now; 

while 1
    grad_temp = double(subs(grad_now,[x_1,x_2,rho],[x_now;rho_now]'));

    while norm(grad_temp) > epsilon_2
        h_x_temp = double(subs(h_x_now,[x_1,x_2,rho],[x_now;rho_now]'));
        step = grad_temp * grad_temp'/(grad_temp * h_x_temp * grad_temp');
        x_now = x_now - step * grad_temp';
        

        g_now = double(subs(g_now,[x_1,x_2,rho],[x_now;rho_now]'));
        grad_temp = double(subs(grad_now,[x_1,x_2,rho],[x_now;rho_now]'));
        i_1 = i_1 + 1;

        if step > 100
            break;
        end
    end

    x_all = [x_all,x_now];

    cost_1_now = double(subs(cost_1,[x_1,x_2,rho],[x_now;rho_now]'));
    cost_2_now = double(subs(cost_2,[x_1,x_2,rho],[x_now;rho_now]'));

    if (cost_1_now + cost_2_now < epsilon_1 ) && (cost_1_now>=0) && (cost_2_now>=0)
        fprintf("\nThe loop is over!\n");
        break;
    else
        rho_now = alpha * rho_now;
    end
    
    i_2 = i_2 + 1;
end

x_now
f_now = double(subs(f_now,[x_1,x_2,rho],[x_now;rho_now]'))


%% Optimisation with nonlinear and linear constrains (2-13)
% Video source: https://youtu.be/_Il7GQdL3Sk
clc
clear

fun = @(x) (x(1)-2)^2 + (x(2)-1)^2;
lb = [];
ub = [];
A = [];
b = [];
Aeq = [];
beq = [];
x0 = [0,1];
nonlcon = @nonlinearcon;
x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon)








