function [c,ceq]=nonlinearcon(x)
    c = [x(1)^2 - x(2),x(1)+x(2)-2];
    ceq = [];