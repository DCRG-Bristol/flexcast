function val = bounded_gd(res,hunt_step,max_step)
    arguments
        res struct
        hunt_step double = 1e-3
        max_step double = inf;
    end
    bounds = res(end).Bounds(1,:);
    deltas = res(end).Bounds(2,:);
    if any(isinf(bounds))
        %% go hunt for the other side of the boundary
        if length(res)==1     
            val = res(1).X + hunt_step;
        else
            m = (res(end).X - res(end-1).X) / (res(end).Delta - res(end-1).Delta);
            c = res(end).X - m*res(end).Delta;
            val = m*(-0.382*res(end).Delta) + c;
        end   
        delta = val-res(end).X;
        if abs(delta)>abs(max_step)
            val = res(end).X + sign(delta)*abs(max_step);
        end
    else
        % valid boundary, first attempt gradient decent
        m = (bounds(2) - bounds(1)) / (deltas(2) - deltas(1));
        c = bounds(1) - m*deltas(1);
        val = m*0 + c;
        % if that guess is outside/too close to boundary, then use golden section search
        b_delta = bounds(2) - bounds(1);
        if val < bounds(1)+b_delta*0.05 || val > bounds(2)-b_delta*0.05
            val = cast.util.ternary(abs(deltas(2))<abs(deltas(1)),bounds(1)+b_delta*0.618,bounds(1)+b_delta*0.382);
        end
    end
end