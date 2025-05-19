function J = nonlinear_mpc_cost_multi(x0, U, r, Ts, Q, R, nx, nu, ny)
    Np = size(r,2);
    x = x0;
    J = 0;
    for i = 1:Np
        ui = U((i-1)*nu+1:i*nu);
        x = x + Ts * nonlinear_f(x, ui);
        y = nonlinear_h(x);
        e = y - r(:,i);
        J = J + e'*Q*e + ui'*R*ui;
    end
end