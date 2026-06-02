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
obj.Masses.PrimaryWingMass = 0;
obj.Masses.SecondaryWingMass = 0;
obj.Masses.ConnectorMass = 0;
for i = 1:length(obj.WingBoxParams)
    [Area,Iyy, Izz, J] = obj.WingBoxParams(i).BeamCondensation;
    Masses = obj.WingBoxParams(i).GetMass;
    eta = Masses.Ribs./sum(Masses.Ribs);
    if contains(obj.Baff.Wing(obj.WingBoxParams(i).Index(1)).Name,"Connector")
        obj.Masses.ConnectorMass = obj.Masses.ConnectorMass + Masses.Total*2*1.2;
        SecMass = Masses.Ribs + eta.*(Masses.Web_stiff_total + Masses.Total*0.2);
    else
        obj.Masses.PrimaryWingMass = obj.Masses.PrimaryWingMass + Masses.Total*2;
        obj.Masses.SecondaryWingMass = obj.Masses.SecondaryWingMass + Masses.Total*0.73*2;
        SecMass = Masses.Ribs + eta.*(Masses.Web_stiff_total + Masses.Total*0.73);
    end
    for j = obj.WingBoxParams(i).Index
        tmp_wing = obj.Baff.Wing(j);
        % assign cross-section properties
        for k = 1:length(tmp_wing.Stations)
            tmp_wing.Stations(k).A = Area.cross_section(k);
            tmp_wing.Stations(k).I = diag([Iyy(k)+Izz(k),Iyy(k),Izz(k)]);
            tmp_wing.Stations(k).J = J(k);
        end
        % assign Additional masses (SecMass: ribs + secondary fraction of total)
        idx = find(contains([tmp_wing.Children.Name],"ribs_"));
        for k = 1:length(idx)
            tmp_wing.Children(idx(k)).mass = SecMass(k);
        end
    end
end
obj.WingMass = obj.Masses.PrimaryWingMass + obj.Masses.SecondaryWingMass;
end
