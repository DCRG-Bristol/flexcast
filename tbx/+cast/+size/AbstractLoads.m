classdef (Abstract) AbstractLoads < handle
    methods(Abstract)
        SetConfiguration(obj,opts)
        Lds = GetLoads(obj,Cases)
    end
end