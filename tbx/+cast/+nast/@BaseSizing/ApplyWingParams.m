function ApplyWingParams(obj,Par)
arguments
    obj
    Par = []
end
if isempty(obj.Baff)
    error('No Baff Model generated')
end
if ~isempty(Par)
    obj.WingBoxParams = Par;
end
%% apply properties to the wings
for i = 1:length(obj.WingBoxParams)
    [Area,Iyy, Izz, J] = obj.WingBoxParams(i).BeamCondensation;
    Masses = obj.WingBoxParams(i).GetMass;
    %divide stiffer + fixtures mass amougst ribs
    eta = Masses.Ribs./sum(Masses.Ribs);
    SecMass = Masses.Web_stiff_total + Masses.Fixtures;
    for j = obj.WingBoxParams(i).Index
        tmp_wing = obj.Baff.Wing(j);
        % assign cross-section properties
        for k = 1:length(tmp_wing.Stations)
            tmp_wing.Stations(k).A = Area.cross_section(k);
            tmp_wing.Stations(k).I = diag([Iyy(k)+Izz(k),Iyy(k),Izz(k)]);
            tmp_wing.Stations(k).J = J(k);
        end
        % assign Additional masses
        idx = find(contains([tmp_wing.Children.Name],"ribs_"));
        for k = 1:length(idx)
            tmp_wing.Children(idx(k)).mass = Masses.Ribs(k) + SecMass * eta(k);
        end
    end
end
end

