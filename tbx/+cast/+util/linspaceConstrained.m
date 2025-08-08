function vals = linspaceConstrained(xs,N)
    % Creates linearly spaced vector including all points in xs.
    %
    % Returns N equally spaced points that include all points in xs, with 
    % additional points distributed proportionally based on the spacing 
    % between consecutive points in xs.
    %
    % Args:
    %     xs (double): Vector of constraint points that must be included in 
    %                  output. Must be sorted in ascending order.
    %     N (double): Total number of points desired. Must be >= length(xs).
    %
    % Returns:
    %     double: Vector of N points including all points from xs.
    %
    % Raises:
    %     error: If N < length(xs) or if xs is not sorted in ascending order.
    %
    % Example:
    %     % Create 11 points between 0 and 1 (equivalent to linspace)
    %     vals = linspaceConstrained([0, 1], 11);
    %     
    %     % Create 11 points with constraints at 0, 0.3, and 1
    %     vals = linspaceConstrained([0, 0.3, 1], 11);
    
    % Input validation
    if N < length(xs)
        error('N (%d) must be >= length(xs) (%d)', N, length(xs))
    elseif N == length(xs)
        vals = xs(:)'; % Ensure row vector output
        return
    end
    
    % Ensure xs is sorted (required for proper interpolation)
    if ~issorted(xs)
        error('Input xs must be sorted in ascending order')
    end
    
    % Calculate number of additional points needed
    n_additional = N - length(xs);
    
    % Calculate segment lengths
    segment_lengths = diff(xs);
    total_length = sum(segment_lengths);
    
    % Distribute additional points proportionally to segment lengths
    if total_length == 0
        % All points in xs are the same - just return N copies
        vals = repmat(xs(1), 1, N);
        return
    end
    
    % Calculate proportional allocation
    proportions = segment_lengths / total_length;
    n_per_segment = proportions * n_additional;
    
    % Round to integers while preserving total
    n_per_segment_int = floor(n_per_segment);
    remainder = n_additional - sum(n_per_segment_int);
    
    % Distribute remainder to segments with largest fractional parts
    if remainder > 0
        fractional_parts = n_per_segment - n_per_segment_int;
        [~, sort_idx] = sort(fractional_parts, 'descend');
        n_per_segment_int(sort_idx(1:remainder)) = n_per_segment_int(sort_idx(1:remainder)) + 1;
    end
    
    % Build the output vector
    vals = xs(1); % Start with first point
    
    for i = 1:length(segment_lengths)
        % Create points for this segment (excluding start point, including end point)
        n_points_in_segment = n_per_segment_int(i) + 2; % +2 for start and end
        segment_points = linspace(xs(i), xs(i+1), n_points_in_segment);
        vals = [vals, segment_points(2:end)]; % Append all but first point
    end
end


    
    