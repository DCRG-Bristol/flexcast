function res = dynBoundary(res,x,value,opts)
arguments
    res
    x
    value
    opts.target = 0
    opts.UpdateBoundary = true
end
% Bounded gradient descent - appends a guess to the data structure res
% and then performs a gradient descent to find the next guess.
if isempty(res) || isempty(fieldnames(res))
    n = 1;
else
    n = length(res)+1;
end
res(n).N = n;
res(n).X = x;
res(n).Y = value;
res(n).Delta = value - opts.target;
if opts.UpdateBoundary
%% update boundary
if n == 1
    % if the first guess, set the boundary to be the entire space
    res(n).Bounds = [-inf inf;-inf inf];
elseif n == 2
    res(n).Bounds = get_boundary(res);
else
    if any(isinf(res(n-1).Bounds),'all')
        % yet to find a boundary so update it from the guesses with biggest delta
        [delta,idx_s] = sort([res.Delta]);
        if sign(delta(1))~=sign(delta(end))
            % a boundary exists
            [~,idx_cross] = find(delta>0,1);
            idx_max = idx_s(idx_cross);
            idx_min = idx_s(idx_cross-1);
        else
            [~,idx_min] = min(delta);
            [~,idx_max] = max(delta);
        end
        res(n).Bounds = get_boundary(res([idx_min,idx_max]));
    else
        %update boundary
        b = res(n-1).Bounds;
        if res(n).X > b(1,2) || res(n).X < b(1,1)
            error('CAST:SizingError','The Guess was not within the boundary of the previous guesses')
        end
        %add current guess to middle of bounds
        b = [b(:,1),[x;value],b(:,2)];
        % pick the pair that has the zero crossing
        if sign(b(2,1))~=sign(b(2,2)) && sign(b(2,3))~=sign(b(2,2))
            error('CAST:SizingError','more than one zero crossing in boundary')
        elseif sign(b(2,1))~=sign(b(2,2))
            res(n).Bounds = b(:,1:2);
        else
            res(n).Bounds = b(:,2:3);
        end
    end
end
end
end

function boundary = get_boundary(res)
if res(1).X > res(2).X
    res = res([2,1]);
end
if sign(res(2).Delta)~= sign(res(1).Delta)
    boundary = [res(1).X,res(2).X;res(1).Delta res(2).Delta];
else
    %setup intial boundary
    m = (res(2).X - res(1).X)/(res(2).Delta - res(1).Delta);
    X_0 = res(1).X - res(1).Delta*m;
    if abs(X_0-res(1).X)<abs(X_0-res(2).X)
        boundary = [-inf,res(1).X;-1*sign(res(1).Delta)*inf,res(1).Delta];
    else
        boundary = [res(2).X,inf;res(2).Delta,-1*sign(res(2).Delta)*inf];
    end
end
end
