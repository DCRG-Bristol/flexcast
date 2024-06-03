classdef Loads
    %LOADS Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Mx
        My
        Mz
        Fx
        Fy
        Fz
        IDs

        % Name of critical load case
        MxIdx
        MyIdx
        MzIdx
        FxIdx
        FyIdx
        FzIdx

        Meta = struct();
    end

    methods
        function obj = Loads(N,opts)
            arguments
                N double
                opts.Idx = nan
            end
            obj.Mx = zeros(1,N);
            obj.My = zeros(1,N);
            obj.Mz = zeros(1,N);
            obj.Fx = zeros(1,N);
            obj.Fy = zeros(1,N);
            obj.Fz = zeros(1,N);
            obj = obj.SetIdx(opts.Idx);
        end
        function obj = max(obj)
            for i = 1:length(obj)
                % Mx
                [obj(i).Mx,I] = max(obj(i).Mx,[],1,"linear");
                obj(i).MxIdx = obj(i).MxIdx(I);
                % My
                [obj(i).My,I] = max(obj(i).My,[],1,"linear");
                obj(i).MyIdx = obj(i).MyIdx(I);
                % Mz
                [obj(i).Mz,I] = max(obj(i).Mz,[],1,"linear");
                obj(i).MzIdx = obj(i).MzIdx(I);
                % Fx
                [obj(i).Fx,I] = max(obj(i).Fx,[],1,"linear");
                obj(i).FxIdx = obj(i).FxIdx(I);
                % Fy
                [obj(i).Fy,I] = max(obj(i).Fy,[],1,"linear");
                obj(i).FyIdx = obj(i).FyIdx(I);
                % Fz
                [obj(i).Fz,I] = max(obj(i).Fz,[],1,"linear");
                obj(i).FzIdx = obj(i).FzIdx(I);
            end
        end
        function obj = min(obj)
            for i = 1:length(obj)
                % Mx
                [obj(i).Mx,I] = min(obj(i).Mx,[],1,"linear");
                obj(i).MxIdx = obj(i).MxIdx(I);
                % My
                [obj(i).My,I] = min(obj(i).My,[],1,"linear");
                obj(i).MyIdx = obj(i).MyIdx(I);
                % Mz
                [obj(i).Mz,I] = min(obj(i).Mz,[],1,"linear");
                obj(i).MzIdx = obj(i).MzIdx(I);
                % Fx
                [obj(i).Fx,I] = min(obj(i).Fx,[],1,"linear");
                obj(i).FxIdx = obj(i).FxIdx(I);
                % Fy
                [obj(i).Fy,I] = min(obj(i).Fy,[],1,"linear");
                obj(i).FyIdx = obj(i).FyIdx(I);
                % Fz
                [obj(i).Fz,I] = min(obj(i).Fz,[],1,"linear");
                obj(i).FzIdx = obj(i).FzIdx(I);
            end
        end
        function obj = or(obj,obj2)
            if ~isa(obj2,'cast.size.Loads')
                error('Second object must be of type Loads')
            end
            for i = 1:length(obj)
                % Mx
                obj(i).Mx = [obj(i).Mx;obj2(i).Mx];
                obj(i).MxIdx = [obj(i).MxIdx;obj2(i).MxIdx];
                % My
                obj(i).My = [obj(i).My;obj2(i).My];
                obj(i).MyIdx = [obj(i).MyIdx;obj2(i).MyIdx];
                % Mz
                obj(i).Mz = [obj(i).Mz;obj2(i).Mz];
                obj(i).MzIdx = [obj(i).MzIdx;obj2(i).MzIdx];
                % Fx
                obj(i).Fx = [obj(i).Fx;obj2(i).Fx];
                obj(i).FxIdx = [obj(i).FxIdx;obj2(i).FxIdx];
                % Fy
                obj(i).Fy = [obj(i).Fy;obj2(i).Fy];
                obj(i).FyIdx = [obj(i).FyIdx;obj2(i).FyIdx];
                % Fz
                obj(i).Fz = [obj(i).Fz;obj2(i).Fz];
                obj(i).FzIdx = [obj(i).FzIdx;obj2(i).FzIdx];

                obj(i).Meta = farg.struct.concat(obj(i).Meta,obj2(i).Meta);
            end
        end
        function obj = and(obj,obj2)
            if ~isa(obj2,class(obj))
                error('Second object must be of type Loads')
            end
            for i = 1:length(obj)
                % Mx
                obj(i).Mx = max(obj(i).Mx,obj2(i).Mx);
                idx = obj2(i).Mx == obj(i).Mx;
                obj(i).MxIdx(idx) = obj2(i).MxIdx(idx);
                % My
                obj(i).My = max(obj(i).My,obj2(i).My);
                idx = obj2(i).My == obj(i).My;
                obj(i).MyIdx(idx) = obj2(i).MyIdx(idx);
                % My
                obj(i).Mz = max(obj(i).Mz,obj2(i).Mz);
                idx = obj2(i).Mz == obj(i).Mz;
                obj(i).MzIdx(idx) = obj2(i).MzIdx(idx);
                % Fx
                obj(i).Fx = max(obj(i).Fx,obj2(i).Fx);
                idx = obj2(i).Fx == obj(i).Fx;
                obj(i).FxIdx(idx) = obj2(i).FxIdx(idx);
                % Fy
                obj(i).Fy = max(obj(i).Fy,obj2(i).Fy);
                idx = obj2(i).Fy == obj(i).Fy;
                obj(i).FyIdx(idx) = obj2(i).FyIdx(idx);
                % Fy
                obj(i).Fz = max(obj(i).Fz,obj2(i).Fz);
                idx = obj2(i).Fz == obj(i).Fz;
                obj(i).FzIdx(idx) = obj2(i).FzIdx(idx);
            end
        end
        function obj = repmat(obj,n)
            obj.Mx = repmat(obj.Mx,n,1);
            obj.My = repmat(obj.My,n,1);
            obj.Mz = repmat(obj.Mz,n,1);
            obj.Fx = repmat(obj.Fx,n,1);
            obj.Fy = repmat(obj.Fy,n,1);
            obj.Fz = repmat(obj.Fz,n,1);
            % add names together
            obj.MxIdx = repmat(obj.MxIdx,n,1);
            obj.MyIdx = repmat(obj.MyIdx,n,1);
            obj.MzIdx = repmat(obj.MzIdx,n,1);
            obj.FxIdx = repmat(obj.FxIdx,n,1);
            obj.FyIdx = repmat(obj.FyIdx,n,1);
            obj.FzIdx = repmat(obj.FzIdx,n,1);
        end
        function obj = plus(obj,obj2)
            if ~isa(obj2,class(obj))
                error('Second object must be of type Loads')
            end
            for i = 1:length(obj)
                if size(obj(i).Mx,2) ~= size(obj2(i).Mx,2)
                    error('Loads must have same number of elements')
                end
                %make sure both sets have same number of rows
                if ~(size(obj(i).Mx,1) == 1 && size(obj2(i).Mx,1) == 1)
                    if size(obj(i).Mx,1) == 1
                        obj(i) = obj(i).repmat(size(obj2(i).Mx,1));
                    elseif size(obj2(i).Mx,1) == 1
                        obj2(i) = obj2(i).repmat(size(obj(i).Mx,1));
                    else
                        error('Mismatch of rows - either both objects must have same number or one must have 1 row')
                    end
                end
                % add together
                obj(i).Mx = obj(i).Mx + obj2(i).Mx;
                obj(i).My = obj(i).My + obj2(i).My;
                obj(i).Mz = obj(i).Mz + obj2(i).Mz;
                obj(i).Fx = obj(i).Fx + obj2(i).Fx;
                obj(i).Fy = obj(i).Fy + obj2(i).Fy;
                obj(i).Fz = obj(i).Fz + obj2(i).Fz;
                % add names together
                obj(i).MxIdx = obj(i).MxIdx + obj2(i).MxIdx;
                obj(i).MyIdx = obj(i).MyIdx + obj2(i).MyIdx;
                obj(i).MzIdx = obj(i).MzIdx + obj2(i).MzIdx;
                obj(i).FxIdx = obj(i).FxIdx + obj2(i).FxIdx;
                obj(i).FyIdx = obj(i).FyIdx + obj2(i).FyIdx;
                obj(i).FzIdx = obj(i).FzIdx + obj2(i).FzIdx;
            end
        end
        function obj = times(obj,val)
            for i = 1:length(obj)
                obj(i).Mx = obj(i).Mx .* val;
                obj(i).My = obj(i).My .* val;
                obj(i).Mz = obj(i).Mz .* val;
                obj(i).Fx = obj(i).Fx .* val;
                obj(i).Fy = obj(i).Fy .* val;
                obj(i).Fz = obj(i).Fz .* val;
            end
        end
        function obj = abs(obj)
            for i = 1:length(obj)
                obj(i).Mx = abs(obj(i).Mx);
                obj(i).My = abs(obj(i).My);
                obj(i).Mz = abs(obj(i).Mz);
                obj(i).Fx = abs(obj(i).Fx);
                obj(i).Fy = abs(obj(i).Fy);
                obj(i).Fz = abs(obj(i).Fz);
            end
        end
        function obj = minus(obj,obj2)
            if ~isa(obj2,class(obj))
                error('Second object must be of type Loads')
            end
            for i = 1:length(obj)
                if size(obj(i).Mx,2) ~= size(obj2(i).Mx,2)
                    error('Loads must have same number of elements')
                end
                %make sure both sets have same number of rows
                if ~(size(obj(i).Mx,1) == 1 && size(obj2(i).Mx,1) == 1)
                    if size(obj(i).Mx,1) == 1
                        obj(i) = obj(i).repmat(size(obj2(i).Mx,1));
                    elseif size(obj2(i).Mx,1) == 1
                        obj2(i) = obj2(i).repmat(size(obj(i).Mx,1));
                    else
                        error('Mismatch of rows - either both objects must have same number or one must have 1 row')
                    end
                end
                % add together
                obj(i).Mx = obj(i).Mx - obj2(i).Mx;
                obj(i).My = obj(i).My - obj2(i).My;
                obj(i).Mz = obj(i).Mz - obj2(i).Mz;
                obj(i).Fx = obj(i).Fx - obj2(i).Fx;
                obj(i).Fy = obj(i).Fy - obj2(i).Fy;
                obj(i).Fz = obj(i).Fz - obj2(i).Fz;
                % add names together
                obj(i).MxIdx = obj(i).MxIdx + obj2(i).MxIdx;
                obj(i).MyIdx = obj(i).MyIdx + obj2(i).MyIdx;
                obj(i).MzIdx = obj(i).MzIdx + obj2(i).MzIdx;
                obj(i).FxIdx = obj(i).FxIdx + obj2(i).FxIdx;
                obj(i).FyIdx = obj(i).FyIdx + obj2(i).FyIdx;
                obj(i).FzIdx = obj(i).FzIdx + obj2(i).FzIdx;
            end
        end
        function obj = SetIdx(obj,id)
            arguments
                obj
                id double
            end
            for i = 1:length(obj)
                ids = repmat(id,1,length(obj(i).Mx));
                obj(i).MxIdx = ids;
                obj(i).MyIdx = ids;
                obj(i).MzIdx = ids;
                obj(i).FxIdx = ids;
                obj(i).FyIdx = ids;
                obj(i).FzIdx = ids;
            end
        end
        function obj = IncreaseIdx(obj,val)
            arguments
                obj
                val double
            end
            for i = 1:length(obj)
                obj(i).MxIdx = obj(i).MxIdx + val;
                obj(i).MyIdx = obj(i).MyIdx + val;
                obj(i).MzIdx = obj(i).MzIdx + val;
                obj(i).FxIdx = obj(i).FxIdx + val;
                obj(i).FyIdx = obj(i).FyIdx + val;
                obj(i).FzIdx = obj(i).FzIdx + val;
            end
        end
        function [p,Etas] = plot(obj,load,Params,opts)
            arguments
                obj
                load string {mustBeMember(load,{'Fx','Fy','Fz','Mx','My','Mz'})}
                Params cast.size.WingBoxSizing
                opts.PlotIdx logical = false
                opts.Row = nan;
                opts.Norm = nan; % index of row to normalise data with
                opts.Xidx = nan;
                opts.XScale = 1;
%                 opts.PlotSeperators logical = true
            end
            Spans = [Params.Span];
            Etas = [0,cumsum(Spans)./sum(Spans)];
            p = [];
            for i = 1:length(obj)
                hold on
                xs = Params(i).Eta * (Etas(i+1)-Etas(i)) + Etas(i);
                if isnan(opts.Xidx)
                    opts.Xidx = 1:length(xs);
                end
                if ~opts.PlotIdx
                    data = obj(i).(load).*opts.XScale;
                    if ~isnan(opts.Norm)
                        data = data ./ repmat(data(opts.Norm,:),size(data,1),1);
                    end
                    if any(isnan(opts.Row))
                        tmp = plot(xs,data(:,opts.Xidx),'-');
                    else
                        tmp = plot(xs,data(opts.Row,opts.Xidx),'-');
                    end
                else
                    data = obj(i).(load+"Idx");
                    if any(isnan(opts.Row))
                        tmp = plot(xs,data(:,opts.Xidx),'-');
                    else
                        tmp = plot(xs,data(opts.Row,opts.Xidx),'-');
                    end
                end
                if isempty(p)
                    p = tmp;
                else
                    p = [p;tmp];
                end
            end
        end
    end
end

