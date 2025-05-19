function dx = nonlinear_f(x, u)
    % 2维状态2维输入示例
    dx = [-x(1) + sin(u(1));
          -x(2) + cos(u(2))];
end