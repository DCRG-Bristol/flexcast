function [Par,BinFolder,Lds] = SimpleSizing(obj,Cases,opts)
    arguments
        obj
        Cases (:,1) cast.LoadCase % Load Cases to run
        opts cast.nast.Opts = cast.nast.Opts % Options for sizing
    end

    if isempty(opts.BinFolder)
            opts.BinFolder = ads.nast.create_tmp_bin;
    end
    
    if ~opts.Silent
        ads.util.printing.title(sprintf('Getting Loads: %s',obj.Name),Length=60);
    end

    %get loads for each case
    [Lds,BinFolder] = obj.GetLoads(Cases,"CleanUp",opts.CleanUp,...
        "BinFolder",opts.BinFolder,"Verbose",opts.Verbose,"Silent",opts.Silent);
    %size aircraft
    Par = obj.WingBoxParams.Size(Lds.max(),1,"Verbose",opts.Verbose,"Converge",0.05,"optiSizing",true);
    obj.WingBoxParams = Par;

    end
    
    