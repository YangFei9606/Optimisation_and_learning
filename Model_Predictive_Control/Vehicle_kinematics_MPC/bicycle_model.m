function x_next = bicycle_model(x, u, Ts, L)
    % x = [X; Y; psi; v]
    % u = [a; delta]
    X = x(1); Y = x(2); psi = x(3); v = x(4);
    a = u(1); delta = u(2);

    X_next = X + Ts * v * cos(psi);
    Y_next = Y + Ts * v * sin(psi);
    psi_next = psi + Ts * v / L * tan(delta);
    v_next = v + Ts * a;

    x_next = [X_next; Y_next; psi_next; v_next];
end