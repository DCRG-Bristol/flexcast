function [CD0,meta] = baff2CD0(model,S_ref,alt,Mach,opts)
arguments
    model
    S_ref
    alt
    Mach
    opts.pLamFuselage = 0.05;
    opts.pLamWing = 0.1;
    opts.pWingMaxThickness = 0.5;
end
meta = cast.drag.DragMeta.empty;
for i = 1:length(model.Orphans)
    meta = [meta,cast.drag.element2CD0(model.Orphans(i),S_ref,alt,Mach,'pLamFuselage',opts.pLamFuselage,...
        'pLamWing',opts.pLamWing,'pWingMaxThickness',opts.pWingMaxThickness)];
end
CD0 = sum([meta.CD0]);
end

