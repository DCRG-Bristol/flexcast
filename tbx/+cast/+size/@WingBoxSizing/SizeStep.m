function Par = SizeStep(obj,Loads,SafetyFactor)
arguments
    obj cast.size.WingBoxSizing
    Loads
    SafetyFactor
end
Par = obj;
%SIZE Summary of this function goes here
%   Detailed explanation goes here
sigma_Y=Par.Mat.yield;
shear_strength = sigma_Y/sqrt(3);
%Update loads with safety factor
My = abs(SafetyFactor * Loads.My);
Mx = abs(SafetyFactor * Loads.Mx);
Fz = abs(SafetyFactor * Loads.Fz);
%% short hand variable
h=Par.Height;                   % wing box height
w=Par.Width;                    % wing box width
web_dc=0.5*h;                   % shear panel stiffener pitch 
ws=Par.CapEta_width*w;          % spar cap dimensions
tsw=Par.SparWeb_Thickness;      % spar web thickness
tskn=Par.Skin.Skin_Thickness;   % spar skin thickness

%% Spar cap sizing
Cap_area_Y=0.5*My./(h*sigma_Y);

Cap_Thickness_Y=Cap_area_Y./ws;
Cap_Thickness_B=(4*My.*Par.Ribs.IdealPitch^2./(pi^2*Par.Mat.E*h.*ws)).^(1/3);
Cap_Thickness=max([Cap_Thickness_Y;Cap_Thickness_B]);

% Update cap thickness and beam properties
Cap_Thickness(Cap_Thickness<Par.Spar_Min_Thickness) = Par.Spar_Min_Thickness;
Par.SparCap_Thickness=Cap_Thickness; 
% update Iyy prediction
Iyy = Par.Iyy; 

%% Spar Web Sizing     
% check bending stress on the top web
Bending_Stress=My.*(0.5*h)./Iyy;

% spar web stresses
Q_skn = w.*tskn.*(0.5*h);
Q_spar = ws.*Cap_Thickness.*(0.5*h)*2;
Q_web = (0.5*tsw.*h.*(0.25*h))*2;
Q = Q_skn + Q_spar + Q_web;

Shear_stress = Fz.*Q./(2*Iyy.*tsw) + Mx./(2*h.*w.*tsw);

% web critical buckling stresses (bending)
Sigma_buckling_web=21*Par.Mat.E*(tsw./h).^2;

% web critical buckling stresses (shear) *
idx = 1:(Par.NumEl-1);
hwa= h(idx)./web_dc(idx);
Ks=13.1*exp(-1.426*hwa) + 5.066*exp(-0.002422*hwa);
Sigma_buckling_shear = Ks .* Par.Mat.E .* (tsw(idx)./web_dc(idx)).^2;
Sigma_buckling_shear = Sigma_buckling_shear([1:end,end]);

