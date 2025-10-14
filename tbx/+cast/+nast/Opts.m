classdef Opts
    properties
        WingboxMaxStep = 40;
        WingboxConvergence = 0.25; % in percentage change
        NGoldenSection = 10;
        CleanUp = true;
        BinFolder = '';
        Verbose = false;
    end
    methods
        function obj = Opts(opts)
            arguments
                opts.WingboxMaxStep = 40;
                opts.WingboxConvergence = 0.25; % in percentage change
                opts.NGoldenSection = 10;
                opts.CleanUp = true;
                opts.BinFolder = '';
                opts.Verbose = false;
            end
            obj.WingboxMaxStep = opts.WingboxMaxStep;
            obj.WingboxConvergence = opts.WingboxConvergence;
            obj.NGoldenSection = opts.NGoldenSection;
            obj.CleanUp = opts.CleanUp;
            obj.BinFolder = opts.BinFolder;
            obj.Verbose = opts.Verbose;         
        end
    end
end