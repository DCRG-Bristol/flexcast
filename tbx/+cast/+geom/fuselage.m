function [fuselage,Ls] = fuselage(L_cabin,D_cabin,opts)
    % returns fuselage length and diameter based on cabin dimensions
    % L_cabin = cabin length in meters
    % D_cabin = cabin diameter in meters
    % opts.L_cp = cockpit length in meters
    % opts.L_tail = tail length in meters
    % output:
    % fuselage = baff.BluffBody object
    % Ls postion of nosecabin start and end;
    arguments
        L_cabin (1,1) double {mustBeNumeric} % cabin length in meters
        D_cabin (1,1) double {mustBeNumeric} % cabin diameter in meters
        opts.L_cp (1,1) double {mustBeNumeric} = 4 % cockpit length in meters
        opts.L_tail = D_cabin*1.6 % tail length in meters
        opts.IsDraggable = true % make fuselage contribute to Drag
    end
    L_f = L_cabin + opts.L_cp + opts.L_tail;  % fuselage length

    x_c = D_cabin*1.3;              % transition point from cockpit to cabin
    x_tail = L_f-D_cabin*3;         % transition point from cabin to tail

    % make cockpit object
    cockpit = baff.BluffBody.SemiSphere(x_c,D_cabin/2);
    [cockpit.Stations.EtaDir] = deal([1;0;tand(4)]);
    % make cabin object
    cabin = baff.BluffBody.Cylinder(x_tail-x_c,D_cabin/2);
    % make tail object
    tail = baff.BluffBody.SemiSphere(L_f-x_tail,D_cabin/2,"Inverted",true,"EtaFrustrum",0.05);
    % tweak tail so top of fuselage in straight line
    for i = 1:(length(tail.Stations)-1)
        dEta = tail.Stations(i+1).Eta - tail.Stations(i).Eta;
        dRadius = tail.Stations(i).Radius - tail.Stations(i+1).Radius;
        tail.Stations(i).EtaDir = [1;0;dRadius./dEta./tail.EtaLength];
    end

    % conbine into a fuselage
    fuselage = cockpit + cabin + tail;
    fuselage.Name = "fuselage";
    fuselage.A = baff.util.rotz(180);
    for i = 1:length(fuselage.Stations)
        fuselage.Stations(i).EtaDir(1) = -fuselage.Stations(i).EtaDir(1);
        fuselage.Stations(i).StationDir = [0;0;1];
    end
    % make fuselage contribute to Drag
    if opts.IsDraggable
        fuselage = cast.drag.DraggableBluffBody(fuselage);
    end
    Ls = [0,opts.L_cp, opts.L_cp+L_cabin, L_f];
end