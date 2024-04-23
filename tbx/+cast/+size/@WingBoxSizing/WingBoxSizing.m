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
        Name string = "";
    end
    
    methods
        function val = eq(obj1,obj2)
            if ~isa(obj2,class(obj1))
                error('cannot compare %s to %s',class(obj1),class(obj2))
            end
            val = inf;
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
                opts.Etas double = [];
            end
            %WINGPARAMS Construct an instance of this class
            %   Detailed explanation goes here
            if isempty(opts.Etas)
                obj.Eta = linspace(0,1,NumEl);
            else
                obj.Eta = opts.Etas;
                NumEl = length(obj.Eta);
            end
            obj.NumEl = NumEl;
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
            obj.Skin = cast.size.SkinParams(nan,Span,Etas=obj.Eta);
        end

        function new_obj = interpolate(obj,etas)
            arguments
                obj
                etas double = [];
            end
            %INTERPOLATE Summary of this method goes here
            %   Detailed explanation goes here
            span = (etas(end)-etas(1))*obj.Span;
            new_obj = cast.size.WingBoxSizing(nan,span,obj.Mat,'Etas',etas./etas(end),'RibPitch',obj.Ribs.IdealPitch);
            new_obj.SparCap_Thickness = interp1(obj.Eta,obj.SparCap_Thickness,etas);
            new_obj.SparWeb_Thickness = interp1(obj.Eta,obj.SparWeb_Thickness,etas);
            % new_obj.Width = interp1(obj.Eta,obj.Width,etas);
            % new_obj.Height = interp1(obj.Eta,obj.Height,etas);
            psi = [0,(obj.Eta(2:end)+obj.Eta(1:end-1))/2,1];
            new_obj.SparWeb_Stiff_N = ceil(interp1(psi,obj.SparWeb_Stiff_N([1,1:end,end]),(etas(2:end)+etas(1:end-1))/2));
            new_obj.SparWeb_Stiff_Thickness = interp1(psi,obj.SparWeb_Stiff_Thickness([1,1:end,end]),(etas(2:end)+etas(1:end-1))/2);
            new_obj.Ribs = obj.Ribs.interpolate(etas);
            new_obj.Skin = obj.Skin.interpolate(etas);
        end
        function new_obj = combine(obj,obj2)
            span = obj.Span + obj2.Span;
            etas = obj.Eta*obj.Span/span;
            etas = [etas obj2.Eta(2:end)*(obj2.Span/span)+obj.Span/span];
            new_obj = cast.size.WingBoxSizing(nan,span,obj.Mat,'Etas',etas,'RibPitch',obj.Ribs.IdealPitch);
            new_obj.SparCap_Thickness = [obj.SparCap_Thickness obj2.SparCap_Thickness(2:end)];
            new_obj.SparWeb_Thickness = [obj.SparWeb_Thickness obj2.SparWeb_Thickness(2:end)];
            new_obj.Width = [obj.Width obj2.Width(2:end)];
            new_obj.Height = [obj.Height obj2.Height(2:end)];
            new_obj.SparWeb_Stiff_N = [obj.SparWeb_Stiff_N obj2.SparWeb_Stiff_N];
            new_obj.SparWeb_Stiff_Thickness = [obj.SparWeb_Stiff_Thickness obj2.SparWeb_Stiff_Thickness];

            new_obj.Ribs = obj.Ribs.combine(obj2.Ribs);
            new_obj.Skin = obj.Skin.combine(obj2.Skin);
        end

    end
    methods
        function obj = plus(obj,obj2)
            if ~isa(obj2(1),class(obj))
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
            if ~isa(obj2(1),class(obj))
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

