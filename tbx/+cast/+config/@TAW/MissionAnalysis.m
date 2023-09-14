function obj = MissionAnalysis(obj)
%MISSIONANALYSIS Summary of this function goes here
%   Detailed explanation goes here
    mission = cast.Mission.StandardWithAlternate(obj.ADR);
    [EWF,fs] = cast.weight.MissionFraction(mission.Segments,obj);
    obj.Mf_Fuel = (1-EWF);
    obj.Mf_TOC = cast.weight.MissionFraction(mission.Segments(1:2),obj);
    obj.Mf_Ldg = 1-(1-cast.weight.MissionFraction(mission.Segments(1:4),obj));
    obj.Mf_res = obj.Mf_Ldg+obj.Mf_Fuel-1;
end

