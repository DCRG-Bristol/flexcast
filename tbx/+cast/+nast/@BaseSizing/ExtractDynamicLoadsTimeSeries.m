function Lds = ExtractDynamicLoadsTimeSeries(obj,filename,tags,elementId)
arguments
    obj
    filename
    tags
    elementId
end
resFile = mni.result.hdf5(filename);
data = resFile.read_dynamic();
for i = 1:length(tags)
    if iscell(tags)
        idx = [obj.fe.Beams.Tag] == tags{i}(1);
    else
        idx = [obj.fe.Beams.Tag] == tags(1);
    end
    EIDs = [obj.fe.Beams(idx).ID];
    [~,bIdx] = ismember(data(1).BeamForce.EIDs,EIDs(elementId));
    bIdx = find(bIdx);
    F_n = @(res,str) res.(str)(:,bIdx,1);
    for j = 1:length(data)
        tmp_lds = cast.size.Loads(nnz(bIdx)+1,"Idx",j/(10^ceil(log10(length(data)+1))));
        tmp_lds.Mx = F_n(data(j).BeamForce,'Mx');
        tmp_lds.My = F_n(data(j).BeamForce,'My');
        tmp_lds.Mz = F_n(data(j).BeamForce,'Mz');
        tmp_lds.Fx = F_n(data(j).BeamForce,'Fx');
        tmp_lds.Fy = F_n(data(j).BeamForce,'Fy');
        tmp_lds.Fz = F_n(data(j).BeamForce,'Fz');
        tmp_lds.t = data(j).t;
        if j == 1
            lds = tmp_lds;
        else
            lds(j) = tmp_lds;
        end
    end
    Lds{i} = lds;
end
end

