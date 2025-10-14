function Vals = Size(obj,Loads,SafetyFactor,opts)
arguments
    obj cast.size.WingBoxSizing
    Loads
    SafetyFactor
    opts.MaxStep = 100;
    opts.Converge = 0.1; % in percentage change
    opts.Verbose = true;
end
if length(obj) ~= length(Loads)
    error('Loads and WingBoxSizing objects must have same size')
end
ads.Log.trace('Sizing Wingboxes','mid');
for i = 1:length(obj)
    clear Par
    Par(1) = obj(i);
    for k = 1:opts.MaxStep
        Par(k+1) = Par(k).SizeStep(Loads(i),SafetyFactor);
        indicator = Par(k) == Par(k+1);
        ads.Log.trace(sprintf('Sizing Wingbox %.0f, Substep %.0f, Max. Percentage Change %.2f',i,k,indicator*100),'low');
        if indicator*100 < opts.Converge
            ads.Log.trace(sprintf('Wingbox %.0f Sizing Complete!',i),'mid');
            break
        else
            if k == opts.MaxStep
                error('CAST:SizingError','Max iteration steps reached for beam sizing')
            end
        end
    end
    Vals(i) = Par(end);
end
end

