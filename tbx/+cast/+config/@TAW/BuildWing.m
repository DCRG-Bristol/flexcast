function [Wing,FuelMassTotal,L_ldg,Masses] = BuildWing(obj,isRight,D_c)
%BUILDWING Summary of this function goes here
%   Detailed explanation goes here
if isRight
    Tag = '_RHS';
else
    Tag = '_LHS';
end
M_c = obj.ADR.M_c;
[rho,a] = cast.util.atmos(obj.ADR.Alt_cruise);
q_c = 0.5*rho*(M_c*a)^2;
span = sqrt(obj.AR*obj.WingArea);

Mstar = 0.935;
Cl_cruise = obj.MTOM*obj.Mf_TOC*9.81/(0.5*rho*(M_c*a)^2*obj.WingArea);
sweep_le = real(acosd(0.75.*Mstar./M_c));
tc_root = getThicknessToChord(M_c,Cl_cruise,sweep_le,Mstar);
tc_tip = tc_root - 0.03;

D_join = sqrt((D_c/2)^2-(D_c/4)^2)*2;
S = @(x)wingArea(obj.WingArea,obj.AR,1/3,obj.KinkEta,x,sweep_le,0,D_join);
c = fminsearch(@(x)(S(x)-obj.WingArea).^2,obj.WingArea./sqrt(obj.WingArea*obj.AR));
[~,cs,LE_sweeps,TE_sweeps] = wingArea(obj.WingArea,obj.AR,1/3,obj.KinkEta,c,sweep_le,0,D_join);

etas = [0 (obj.KinkEta*obj.Span-D_join)/(obj.Span-D_join) 1];
etas = [0 (etas*(obj.Span-D_join)/2 + D_join/2)/(obj.Span/2)];
tr = interp1([0 1],[tc_root,tc_tip],etas,"linear");


%% calc properties of interest
etas = [0 (obj.KinkEta*obj.Span-D_join)/(obj.Span-D_join) 1];
etas = [0 (etas*(obj.Span-D_join)/2 + D_join/2)/(obj.Span/2)];
tr = interp1([0 1],[tc_root,tc_tip],etas,"linear");
Wing = baff.Wing.FromLETESweep(obj.Span/2,cs(1),etas,[0,LE_sweeps],[0,TE_sweeps],0.4,...
                baff.Material.Stiff,"ThicknessRatio",[tr(1),tr],"Dihedral",[0 -1 -1]*obj.Dihedral);
Wing.A = baff.util.rotz(90)*baff.util.rotx(180);
Wing.Eta = obj.WingEta;
Wing.Offset = [0;0;-D_c/4];
Wing.Name = string(['Wing',Tag]);
Wing = cast.drag.DraggableWing(Wing);

%% estimate wing mass
b = obj.Span*cast.SI.ft;
Sw = obj.WingArea.*cast.SI.ft^2;
n_z = 1.5*2.5;
% wing mass Torenbeek (Eq. 8.1 assume eta_cp = 0.65...)
m_wing = 0.0013*n_z*sqrt(obj.MTOM^2*obj.Mf_Ldg*cast.SI.lb)*0.75*b/328*obj.AR/((tc_root-0.015)*cosd(sweep_le)^2)+Sw*4.4;
m_wing = m_wing./cast.SI.lb;
obj.Masses.Wings = m_wing;
Wing.DistributeMass(m_wing/2,10,"Method","ByVolume","tag",string(['wing_mass',Tag]));

%% fuel volume
FuelVol = Wing.AeroStations(2:end).GetNormVolume([0.15 0.65])*Wing.EtaLength;
FuelMassTotal = 0.89*FuelVol.*cast.SI.litre.*0.785;
Wing.DistributeMass(FuelMassTotal,10,"Method","ByVolume","tag",string(['wing_fuel',Tag]),"isFuel",true,"Etas",[Wing.AeroStations(2).Eta,Wing.AeroStations(end).Eta]);
            
%% Winglet
if obj.WingletHeight>0
    h = obj.WingletHeight;
    cr = Wing.AeroStations(end).Chord;
    taper = Wing.AeroStations(end).Chord/Wing.AeroStations(end-1).Chord;
    LE_sweep = LE_sweeps(end);
    c_bar = tand(LE_sweep)*h+cr*taper-cr;
    te_sweep = sign(c_bar)*atand(abs(c_bar)/h);
    Winglet = baff.Wing.FromLETESweep(h,cr,[0 1],LE_sweep,te_sweep,0.4,...
    baff.Material.Stiff,"ThicknessRatio",[1 1]*tr(end));
    Winglet.A = baff.util.roty(90);
    Winglet.Eta = 1;
    Winglet = cast.drag.DraggableWing(Winglet);
    Wing.add(Winglet);
