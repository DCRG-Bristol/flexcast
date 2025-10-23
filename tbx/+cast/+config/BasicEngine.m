classdef BasicEngine
    %AbstractEngine Abstract class for conceptual Engine
    properties
        TSFC_0 % SFC on ground
        TSFC_crusie % SFC in cruise
    end
    methods 
        function obj = BasicEngine(TSFC_0,TSFC_cruise)
            obj.TSFC_0 = TSFC_0;
            obj.TSFC_crusie = TSFC_cruise;
        end
        function TSFC = TSFC(obj,M,alt)
            if M==0 || alt<1000
                TSFC  = obj.TSFC_0;
            else
                TSFC = obj.TSFC_crusie; % Assign cruise TSFC for higher Mach numbers
            end
        end
    end
end

