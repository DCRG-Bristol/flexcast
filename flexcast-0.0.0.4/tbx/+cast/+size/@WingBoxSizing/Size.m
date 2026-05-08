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
    error('Loads and WingBoxSizzing objects must have same size')
end
ads.util.printing.title('Sizing Wingboxes',Length=60);
for i = 1:length(obj)
    clear Par
    Par(1) = obj(i);
    for k = 1:opts.MaxStep
        Par(k+1) = Par(k).SizeStep(Loads(i),SafetyFactor);
        indicator = Par(k) == Par(k+1);
        logger(sprintf('Sizing Wingbox %.0f, Substep %.0f, Max. Percentage Change %.2f',i,k,indicator*100),opts.Verbose)
        if indicator*100 < opts.Converge
            logger('Sizing Complete!',opts.Verbose);
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


function logger(str,enabled)
if enabled
    ads.util.printing.title(str,Length=60,Symbol=" ")
end
end

