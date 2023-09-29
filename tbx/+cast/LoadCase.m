classdef LoadCase
    %LOADCASE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Type string = "StaticLoads"
        LoadFactor double = 1;
        Mach double = 0.8;
        Alt double = 32e3;
        SafetyFactor double = 1.5;
        ConfigParams = struct();
        Name string
        Nonlinear logical = false;
        IdxOverride double = nan % if not nan overrides idx of load case
    end
    
    methods(Static)
        function obj = Dummy()
            obj = LoadCase();
            obj.Name = 'Dummy';
            obj.Type = "Dummy";
        end
        function obj = Ground(opts)
            arguments
                opts.SafetyFactor = 1.5;
                opts.Config = struct();
                opts.Name = ""
                opts.NonLinear = false;
                opts.Idx = nan;
            end
            obj = cast.LoadCase();
            obj.Name = sprintf('Grd');
            if opts.Name ~= ""
                obj.Name = obj.Name + "_" + opts.Name;
            end
            obj.Type = "GroundLoads";
            obj.LoadFactor = 1;
            obj.Mach = 0;
            obj.Alt = 0;
            obj.SafetyFactor = opts.SafetyFactor;
            obj.ConfigParams = opts.Config;
            obj.Nonlinear = opts.NonLinear;
            obj.IdxOverride = opts.Idx;
        end
        function obj = Manoeuvre(Mach,alt,LoadFactor,opts)
            arguments
                Mach
                alt
                LoadFactor
                opts.SafetyFactor = 1.5;
                opts.Config = struct();
                opts.Name = ""
                opts.NonLinear = false;
                opts.Idx = nan;
            end
            obj = cast.LoadCase();
            obj.Name = sprintf('Mano_M%.0f_FL%.0f_LF%.0fd%.0f',Mach*100,alt/1e2,...
                floor(LoadFactor),10*(LoadFactor-floor(LoadFactor)));
            if opts.Name ~= ""
                obj.Name = obj.Name + "_" + opts.Name;
            end
            obj.Type = "StaticLoads";
            obj.LoadFactor = LoadFactor;
            obj.Mach = Mach;
            obj.Alt = alt;
            obj.SafetyFactor = opts.SafetyFactor;
            obj.ConfigParams = opts.Config;
            obj.Nonlinear = opts.NonLinear;
            obj.IdxOverride = opts.Idx;
        end
        function obj = Gust(Mach,alt,opts)
            arguments
                Mach
                alt
                opts.SafetyFactor = 1.5;
                opts.Config = struct();
                opts.Name = ""
                opts.NonLinear = false;
                opts.Idx = nan;
            end
            obj = cast.LoadCase();
            obj.Name = sprintf('1MC_M%.0f_FL%.0f',Mach*100,alt/1e2);
            if opts.Name ~= ""
                obj.Name = obj.Name + "_" + opts.Name;
            end
            obj.Type = "GustLoads";
            obj.LoadFactor = 1;
            obj.Mach = Mach;
            obj.Alt = alt;
            obj.SafetyFactor = opts.SafetyFactor;
            obj.ConfigParams = opts.Config;
            obj.Nonlinear = opts.NonLinear;
            obj.IdxOverride = opts.Idx;
        end
        function obj = Turbulence(Mach,alt,opts)
            arguments
                Mach
                alt
                opts.SafetyFactor = 1.5;
                opts.Config = struct();
                opts.Name = ""
                opts.NonLinear = false;
                opts.Idx = nan;
            end
            obj = cast.LoadCase();
            obj.Name = sprintf('Turb_M%.0f_FL%.0f',Mach*100,alt/1e2);
            if opts.Name ~= ""
                obj.Name = obj.Name + "_" + opts.Name;
            end
            obj.Type = "TurbLoads";
            obj.LoadFactor = 1;
            obj.Mach = Mach;
            obj.Alt = alt;
            obj.SafetyFactor = opts.SafetyFactor;
            obj.ConfigParams = opts.Config;
            obj.Nonlinear = opts.NonLinear;
            obj.IdxOverride = opts.Idx;
        end
    end

end

