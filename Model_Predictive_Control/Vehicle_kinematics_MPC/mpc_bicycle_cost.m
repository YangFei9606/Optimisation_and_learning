function J = mpc_bicycle_cost(x0, U, r, Ts, L, Q, R, nx, nu, Np)
    x = x0;
    J = 0;
    for i = 1:Np
        ui = U((i-1)*nu+1:i*nu);
        x = bicycle_model(x, ui, Ts, L);
        e = x - r(:,i);
        J = J + e'*Q*e + ui'*R*ui;
    end
end