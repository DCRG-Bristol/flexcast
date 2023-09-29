classdef WingBoxSizing
    %WINGPARAMS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        NumEl
        Eta
        Span

        %spar properties
        CapEta_width=0.1;
        CapEta_height=0;
        SparCap_Thickness
        SparWeb_Thickness
        SparWeb_Stiff_N         % Number of Stiffeners on web
        SparWeb_Stiff_Thickness % Thickness of stiffeners
        Height
        Width

        % Material
        Mat ads.fe.Material

        % Ribs
        Ribs cast.size.RibParams

        %skin-stringer panels
        Skin cast.size.SkinParams

        %minValues
        Spar_Min_Thickness = 1e-3;

        Index = 0;
    end
    
    methods
        function val = eq(obj1,obj2)
            if ~isa(obj2,'cast.size.WingBoxSizing')
                error('cannot compare %s to %s',class(obj1),class(obj2))
            end
            val = 0;
            for i = 1:length(obj1)
                % skin thickness delta
                st_delta = (obj2(i).Skin.Skin_Thickness - obj1(i).Skin.Skin_Thickness);
                st_delta = st_delta./obj1(i).Skin.Skin_Thickness;
                indicator1=max(abs(st_delta));
                
                % web thickness indicator
                tsw_delta = (obj2(i).SparWeb_Thickness - obj1(i).SparWeb_Thickness);
                tsw_delta = tsw_delta./obj1(i).SparWeb_Thickness;
                indicator2=max(abs(tsw_delta));
    
                %overall indicator
                val=max([indicator1,indicator2]);
            end
        end

        function obj = WingBoxSizing(NumEl,Span,Mat,opts)
            arguments
                NumEl double
                Span double
                Mat ads.fe.Material
                opts.RibPitch double= 0.6;
            end
            %WINGPARAMS Construct an instance of this class
            %   Detailed explanation goes here
            obj.NumEl = NumEl;
            obj.Eta = linspace(0,1,obj.NumEl);
            obj.Span = Span;
            obj.Mat = Mat;
            %spar properties
            obj.SparCap_Thickness=0.01*ones(1,NumEl);
            obj.SparWeb_Thickness=0.01*ones(1,NumEl);
            obj.Width = 1*ones(1,NumEl);
            obj.Height = 0.1*ones(1,NumEl);
            obj.SparWeb_Stiff_N = ones(1,obj.NumEl-1) * 5;
            obj.SparWeb_Stiff_Thickness = ones(1,obj.NumEl-1) * 1e-3;

            %Ribs
            obj.Ribs = cast.size.RibParams(Span,opts.RibPitch);

            % skin-stringer panels 
            obj.Skin = cast.size.SkinParams(NumEl);
        end
    end
    methods
        function obj = plus(obj,obj2)
            if ~isa(obj2(1),"cast.size.WingBoxSizing")
                error('Must be two WingBoxSizing')
            end
            for i= 1:length(obj)
                obj(i).SparCap_Thickness = obj(i).SparCap_Thickness + obj2(i).SparCap_Thickness; 
                obj(i).SparWeb_Thickness = obj(i).SparWeb_Thickness + obj2(i).SparWeb_Thickness;  
                obj(i).SparWeb_Stiff_N = obj(i).SparWeb_Stiff_N + obj2(i).SparWeb_Stiff_N; 
                obj(i).SparWeb_Stiff_Thickness = obj(i).SparWeb_Stiff_Thickness + obj2(i).SparWeb_Stiff_Thickness; 
                obj(i).Ribs = obj(i).Ribs + obj2(i).Ribs;
                obj(i).Skin = obj(i).Skin + obj2(i).Skin;
            end
        end
        function obj = minus(obj,obj2)
            if ~isa(obj2(1),"cast.size.WingBoxSizing")
                error('Must be two WingBoxSizing')
            end
            for i= 1:length(obj)
                obj(i).SparCap_Thickness = obj(i).SparCap_Thickness - obj2(i).SparCap_Thickness;
                obj(i).SparWeb_Thickness = obj(i).SparWeb_Thickness - obj2(i).SparWeb_Thickness;
                obj(i).SparWeb_Stiff_N = obj(i).SparWeb_Stiff_N - obj2(i).SparWeb_Stiff_N;
                obj(i).SparWeb_Stiff_Thickness = obj(i).SparWeb_Stiff_Thickness - obj2(i).SparWeb_Stiff_Thickness;
                obj(i).Ribs = obj(i).Ribs - obj2(i).Ribs;
                obj(i).Skin = obj(i).Skin - obj2(i).Skin;
            end
        end
        function obj = times(obj,val)
            for i = 1:length(obj)
                obj(i).SparCap_Thickness = obj(i).SparCap_Thickness .* val;
                obj(i).SparWeb_Thickness = obj(i).SparWeb_Thickness .* val;
                obj(i).SparWeb_Stiff_N = round(obj(i).SparWeb_Stiff_N .* val);
                obj(i).SparWeb_Stiff_Thickness = obj(i).SparWeb_Stiff_Thickness .* val;
                obj(i).Ribs = obj(i).Ribs .* val;
                obj(i).Skin = obj(i).Skin .* val;
            end
        end
        function obj = mtimes(obj,val)
            obj = obj.*val;
        end
        function obj = rdivide(obj,val)
            for i = 1:length(obj)
                obj(i).SparCap_Thickness = obj(i).SparCap_Thickness ./ val;
                obj(i).SparWeb_Thickness = obj(i).SparWeb_Thickness ./ val;
                obj(i).SparWeb_Stiff_N = round(obj(i).SparWeb_Stiff_N ./ val);
                obj(i).SparWeb_Stiff_Thickness = obj(i).SparWeb_Stiff_Thickness ./ val;
                obj(i).Ribs = obj(i).Ribs ./ val;
                obj(i).Skin = obj(i).Skin ./ val;
            end
        end
    end
end

