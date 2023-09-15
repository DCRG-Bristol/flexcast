classdef TAW < cast.ADP
    %TAW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Baff;
        Masses = struct();
        Dihedral = 5;
        Engine = cast.config.Engine.CFM_LEAP_1A;
    end
    
    methods
        function PrintMass(obj)
            m = [];
            m(1) = obj.MTOM;
            m(2) = obj.Masses.Wings;
            m(3) = obj.Masses.Fuselage;
            m(4) = obj.Masses.HTP;
            m(5) = obj.Masses.VTP;
            m(6) = obj.Masses.LandingGear;
            m(7) = obj.Masses.EnginePylon;
            m(8) = obj.Masses.Engine;
            m(9) = obj.Masses.FuelSys;
            m(10) = 0;
            m(11) = obj.Masses.AirConDeIce;
            m(12) = 0;
            m(13) = obj.Masses.Hydaulics;
            m(14) = obj.Masses.Elec;
            m(15) = obj.Masses.Avionics;
            m(16) = obj.Masses.Control;
            m(17) = obj.Masses.Furniture;
            m(18) = 0;
            m(19) = 0;
            m(20) = obj.Masses.OperatorItems;
            num2clip(m');
        end
        function obj = TAW()
        end
        function obj = BuildBaff(obj)
            %% calculate fuselage
            % get parameters
            obj.V_HT = 0.97;
            obj.V_VT = 0.0717;

            % cruise condition
            M_c = obj.ADR.M_c;
            [rho,a] = cast.util.atmos(obj.ADR.Alt_cruise);
            q_c = 0.5*rho*(M_c*a)^2;
            span = sqrt(obj.AR*obj.WingArea);

            % number of rows and ailses
            PAX = obj.ADR.PAX;
%             N_sr = max(6,round(0.45*sqrt(PAX)));       % number of seats per row
            N_sr = 6;
            N_a = cast.util.tern(N_sr>6,2,1);   % number of aisles
            N_arm = N_sr+1+N_a;                 % number of armrests
            Nr = PAX/N_sr;                      % number of rows
            %length of sections
            if N_a >1
                k_cabin = 1.17;
                delta_d = 0.46;
            else
                k_cabin = 0.91;
%                 k_cabin = 1.0131;
                delta_d = 0.42;
            end
            D_c = (N_sr*18 + N_arm*1.5 + N_a*19)./cast.SI.inch + delta_d; % fuselage diameter
            L_c = Nr*k_cabin;           % length of cabin section
            L_cp = 4;                   % cockpit length
            L_tail =  D_c*1.6;          % tail length
            L_f = L_c + L_cp + L_tail;  % fuselage length
            x_c = D_c*1.3;              % transition point from cockpit to cabin
            x_tail = L_f-D_c*3;         % transition point from cabin to tail


            % make the fuselage
            cockpit = baff.BluffBody.SemiSphere(x_c,D_c/2);
            [cockpit.Stations.EtaDir] = deal([1;0;tand(4)]);
            cabin = baff.BluffBody.Cylinder(x_tail-x_c,D_c/2);
            tail = baff.BluffBody.SemiSphere(L_f-x_tail,D_c/2,"Inverted",true,"EtaFrustrum",0.05);
            for i = 1:(length(tail.Stations)-1)
                dEta = tail.Stations(i+1).Eta - tail.Stations(i).Eta;
                dRadius = tail.Stations(i).Radius - tail.Stations(i+1).Radius;
                tail.Stations(i).EtaDir = [1;0;dRadius./dEta./tail.EtaLength];
            end
%             [tail.Stations.EtaDir] = deal([1;0;tand(7)]);
            
            fuselage = cockpit + cabin + tail;
            fuselage.Name = "fuselage";
            for i = 1:length(fuselage.Stations)
                fuselage.Stations(i).EtaDir(1) = -fuselage.Stations(i).EtaDir(1);
                fuselage.Stations(i).StationDir = [0;0;1];
            end
            % make fuselage contribute to Drag
            fuselage = cast.drag.DraggableBluffBody(fuselage);

            % estimate mass
            S_f = fuselage.WettedArea * cast.SI.ft^2;
            M_dg = obj.MTOM*obj.Mf_TOC*cast.SI.lb; % design mass (taking at M_TOC)
            M_ldg = obj.MTOM*obj.Mf_Ldg*cast.SI.lb;
            
            % mass of fuselage Torenbeek (Torenbeek 8.3)
            m_f = (60*D_c^2*(L_f+1.5)+160*(1.5*2.5)^0.5*D_c*L_f)./9.81;
            % mass of furniture (Torenbeek 8.10)
            m_furn = (12*L_f*D_c*(3*D_c+0.5*1+1)+3500)./9.81*1.2; % 1.2 fudge factor
            %fuel system mass Torenbeek(10.1007/s13272-022-00601-6 Eq. 8)
            V_t = obj.MTOM*obj.Mf_Fuel/0.785;
            N_fuelTank = 2;
            m_fuelsys = (36.3*(obj.N_eng+N_fuelTank-1)+4.366*N_fuelTank^0.5*V_t^(1/3));

            % mass Avionics (Raymer 15.57 (assuming 1000lb of avionics))
            m_av = 2.117*(2000)^0.933./cast.SI.lbf./9.81;

            % Systems Mass (Torenbeek 8.9)
            m_sys = (270*L_f*D_c+150*L_f)/9.81*1.2;

            % operator Equipment (Torenbeek Table 8.1)
            N_person = obj.ADR.PAX + obj.ADR.Crew;
            m_op = (350*N_person)./9.81*0.75 + obj.ADR.CrewMass;

            obj.Masses.Fuselage = m_f;
            obj.Masses.Furniture = m_furn;
            obj.Masses.Hydaulics = 0;
            obj.Masses.Avionics = 0;
            obj.Masses.AirConDeIce = 0;
            obj.Masses.FuelSys = m_fuelsys;
            obj.Masses.Elec = 0;
            obj.Masses.Control = m_sys;
            obj.Masses.OperatorItems = m_op;

            m_fuselage = m_f + m_furn + m_sys + m_fuelsys + m_op;
            fuselage.DistributeMass(m_fuselage,14,"tag","fus_OEM");
            fuselage.DistributeMass(obj.ADR.Payload,14,"tag","fus_Payload","isPayload",true,"Etas",[L_cp,L_c + L_cp]./L_f);

            %% create wings
            % get common properties

            [Wing_RHS,fuelCap_RHS] = obj.BuildWing(true,D_c);
            fuselage.add(Wing_RHS);
            [Wing_LHS,fuelCap_LHS,L_ldg,obj.Masses] = obj.BuildWing(false,D_c);
            for i = 1:length(Wing_LHS.Stations)
                Wing_LHS.Stations(i).EtaDir(1) = -Wing_LHS.Stations(i).EtaDir(1); 
            end
            fuselage.add(Wing_LHS);
      
            % if not enough capaicty in wings add a fuel tank in fuselage
            if (fuelCap_RHS + fuelCap_LHS)<(obj.MTOM*obj.Mf_Fuel)
                fus_fuel = baff.Fuel((obj.MTOM*obj.Mf_Fuel - (fuelCap_RHS + fuelCap_LHS)*2),"eta",obj.WingEta,"Name",'Fuselage Fuel Tank');
                fus_fuel.Offset = [0;0;-D_c/4];
                fuselage.add(fus_fuel);
            end
           
            [mgc,eta_mgc]= Wing_LHS.AeroStations.GetMGC();
            X_mgc = Wing_LHS.GetGlobalPos(eta_mgc,Wing_LHS.AeroStations.GetPos(0,0.25));
            X_mgc(2) = 0;

            %% add nose landing gear
            L_ldg_nose = L_ldg -D_c/4 + D_c*0.1;
            m_ldg = 0.125*(1*1.5*M_ldg)^0.566*(L_ldg_nose*cast.SI.ft)^0.845;
            m_ldg = m_ldg ./ cast.SI.lb;
            ldg = baff.Mass(m_ldg,"eta",5/fuselage.EtaLength,"Name","ldg_nose");
            ldg.Offset = [0;0;-(L_ldg_nose+0.4*D_c)];
            fuselage.add(ldg);
            obj.Masses.LandingGear = obj.Masses.LandingGear + m_ldg;

            %% add HTP
            Mstar = 0.935;
            Cl_cruise = obj.MTOM*obj.Mf_TOC*9.81/(0.5*rho*(M_c*a)^2*obj.WingArea);
            sweep_le = real(acosd(0.75.*Mstar./M_c));
            tc_root = getThicknessToChord(M_c,Cl_cruise,sweep_le,Mstar);
            tc_tip = tc_root - 0.03;

            l_HT = fuselage.EtaLength*0.92 - abs(X_mgc(1));
            S_HT = obj.WingArea*mgc*obj.V_HT/l_HT;
            AR = 5.5;
            b_HT = sqrt(AR*S_HT);
            tr = 0.37;
            c_r = S_HT/(b_HT*(1+tr)/2);
            c_t = tr*c_r;
            mgc = 2/3*c_r*(1+tr+tr^2)/(1+tr);
            y_mgc_ht = b_HT/6*(1+2*tr)/(1+tr);
            x_mgc_ht = y_mgc_ht*tan(sweep_le)+mgc*0.25;
            sweep_te = tand(sweep_le)-4*AR*(1-tr)/(1+tr);
            m_HT = 0.016*(1.5*2.5*M_dg)^0.414*(cast.SI.lbft*q_c)^0.168*(S_HT*cast.SI.ft^2)^0.896*...
                (100*(tc_root+tc_tip)/2/cosd(sweep_le))^-0.12*(AR/cosd(sweep_le)^2)^0.043*tr^-0.02;
            m_HT = m_HT./cast.SI.lb;

            obj.Masses.HTP = m_HT;

            HT_RHS = baff.Wing.FromLETESweep(b_HT/2,c_r,[0 1],sweep_le,sweep_te,0.25,...
                baff.Material.Stiff,"ThicknessRatio",[tc_root,tc_tip]);
            HT_RHS.A = baff.util.rotz(90)*baff.util.rotx(180);
            HT_RHS.Eta = 0.92;
            HT_RHS.Offset = [0;0;0];
            HT_RHS.DistributeMass(m_HT/2,10,"Method","ByVolume","tag","HTP_mass");
            HT_RHS = cast.drag.DraggableWing(HT_RHS);
            HT_RHS.InterferanceFactor = 1.04;
            fuselage.add(HT_RHS);

            HT_LHS = baff.Wing.FromLETESweep(b_HT/2,c_r,[0 1],sweep_le,sweep_te,0.25,...
                baff.Material.Stiff,"ThicknessRatio",[tc_root,tc_tip]);
            for i = 1:length(HT_LHS.Stations)
                HT_LHS.Stations(i).EtaDir(1) = -HT_LHS.Stations(i).EtaDir(1);
            end
            HT_LHS.A = baff.util.rotz(90)*baff.util.rotx(180);
            HT_LHS.Eta = 0.92;
            HT_LHS.Offset = [0;0;0];
            HT_LHS.DistributeMass(m_HT/2,10,"Method","ByVolume","tag","HTP_mass");
            HT_LHS = cast.drag.DraggableWing(HT_LHS);
            HT_LHS.InterferanceFactor = 1.04;
            fuselage.add(HT_LHS);

            %% add VTP
            l_VT = fuselage.EtaLength*0.91 - abs(X_mgc(1));
            S_VT = obj.WingArea*obj.Span*obj.V_VT/l_VT;
            AR = 1.6;
            b_VT = sqrt(AR*S_VT);
            tr = 0.28;
            c_r = S_VT/(b_VT*(1+tr)/2);
            c_t = tr*c_r;
            mgc = 2/3*c_r*(1+tr+tr^2)/(1+tr);
            y_mgc_vt = b_VT/6*(1+2*tr)/(1+tr);
            x_mgc_vt = y_mgc_vt*tan(sweep_le)+mgc*0.25;
            sweep_te = tand(sweep_le)-4*AR*(1-tr)/(1+tr);
            VT = baff.Wing.FromLETESweep(b_VT,c_r,[0 1],sweep_le,sweep_te,0.25,...
                baff.Material.Stiff,"ThicknessRatio",[tc_root,tc_tip]);
            VT.A = baff.util.rotz(90)*baff.util.rotx(180)*baff.util.roty(90);
            VT.Eta = 0.91;
            R = fuselage.Stations.interpolate(0.91).Radius;
            VT.Offset = [0;0;R];
            m_VT = 0.073*(1+0.2*0)*(1.5*2.5*M_dg)^0.376*(cast.SI.lbft*q_c)^0.122*(S_VT*cast.SI.ft^2)^0.873*...
                (100*(tc_root+tc_tip)/2/cosd(sweep_le))^-0.49*(AR/cosd(sweep_le)^2)^0.357*tr^0.039;
            m_VT = m_VT./cast.SI.lb;
            obj.Masses.VTP = m_VT;
            VT.DistributeMass(m_VT,10,"Method","ByVolume","tag","VTP_mass");
            VT = cast.drag.DraggableWing(VT);
            VT.InterferanceFactor = 1.04;
            fuselage.add(VT);

            %% create model
            model = baff.Model;
            model.AddElement(fuselage);
            model.UpdateIdx();
            obj.Baff = model;

            %% adjust wing position to have CoM at 30% of MAC
            % get overall CoM
            [CoM,m] = model.GetCoM;
            % get wing com
            wing_r = model.Wing([model.Wing.Name]=="Wing_RHS");
            [CoM_rhs,m_rhs] = wing_r.GetCoM;
            CoM_rhs =  fuselage.GetPos(wing_r.Eta) + wing_r.Offset + wing_r.A'*CoM_rhs;
            wing_l = model.Wing([model.Wing.Name]=="Wing_LHS");
            [CoM_lhs,m_lhs] = wing_l.GetCoM;
            CoM_lhs = fuselage.GetPos(wing_l.Eta) + wing_l.Offset + wing_l.A'*CoM_lhs;
            m_w = m_rhs + m_lhs;
            CoM_w = (CoM_lhs.*m_lhs + CoM_rhs.*m_rhs)./m_w;
            [~,xr_mgc] = wing_r.GetMGC(0.3);
            [~,xl_mgc] = wing_l.GetMGC(0.3);
            x_mgc = (xr_mgc + xl_mgc)/2;

            m_f = m-m_w;
            CoM_f = (CoM*m-CoM_w*m_w)/m_f;
            x_f = CoM_f(1);
            x_w = CoM_w(1);
            delta = x_mgc(1)-x_w;
            x_w = x_f - delta - m_w/m_f*delta;
            delta_wing = CoM_w(1) - x_w;
            delta_eta = delta_wing./fuselage.EtaLength;

            eta = model.Wing([model.Wing.Name]=="Wing_RHS").Eta;
            model.Wing([model.Wing.Name]=="Wing_RHS").Eta = eta+delta_eta;
            model.Wing([model.Wing.Name]=="Wing_LHS").Eta = eta+delta_eta;
        end
    end
end

function tc = getThicknessToChord(M,Cl_cruise,sweep,Mstar)
% equation 10.49 in Torenbeck;
    tc = cosd(sweep).*(Mstar - 0.1*(1.1.*Cl_cruise./cosd(sweep)^2).^1.5 - M.*cosd(sweep));
end

function [S,cs,le_sweep,te_sweep] = wingArea(S,AR,lambda,k,c,Lambda_LE,Lambda_TE,D_f)
    b = sqrt(AR*S)/2;
    R_f = D_f/2;
    c_t = lambda*c;
    c_r = c+(tand(Lambda_LE)-tand(Lambda_TE))*(k*b-R_f);
    A_1 = (c+c_t)/2*b*(1-k);
    A_2 = (c_r+c)/2*(k*b-D_f/2);
    A_3 = c_r*R_f;
    A_4 = R_f^2*tand(Lambda_LE)/2;
    S = 2*(A_1+A_2+A_3-A_4);
    cs = [c_r,c,c_t];
    le_sweep = [1 1]*Lambda_LE;
    L = b*(1-k);
    te_sweep_end = atand((tand(Lambda_LE)*L+c_t-c)/L);
    te_sweep = [Lambda_TE te_sweep_end];
end

