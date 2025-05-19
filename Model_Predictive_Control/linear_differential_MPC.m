%% MPC codes without MPC toolbox
clc
clear

%% 发现的问题：
% 当我们维持预测步长不变，减小系统的控制周期长度（T_s）时，会出现系统不稳定/发散的情况
% 当A矩阵中包含T_s时，A的特征值会更接近1，导致慢性漂移或发散
% 在同一预测步长下，更短的周期意味着算法更短视，预测时间更短，惩罚变少，控制器容易更激进

%% Differential MPC for linear systems
% (1) No input constraints
% (2) Differential structure

Ts = 0.02;
A = [1 Ts; 0 1];
B = [0.5*Ts^2; Ts];
C = [1 0];
nx = size(A,1);
nu = size(B,2);
ny = size(C,1);

Np = 50; % 预测步长
Q = 5;   % 输出误差权重
R = 0.1; % 控制增量权重

Nsim = 5000;
t = (0:Nsim-1)*Ts;
ref = 1 + sin(0.2*t); % 期望轨迹

% 累加矩阵
T = tril(ones(Np));

Phi = zeros(Np*ny, nx);
Gamma = zeros(Np*ny, Np*nu);
for i = 1:Np
    Phi((i-1)*ny+1:i*ny,:) = C*A^i;
    for j = 1:i
        Gamma((i-1)*ny+1:i*ny, (j-1)*nu+1:j*nu) = C*A^(i-j)*B;
    end
end

x = [0; 0];
y = zeros(1,Nsim);
u = zeros(1,Nsim);
u_prev = 0; % 初始输入


Qbar = kron(eye(Np), Q);
Rbar = kron(eye(Np), R);

for k = 1:Nsim
    % 构造参考轨迹向量
    if k+Np-1 <= Nsim
        r = ref(k:k+Np-1)';
    else
        r = [ref(k:end) repmat(ref(end),1,Np-(Nsim-k+1))]';
    end

    % 差分MPC预测
    % 未来输入序列: U = u_prev*ones(Np,1) + T*DeltaU
    % 未来输出: Y = Phi*x + Gamma*U
    %         = Phi*x + Gamma*(u_prev*ones(Np,1) + T*DeltaU)
    %         = (Phi*x + Gamma*u_prev*ones(Np,1)) + Gamma*T*DeltaU
    %         = Y0 + Gd*DeltaU

    Y0 = Phi*x + Gamma*u_prev*ones(Np,1);
    Gd = Gamma*T;

    % QP目标
    H = Gd'*Qbar*Gd + Rbar;
    f = Gd'*Qbar*(Y0 - r);

    % 无约束直接解析解
    deltaU = -H\f;

    % 只取第一个Δu
    if isempty(deltaU)
        du = 0;
    else
        du = deltaU(1);
    end
    u(k) = u_prev + du;

    % 系统更新
    x = A*x + B*u(k);
    y(k) = C*x;
    u_prev = u(k);
end

figure;
subplot(3,1,1);
plot(t, ref, 'r--', t, y, 'b');
legend('参考轨迹','系统输出');
xlabel('时间 (s)');
ylabel('输出');
title('无约束差分MPC轨迹跟踪');

subplot(3,1,2);
stairs(t, u, 'k');
xlabel('时间 (s)');
ylabel('控制输入');
title('MPC控制输入');

subplot(3,1,3);
plot(t, ref - y, 'b');
legend('跟踪误差');
xlabel('时间 (s)');
ylabel('输出');
