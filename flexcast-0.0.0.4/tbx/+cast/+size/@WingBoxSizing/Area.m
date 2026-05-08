function Area = Area(obj)
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
bw=obj.Skin.Strg_Depth;
bf=obj.Skin.StrgFlange_Width;

ta=obj.Skin.StrgThickness_Ground;
tw=obj.Skin.StrgThickness_Web;
tf=obj.Skin.StrgThickness_Flange;

Strg_Area=ba.*ta + bf.*tf + bw.*tw;
Num_strg=round(w./be);

%% calc area
Area_cap=(lcw + lch).*t_cap;
Area_skin=w.*t_skin;
Area_web=h.*t_web;

Area.spar_cap=4*Area_cap;
Area.spar_web=2*Area_web;
Area.skin=2*Area_skin;
Area.Strg=2*Strg_Area.*Num_strg;

Area.cross_section=Area.spar_cap + Area.spar_web + Area.skin + Area.Strg;
end

