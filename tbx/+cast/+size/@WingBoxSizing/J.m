function [J] = J(obj)
%% Shorthand variables
h=obj.Height;
w=obj.Width;
lcw=obj.CapEta_width*w; % spar cap top length
lch=obj.CapEta_height*h; % spar cap web length
t_cap=obj.SparCap_Thickness;
t_web=obj.SparWeb_Thickness;
% skin-stringer panel params
% Note stringer pitch is assumed to be equal to the effective width of the ss panel.
% Hence be=b.
t_skin=obj.Skin.Skin_Thickness;
be=obj.Skin.Effective_Width;
ba=obj.Skin.StrgGround_Width;

%% Area of individual stringer at each section.
Num_strg=round(w./be);

%% Torsional moment of area 

% spar web + skin 
sp_skin=ba.*Num_strg./w;
un_skin=1-sp_skin;

% calcualte equivalent skin thickness
t_skn_eq = 1.7*t_skin.*sp_skin + t_skin.*un_skin;

J=4*(h.*w).^2./(4*lcw./(t_cap+t_skn_eq) + 4*lch./(t_cap+t_web) + 2*(w-2*lcw)./t_skn_eq + 2*(h-2*lch)./t_web);

end

