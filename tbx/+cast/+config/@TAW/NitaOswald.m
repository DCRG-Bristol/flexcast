function [e,Q,P,KeM] = NitaOswald(obj,Mach)
%NITAOSWALD uses method from "Estimating the Oswald factor from Basic Aircraft Geometrical Paramters"
% to estimate oswald efficency factor of a Baff Aircraft
model = obj.Baff;
Wing = model.Wing(1);
fus = model.BluffBody(1);

taperRatio = Wing.AeroStations(end).Chord/Wing.AeroStations(1).Chord;
% get average sweep of qtr chord
etaRoot = Wing.AeroStations(2).Eta;
p1 = Wing.Stations.GetPos(etaRoot)*Wing.EtaLength + Wing.AeroStations.GetPos(etaRoot,0.25);
p2 = Wing.Stations.GetPos(1)*Wing.EtaLength + Wing.AeroStations.GetPos(1,0.25);
V = p2-p1;
sDir = Wing.AeroStations(2).StationDir;
Z = cross(sDir,V);
X = cross(Z,sDir);
sweep = acosd(dot(X,V)/(norm(X)*norm(V)));

%get delta taper (Eq. 37)
deltaTaper = -0.357 + 0.45*exp(0.0375*deg2rad(sweep));
% estimate theoretical e (Eq. 36 and Eq. 38)
f = @(tr) 0.0524*tr^4 - 0.15*tr^3 + 0.1659*tr^2 - 0.0706*tr + 0.0119;
e_theo = 1/(1 + f(taperRatio + deltaTaper)*obj.AR);

%viscous corrections (Eq. 40 and Eq. 39b)
KeF = 1-2*(max([fus.Stations.Radius])*2/fus.EtaLength)^2; % fuselage factor (Eq. 40)
ae = -0.001521;
be = 10.82;
KeM = cast.util.tern(Mach<=0.3,1,ae*(Mach/0.3-1)^be+1); % Compressibility factor (Eq. 41)

Q = 1/(e_theo*KeF);
P = 0.38*obj.CD0;
e = KeM/(Q+P*pi*obj.AR);

% geometric considerations
KeGamma = (1/cosd(obj.Dihedral))^2; % (Eq. 49)
e = e * KeGamma;
end

