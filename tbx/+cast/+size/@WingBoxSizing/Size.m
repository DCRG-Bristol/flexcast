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
fh.printing.title('Sizing Wingboxes',Length=60);
for i = 1:length(obj)
    clear Par
    Par(1) = obj(i);
    for k = 1:opts.MaxStep
        Par(k+1) = Par(k).SizeStep(Loads(i),SafetyFactor);
        indicator = Par(k) == Par(k+1);
        logger(sprintf('\t Sizing Wingbox %.0f, Substep %.0f, Max. Percentage Change %.2f\n',i,k,indicator*100),opts.Verbose)
        if indicator*100 < opts.Converge
            logger(sprintf('\t Sizing Complete! \n'),opts.Verbose);
            break
        else
            if k == opts.MaxStep
                error('Max iteration steps reached')
            end
        end
    end
    Vals(i) = Par(end);
end
end


function logger(str,enabled)
if enabled
    fprintf(str)
end
end

