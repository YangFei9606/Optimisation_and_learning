% 带有系统不确定性的线性系统MPC追踪控制
clear all;
close all;
clc;

% 系统参数
Ts = 0.1;           % 采样时间
Np = 20;            % 预测时域
Nc = 5;             % 控制时域
nx = 2;             % 状态维度
nu = 1;             % 输入维度

% 系统矩阵（标称模型）
A_nominal = [1 Ts; 0 1];
B_nominal = [0.5*Ts^2; Ts];

% 不确定性范围
delta_A = 0.1;      % 状态矩阵不确定性
delta_B = 0.1;      % 输入矩阵不确定性

% 约束条件
x_min = [-10; -5];  % 状态下限
x_max = [10; 5];    % 状态上限
u_min = -2;         % 输入下限
u_max = 2;          % 输入上限

% 权重矩阵
Q = diag([10, 1]);  % 状态权重
R = 0.1;            % 输入权重

% 参考轨迹生成
t = 0:Ts:20;
x_ref = zeros(2, length(t));
x_ref(1,:) = sin(0.2*t);  % 位置参考
x_ref(2,:) = 0.2*cos(0.2*t);  % 速度参考

% 初始化
x = zeros(nx, length(t));  % 状态序列
u = zeros(nu, length(t));  % 控制输入序列
x(:,1) = [0; 0];          % 初始状态

% MPC控制循环
for k = 1:length(t)-1
    % 构建预测模型
    [A_pred, B_pred] = build_prediction_model(A_nominal, B_nominal, Np, delta_A, delta_B);
    
    % 构建约束矩阵
    [A_con, b_con] = build_constraints(Np, Nc, x_min, x_max, u_min, u_max, x(:,k));
    
    % 构建目标函数
    [H, f] = build_objective_function(A_pred, B_pred, Q, R, Np, Nc, x(:,k), x_ref(:,k:k+Np-1));
    
    % 求解QP问题
    options = optimoptions('quadprog', 'Display', 'off');
    u_opt = quadprog(H, f, A_con, b_con, [], [], [], [], [], options);
    
    % 提取最优控制输入
    u(k) = u_opt(1);
    
    % 系统更新（考虑不确定性）
    A_actual = A_nominal + delta_A * randn(size(A_nominal));
    B_actual = B_nominal + delta_B * randn(size(B_nominal));
    x(:,k+1) = A_actual * x(:,k) + B_actual * u(k);
end

% 绘制结果
figure;
subplot(3,1,1);
plot(t, x(1,:), 'b-', t, x_ref(1,:), 'r--');
title('位置追踪');
xlabel('时间 (s)');
ylabel('位置');
legend('实际位置', '参考位置');
grid on;

subplot(3,1,2);
plot(t, x(2,:), 'b-', t, x_ref(2,:), 'r--');
title('速度追踪');
xlabel('时间 (s)');
ylabel('速度');
legend('实际速度', '参考速度');
grid on;

subplot(3,1,3);
plot(t(1:end-1), u, 'b-');
title('控制输入');
xlabel('时间 (s)');
ylabel('控制输入');
grid on;

% 辅助函数：构建预测模型
function [A_pred, B_pred] = build_prediction_model(A, B, Np, delta_A, delta_B)
    nx = size(A,1);
    nu = size(B,2);
    
    % 考虑最坏情况的不确定性
    A_worst = A + delta_A * ones(size(A));
    B_worst = B + delta_B * ones(size(B));
    
    A_pred = zeros(nx*Np, nx);
    B_pred = zeros(nx*Np, nu*Np);
    
    for i = 1:Np
        A_pred((i-1)*nx+1:i*nx,:) = A_worst^i;
        for j = 1:i
            B_pred((i-1)*nx+1:i*nx,(j-1)*nu+1:j*nu) = A_worst^(i-j)*B_worst;
        end
    end
end

% 辅助函数：构建约束矩阵
function [A_con, b_con] = build_constraints(Np, Nc, x_min, x_max, u_min, u_max, x0)
    nx = length(x0);
    nu = 1;
    
    % 状态约束
    A_x = [eye(nx*Np); -eye(nx*Np)];
    b_x = [repmat(x_max, Np, 1); -repmat(x_min, Np, 1)];
    
    % 输入约束
    A_u = [eye(nu*Nc); -eye(nu*Nc)];
    b_u = [repmat(u_max, Nc, 1); -repmat(u_min, Nc, 1)];
    
    % 组合约束
    A_con = [A_x; A_u];
    b_con = [b_x; b_u];
end

% 辅助函数：构建目标函数
function [H, f] = build_objective_function(A_pred, B_pred, Q, R, Np, Nc, x0, x_ref)
    nx = size(Q,1);
    nu = size(R,1);
    
    % 构建扩展权重矩阵
    Q_ext = kron(eye(Np), Q);
    R_ext = kron(eye(Nc), R);
    
    % 构建Hessian矩阵
    H = B_pred'*Q_ext*B_pred + R_ext;
    
    % 构建线性项
    f = 2*B_pred'*Q_ext*(A_pred*x0 - x_ref(:));
end 