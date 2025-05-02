function Iyy = Iyy(obj)
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
b=obj.Skin.Strg_Pitch;

ba=obj.Skin.StrgGround_Width;
bw=obj.Skin.Strg_Depth;
bf=obj.Skin.StrgFlange_Width;

ta=obj.Skin.StrgThickness_Ground;
tw=obj.Skin.StrgThickness_Web;
tf=obj.Skin.StrgThickness_Flange;

%% out of plane moment of inertia Iyy

% cap
Iyy_sparcap_= lcw.*t_cap.^3/12 + lcw.*t_cap.*(0.5*h).^2 + t_cap.*lch.^3/12 + t_cap.*lch.*(0.5*h - 0.5*lch).^2;

Iyy_sparcap=Iyy_sparcap_*4;

% web
Iyy_web_=t_web.*(h-t_skin*2).^3/12;

Iyy_web=Iyy_web_*2;

% skin-stringer panel 

% skin
Iyy_skin=w.*t_skin.^3/12 + w.*t_skin.*(h-t_skin).^2/4;

% stringer
seg1=ba.*ta.^3/12 + ba.*ta.*(0.5*h).^2;

seg2=tw.*bw.^3/12 + tw.*bw.*(0.5*h-0.5*bw).^2;

seg3=bf.*tf.^3/12 + bf.*tf.*(0.5*h-bf).^2;

Iyy_strg_= seg1+seg2+seg3;

Num_strg=round(w./be);

Iyy_SkinStrg=Iyy_strg_.*Num_strg*2 + Iyy_skin*2;

% total Iyy
Iyy=Iyy_sparcap + Iyy_web + Iyy_SkinStrg;
end

