%% MPC codes without MPC toolbox
clc
clear

%% MPC for linear systems
% (1) Without input constraints
% (2) Nonlinear systems

Ts = 0.05;
Np = 20;      % 预测步长
Nsim = 1000;    % 仿真步数
nx = 2;       % 状态维数
nu = 2;       % 输入维数
ny = 2;       % 输出维数

Q = 10 * eye(ny);  % 输出误差权重
R = 0.1*eye(nu); % 控制输入权重
umin = [-2; -2]; % 输入下限
umax = [2; 2];   % 输入上限
x0 = [0; 0];     % 初始状态
t = (0:Nsim-1)*Ts;
ref = [sin(0.2*t); cos(0.2*t)]; % 2维参考轨迹

x = x0;
y = zeros(ny,Nsim);
u = zeros(nu,Nsim);

options = optimoptions('fmincon','Display','off');

for k = 1:Nsim
    % 构造参考轨迹向量
    if k+Np-1 <= Nsim
        r = ref(:,k:k+Np-1);
    else
        r = [ref(:,k:end), repmat(ref(:,end),1,Np-(Nsim-k+1))];
    end

    % 优化变量初值
    u_init = zeros(nu*Np,1);

    % 构造目标函数
    costfun = @(U) nonlinear_mpc_cost_multi(x, U, r, Ts, Q, R, nx, nu, ny);

    % 输入约束
    lb = repmat(umin, Np, 1);
    ub = repmat(umax, Np, 1);

    % 求解MPC优化
    U_opt = fmincon(costfun, u_init, [], [], [], [], lb, ub, [], options);

    % 只取第一个控制量
    u(:,k) = U_opt(1:nu);

    % 系统更新
    x = x + Ts * nonlinear_f(x, u(:,k));
    y(:,k) = nonlinear_h(x);
end

figure;
subplot(2,1,1);
plot(t, ref(1,:), 'r--', t, y(1,:), 'b', t, ref(2,:), 'g--', t, y(2,:), 'k');
legend('参考1','输出1','参考2','输出2');
xlabel('时间 (s)');
ylabel('输出');
title('多维非线性MPC轨迹跟踪');

subplot(2,1,2);
stairs(t, u(1,:), 'b'); hold on;
stairs(t, u(2,:), 'k');
xlabel('时间 (s)');
ylabel('控制输入');
legend('u1','u2');
title('MPC控制输入');

