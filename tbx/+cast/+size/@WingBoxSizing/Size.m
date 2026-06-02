% function Vals = Size(obj,Loads,SafetyFactor,opts)
% arguments
%     obj cast.size.WingBoxSizing
%     Loads
%     SafetyFactor
%     opts.MaxStep = 100;
%     opts.Converge = 0.1; % in percentage change
%     opts.Verbose = true;
%     opts.optiSizing = false;
% end
% if length(obj) ~= length(Loads)
%     error('Loads and WingBoxSizzing objects must have same size')
% end
% ads.util.printing.title('Sizing Wingboxes',Length=60);
% for i = 1:length(obj)
%     clear Par
%     Par(1) = obj(i);
%     for k = 1:opts.MaxStep
%         Par(k+1) = Par(k).SizeStep(Loads(i),SafetyFactor);
%         indicator = Par(k) == Par(k+1);
%         logger(sprintf('Sizing Wingbox %.0f, Substep %.0f, Max. Percentage Change %.2f',i,k,indicator*100),opts.Verbose)
%         if indicator*100 < opts.Converge
%             Par(end+1) = Par(end).SizeStep(Loads(i),SafetyFactor,optiSizing = opts.optiSizing);
%             logger('Sizing Complete!',opts.Verbose);
%             break
%         else
%             if k == opts.MaxStep
%                 error('CAST:SizingError','Max iteration steps reached for beam sizing')
%             end
%         end
%     end
%     Vals(i) = Par(end);
% end
% end

function Vals = Size(obj, Loads, SafetyFactor, opts)
    % Size  Iterates SizeStep until the wingbox geometry converges.
    %
    %   The optiSizing flag has been removed. Optimizer contributions are always
    %   active inside SizeStep, but evaluate to zero when:
    %       mod_SparWeb_Thickness = @(x) 0
    %       mod_Skin_Thickness    = @(x) 0
    %   Set these on the WingBoxSizing object to run a baseline (unoptimized) case.
    %
    %   GRADIENT TRANSPARENCY
    %   ─────────────────────
    %   Because SizeStep uses Iyy_structural (decoupled from optimizer constraints),
    %   the weight response to changes in mod_* is:
    %
    %       dW/dx = rho * d(t_free)/dx + rho * d(t_constraint)/dx
    %                       ~0 (converged)        direct term
    %
    %   The structural free variable has converged at its fixed point and is
    %   insensitive to x. Only the direct constraint contribution drives weight.
    %   This gives a clean, predictable gradient for the outer optimizer.
    
    arguments
        obj cast.size.WingBoxSizing
        Loads
        SafetyFactor
        opts.MaxStep  = 100;
        opts.Converge = 0.1;    % percentage change threshold
        opts.Verbose  = true;
        opts.optiSizing = false;   % kept for API compatibility but no longer changes behaviour
    end
    
    if length(obj) ~= length(Loads)
        error('Loads and WingBoxSizing objects must have the same length.')
    end
    
    ads.util.printing.title('Sizing Wingboxes', Length=60);
    
    for i = 1:length(obj)
        Par_curr = obj(i);
    
        for k = 1:opts.MaxStep
            Par_prev = Par_curr;
            Par_curr = Par_prev.SizeStep(Loads(i), SafetyFactor);
    
            pct_change = (Par_prev == Par_curr) * 100;
            logger(sprintf('Wingbox %d  |  step %d  |  change %.3f%%', ...
                   i, k, pct_change), opts.Verbose);
    
            if pct_change < opts.Converge
                logger(sprintf('Wingbox %d converged in %d steps.', i, k), opts.Verbose);
                break
            elseif k == opts.MaxStep
                error('CAST:SizingError', ...
                      'Wingbox %d did not converge within %d steps.', i, opts.MaxStep)
            end
        end
    
        Vals(i) = Par_curr;
    end
    
    end
    
    function logger(str, enabled)
        if enabled
            ads.util.printing.title(str, Length=60, Symbol=' ');
        end
    end