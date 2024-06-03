function [x,m] = GetSpanwiseMass(obj)
arguments
    obj cast.size.WingBoxSizing
end
for i = 1:length(obj)
%% get Volume of each segment
Seg_eta = (obj(i).Eta(2:end) + obj(i).Eta(1:end-1))/2;
Seg_len=(obj(i).Eta(2:end) - obj(i).Eta(1:end-1))*obj(i).Span;
A = obj(i).Area();

% All volume
A1=A.cross_section(1:end-1);
A2=A.cross_section(2:end);
Volume=(A1+A2+sqrt(A1.*A2)).*Seg_len/3;

m = Volume*obj(i).Mat.rho./Seg_len;

%% Rib Mass
w_rib = interp1(obj(i).Eta,obj(i).Width,obj(i).Ribs.Eta);
h_rib = interp1(obj(i).Eta,obj(i).Height,obj(i).Ribs.Eta);
m_r = w_rib.*h_rib.*obj(i).Ribs.Thickness*obj(i).Mat.rho *1.5;

% m = m + interp1(obj(i).Ribs.Eta,m_r,Seg_eta);
%% Web stiffener Mass
%assuming 1 inch r section
Vol_stiff=(0.0254*2)*obj(i).SparWeb_Stiff_Thickness.*obj(i).Height(1:end-1);
m_stiff=obj(i).SparWeb_Stiff_N.*Vol_stiff.*2.*obj(i).Mat.rho;

% m = m + m_stiff;
x = Seg_eta;

end