% web constraint check
Constraint_web1=Shear_stress./shear_strength;
Constraint_web2=Bending_Stress./Sigma_buckling_web;
Constraint_web3=Shear_stress./Sigma_buckling_shear;
%         Constraint_web=max([Constraint_web1'; Constraint_web2'; Constraint_web3']);
Constraint_web=max([Constraint_web1; Constraint_web3]);

% update spar web thickness
SparWeb_adjust=step_size(Constraint_web);

Par.SparWeb_Thickness=Par.SparWeb_Thickness.*SparWeb_adjust;
Par.SparWeb_Thickness(Par.SparWeb_Thickness<Par.Spar_Min_Thickness) = Par.Spar_Min_Thickness;
% update beam properties
Iyy = Par.Iyy;  

%% skin-stringer panel sizing
%effective length (inches)
c=1.5;
L_inch = convlength(Par.Ribs.IdealPitch/sqrt(c),'m','in'); 

%bending stress (psi)
sigma_psi=convpres(0.5*My.*h./Iyy,'pa','psi');

% calculating skin thickness
% Note factor of 1.5 applied as the area ratio Ast/Askin=0.5;
% Total force act on the skin-stringer panel = sigma * (Ask+ 0.5*Askin)
t_skin=sigma_psi.*L_inch./(3000^2);
%ensure minimium skin thicknesses
skin_min_thick = convlength(Par.Skin.Skin_Min_Thickness,'m','in'); 
t_skin(t_skin<skin_min_thick) = skin_min_thick;

% N load intensity (load per unit lenth)
N=t_skin.*sigma_psi;
Fe=2000*(N./L_inch).^0.5;
be_t = -7.743e-6*(Fe/1000).^4 + 0.0006387*(Fe/1000).^3 + 0.007084*(Fe/1000).^2 - 1.966*(Fe/1000) + 76.83;
idx = Fe > convpres(1,'pa','psi')*Par.Mat.yield;
if any(idx)
    warning('Load intensity Exceeded on Skin - setting be_t to 10...');
    be_t(idx) = 10;
end

%calculate all the params
be=be_t.*t_skin;                            % skin-stringer panel effective width (inch)
b=be;                                       % stringer pitch = effective width (inch)
ta=0.7*t_skin;                              % ground thickness (inch)
ba=ta*9.35;                                 % ground width (inch)
A_st=0.5*b.*t_skin;                         % stringer area (inch^2)
bw=(be_t.*((A_st-2.*ba.*ta)./1.327)).^0.5;  % stringer depth (inch)
tw=bw./be_t;                                % stringer web thickness (inch)    
bf=0.327*bw;                                % stringer flange width (inch)
tf=tw;                                      % stringer flange thickness (inch)

% Update data logger String and skin (factor of 0.0254 to convert unit from inch to metre)
Par.Skin.Skin_Thickness=t_skin*0.0254;
Par.Skin.Effective_Width=be*0.0254;
Par.Skin.Strg_Pitch=b*0.0254;
Par.Skin.Strg_Depth=bw*0.0254;
Par.Skin.StrgFlange_Width=bf*0.0254;
Par.Skin.StrgGround_Width=ba*2*0.0254;
Par.Skin.StrgThickness_Ground=ta*0.0254;
Par.Skin.StrgThickness_Web=tw*0.0254;
Par.Skin.StrgThickness_Flange=tf*0.0254;

%ensure minimium skin thicknesses
skin_min_thick = Par.Skin.Skin_Min_Thickness;
Par.Skin.Skin_Thickness(Par.Skin.Skin_Thickness<skin_min_thick) = skin_min_thick;

%ensure minimium Stringer thickness
strg_min_thick = Par.Skin.Strg_Min_Thickness;
Par.Skin.StrgThickness_Web(Par.Skin.StrgThickness_Web<strg_min_thick) = strg_min_thick;
Par.Skin.StrgThickness_Flange(Par.Skin.StrgThickness_Flange<strg_min_thick) = strg_min_thick;
Par.Skin.StrgThickness_Ground(Par.Skin.StrgThickness_Ground<strg_min_thick) = strg_min_thick;

%% Size Ribs
% crushing stress
My_rib = interp1(Par.Eta,My,Par.Ribs.Eta);
w_rib = interp1(Par.Eta,Par.Width,Par.Ribs.Eta);
h_rib = interp1(Par.Eta,Par.Height,Par.Ribs.Eta);
% factor 1.5 applied as the ratio between A_st/A_skn=0.5; Hence effective
% thickness of the panel is taken as 1.5 times t_skin.
te_rib = interp1(Par.Eta,Par.Skin.Skin_Thickness,Par.Ribs.Eta)*1.5;

N_crush=My_rib./(h_rib.*w_rib);
Sigma_Crush=2*N_crush.^2./(Par.Mat.E*te_rib.*h_rib);
F_crush=Par.Ribs.ActualPitch*Sigma_Crush.*w_rib;
t_y=F_crush./(w_rib*Par.Mat.yield); % critical thickness for yielding 
A=pi^2*Par.Mat.E/12; % critical thickness for wide column buckling
c=1;
t_cb=(F_crush.*(h_rib./sqrt(c)).^2./(A*w_rib)).^(1/3);

Par.Ribs.Thickness=max([t_y;t_cb;repmat(Par.Spar_Min_Thickness,1,numel(t_cb))]); % set rib thickness
if Par.Ribs.Eta(end) == 1
    Par.Ribs.Thickness(end) = Par.Ribs.Thickness(end-1);
end

%% web stiffner sizing 
Seg_len = (Par.Eta(2:end) - Par.Eta(1:(end-1)))*Par.Span;
idx = 1:(Par.NumEl-1);
hd=h(idx)./web_dc(idx);                % find ratio of h/ds
% determine the required stiffner moment of inertia from Fig 27 in paper
N_Iu=-0.06203*hd.^3 + 0.7356*hd.^2 - 0.3935*hd - 0.1241; % normalised Iu
Iu=N_Iu.*h(idx).*Par.SparWeb_Thickness(idx).^3; 
% get required thickness assuming thin-wall theory (restangular beam perp
% to web) - assuming stringer length is 1 inch 
t_stiff=3*Iu/0.0254^3;

Par.SparWeb_Stiff_N =Seg_len./web_dc(idx);  % Number of stiffners in each shear panel. 
Par.SparWeb_Stiff_Thickness = t_stiff; % Set spar web stifferner thickness
end

function c=step_size(x)
x = x-1;
c = 0.5*x.^2.*sign(x) + 1;
c(x>0) = 0.5*x(x>0).^2 + 1;
c(c>1.3) = 1.3;
c(c<0.7) = 0.7;
end


