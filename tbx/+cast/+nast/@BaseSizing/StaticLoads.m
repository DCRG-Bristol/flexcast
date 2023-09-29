function [Lds,BinFolder] = StaticLoads(obj,Case,idx,opts)
arguments
    obj
    Case cast.LoadCase
    idx double
    opts.BinFolder = '';
    opts.Verbose = true;
end
error('StaticLoads calculation not implemented')
end

