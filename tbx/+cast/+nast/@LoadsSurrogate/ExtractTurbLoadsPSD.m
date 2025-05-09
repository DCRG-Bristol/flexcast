function [Lds,f,S] = ExtractTurbLoadsPSD(obj,filename,tags,elementId)
arguments
    obj
    filename
    tags
    elementId
end
resFile = mni.result.hdf5(filename);
data = resFile.read_random_turbulence();
% get VK spectrum
vk = h5read(filename,'/NASTRAN/INPUT/TABLE/TABRNDG');
p = 1/3;
k = 1.339;
f = data.f;
S = VK(2*pi*f,vk.LU,p,k)*vk.WG^2;
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
        if j == 1
            lds = tmp_lds;
        else
            lds(j) = tmp_lds;
        end
    end
    Lds{i} = lds;
end
end


function S = VK(omega,LpV,p,k)
p1 = 2*LpV;
p2 = 1+2.*(p+1).*(k*LpV.*omega).^2;
p3 = 1+(k*LpV.*omega).^2;
S = p1.*p2./p3.^(p+1.5);
end

