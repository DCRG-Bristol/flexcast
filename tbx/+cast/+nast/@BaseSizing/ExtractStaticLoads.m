function lds = ExtractStaticLoads(obj,filename,tags)
resFile = mni.result.hdf5(filename);
data = resFile.read_force_CBEAM();
for i = 1:length(tags)
    if iscell(tags)
        idx = [obj.fe.Beams.Tag] == tags{i}(1);
    else
        idx = [obj.fe.Beams.Tag] == tags(i);
    end
    EIDs = [obj.fe.Beams(idx).ID];
    [~,bIdx] = ismember(data.EIDs,EIDs);
    bIdx = find(bIdx);
%     F_n = @(str) [data.(str)(bIdx)',data.(str)(bIdx(end))];
    F_n = @(str) [data.(str)(1,bIdx),data.(str)(2,bIdx(end))];
    lds(i) = cast.size.Loads(nnz(bIdx)+1);
    lds(i).Mx = F_n('Mx');
    lds(i).My = F_n('My');
    lds(i).Mz = F_n('Mz');
    lds(i).Fx = F_n('Fx');
    lds(i).Fy = F_n('Fy');
    lds(i).Fz = F_n('Fz');

    lds(i).Meta = obj.ExtractMeta(filename);
end
end

