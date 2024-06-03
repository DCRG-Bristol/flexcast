function Izz = Izz(obj)
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
%% Area of individual stringer at each section.
Strg_Area=ba.*ta + bf.*tf + bw.*tw;
Num_strg=round(w./be);

%% in-plane moment of inertia Izz
% cap
Izz_sparcap_=lch.*t_cap.^3/12 + t_cap.*lch.*(0.5*w).^2 + t_cap.*lcw.^3/12 + t_cap.*lcw.*(0.5*w - 0.5*lcw).^2;

Izz_sparcap=Izz_sparcap_*4;


% web
Izz_web_=h.*t_web.^3/12 + t_web.*h.*(0.5*w).^2;

Izz_web=Izz_web_*2;


% skin-stringer panel 

% skin
Izz_skin_=t_skin.*w.^3/12;

Izz_skin=Izz_skin_*2;


% stringer 
seg1_zz=ta.*ba.^3/12;

seg2_zz=bw.*tw.^3/12;

seg3_zz=tf.*bf.^3/12 + bf.*tf.*(0.5*bf).^2;

Izz_strg_= seg1_zz+seg2_zz+seg3_zz;


Izz_strg=zeros(1,length(w));

for i=1:length(length(w))
    
    if mod(Num_strg(i),2)==0
        
        sp=be(i);
        
        offset=0.5*sp:sp:(w(i)/2);
        Izz_strg(i)=(Num_strg(i)*Izz_strg_(i) + Strg_Area(i)*(sum(offset.^2)))*2;
        
    elseif mod(Num_strg(i),2)==1
        
        sp=be(i);
        
        offset=0:sp:(w(i)/2);
        Izz_strg(i)=(Num_strg(i)*Izz_strg_(i) + Strg_Area(i)*(sum(offset.^2)))*2;
        
    end
    
end

Izz=Izz_strg+Izz_web+Izz_skin+Izz_sparcap;
end

