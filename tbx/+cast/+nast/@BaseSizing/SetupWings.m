function SetupWings(obj)
if isempty(obj.Baff)
    error('No Baff Model generated')
end
for i = 1:length(obj.Tags)
    idx = [obj.Baff.Wing.Name]==obj.Tags{i}(1);
    if nnz(idx) ~= 1
        error('No wing with tag %s detected',obj.Tags{i}(1))
    end
    idx = find(idx,1);
    wing = obj.Baff.Wing(idx);
    mat = ads.fe.Material.FromBaffMat(wing.Stations(1).Mat);
    mat.Yield = 5.0e8;
    % setup the param object
    obj.WingBoxParams(i) = cast.size.WingBoxSizing(length(wing.Stations),wing.EtaLength,mat);
    obj.WingBoxParams(i).Index = idx;
    % get wingbox height and width
    aero_stations = wing.AeroStations.interpolate([wing.Stations.Eta]);
    % wingbox height mean of spar heights
    obj.WingBoxParams(i).Height = [aero_stations.ThicknessRatio].*[aero_stations.Chord];
    for j = 1:length(aero_stations)
        obj.WingBoxParams(i).Height(j) = obj.WingBoxParams(i).Height(j)* mean(interp1(aero_stations(i).Airfoil.Etas',aero_stations(i).Airfoil.Ys(:,1)',[0.15 0.65])*2);
    end
%     obj.WingBoxParams(i).Height = [aero_stations.ThicknessRatio].*[aero_stations.Chord];
    obj.WingBoxParams(i).Width = [aero_stations.Chord].*(0.65-0.15);
    %setup distributed mass for ribs
    wing.DistributeMass(1,obj.WingBoxParams(i).Ribs.NumEl,"tag","ribs","Method","Regular");
    %setup dependent wings
    for j = 2:length(obj.Tags{i})
        idx = [obj.Baff.Wing.Name]==obj.Tags{i}(j);
        if nnz(idx) ~= 1
            error('No wing with tag %s detected',obj.Tags{i}(j))
        end
        idx = find(idx,1);
        wing = obj.Baff.Wing(idx);
        if length([wing.Stations]) ~= obj.WingBoxParams(i).NumEl
            error('Wing %s does not have the same number of elements as wing %s',obj.Tags{i}(j),obj.Tags{i}(1));
        end
        obj.WingBoxParams(i).Index = [obj.WingBoxParams(i).Index,idx];
        %setup distributed mass for ribs
        wing.DistributeMass(1,obj.WingBoxParams(i).Ribs.NumEl,"tag","ribs","Method","Regular");
    end
end
end

