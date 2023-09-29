classdef RibParams    
    properties
        NumEl               % Number of Ribs
        Eta                 % Normalised Position of each Rib
        Pitch;              % distance in y between each rib
        Thickness;          % Thickness of each rob
    end
    methods
        function obj = RibParams(Span,Pitch)
            obj.NumEl = ceil(Span/Pitch)+1;
            obj.Pitch = Span/(obj.NumEl-1);
            obj.Eta = linspace(0,1,obj.NumEl);
            obj.Thickness = ones(1,obj.NumEl) * 0.01;
        end
    end
    methods
        function obj = plus(obj,obj2)
            if ~isa(obj2,"RibParams")
                error('Must be two rib params')
            end
            obj.Pitch = obj.Pitch + obj2.Pitch;
            obj.Thickness = obj.Thickness + obj2.Thickness;
        end
        function obj = minus(obj,obj2)
            if ~isa(obj2,"RibParams")
                error('Must be two rib params')
            end
            obj.Pitch = obj.Pitch - obj2.Pitch;
            obj.Thickness = obj.Thickness - obj2.Thickness;
        end
        function obj = times(obj,val)
            obj.Pitch = obj.Pitch .* val;
            obj.Thickness = obj.Thickness .* val;
        end
        function obj = rdivide(obj,val)
            obj.Pitch = obj.Pitch ./ val;
            obj.Thickness = obj.Thickness ./ val;
        end
    end
end