end

%% Engine
% rubberise engine to get required thrust
obj.Engine = obj.Engine.Rubberise(obj.Thrust/obj.N_eng);
% engine insatllation mass (Raymer 15.52)
m_engi = (2.575*(obj.Engine.Mass*cast.SI.lb)^0.922)./cast.SI.lb - obj.Engine.Mass;
m_nac = 0.065*obj.Engine.T_Static/9.81; % Snorri 6-75
obj.Masses.Engine = (obj.Engine.Mass+m_nac)*2;
obj.Masses.EnginePylon = m_engi*2;

engine_mat = baff.Material.Stiff;
eta = [0 0.6 1];
radius = [1 1 1/1.4]*obj.Engine.Diameter/2;
engine = baff.BluffBody.FromEta(obj.Engine.Length,eta,radius,"Material",engine_mat,"NStations",4);
engine.A = baff.util.rotz(-90);
engine.Eta = obj.EngineEta;
engine.Offset = [0;obj.Engine.Length;obj.Engine.Diameter/2+0.1];
engine.Name = string(['engine',Tag]);
%make engine contribute to Drag
engine = cast.drag.DraggableBluffBody(engine);
engine.InterferanceFactor = 1.25; % Raymer section 12.5.5
%add to wing
Wing.add(engine);
% add mass to engine 
eng_mass = baff.Mass(obj.Engine.Mass+m_nac,"eta",0.4,"Name",string(['engine_mass',Tag]));
pylon_mass = baff.Mass(m_engi,"eta",0.8,"Name",string(['engine_installation_mass',Tag]));
engine.add(eng_mass);
engine.add(pylon_mass);

% add main landing gear
l_offset = 0.2;
z_e = abs(engine.Offset(3)) + obj.Engine.Diameter/2 + tand(5)*(obj.EngineEta*span/2 - D_c*l_offset);
L_ldg = sind(85)/sind(50)*z_e/sqrt(2);
Eta_ldg = (L_ldg + D_c*l_offset)/Wing.EtaLength;
M_ldg = obj.MTOM*obj.Mf_Ldg*cast.SI.lb; % estamate of landing mass
m_ldg = 0.095*(1*1.5*M_ldg)^0.768*(L_ldg*cast.SI.ft)^0.409;
m_ldg = m_ldg ./ cast.SI.lb;
ldg = baff.Mass(m_ldg,"eta",Eta_ldg,"Name","ldg_main_RHS");
st = Wing.AeroStations.interpolate(Eta_ldg);
ldg.Offset = [0;-((st.Chord-1)-st.Chord*st.BeamLoc);L_ldg];
Wing.add(ldg);
obj.Masses.LandingGear = m_ldg*2;

Masses = obj.Masses;

end


function tc = getThicknessToChord(M,Cl_cruise,sweep,Mstar)
% equation 10.49 in Torenbeck;
    tc = cosd(sweep).*(Mstar - 0.1*(1.1.*Cl_cruise./cosd(sweep)^2).^1.5 - M.*cosd(sweep));
end

function [S,cs,le_sweep,te_sweep] = wingArea(S,AR,lambda,k,c,Lambda_LE,Lambda_TE,D_f)
    b = sqrt(AR*S)/2;
    R_f = D_f/2;
    c_t = lambda*c;
    c_r = c+(tand(Lambda_LE)-tand(Lambda_TE))*(k*b-R_f);
    A_1 = (c+c_t)/2*b*(1-k);
    A_2 = (c_r+c)/2*(k*b-D_f/2);
    A_3 = c_r*R_f;
    A_4 = R_f^2*tand(Lambda_LE)/2;
    S = 2*(A_1+A_2+A_3-A_4);
    cs = [c_r,c,c_t];
    le_sweep = [1 1]*Lambda_LE;
    L = b*(1-k);
    te_sweep_end = atand((tand(Lambda_LE)*L+c_t-c)/L);
    te_sweep = [Lambda_TE te_sweep_end];
end