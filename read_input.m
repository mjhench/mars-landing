function [Xo, Yo, Zo, Uo, Vo, Wo] = read_input(inputfile, traj_id)
%READ_INPUT reads the simulation data file and converts it into usable
%position and velocity vectors
%   Call format: read_input(inputfile, traj_id)

    % input data found in simulation_data.txt
    inputfile = 'simulation_data.txt';

    % import data from simulation_data.txt
    param = importdata(inputfile, '\t', 2);

    % if the trajectory id matches one in the data, return the data in the
    % latter's row
    if (any(traj_id == param.data(:,1)))
        row = find(traj_id == param.data(:,1));
        Xo = param.data(row,2);
        Yo = param.data(row,3);
        Zo = param.data(row,4);
        Uo = param.data(row,5);
        Vo = param.data(row,6);
        Wo = param.data(row,7);
    else % otherwise return NaN and display a warning
        Xo = NaN;
        Yo = NaN;
        Zo = NaN;
        Uo = NaN;
        Vo = NaN;
        Wo = NaN;
        disp('Warning: traj_id is not found!');
    end % if on line 14
end % function read_input