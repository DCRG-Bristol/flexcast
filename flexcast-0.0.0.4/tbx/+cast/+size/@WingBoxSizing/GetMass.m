function Mass = GetMass(obj)
arguments
    obj cast.size.WingBoxSizing
end
for i = 1:length(obj)
%% get Volume of each segment
Seg_len=(obj(i).Eta(2:end) - obj(i).Eta(1:end-1))*obj(i).Span;
A = obj(i).Area();

% All volume
A1=A.cross_section(1:end-1);
A2=A.cross_section(2:end);
Volume=sum((A1+A2+sqrt(A1.*A2)).*Seg_len/3);

% cap volume
A1_cap=A.spar_cap(1:end-1);
A2_cap=A.spar_cap(2:end);
Volume_cap=sum((A1_cap+A2_cap+sqrt(A1_cap.*A2_cap)).*Seg_len/3);

% web volume
A1_web=A.spar_web(1:end-1);
A2_web=A.spar_web(2:end);
Volume_web=sum((A1_web+A2_web+sqrt(A1_web.*A2_web)).*Seg_len/3);

% skin volume
A1_skn=A.skin(1:end-1);
A2_skn=A.skin(2:end);
Volume_skn=sum((A1_skn+A2_skn+sqrt(A1_skn.*A2_skn)).*Seg_len/3);

% stringer volume
A1_strg=A.Strg(1:end-1);
A2_strg=A.Strg(2:end);
Volume_strg=sum((A1_strg+A2_strg+sqrt(A1_strg.*A2_strg)).*Seg_len/3);

%% get structural masses
% Structural mass
Mass(i).Wing=Volume*obj(i).Mat.rho;
Mass(i).SparCap=Volume_cap*obj(i).Mat.rho;
Mass(i).SparWeb=Volume_web*obj(i).Mat.rho;
Mass(i).Skin=Volume_skn*obj(i).Mat.rho;
Mass(i).Strg=Volume_strg*obj(i).Mat.rho;

%% Rib Mass
w_rib = interp1(obj(i).Eta,obj(i).Width,obj(i).Ribs.Eta);
h_rib = interp1(obj(i).Eta,obj(i).Height,obj(i).Ribs.Eta);
Mass(i).Ribs=w_rib.*h_rib.*obj(i).Ribs.Thickness*obj(i).Mat.rho;
Mass(i).Ribs = Mass(i).Ribs*1.5; % account for fact wingbox is only 66% of crosssection area
Mass(i).RibTotal = sum(Mass(i).Ribs);
%% Web stiffener Mass
%assuming 1 inch r section
Vol_stiff=(0.0254*2)*obj(i).SparWeb_Stiff_Thickness.*obj(i).Height(1:end-1);
total_vol_stiff=obj(i).SparWeb_Stiff_N.*Vol_stiff.*2;
Mass(i).Web_stiff_total=sum(total_vol_stiff*obj(i).Mat.rho);
Mass(i).Web_stiff=total_vol_stiff*obj(i).Mat.rho;

Mass(i).Total = Mass(i).Web_stiff_total + Mass(i).RibTotal + Mass(i).Wing;
Mass(i).Fixtures = Mass(i).Total * 0.00;

Mass(i).Total = Mass(i).Total + Mass(i).Fixtures;

end

