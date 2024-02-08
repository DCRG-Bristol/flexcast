function lds = ExtractTurbLoads(obj,filename,tags)
arguments
    obj
    filename
    tags
end
resFile = mni.result.hdf5(filename);
data = resFile.read_random_turbulence();
% get VK spectrum
vk = h5read(filename,'/NASTRAN/INPUT/TABLE/TABRNDG');
f = data.f;
S = VK(2*pi*f,vk.LU,1/3,1.339)*vk.WG^2;

for i = 1:length(tags)
    if iscell(tags)
        idx = [obj.fe.Beams.Tag] == tags{i}(1);
    else
        idx = [obj.fe.Beams.Tag] == tags(1);
    end
    EIDs = [obj.fe.Beams(idx).ID];
    [~,bIdx] = ismember(data(1).BeamForce.EIDs,EIDs);
    bIdx = find(bIdx);
    Sb = repmat(S,1,length(bIdx)+1);
    F_n = @(res,str) sqrt(trapz(f,[res.(str)(:,bIdx,1),res.(str)(:,bIdx(end),2)].^2.*Sb));
    lds(i) = cast.size.Loads(nnz(bIdx)+1);
    for j = 1:length(data)
        tmp_lds = cast.size.Loads(nnz(bIdx)+1,"Idx",j/(10^ceil(log10(length(data)+1))));
        tmp_lds.Mx = F_n(data(j).BeamForce,'Mx');
        tmp_lds.My = F_n(data(j).BeamForce,'My');
        tmp_lds.Mz = F_n(data(j).BeamForce,'Mz');
        tmp_lds.Fx = F_n(data(j).BeamForce,'Fx');
        tmp_lds.Fy = F_n(data(j).BeamForce,'Fy');
        tmp_lds.Fz = F_n(data(j).BeamForce,'Fz');
        if j == 1
            lds(i) = tmp_lds;
        else
            lds(i) = lds(i) | tmp_lds;
        end
    end
end
end

function S = VK(omega,LpV,p,k)
p1 = 2*LpV;
p2 = 1+2.*(p+1).*(k*LpV.*omega).^2;
p3 = 1+(k*LpV.*omega).^2;
S = p1.*p2./p3.^(p+1.5);
end

