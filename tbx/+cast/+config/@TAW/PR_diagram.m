function p = PR_diagram(obj)
OEM = obj.Baff.GetOEM();
PayloadCapacity = sum([obj.Baff.Payload.Capacity]);
FuelCapacity = sum([obj.Baff.Fuel.Capacity]);
MTOM = obj.MTOM;
% get point A (Max. payload + fuel upto MTOM)
M_f = MTOM-OEM-PayloadCapacity;
M_P_A = PayloadCapacity;
M_TO_A = MTOM;
A_r = fminsearch(@(x)(fuelMass(x,obj,M_TO_A)-M_f)^2,obj.ADR.Range);
% get point B (Max. fuel + payload upto MTOM)
M_TO_B = MTOM;
if M_f>=FuelCapacity
    M_P_B = M_P_A;
    B_r = A_r;
else
    M_f = FuelCapacity;
    M_P_B = MTOM-FuelCapacity-OEM;
    B_r = fminsearch(@(x)(fuelMass(x,obj,M_TO_B)-M_f)^2,A_r);
end
% get point C (Max. fuel + payload upto MTOM)
M_TO_C = min(OEM+FuelCapacity,MTOM);
M_f = M_TO_C-OEM;
M_P_C = M_TO_C-OEM-M_f;
C_r = fminsearch(@(x)(fuelMass(x,obj,M_TO_C)-M_f)^2,B_r);

p = plot([0,A_r,B_r,C_r].*cast.SI.Nmile,[PayloadCapacity,M_P_A,M_P_B,M_P_C]./1e3,'k-s');
end

function M_Fuel = fuelMass(range,obj,M_TO)
    ADR = obj.ADR;
    ADR.Range = range;
    mission = cast.Mission.StandardWithAlternate(ADR);
    [EWF,fs] = cast.weight.MissionFraction(mission.Segments,obj);
    M_Fuel = (1-EWF)*M_TO;
    Er=1;
    for i =6:11
        Er = Er*fs(i);
    end
    M_res = (1-Er)*M_TO;
end

