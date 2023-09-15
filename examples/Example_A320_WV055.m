clear all
ADR = cast.ADR.A320(180,2450,19280);
ADR.GroundRun = 1800;
ADP = cast.config.TAW();
ADP.ADR = ADR;
% Offical Fudge it Factors
ADP.Delta_Cl_ld = 1.6;
ADP.Delta_Cl_to = 1;
ADP.Engine = cast.config.Engine.CFM_LEAP_1A;
ADP.AR = 10.2;
ADP.WingletHeight = 2.4;

%% inital mass estimate
% guess initial Aerodyanmic values
ADP.CL_max = 2;     %Max CL in landing configuration
ADP.CD_TO = 0.03;   %CD in ground run
ADP.CL_TO = 0.8;    %CL during ground run
ADP.CL_TOmax = 1.5; % max CL in TO condition
ADP.CD_LDG = 0.03;  %CD in ground run on landing
ADP.CL_LDG = 0.8;   %CL during ground run on landing
ADP.CD0 = 0.02;     %CD0
ADP.e = 0.8;        %Oswald Efficency Factor
ADP.TWgr = 0;       %thrust to weight ratio on ground run
ADP.LD_c = 18;      % lift-to-drag ratio in cruise
ADP.LD_app = 10;    % lift-to-drag ratio on approach

%initial mission analysis to estimate MTOM
mission = cast.Mission.StandardWithAlternate(ADP.ADR);
[EWF,fs] = cast.weight.MissionFraction(mission.Segments,ADP);
val = @(x) 1.1166 - 0.0516*log(x)+(ADR.Payload+ADR.CrewMass)/x-EWF; % from database
ADP.MTOM = fminsearch(@(x)val(x)^2,0);
% set inital mass fractions
ADP = ADP.MissionAnalysis();

%% create geometry
itr = 1;
for i = 1:20
    fprintf('iteration %.0f: MTOM %.0f kg\n',i,ADP.MTOM);
    % constraint analysis
    [ADP,TWi,WS_ldg] = ADP.ConstraintAnalysis("Plot",false);
    % create geometry
    ADP = ADP.BuildBaff();
    % update paramters
    ADP.WingEta = ADP.Baff.Wing(1).Eta;
    ADP = ADP.UpdateAeroEstimates();
    %check for convergence
    mtom = ADP.Baff.GetOEM() + ADP.ADR.Payload + ADP.MTOM * ADP.Mf_Fuel;
    if i>2 && abs(ADP.MTOM/mtom-1)<0.005
        ADP.MTOM = mtom;
        ADP = ADP.MissionAnalysis();
        break
    else
        ADP.MTOM = mtom;
        ADP = ADP.MissionAnalysis();
    end
end
%% ddraw
ADP = ADP.BuildBaff();
model = ADP.Baff;

f = figure(3);
clf;
hold on
model.draw(f)
ax = gca;
ax.Clipping = false;
% ax.ZAxis.Direction = "reverse";
axis equal
X = ADP.Baff.GetCoM();
plot3(X(1),0,X(3),'sk','MarkerFaceColor','k','DisplayName','CoM');

%% plot payload range diagram
f = figure(7);
f.Units = 'centimeters';
f.Position = [20 5,10,5];
clf
ADP.PR_diagram();
hold on 
plot([0 2.45 3.417 4.295].*1e3,[19.28 19.28 15.12 0],'r--')
xlabel('Range [nm]')
ylabel('Payload [Tonne]')

MTOM = ADP.MTOM;
PLM = ADP.ADR.Payload;
MZFM = ADP.Baff.GetOEM + PLM;
M_land = ADP.MTOM.*ADP.Mf_Ldg;
F_cap = sum([ADP.Baff.Fuel.Capacity]);
S = ADP.WingArea;
b = ADP.Span;
l_fus = ADP.Baff.BluffBody(1).EtaLength;
r_fus = max(arrayfun(@(x)x.Radius,[ADP.Baff.BluffBody(1).Stations]));
T = ADP.Thrust/2;

res = [MTOM./1e3,PLM./1e3,MZFM./1e3,M_land./1e3,F_cap./1e3,S,b,l_fus,r_fus,T];
num2clip(res');
ax = gca;
ax.FontSize = 10;
title('A320')


