classdef DraggableBluffBody < baff.BluffBody & cast.drag.Draggable
    %DRAGGABLEBLUFFBODY Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = DraggableBluffBody(BluffBody)
            arguments
                BluffBody
            end
            %DRAGGABLEBLUFFBODY Construct an instance of this class
            %   Detailed explanation goes here
            obj.Eta = BluffBody.Eta;
            obj.A = BluffBody.A;
            obj.Offset = BluffBody.Offset;
            obj.isAbsolute = BluffBody.isAbsolute;
            obj.Eta = BluffBody.Eta;
            obj.EtaLength = BluffBody.EtaLength;
            obj.Parent = BluffBody.Parent;
            if ~isempty(obj.Parent)
                for i = 1:length(obj.Parent.Children)
                    if obj.Parent.Children(i) == BluffBody
                        obj.Parent.Children(i) = obj;
                        break;
                    end
                end
            end
            obj.Children = BluffBody.Children;
            for i = 1:length(BluffBody.Children)
                BluffBody.Children(i).Parent = obj;
            end
            obj.Name = BluffBody.Name;
            obj.Index = BluffBody.Index;
            obj.Index = BluffBody.Index;
            obj.Stations = BluffBody.Stations;
        end
        
        function val = eq(obj1,obj2)
            if length(obj1)~= length(obj2) || ~isa(obj2,'cast.drag.DraggableBluffBody')
                val = false;
                return
            end
            val = eq@baff.BluffBody(obj1,obj2);
            for i = 1:length(obj1)
                val = val && obj1(i).DragEnabled == obj2(i).DragEnabled;
                val = val && obj1(i).InterferanceFactor == obj2(i).InterferanceFactor;
            end
        end
    end
end

