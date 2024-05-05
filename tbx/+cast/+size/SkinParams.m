classdef SkinParams
    %SKINPARAMS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        NumEl
        Eta
        Span
        Skin_Thickness
        Effective_Width
        Strg_Pitch
        Strg_Depth
        StrgFlange_Width
        StrgGround_Width
        StrgThickness_Ground
        StrgThickness_Web
        StrgThickness_Flange
        

        %minimium values
        Skin_Min_Thickness = 0.5e-3;
        Strg_Min_Thickness = 0.5e-3;
    end
    
    methods
        function obj = SkinParams(NumEl,Span,opts)
            %SKINPARAMS Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                NumEl
                Span
                opts.Etas = [];
            end
            if isempty(opts.Etas)
                obj.Eta = linspace(0,1,NumEl);
            else
                obj.Eta = opts.Etas;
                NumEl = length(obj.Eta);
            end
            obj.Span = Span;
            obj.NumEl = NumEl;
            obj.Skin_Thickness=1e-3*ones(1,NumEl);
            obj.Effective_Width=1e-3*ones(1,NumEl);
            obj.Strg_Pitch=obj.Effective_Width;
            obj.Strg_Depth=1e-3*ones(1,NumEl);
            obj.StrgFlange_Width=1e-3*ones(1,NumEl);
            obj.StrgGround_Width=1e-3*ones(1,NumEl);
            obj.StrgThickness_Ground=1e-3*ones(1,NumEl);
            obj.StrgThickness_Web=1e-3*ones(1,NumEl);
            obj.StrgThickness_Flange=1e-3*ones(1,NumEl);
        end
        function obj = apply(obj,obj2)
            if obj.NumEl ~= obj2.NumEl
                error('Must be same number of skin params')
            end
            obj.Skin_Thickness = obj2.Skin_Thickness;
            obj.Effective_Width = obj2.Effective_Width;
            obj.Strg_Pitch = obj2.Strg_Pitch;
            obj.Strg_Depth = obj2.Strg_Depth;
            obj.StrgFlange_Width = obj2.StrgFlange_Width;
            obj.StrgGround_Width = obj2.StrgGround_Width;
            obj.StrgThickness_Ground = obj2.StrgThickness_Ground;
            obj.StrgThickness_Web = obj2.StrgThickness_Web;
            obj.StrgThickness_Flange = obj2.StrgThickness_Flange;
        end
        function new_obj = interpolate(obj,etas)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            span = (etas(end)-etas(1))*obj.Span;
            new_obj = cast.size.SkinParams(nan,span,Etas=etas./etas(end));
            new_obj.Skin_Thickness = interp1(obj.Eta,obj.Skin_Thickness,etas);
            new_obj.Effective_Width = interp1(obj.Eta,obj.Effective_Width,etas);
            new_obj.Strg_Pitch = interp1(obj.Eta,obj.Strg_Pitch,etas);
            new_obj.Strg_Depth = interp1(obj.Eta,obj.Strg_Depth,etas);
            new_obj.StrgFlange_Width = interp1(obj.Eta,obj.StrgFlange_Width,etas);
            new_obj.StrgGround_Width = interp1(obj.Eta,obj.StrgGround_Width,etas);
            new_obj.StrgThickness_Ground = interp1(obj.Eta,obj.StrgThickness_Ground,etas);
            new_obj.StrgThickness_Web = interp1(obj.Eta,obj.StrgThickness_Web,etas);
            new_obj.StrgThickness_Flange = interp1(obj.Eta,obj.StrgThickness_Flange,etas);
        end
        function new_obj = combine(obj,obj2)
            span = obj.Span + obj2.Span;
            etas = obj.Eta*obj.Span/span;
            etas = [etas obj2.Eta(2:end)*(obj2.Span/span)+obj.Span/span];
            new_obj = cast.size.SkinParams(nan,span,Etas=etas);
            new_obj.Skin_Thickness = [obj.Skin_Thickness obj2.Skin_Thickness(2:end)];
            new_obj.Effective_Width = [obj.Effective_Width obj2.Effective_Width(2:end)];
            new_obj.Strg_Pitch = [obj.Strg_Pitch obj2.Strg_Pitch(2:end)];
            new_obj.Strg_Depth = [obj.Strg_Depth obj2.Strg_Depth(2:end)];
            new_obj.StrgFlange_Width = [obj.StrgFlange_Width obj2.StrgFlange_Width(2:end)];
            new_obj.StrgGround_Width = [obj.StrgGround_Width obj2.StrgGround_Width(2:end)];
            new_obj.StrgThickness_Ground = [obj.StrgThickness_Ground obj2.StrgThickness_Ground(2:end)];
            new_obj.StrgThickness_Web = [obj.StrgThickness_Web obj2.StrgThickness_Web(2:end)];
            new_obj.StrgThickness_Flange = [obj.StrgThickness_Flange obj2.StrgThickness_Flange(2:end)];

        end
    end
    methods
        function obj = plus(obj,obj2)
            if ~isa(obj2,class(obj))
                error('Must be two skin params')
            end
            obj.Skin_Thickness = obj.Skin_Thickness + obj2.Skin_Thickness;
            obj.Effective_Width = obj.Effective_Width + obj2.Effective_Width;
            obj.Strg_Pitch = obj.Strg_Pitch + obj2.Strg_Pitch;
            obj.Strg_Depth = obj.Strg_Depth + obj2.Strg_Depth;
            obj.StrgFlange_Width = obj.StrgFlange_Width + obj2.StrgFlange_Width;
            obj.StrgGround_Width = obj.StrgGround_Width + obj2.StrgGround_Width;
            obj.StrgThickness_Ground = obj.StrgThickness_Ground + obj2.StrgThickness_Ground;
            obj.StrgThickness_Web = obj.StrgThickness_Web + obj2.StrgThickness_Web;
            obj.StrgThickness_Flange = obj.StrgThickness_Flange + obj2.StrgThickness_Flange;
        end
        function obj = minus(obj,obj2)
            if ~isa(obj2,class(obj))
                error('Must be two skin params')
            end
            obj.Skin_Thickness = obj.Skin_Thickness - obj2.Skin_Thickness;
            obj.Effective_Width = obj.Effective_Width - obj2.Effective_Width;
            obj.Strg_Pitch = obj.Strg_Pitch - obj2.Strg_Pitch;
            obj.Strg_Depth = obj.Strg_Depth - obj2.Strg_Depth;
            obj.StrgFlange_Width = obj.StrgFlange_Width - obj2.StrgFlange_Width;
            obj.StrgGround_Width = obj.StrgGround_Width - obj2.StrgGround_Width;
            obj.StrgThickness_Ground = obj.StrgThickness_Ground - obj2.StrgThickness_Ground;
            obj.StrgThickness_Web = obj.StrgThickness_Web - obj2.StrgThickness_Web;
            obj.StrgThickness_Flange = obj.StrgThickness_Flange - obj2.StrgThickness_Flange;
        end
        function obj = times(obj,val)
            obj.Skin_Thickness = obj.Skin_Thickness .* val;
            obj.Effective_Width = obj.Effective_Width .* val;
            obj.Strg_Pitch = obj.Strg_Pitch .* val;
            obj.Strg_Depth = obj.Strg_Depth .* val;
            obj.StrgFlange_Width = obj.StrgFlange_Width .* val;
            obj.StrgGround_Width = obj.StrgGround_Width .* val;
            obj.StrgThickness_Ground = obj.StrgThickness_Ground .* val;
            obj.StrgThickness_Web = obj.StrgThickness_Web .* val;
            obj.StrgThickness_Flange = obj.StrgThickness_Flange .* val;
        end
        function obj = rdivide(obj,val)
            obj.Skin_Thickness = obj.Skin_Thickness ./ val;
            obj.Effective_Width = obj.Effective_Width ./ val;
            obj.Strg_Pitch = obj.Strg_Pitch ./ val;
            obj.Strg_Depth = obj.Strg_Depth ./ val;
            obj.StrgFlange_Width = obj.StrgFlange_Width ./ val;
            obj.StrgGround_Width = obj.StrgGround_Width ./ val;
            obj.StrgThickness_Ground = obj.StrgThickness_Ground ./ val;
            obj.StrgThickness_Web = obj.StrgThickness_Web ./ val;
            obj.StrgThickness_Flange = obj.StrgThickness_Flange ./ val;
        end
    end
end

