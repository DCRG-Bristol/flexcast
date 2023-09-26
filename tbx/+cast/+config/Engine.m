classdef Engine
    %ENGINE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Length
        Diameter
        Mass
        SFC_TO
        SFC_cruise
        T_Static
        BPR;
    end
    methods
        function obj = Engine(T_Static,L,D,M,SFC_TO,SFC_cruise,BPR)
            obj.T_Static = T_Static;
            obj.Length = L;
            obj.Diameter = D;
            obj.Mass = M;
            obj.SFC_TO = SFC_TO;
            obj.SFC_cruise = SFC_cruise;
            obj.BPR = BPR;
        end
        function eng_new = Rubberise(obj,T_new)
            f = T_new/obj.T_Static;
            % rubberise a new engine using scaling laws from Raymer (10.1 - 10.3)
            eng_new = cast.config.Engine(T_new,obj.Length*f^0.4,obj.Diameter*f^0.5,obj.Mass*f^1.1,...
                obj.SFC_TO,obj.SFC_cruise,obj.BPR);
        end

    end
    
    methods(Static)
        
        function obj = CFM_LEAP_1A(sfc_scaling)
            arguments
                 sfc_scaling = 1;
            end
            %CFM_LEAP_1A SData for CFM LEAP-1A
            %   https://en.wikipedia.org/wiki/CFM_International_LEAP
            %   SFC_To is a guess
            f = 1./(cast.SI.lb/(cast.SI.lbf*cast.SI.hr)) * sfc_scaling; % to convert SFC from imperial to SI.
            obj = cast.config.Engine(143.05e3,3.328,2.4,3153,0.3*f,0.515*f,11);
        end
        function obj = CFM56_5()
            %CFM56_5 Data for CFM56-5 as on a318/a319
            %   https://en.wikipedia.org/wiki/CFM_International_CFM56
            f = 1./(cast.SI.lb/(cast.SI.lbf*cast.SI.hr)); % to convert SFC from imperial to SI.
            obj = cast.config.Engine(107e3,2.422,2.00,2331,0.3316*f,0.596*f,6);
        end
    end
end

