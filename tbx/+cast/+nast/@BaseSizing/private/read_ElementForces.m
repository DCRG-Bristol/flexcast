function [data, type] = read_ElementForces(resFile)
%extractElementForces Extracts element forces from an HDF5 file.
%   This function attempts to read CBEAM, CBAR, and CQUAD4 forces from
%   the provided HDF5 file. It returns the data and the type of element
%   found.

supported_types = {'CBEAM', 'CBAR', 'CQUAD4'};
data = [];
type = 'NONE';

for i = 1:length(supported_types)
    current_type = supported_types{i};
    try
        read_func = str2func(['read_force_' current_type]);
        data = resFile.(read_func)();
        type = current_type;
        return; % Exit after finding the first valid data
    catch
        % Continue to the next type if this one fails
    end
end

if strcmp(type, 'NONE')
    error('No CBEAM, CBAR, or QUAD4 forces found in HDF5 file: %s', resFile.filepath);
end

end
