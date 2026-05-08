function vals = linspaceConstrained(xs,N)
    if N<length(xs)
        error('N less than length of array')
    elseif N == length(xs)
        vals = xs;
        return
    end
    N = N - length(xs);
    delta = xs(2:end)-xs(1:end-1);
    delta = delta./(xs(end)-xs(1));
    Ns = round(delta*N);
    while sum(Ns)~= N
        if sum(Ns)>N
            [~,idx] = max(Ns);
            Ns(idx) = Ns(idx)-1;
        else
            [~,idx] = min(Ns);
            Ns(idx) = Ns(idx)+1;
        end
    end
    vals = linspace(xs(1),xs(2),2+Ns(1));
    for i = 2:length(xs)-1
        tmp = linspace(xs(i),xs(i+1),2+Ns(i));
        vals = [vals,tmp(2:end)];
    end
    end
    
    function vals = AddUntillFill(vals,gap)
    delta = vals(2:end)-vals(1:end-1);
    [md,idx] = max(abs(delta));
    while md>gap
        new_val = vals(idx) + (vals(idx+1)-vals(idx))*0.5;
        vals = [vals(1:idx),new_val,vals((idx+1):end)];
        delta = vals(2:end)-vals(1:end-1);
        [md,idx] = max(abs(delta));
    end
    end
    
    