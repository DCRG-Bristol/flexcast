function Par = SizeStep(obj, Loads, SafetyFactor)
    % SizeStep  One sizing iteration of the wingbox.
    %
    %   ADDITIVE ARCHITECTURE WITH STRUCTURAL BASELINE SHADOW
    %   ───────────────────────────────────────────────────
    %   The optimizer scaling functions (mod_SparWeb_Thickness, mod_Skin_Thickness)
    %   add material for aeroelastic reasons. This material is hidden from the
    %   structural stress calculations using a shadow object Par_s, so:
    %     - Iyy_structural is decoupled from optimizer contributions
    %     - the gradient dW/dx is clean and transparent
    %     - re-equilibration parasitism is eliminated
    %
    %   CRITICAL: t_free must be clamped to minimum gauge at extraction. Otherwise
    %   if Δt > t_total, t_free goes to zero, divide-by-zero in shear stress,
    %   and step_size locks the web at zero permanently (zero × multiplier = zero).
    %
    %   Baseline aircraft: set mod_SparWeb_Thickness = @(x) 0
    %                          mod_Skin_Thickness    = @(x) 0
    %   The constraint terms evaluate to zero automatically — no flag needed.
    %
    %   WingBoxSizing is a value class; `Par_s = Par` creates an independent copy.
    
    Par = obj;
    
    %% Material & Load Setup
    sigma_Y        = Par.Mat.yield;
    shear_strength = sigma_Y / sqrt(3);   % von Mises criterion
    
    My = abs(SafetyFactor * Loads.My);
    Mx = abs(SafetyFactor * Loads.Mx);
    Fz = abs(SafetyFactor * Loads.Fz);
    
    h      = Par.Height;
    w      = Par.Width;
    web_dc = 0.5 * h;
    ws     = Par.CapEta_width * w;
    
    %% Freeze Optimizer Constraint Contributions
    %   These are constant for the duration of the inner sizing loop.
    %   mod_* = @(x) 0 → constraint = 0 → baseline case, no branching needed.
    
    t_web_con    = Par.Spar_Min_Thickness .* ...
                   max(Par.mod_SparWeb_Thickness(-Par.Eta), 0);          % [m]
    
    t_skin_con_m  = Par.Skin.Skin_Min_Thickness .* ...
                    max(Par.Skin.mod_Skin_Thickness(-Par.Eta), 0);       % [m]
    t_skin_con_in = convlength(t_skin_con_m, 'm', 'in');                 % [in]
    
    %   Extract structural (free) thicknesses from previous iteration.
    %   Clamp to minimum gauge — required for both physical correctness AND
    %   numerical stability (prevents divide-by-zero in shear stress and the
    %   zero-multiplier trap in step_size).
    t_free_web    = max(Par.SparWeb_Thickness   - t_web_con,    Par.Spar_Min_Thickness);
    t_free_skin_m = max(Par.Skin.Skin_Thickness - t_skin_con_m, Par.Skin.Skin_Min_Thickness);
    
    %   Build a structural shadow object (value-class copy).
    Par_s                     = Par.copy();
    Par_s.SparWeb_Thickness   = t_free_web;
    Par_s.Skin.Skin_Thickness = t_free_skin_m;
    
    %% Spar Cap Sizing
    %   Cap sizing is purely analytical (loads / allowable). No Iyy dependency,
    %   no optimizer constraint. Feeds into Iyy_structural immediately.
    
    Cap_area_Y      = 0.5 * My ./ (h * sigma_Y);
    Cap_Thickness_Y = Cap_area_Y ./ ws;
    Cap_Thickness_B = (4 * My .* Par.Ribs.IdealPitch.^2 ./ ...
                      (pi^2 * Par.Mat.E * h .* ws)).^(1/3);
    
    Cap_Thickness = max([Cap_Thickness_Y; Cap_Thickness_B]);
    Cap_Thickness(Cap_Thickness < Par.Spar_Min_Thickness) = Par.Spar_Min_Thickness;
    
    Par.SparCap_Thickness   = Cap_Thickness;
    Par_s.SparCap_Thickness = Cap_Thickness;
    
    %   First structural Iyy: new caps + free web (prev iter) + free skin (prev iter)
    Iyy_s = Par_s.Iyy;
    
    %% Spar Web Sizing
    %   All stress and buckling checks use Iyy_s — not affected by optimizer skin.
    
    tsw  = t_free_web;              % [m]
    tskn = t_free_skin_m;           % [m]
    
    Q_skn  = w .* tskn .* (0.5 * h);
    Q_spar = ws .* Cap_Thickness .* (0.5 * h) * 2;
    Q_web  = (0.5 * tsw .* h .* (0.25 * h)) * 2;
    Q      = Q_skn + Q_spar + Q_web;
    
    Shear_stress = Fz .* Q ./ (2 * Iyy_s .* tsw) + Mx ./ (2 * h .* w .* tsw);
    
    Sigma_buckling_web = 21 * Par.Mat.E * (tsw ./ h).^2;
    
    idx = 1:(Par.NumEl - 1);
    hwa = h(idx) ./ web_dc(idx);
    Ks  = 13.1 * exp(-1.426 * hwa) + 5.066 * exp(-0.002422 * hwa);
    Sigma_buckling_shear = Ks .* Par.Mat.E .* (tsw(idx) ./ web_dc(idx)).^2;
    Sigma_buckling_shear = Sigma_buckling_shear([1:end, end]);
    
    Constraint_web1 = Shear_stress ./ shear_strength;
    Constraint_web3 = Shear_stress ./ Sigma_buckling_shear;
    Constraint_web  = max([Constraint_web1; Constraint_web3]);
    
    %   Size free variable, clamp to min gauge for numerical safety
    t_free_web_new = t_free_web .* step_size(Constraint_web);
    t_free_web_new = max(t_free_web_new, Par.Spar_Min_Thickness);
    
    %   Purely additive reconstruction
    Par.SparWeb_Thickness = t_free_web_new + t_web_con;
    
    %   Propagate new free web into shadow object for skin sizing below
    Par_s.SparWeb_Thickness = t_free_web_new;
    Iyy_s = Par_s.Iyy;
    
    %% Skin-Stringer Panel Sizing
    c_fix  = 1.5;
    L_inch = convlength(Par.Ribs.IdealPitch / sqrt(c_fix), 'm', 'in');
    
    %   Stress from structural Iyy_s only — decoupled from optimizer skin
    sigma_psi = convpres(0.5 * My .* h ./ Iyy_s, 'pa', 'psi');
    
    skin_min_in    = convlength(Par.Skin.Skin_Min_Thickness, 'm', 'in');
    
    %   Base skin thickness from structural stresses, clamped to min gauge
    t_skin_free_in = sigma_psi .* L_inch ./ (3000^2);
    t_skin_free_in = max(t_skin_free_in, skin_min_in);
    
    %   Stringer geometry derived from free skin thickness
    N    = t_skin_free_in .* sigma_psi;
    Fe   = 2000 * (N ./ L_inch).^0.5;
    be_t = -7.743e-6*(Fe/1000).^4 + 0.0006387*(Fe/1000).^3 ...
           + 0.007084*(Fe/1000).^2 - 1.966*(Fe/1000) + 76.83;
    
    exceed_idx = Fe > convpres(1, 'pa', 'psi') * Par.Mat.yield;
    if any(exceed_idx)
        warning('Load intensity exceeded on skin — setting be_t to 10.');
        be_t(exceed_idx) = 10;
    end
    
    be   = be_t .* t_skin_free_in;
    b    = be;
    ta   = 0.7 * t_skin_free_in;
    A_st = 0.5 * b .* t_skin_free_in;
    ba   = (0.40 * A_st) ./ (2 * ta);
    bw   = (be_t .* ((A_st - 2 .* ba .* ta) ./ 1.327)).^0.5;
    tw   = bw ./ be_t;
    bf   = 0.327 * bw;
    tf   = tw;
    
    %   Purely additive reconstruction for skin (in inches), then to metres
    t_skin_total_in = t_skin_free_in + t_skin_con_in;
    
    Par.Skin.Skin_Thickness       = t_skin_total_in * 0.0254;
    Par.Skin.Effective_Width      = be    * 0.0254;
    Par.Skin.Strg_Pitch           = b     * 0.0254;
    Par.Skin.Strg_Depth           = bw    * 0.0254;
    Par.Skin.StrgFlange_Width     = bf    * 0.0254;
    Par.Skin.StrgGround_Width     = ba * 2 * 0.0254;
    Par.Skin.StrgThickness_Ground = ta    * 0.0254;
    Par.Skin.StrgThickness_Web    = tw    * 0.0254;
    Par.Skin.StrgThickness_Flange = tf    * 0.0254;
    
    strg_min = Par.Skin.Strg_Min_Thickness;
    Par.Skin.StrgThickness_Web(Par.Skin.StrgThickness_Web       < strg_min) = strg_min;
    Par.Skin.StrgThickness_Flange(Par.Skin.StrgThickness_Flange < strg_min) = strg_min;
    Par.Skin.StrgThickness_Ground(Par.Skin.StrgThickness_Ground < strg_min) = strg_min;
    
    %% Rib Sizing
    %   N_crush has no Iyy dependency — ribs unaffected by structural decoupling.
    %   te uses total skin thickness (optimizer-thickened skin carries real compression).
    
    My_rib = interp1(Par.Eta, My,                       Par.Ribs.Eta);
    w_rib  = interp1(Par.Eta, Par.Width,                Par.Ribs.Eta);
    h_rib  = interp1(Par.Eta, Par.Height,               Par.Ribs.Eta);
    te_rib = interp1(Par.Eta, Par.Skin.Skin_Thickness,  Par.Ribs.Eta) * 1.5;
    
    N_crush     = My_rib ./ (h_rib .* w_rib);
    Sigma_Crush = 2 * N_crush.^2 ./ (Par.Mat.E * te_rib .* h_rib);
    F_crush     = Par.Ribs.ActualPitch * Sigma_Crush .* w_rib;
    
    t_y    = F_crush ./ (w_rib * Par.Mat.yield);
    A_wide = pi^2 * Par.Mat.E / 12;
    t_cb   = (F_crush .* (h_rib ./ sqrt(1)).^2 ./ (A_wide * w_rib)).^(1/3);
    
    Par.Ribs.Thickness = max([t_y; t_cb; ...
                              repmat(Par.Spar_Min_Thickness, 1, numel(t_cb))]);
    if Par.Ribs.Eta(end) == 1
        Par.Ribs.Thickness(end) = Par.Ribs.Thickness(end-1);
    end
    
    %% Web Stiffener Sizing
    Seg_len = (Par.Eta(2:end) - Par.Eta(1:(end-1))) * Par.Span;
    hd      = h(idx) ./ web_dc(idx);
    
    N_Iu = -0.06203*hd.^3 + 0.7356*hd.^2 - 0.3935*hd - 0.1241;
    Iu   = N_Iu .* h(idx) .* Par.SparWeb_Thickness(idx).^3;   % uses total web
    
    t_stiff = 3 * Iu / 0.0254^3;
    
    Par.SparWeb_Stiff_N         = Seg_len ./ web_dc(idx);
    Par.SparWeb_Stiff_Thickness = t_stiff;
    
    end
    
    %% helpers
    function c = step_size(x)
    % Multiplicative adjustment factor given a constraint ratio x.
    % x = 1 → at limit → c = 1 (no change)
    % x > 1 → over limit → c > 1 (increase thickness)
    % x < 1 → under limit → c < 1 (reduce thickness)
        x_adj = x - 1;
        c = 1 + 0.5 * x_adj.^2 .* sign(x_adj);
        c = min(max(c, 0.7), 1.3);   % clamp to prevent wild steps
    end