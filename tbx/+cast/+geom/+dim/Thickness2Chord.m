function tc = Thickness2Chord(M,Cl_cruise,sweep,Mstar)
    % equation 10.49 in Torenbeck;
    tc = cosd(sweep).*(Mstar - 0.1*(1.1.*Cl_cruise./cosd(sweep)^2).^1.5 - M.*cosd(sweep));
    end