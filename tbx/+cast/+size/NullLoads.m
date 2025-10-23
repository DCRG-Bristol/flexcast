classdef NullLoads < cast.size.AbstractLoads
    methods
        function SetConfiguration(obj,opts)
            error('Not implemented');
        end
        function Lds = GetLoads(obj,Cases)
            error('Not implemented');
        end
    end
end