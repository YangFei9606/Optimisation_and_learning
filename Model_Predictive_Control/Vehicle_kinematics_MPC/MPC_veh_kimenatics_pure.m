clc
clear

close all

Ts = 0.1;         % 采样周期
Np = 10;          % 预测步长
Nsim = 500;        % 仿真步数
L = 2.5;          % 轴距
nx = 4;           % 状态维数
nu = 2;           % 输入维数

Q = diag([20, 20, 5, 0.5]);   % 状态误差权重
R = diag([0.1, 0.1]);         % 控制输入权重
x0 = [0; 0; 0; 5];            % 初始状态 [X; Y; psi; v]

t = (0:Nsim-1)*Ts;
t_pred = (0:Nsim+Np-2)*Ts;
radius = 20;
omega = 0.5; % 角速度
ref = [radius*cos(omega*t)+5; radius*sin(omega*t)+5; omega*t; 5*ones(1,Nsim)];
ref_pred = [radius*cos(omega*t_pred)+5; radius*sin(omega*t_pred)+5; omega*t_pred; radius*omega*ones(1,Nsim + Np - 1)];
% [X_ref; Y_ref; psi_ref; v_ref]

x = x0;
X_log = zeros(nx, Nsim);
U_log = zeros(nu, Nsim);

% optimoptions 是 MATLAB 中用于创建和修改优化器选项的函数。
% 它常用于设置如 fmincon、quadprog、lsqnonlin 等优化函数的求解精度、最大迭代次数、显示方式等参数。
% 用法：options = optimoptions('优化器名称', '参数1', 值1, '参数2', 值2, ...);
% 常见参数举例（以 fmincon 为例）
% 'Display'：控制输出信息（如 'off', 'iter', 'final'）
% 'MaxIterations'：最大迭代次数
% 'OptimalityTolerance'：最优性容差（越小越精确）
% 'StepTolerance'：步长容差
% 'Algorithm'：选择算法（如 'interior-point', 'sqp'）

options = optimoptions('fmincon','Display','off','OptimalityTolerance',1e-4,'StepTolerance',1e-6);

% fmincon是一个非线性优化求解器

for k = 1:Nsim
    % 构造参考轨迹
    % if k+Np-1 <= Nsim
    %     r = ref(:,k:k+Np-1);
    % else
    %     r = [ref(:,k:end), repmat(ref(:,end),1,Np-(Nsim-k+1))];
    % end

    % 假设参考轨迹会延伸（对于预测窗口超出任务执行时间的情况）
    % pre_window = (k -1: k + Np - 2) * Ts;
    % r = [radius*cos(omega*pre_window)+5; radius*sin(omega*pre_window)+5; omega*pre_window; 5*ones(1,Np)];
    r = ref_pred(:,k:k+Np-1);

    % 优化变量初值
    if k == 1
        % 第一次求解就初始化为0
        u_init = zeros(nu*Np,1);
    else
        % 之后的求解可以重复利用之前求解过的控制输入，也就是补足一个最远端的控制输入就可以
        u_init = [U_opt(nu+1:end); zeros(nu,1)];
    end

    % 输入约束
    amin = -3; amax = 2;           % 加速度约束
    dmin = -0.5; dmax = 0.5;       % 前轮转角约束（弧度）
    % repmat是扩展
    lb = repmat([amin; dmin], Np, 1);
    ub = repmat([amax; dmax], Np, 1);

    % 目标函数
    costfun = @(U) mpc_bicycle_cost(x, U, r, Ts, L, Q, R, nx, nu, Np);

    % 优化
    U_opt = fmincon(costfun, u_init, [], [], [], [], lb, ub, [], options);

    % 只取第一个控制量
    u_apply = U_opt(1:nu);

    % 系统更新
    x = bicycle_model(x, u_apply, Ts, L);

    % 记录
    X_log(:,k) = x;
    U_log(:,k) = u_apply;
end

figure;
plot(ref(1,:), ref(2,:), 'r--', 'LineWidth',1.5); hold on;
plot(X_log(1,:), X_log(2,:), 'b-', 'LineWidth',1.5);
legend('参考轨迹','车辆轨迹');
xlabel('X (m)'); ylabel('Y (m)'); axis equal; grid on;
title('车辆MPC路径跟踪');

figure;
subplot(2,1,1);
plot(t, U_log(1,:), 'b'); ylabel('加速度 a (m/s^2)');
subplot(2,1,2);
plot(t, U_log(2,:), 'r'); ylabel('前轮转角 \delta (rad)');
xlabel('时间 (s)');

figure;
hold on;
subplot(2,1,1)
plot(t, X_log(1,:) - ref(1,:), 'r--');
subplot(2,1,2)
plot(t, X_log(2,:) - ref(2,:), 'r--');
xlabel('时间 (s)');
