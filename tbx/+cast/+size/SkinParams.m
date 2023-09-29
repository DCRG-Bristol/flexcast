classdef SkinParams
    %SKINPARAMS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        NumEl
        Eta
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
        function obj = SkinParams(NumEl)
            %SKINPARAMS Construct an instance of this class
            %   Detailed explanation goes here
            obj.NumEl = NumEl;
            obj.Eta = linspace(0,1,obj.NumEl);
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
    end
    methods
        function obj = plus(obj,obj2)
            if ~isa(obj2,"SkinParams")
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
            if ~isa(obj2,"SkinParams")
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

