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
% 
% function lds = ExtractStaticLoads(obj,filename,tags)
% %EXTRACTSTATICLOADS Extracts static loads from an HDF5 file.
% %   This function reads element forces from an HDF5 file for given tags,
% %   and returns an array of cast.size.Loads objects.
% 
% resFile = mni.result.hdf5(filename);
% [data, type] = read_ElementForces(resFile);
% 
% % Define element-specific configurations
% elem_configs = struct(...    'CBEAM', struct('FeProp', 'Beams', 'ForceFields', {{ 'Mx', 'My', 'Mz', 'Fx', 'Fy', 'Fz'}}), ...
%     'CBAR',  struct('FeProp', 'Bars',  'ForceFields', {{ 'Mx', 'My', 'Mz', 'Fx', 'Fy', 'Fz'}}), ...
%     'CQUAD4',struct('FeProp', 'Quads', 'ForceFields', {{ 'Mx', 'My', 'Mxy', 'Fx', 'Fy', 'Nx', 'Ny', 'Nxy'}}));
% 
% config = elem_configs.(type);
% 
% for i = 1:length(tags)
%     if iscell(tags)
%         tag = tags{i}(1);
%     else
%         tag = tags(i);
%     end
% 
%     elem_prop = obj.fe.(config.FeProp);
%     idx = [elem_prop.Tag] == tag;
%     EIDs = [elem_prop(idx).ID];
%     [~,bIdx] = ismember(EIDs, data(1).EIDs);
%     bIdx = bIdx(bIdx~=0);
% 
%     if isempty(bIdx)
%         lds(i) = cast.size.Loads(0);
%         lds(i).Meta = obj.ExtractMeta(filename);
%         continue;
%     end
% 
%     % CBAR data is 1D, CBEAM/CQUAD4 is 2D. Handle both.
%     if size(data(1).Fx, 1) == 1 % CBAR
%         F_n = @(str) data(1).(str)(bIdx);
%         num_points = length(bIdx);
%     else % CBEAM or CQUAD4
%         F_n = @(str) [data(1).(str)(1,bIdx), data(1).(str)(2,bIdx(end))];
%         num_points = length(bIdx) + 1;
%     end
% 
%     lds(i) = cast.size.Loads(num_points);
%     for f = 1:length(config.ForceFields)
%         field = config.ForceFields{f};
%         lds(i).(field) = F_n(field);
%     end
% 
%     lds(i).Meta = obj.ExtractMeta(filename);
% end
% end
