function [doc,M_f] = MJperPAX(obj,range,payloadFactor,opts)
arguments
    obj
    range
    payloadFactor
    opts.M_f = obj.MTOM-obj.ADR.Payload-obj.OEM;
end
[M_f,doc] = deal(zeros(size(range)));
for i = 1:length(range)
    mission = cast.Mission.StandardWithAlternate(obj.ADR,range(i));
    M_to = 0;
    if i == 1
        M_f(i) = opts.M_f;
    else
        M_f(i) = M_f(i-1);
    end
    while abs(M_to-(obj.OEM+obj.ADR.Payload*payloadFactor+M_f(i)))>10
        M_to = obj.OEM+obj.ADR.Payload*payloadFactor+M_f(i);
        [EWF,fs] = cast.weight.MissionFraction(mission.Segments,obj,M_TO=M_to,OverideLD=true);
        M_f(i) =  (1-EWF)/(EWF)*(obj.OEM+obj.ADR.Payload*payloadFactor);
    end
    M_Fuel_design = (1-prod(fs([1:5,end])))*M_to;
    doc(i) = M_Fuel_design*obj.FuelType.SpecificEnergy/(obj.ADR.PAX*payloadFactor)/(range(i)/1000);
end
end