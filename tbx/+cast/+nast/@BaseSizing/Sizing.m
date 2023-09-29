function [Par,BinFolder,Lds,isError,indicator] = Sizing(obj,Cases,opts)
arguments
    obj
    Cases (:,1) cast.LoadCase % Load Cases to run
    opts.MaxStep = 40;
    opts.Converge = 0.25; % in percentage change
    opts.CleanUp = true;
    opts.BinFolder = '';
    opts.Verbose = false;
    opts.Silent = false;
end
Par{1} = obj.WingBoxParams;
indicator = inf;
for n = 1:opts.MaxStep+1
    if indicator*100 < opts.Converge
        isError = false;
        break
    else
        if n == opts.MaxStep+1
            if opts.MaxStep>1
                warning('Max iteration steps reached')
            end
             isError = true;
            break
        end
    end
    if ~opts.Silent
        fh.printing.title(sprintf('Sizing %s, Step %.0f',obj.Name,n),Length=60);
    end
    obj.WingBoxParams = Par{n};
    %get loads for each case
    [Lds,BinFolder] = obj.GetLoads(Cases,"CleanUp",opts.CleanUp,...
        "BinFolder",opts.BinFolder,"Verbose",opts.Verbose,"Silent",opts.Silent);
    %size aircraft
    Par{n+1} = obj.WingBoxParams.Size(Lds.max(),1,"Verbose",opts.Verbose);
    %add check if slow to converge
    if (n>5 &&  (Par{n+1} == Par{n})>0.05) || n>10
        Par{n+1} = Par{n} + (Par{n+1} - Par{n}).*0.382;
    end
    % check for convergence
    indicator = Par{n} == Par{n+1};
    if ~opts.Silent
        fprintf('\t Sizing step %.0f Complete, Total Percentage Change %.2f\n',n,indicator*100);
    end
end
Par = Par{end};
obj.WingBoxParams = Par;
if ~opts.Silent
    fh.printing.title(sprintf('Sizing %s Complete!',obj.Name),Length=60);
end
end

