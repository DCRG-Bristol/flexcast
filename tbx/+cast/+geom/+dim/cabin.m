function [L,D] = cabin(PAX,opts)
    arguments
        PAX (1,1) double {mustBeInteger}    % passengers
        opts.N_sr (1,1) double {mustBeInteger} = 0 % seats per row
    end
    % retruns estimated cabin length and diameter based on number of passengers
    % PAX = number of passengers
    % L = length in meters
    % D = diameter in meters

    %estimate number of seats per row, aisles, armrests, and rows
    if opts.N_sr == 0
        N_sr = max(6,round(0.45*sqrt(PAX)));
    else
        N_sr = opts.N_sr;
    end
    N_a = ads.util.tern(N_sr>6,2,1);   % number of aisles
    N_arm = N_sr+1+N_a;                 % number of armrests
    Nr = ceil(PAX/N_sr);                % number of rows

    % constants based on existing aircraft
    if N_a >1
        % A350 Like
        k_cabin = 1.17;
        delta_d = 0.46;
    else
        % A320 like
        k_cabin = 0.7456;
        delta_d = 0.48;
    end

    % calculate cabin length and diameter
    L = Nr*k_cabin;
    % constants from a320 charteristics
    D = (N_sr*18 + N_arm*1.5 + N_a*19)./cast.SI.inch + delta_d; % fuselage diameter
end