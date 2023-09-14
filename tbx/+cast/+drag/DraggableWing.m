classdef DraggableWing < baff.Wing & cast.drag.Draggable
    %DRAGGABLEBLUFFBODY Summary of this class goes here
    %   Detailed explanation goes here  
    methods
        function obj = DraggableWing(Wing)
            arguments
                Wing
            end
            %DRAGGABLEBLUFFBODY Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@baff.Wing(Wing.AeroStations);
            obj.Eta = Wing.Eta;
            obj.A = Wing.A;
            obj.Offset = Wing.Offset;
            obj.isAbsolute = Wing.isAbsolute;
            obj.Eta = Wing.Eta;
            obj.EtaLength = Wing.EtaLength;
            obj.Parent = Wing.Parent;
            obj.Children = Wing.Children;
            for i = 1:length(Wing.Children)
                Wing.Children(i).Parent = obj;
            end
            obj.Name = Wing.Name;
            obj.Index = Wing.Index;
            obj.Index = Wing.Index;

            obj.Stations = Wing.Stations;
            obj.AeroStations = Wing.AeroStations;
            obj.ControlSurfaces = Wing.ControlSurfaces;
        end
        
        function val = eq(obj1,obj2)
            if length(obj1)~= length(obj2) || ~isa(obj2,'cast.drag.DraggableWing')
                val = false;
                return
            end
            val = eq@baff.Wing(obj1,obj2);
            for i = 1:length(obj1)
                val = val && obj1(i).DragEnabled == obj2(i).DragEnabled;
                val = val && obj1(i).InterferanceFactor == obj2(i).InterferanceFactor;
            end
        end
    end
end

