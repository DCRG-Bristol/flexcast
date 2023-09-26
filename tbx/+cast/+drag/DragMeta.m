classdef DragMeta
    %DragMeta Summary of this class goes here
    %   Detailed explanation goes here
properties (SetAccess = immutable)
    Name
    CD0
end
methods
    function obj = DragMeta(name,cd0)
        obj.Name = name;
        obj.CD0 = cd0;
    end
end
end