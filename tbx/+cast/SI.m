classdef SI
    %SI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        ft = 3.28084;
        inch = 39.3701;
        Nmile = 0.000539957;
        mile = 0.000621371;
    end
    %pressure
    properties(Constant)
        lbft = 0.0208854342;
        psi = 0.0001450377;
    end
    %force
    properties(Constant)
        lbf = 0.224809;
    end
    %mass
    properties(Constant)
        lb = 2.20462;
        Tonne = 1/1e3;
    end
    %volume
    properties(Constant)
        gal = 219.969;
        litre = 1000;
    end
    %velocity
    properties(Constant)
        knt = 1/0.514444;
    end
    %time
    properties(Constant)
        hr = 1/(60*60);
        min = 1/60;
    end
    %other
    properties(Constant)
        DragCount = 1e4;
    end
    methods
%         function obj = SI(inputArg1,inputArg2)
%             %SI Construct an instance of this class
%             %   Detailed explanation goes here
%             obj.Property1 = inputArg1 + inputArg2;
%         end
%         
%         function outputArg = method1(obj,inputArg)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             outputArg = obj.Property1 + inputArg;
%         end
    end
end

