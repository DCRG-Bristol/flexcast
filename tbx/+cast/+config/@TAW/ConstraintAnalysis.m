function [obj,TW,WS] = ConstraintAnalysis(obj,opts)
arguments
    obj
    opts.Plot = true
end
%CONSTRAINTANALYSIS Summary of this function goes here
%   Detailed explanation goes here
if opts.Plot
    f = figure(1);
    clf;
    hold on
    ylim([0 1])
    xlim([0,10e3])
    axis manual
end
% Landing constraint
WS_ldg = cast.ca.sg.LandingDistance(obj,0,10);
if opts.Plot
    plot([1 1]*WS_ldg,[0 1],"DisplayName",'Landing')
end
% Take-off Analysis
WSx = 10:100:10000;
TW_TO = cast.ca.sg.TOGroundRun(WSx,obj,0);
TWi = interp1(WSx,TW_TO,WS_ldg,"linear");
if opts.Plot
    plot(WSx,TW_TO,"DisplayName",'TO')
end
% Service Ceiling
TLR = @(x)cast.util.atmos(x)/cast.util.atmos(0);
TW = cast.ca.sg.ROC_Mach_Vv(WSx,obj,0.78,100./cast.SI.ft.*cast.SI.min,obj.ADR.Alt_max)/TLR(obj.ADR.Alt_max);
TWi_tmp = interp1(WSx,TW,WS_ldg,"linear");
TWi = cast.util.tern(TWi<TWi_tmp,TWi_tmp,TWi);
if opts.Plot
    plot(WSx,TW,"DisplayName",'Ceil') % Service ceiling of 40,000ft
end

% engine out ROC TO
TW = 2*cast.ca.sg.ROC_VSR(WSx,obj,1.13,obj.CL_TOmax,2.4,0);
TWi_tmp = interp1(WSx,TW,WS_ldg,"linear");
TWi = cast.util.tern(TWi<TWi_tmp,TWi_tmp,TWi);
if opts.Plot
    plot(WSx,TW,"DisplayName",'Eng-Out ROC TO')
end
% engine out ROC Approach
TW =2*cast.ca.sg.ROC_VSR(WSx,obj,1.4,obj.CL_max,2.1,0);
TWi_tmp = interp1(WSx,TW,WS_ldg,"linear");
TWi = cast.util.tern(TWi<TWi_tmp,TWi_tmp,TWi);
if opts.Plot
    plot(WSx,TW,"DisplayName",'Eng-Out ROC App')
end

% ROC 25 min to cruise
heights = [10,20]*1e3./cast.SI.ft;
for i = 1:length(heights)
    TW =cast.ca.sg.ROC_Mach_Vv(WSx,obj,obj.ADR.M_c,obj.ADR.Alt_cruise/(25*60),heights(i))/TLR(heights(i));
    TWi_tmp = interp1(WSx,TW,WS_ldg,"linear");
    TWi = cast.util.tern(TWi<TWi_tmp,TWi_tmp,TWi);
    if opts.Plot
        plot(WSx,TW,"DisplayName",sprintf('ROC FL%03.0f',heights(i).*cast.SI.ft./1e2));
    end
end

%% set values
obj.Thrust = TWi*obj.MTOM*9.81;
obj.WingArea = 1/WS_ldg*obj.MTOM*9.81;
obj.Span = sqrt(obj.AR*obj.WingArea);
if opts.Plot
    plot(WS_ldg,TWi,'sk','MarkerFaceColor','k','DisplayName','Target');
end
TW = TWi;
WS = WS_ldg;

if opts.Plot
    lg = legend();
    lg.Location = "eastoutside";
end

end

