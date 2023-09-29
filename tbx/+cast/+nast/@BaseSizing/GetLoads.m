function [Lds,BinFolder] = GetLoads(obj,Cases,opts,CaseOpts)
arguments
    obj
    Cases (:,1) cast.LoadCase % Load Cases to run
    opts.CleanUp = true;
    opts.Silent = false;
    CaseOpts.BinFolder = '';
    CaseOpts.Verbose = true;
end
fh.printing.title('Calculating Loads',Length=60);
for i = 1:length(Cases)
    if ~opts.Silent
        fprintf('\t Running Case %s\n',Cases(i).Name);
    end
    cellArgs = namedargs2cell(Cases(i).ConfigParams);
    obj.SetConfiguration(cellArgs{:});
    if ~ismethod(obj,Cases(i).Type)
        error('method %s does not exist',Cases(i).Type);
    end
    CaseCell = namedargs2cell(CaseOpts);
    if isnan(Cases(i).IdxOverride)
        [tmp_Lds,BinFolder] = obj.(Cases(i).Type)(Cases(i),i,CaseCell{:});
    else
        [tmp_Lds,BinFolder] = obj.(Cases(i).Type)(Cases(i),Cases(i).IdxOverride,CaseCell{:});
    end
    if i == 1
        Lds = tmp_Lds;
    else
        Lds = Lds | tmp_Lds;
    end
    if opts.CleanUp
        rmdir(BinFolder,"s")
    end
end
end