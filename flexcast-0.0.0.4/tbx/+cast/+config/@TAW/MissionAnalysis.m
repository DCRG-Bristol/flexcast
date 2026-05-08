function obj = MissionAnalysis(obj,opts)
arguments
    obj
    opts.PayloadFraction = 1;
    opts.Range = obj.ADR.Range;
    opts.OverideLD=true;
end
%MISSIONANALYSIS Summary of this function goes here
%   Detailed explanation goes here
delta_M = obj.ADR.Payload*(1-opts.PayloadFraction);
M = obj.MTOM - delta_M;

mission = cast.Mission.StandardWithAlternate(obj.ADR,opts.Range);

[EWF,fs] = cast.weight.MissionFraction(mission.Segments,obj,M_TO=M,OverideLD=opts.OverideLD);
obj.Mf_Fuel = (1-EWF) * M /obj.MTOM;
obj.Mf_TOC = prod(fs(1:2));
obj.Mf_Ldg = (prod(fs(1:4))*M+delta_M)/obj.MTOM;
obj.Mf_res = (prod(fs(5:end))*M+delta_M)/obj.MTOM;
% if PayloadFraction<1
%     M_pay = obj.ADR.Payload*PayloadFraction;
%     M = obj.MTOM - obj.ADR.Payload*(1-PayloadFraction);
% 
%     obj.Mf_Fuel = obj.Mf_Fuel * M /obj.MTOM;
%     %         obj.Mf_TOC = (obj.Mf_TOC * M + M_pay ) /obj.MTOM;
%     %         obj.Mf_res = obj.Mf_Ldg+obj.Mf_Fuel-1;
%     %         obj.Mf_Ldg = (obj.Mf_Ldg * M + M_pay ) /obj.MTOM;
%     %         obj.Mf_res = obj.Mf_res * M /obj.MTOM;
% end
end

