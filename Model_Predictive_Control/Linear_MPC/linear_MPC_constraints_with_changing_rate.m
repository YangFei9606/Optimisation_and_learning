%% MPC codes without MPC toolbox
clc
clear

%% MPC for linear systems
% (1) With input constraints (input saturation + limited changing rate)
% (2) Control steps fewer than prediction steps

% 离散时间系统参数
Ts = 0.02;
A = [1 Ts; 0 1];
B = [0.5*Ts^2; Ts];
C = [1 0];
nx = size(A,1);
nu = size(B,2);
ny = size(C,1);

Np = 10; % 预测步长
Nc = 5;
Q = 5;   % 输出误差权重
R = 0.1; % 控制输入权重
umin = -0.1; % 输入下限
umax = 0.1;  % 输入上限
dumin = -0.1; % 最小变化率
dumax = 0.1;  % 最大变化率

Nsim = 5000;
t = (0:Nsim-1)*Ts;
ref = sin(0.2*t); % 期望轨迹

% 预测矩阵
Phi = zeros(Np*ny, nx);
Gamma = zeros(Np*ny, Np*nu);
for i = 1:Np
    Phi((i-1)*ny+1:i*ny,:) = C*A^i;

    if i <= Nc
        for j = 1 : i
            Gamma((i-1)*ny+1:i*ny, (j-1)*nu+1:j*nu) = C*A^(i-j)*B;
        end
    else
        for j = 1 : Nc
            if j == Nc
                for k = 0 : i - Nc
                    Gamma((i-1)*ny+1:i*ny, (j-1)*nu+1:j*nu) = Gamma((i-1)*ny+1:i*ny, (j-1)*nu+1:j*nu) + C*A^k*B;
                end      
            else
                Gamma((i-1)*ny+1:i*ny, (j-1)*nu+1:j*nu) = C*A^(i-j)*B;
            end
        end
    end

    
end

Qbar = kron(eye(Np), Q);
Rbar = kron(eye(Np), R);

x = [0; 0];
y = zeros(1,Nsim);
u = zeros(1,Nsim);

options = optimoptions('quadprog','Display','off');
u_prev = 0; % 初始输入

for k = 1:Nsim
    % 构造参考轨迹向量
    if k+Np-1 <= Nsim
        r = ref(k:k+Np-1)';
    else
        r = [ref(k:end) repmat(ref(end),1,Np-(Nsim-k+1))]';
    end

    % QP目标
    H = Gamma'*Qbar*Gamma + Rbar;
    f = Gamma'*Qbar*(Phi*x - r);

    % 输入约束
    lb = umin*ones(Np,1);
    ub = umax*ones(Np,1);

    % 变化率约束
    % 构造差分矩阵
    E = eye(Np);
    E = E - [zeros(1,Np); eye(Np-1,Np)];
    % E*u = [u1-u0; u2-u1; ...; uNp-uNp-1]
    % 其中u0为上一次实际输入
    % 所以E*u = du, 其中第一个元素是u1-u0

    % 变化率上下限
    lb_du = dumin*ones(Np,1);
    ub_du = dumax*ones(Np,1);
    % 第一个元素是u1-u_prev
    lb_du(1) = dumin + u_prev;
    ub_du(1) = dumax + u_prev;
    % 其余是du(i) = u(i)-u(i-1)

    % 线性不等式
    A_du = [ E; -E ];
    b_du = [ ub_du; -lb_du ];

    % QP求解
    du = quadprog(H, f, A_du, b_du, [], [], lb, ub, [], options);

    % 只取第一个控制量
    u(k) = du(1);

    % 系统更新
    x = A*x + B*u(k);
    y(k) = C*x;
    u_prev = u(k); % 更新上一次输入
end

figure;
subplot(3,1,1);
plot(t, ref, 'r--', t, y, 'b');
legend('参考轨迹','系统输出');
xlabel('时间 (s)');
ylabel('输出');
title('无约束MPC轨迹跟踪');

subplot(3,1,2);
stairs(t, u, 'k');
xlabel('时间 (s)');
ylabel('控制输入');
title('MPC控制输入');

subplot(3,1,3)
plot(t, ref - y, 'r--');
xlabel('时间 (s)');
ylabel('控制误差');
