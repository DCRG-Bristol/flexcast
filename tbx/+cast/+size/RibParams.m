classdef RibParams    
    properties
        NumEl               % Number of Ribs
        Eta                 % Normalised Position of each Rib
        ActualPitch;        % distance in y between each rib
        IdealPitch          % Specified rib pitch
        Thickness;          % Thickness of each rob
        Span
        Min_Thickness = 1e-3;
    end
    % properties(Dependent)
    %     Span
    % end
    methods
        function obj = RibParams(Span,Pitch)
            obj.IdealPitch = Pitch;
            obj.Span = Span;
            obj.NumEl = max(round(Span/Pitch)+1,2);
            obj.ActualPitch = Span/(obj.NumEl-1);
            obj.Eta = linspace(0,1,obj.NumEl);
            obj.Thickness = ones(1,obj.NumEl) * 0.01;
        end
    end
    methods
        function val = get.Span(obj)
            if isempty(obj.Span)
                val = obj.IdealPitch*(obj.NumEl-1);
            else
                val = obj.Span;
            end
        end
        function obj = set.Span(obj,val)
            obj.Span = val;
        end
    end
    methods
        function obj = plus(obj,obj2)
            if ~isa(obj2,class(obj))
                error('Must be two rib params')
            end
            obj.Thickness = obj.Thickness + obj2.Thickness;
        end
        function obj = minus(obj,obj2)
            if ~isa(obj2,class(obj))
                error('Must be two rib params')
            end
            obj.Thickness = obj.Thickness - obj2.Thickness;
        end
        function obj = times(obj,val)
            obj.Thickness = obj.Thickness .* val;
        end
        function obj = rdivide(obj,val)
            obj.Thickness = obj.Thickness ./ val;
        end
        function obj = apply(obj,obj2)
            % wings can have diffetn numbers of ribs so we need to interpolate again
            obj.Thickness = interp1(obj2.Eta,obj2.Thickness,obj.Eta,'linear','extrap');
            obj.Thickness(obj.Thickness<obj.Min_Thickness) = obj.Min_Thickness;
        end
        function new_obj = interpolate(obj,etas)
            span = obj.Span*(etas(end)-etas(1));
            new_obj = cast.size.RibParams(span,obj.IdealPitch);
            new_obj.Thickness = interp1(obj.Eta,obj.Thickness,new_obj.Eta*span/obj.Span,'linear','extrap');
        end
        function new_obj = combine(obj,obj2)
            new_span = obj.Span+obj2.Span;
            new_obj = cast.size.RibParams(new_span,obj.IdealPitch);
            etas = obj.Eta*obj.Span/new_span;
            etas = [etas obj2.Eta*(obj2.Span/new_span)+obj.Span/new_span];
            thickness = [obj.Thickness obj2.Thickness];
            [etas,idx] = unique(etas);

            new_obj.NumEl = length(etas);
            new_obj.Eta = etas;
            new_obj.Thickness = thickness(idx);
            new_obj.ActualPitch = new_span/(new_obj.NumEl-1);

            % idx1 = idx(idx<=obj.NumEl);
            % idx2 = idx(idx>obj.NumEl)-obj.NumEl;
            % thicknesses = [obj.Thickness(idx1) obj2.Thickness(idx2)];
            % new_obj.Thickness = interp1(etas,thicknesses,new_obj.Eta,'linear','extrap');
        end
    end
end

