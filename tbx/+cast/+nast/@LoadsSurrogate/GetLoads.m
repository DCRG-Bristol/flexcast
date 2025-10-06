function [Lds,BinFolder] = GetLoads(obj,Cases)
arguments
    obj
    Cases (:,1) cast.LoadCase % Load Cases to run
end
ads.Log.debug('Calculating Nastran Loads');
for i = 1:length(Cases)
    if ~opts.Silent
        ads.Log.debug(sprintf('Running Case %s',Cases(i).Name));
    end
    cellArgs = namedargs2cell(Cases(i).ConfigParams);
    obj.SetConfiguration(cellArgs{:});
    if ~ismethod(obj,Cases(i).Type)
        error('method %s does not exist',Cases(i).Type);
    end
    if isnan(Cases(i).IdxOverride)
        [tmp_Lds] = obj.(Cases(i).Type)(Cases(i),i);
    else
        [tmp_Lds] = obj.(Cases(i).Type)(Cases(i),Cases(i).IdxOverride);
    end
    if i == 1
        Lds = tmp_Lds;
    else
        Lds = Lds | tmp_Lds;
    end
    if obj.CleanUp
        rmdir(obj.BinFolder,"s")
    end
end
end