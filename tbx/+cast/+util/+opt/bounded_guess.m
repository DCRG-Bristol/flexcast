function val = bounded_guess(res,guess)
    arguments
        res struct
        guess
    end
    bounds = res(end).Bounds(1,:);
    deltas = res(end).Bounds(2,:);
    val = guess;
    if ~any(isinf(bounds))
        if val<bounds(1) || val>bounds(2)
            %guess outside boundary try golden section search instead
            if abs(deltas(1))<abs(deltas(2))
                val = bounds(1)+0.382*(bounds(2)-bounds(1));
            else
                val = bounds(1)+0.618*(bounds(2)-bounds(1));
            end
        end
    end
end