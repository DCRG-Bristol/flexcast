function val = gd(res,hunt_step,max_step)
    arguments
        res struct
        hunt_step double = 1e-3
        max_step double = inf;
    end
    if length(res)==1     
        val = res(1).X + hunt_step;
    else
        m = (res(end).X - res(end-1).X) / (res(end).Delta - res(end-1).Delta);
        val = res(end).X - m*res(end).Delta;
    end
    delta = val-res(end).X;
    if abs(delta)>abs(max_step)
        val = res(end).X + sign(delta)*abs(max_step);
    end
end