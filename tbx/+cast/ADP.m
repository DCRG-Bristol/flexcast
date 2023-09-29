classdef ADP < handle
    %ADP Aircraft Design Parameters
    properties
        ADR cast.ADR; % Aircraft Design Requirements
        FuelType = cast.config.Fuel.JA1;
    end
    %geometry
    properties
        SweepAngle
        AR
        Span;
        WingArea;
        Thrust;
        KinkEta = 0.3;
        EngineEta = 0.3;
        WingEta = 0.5;
        WingletHeight = 2.4;

        V_HT; % Horizontal Tail Volume
        V_VT; % Vertical tail volume
    end
    %Aerodynamic
    properties
        Cl_max = 1.5;   % airfoil amx Cl for wing
        
        Delta_Cl_ld = 1.3;
        Delta_Cl_to = 0.4;

        CL_max = 2;     %Max CL in landing configuration 
        CD_TO = 0.04;   %CD in ground run
        CL_TO = 0;      %CL during ground run        
        CL_TOmax        % max CL in TO condition
        CD_LDG = 0.04;  %CD in ground run on landing
        CL_LDG = 0;     %CL during ground run on landing
        CL_cruise = 0.5;%CL during cruise

        LD_c = 15;
        LD_app = 10;

        CD0;
        e; %Oswald Efficency Factor

        TWgr; %thrust to weight ratio on ground run 
    end
    %mass
    properties
        MTOM
        OEM
        Mf_Fuel % mass ratio fuel
        Mf_TOC % mass ratio top of climb
        Mf_Ldg % mass ratio at landing
        Mf_res % Resevre Fuel ratio
    end
    %engine initial guess
    properties
        SFC_0; % specific fuel consumption on ground
        SFC_app; % specific fuel consumption on ground
        SFC_c; % SFC cruise
        N_eng = 2;
        TW_idle = 0.02;
    end
    
    methods
        function obj = ADP()
        end
    end
end

