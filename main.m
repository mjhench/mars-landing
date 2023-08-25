%% The following commands are required at the very top of the file
clear all;   %#ok<*CLALL> % This clears all workspaces 
close all;   % This closes all figures 
clc;         % This clears the command window
format long; 

%% Student name, ID number, and homework_number are required
name = 'Michael Hench';
id = 'XXXXXXXXX';
hw_num = 'project';

fprintf('Program initiated.\n');
%% Define global variables
global R M G m;

R = 3.3895*10^6;    % meters
M = 6.39*10^23;     % kilograms
G = 6.67408*10^-11; % m^3 / (kg * s^2)
m = 800;            % kilograms

% define colors vector (will be useful when graphing)
colors = ['b' 'c' 'k' 'm' 'g' 'r'];

%% Calculate trajectory, time, position, and velocity vectors for 
% Use the counting backward trick to better initialize the structures for speed
for traj_id = 6:-1:1
    fprintf('Calculating Trajectory #%d... ', traj_id);
    [Xo, Yo, Zo, Uo, Vo, Wo] = read_input('simulation_data.txt', traj_id);
    [T{traj_id}, X{traj_id}, Y{traj_id}, Z{traj_id}, U{traj_id},...
        V{traj_id}, W{traj_id}] = trajectory(Xo, Yo, Zo, Uo, Vo, Wo);
    fprintf('Done!\n');
end % for on line 25

%% Plot trajectories
fprintf('Generating graphs... ');

% constant text for graph legends
legendText = ['Lander #1'; 'Lander #2'; 'Lander #3'; 'Lander #4';...
    'Lander #5'; 'Lander #6'];
load('Mars_topo.mat');  % load the topographical map of Mars

% create Figure 1
figure(1);
set(gcf, 'Position', [50, 200, 1000, 600]);
hold on;

% create 6 subplots, each with a model of Mars
for n = 6:-1:1
    subplot(2,3,n);
    hold on;
    
    % provided code for generating Mars, courtesy of the course professor
    [x,y,z] = sphere(50);
    s = surf(R*x/1e6,R*y/1e6,R*z/1e6); % create a sphere
    colormap('hot'); view(3);
    s.CData = Mars_topo;  % set color data to topographic data
    s.FaceColor = 'texturemap';    % use texture mapping
    s.EdgeColor = 'none';          % remove edges
    s.FaceLighting = 'gouraud';    % preferred lighting for curved surfaces
    s.SpecularStrength = 0.4;      % change the strength of the reflected light
    grid on; box on; axis equal;
    axis(4*[-1 1 -1 1 -1 1]);
    xlabel('x (10^6 m)'); ylabel('y (10^6 m)'); zlabel('z (10^6 m)');
    title('Mars Topography');
    set(gca,'LineWidth',1,'FontSize',10, ...
        'Xtick',-4:2:4,'Ytick',-4:2:2,'Ztick',-4:2:2);

    % plot each trajectory's path and endpoint
    plot3(X{n}./10^6, Y{n}./10^6, Z{n}./10^6, ['-' colors(n)], 'LineWidth', 2);
    plot3(X{n}(end)./10^6, Y{n}(end)./10^6, Z{n}(end)./10^6, [colors(n) 'o'],...
        'MarkerFaceColor', colors(n), 'MarkerSize', 10);
    titleString = sprintf('Trajectory #%d', n);
    title(titleString); % title each subplot w/ its trajectory number
end % for on line 47

%% graph analytical plots
% create figure 2
figure(2);
set(gcf, 'Position', [100, 150, 1000, 600]);

% Use the counting backward trick to better initialize the structures for speed
for n = 6:-1:1
    %% subplot 1 contains time vs altitude of all trajectories
    subplot(3,1,1);
    hold on;
    
    % create an altitude vector from position vectors and Mars' radius
    alt{n} = sqrt(X{n}.^2 + Y{n}.^2 + Z{n}.^2) - R;
    
    % plot said altitude vector (time in hours, altitude in kilometers)
    plot(T{n}/3600, alt{n}/1000, ['-' colors(n)], 'LineWidth', 2);
    titleString = 'Altitude';
    xlabel('Time (hrs)'); ylabel('Altitude (km)'); title(titleString);
    
    
    %% subplot 2 contains time vs speed of all trajectories
    subplot(3,1,2);
    hold on;
    
    % create speed vector from the magnitude of the traj. velocity vectors
    speed{n} = sqrt(U{n}.^2 + V{n}.^2 + W{n}.^2);
    
    % plot the time vs speed (time in hrs, speed in km/s)
    plot(T{n}/3600, speed{n}./1000, ['-' colors(n)], 'LineWidth', 2);
    titleString = 'Speed';
    xlabel('Time (hrs)'); ylabel('Speed (km/s)'); title(titleString);
    
    %% subplot 3 contains time vs acceleration of all trajectories
    subplot(3,1,3);
    hold on;
    
    % create acceleration vector through dy/dt of the speed vector
    dt = 0.2;
    acc{n} = [0 diff(speed{n})]/dt;
    
    % plot the time vs acceleration (time in hrs, acceleration in km/s^2)
    plot(T{n}/3600, acc{n}/1000, ['-' colors(n)], 'LineWidth', 2);
    titleString = 'Acceleration';
    xlabel('Time (hrs)'); ylabel('Acceleration (km/s^2)'); title(titleString);
end % for on line 80
legend(legendText, 'Location', 'Southwest');

%% create figure 3
figure(3);
set(gcf, 'Position', [150, 100, 1000, 600]);
hold on;
     
for n = 6:-1:1
    % plot the acceleration vs altitude (acceleration in km/s^2, altitude
    % in meters)
    plot(acc{n}/1000, alt{n}, ['-' colors(n)], 'LineWidth', 2);
    titleString = 'Acceleration During Descent';
    xlabel('Acceleration (km/s^2)'); ylabel('Altitude (m)');...
        title(titleString);
    set(gca, 'Yscale', 'log');  % set y-axis scaling to logarithmic
    
end % for on line 136

% After all trajectories have been graphed, create a legend
legend(legendText, 'Location', 'North');
    
fprintf('Done!\n');

%% generate structure stat, as required in project specifications
fprintf('Generating structure "stat"... ');
for n = 6:-1:1
    % generate the fields as described by the project specifications
    stat{n}.trajectory_id = n;
    stat{n}.final_time = T{n}(end);
    stat{n}.final_position = [X{n}(end), Y{n}(end), Z{n}(end)];
    stat{n}.final_velocity = [U{n}(end), V{n}(end), W{n}(end)];
    stat{n}.final_speed = speed{n}(end);
   
    % find and store the indices of the local maxes
    localMax = [];
    for l = 2:length(alt{n}) - 1
        if (alt{n}(l) > alt{n}(l - 1) && alt{n}(l) > alt{n}(l + 1))
            localMax = [localMax l]; %#ok<AGROW>
        end % if on line 164
    end % for on line 163
    
    % convert the local maxes' indices to the time, and store them in stat
    timeLocalMax = localMax * 0.2 - 0.2;
    stat{n}.time_hmax_altitude = timeLocalMax;
    
    % calculate the difference between the 1st two local max times
    stat{n}.orbital_period = diff(timeLocalMax(1:2));
end % for on line 153
fprintf('Done!\n');

%% generate report.txt
fprintf('Generating report.txt... ');

% create file 'report.txt' with write privileges
fidw = fopen('report.txt', 'w');

% write out the first 3 lines with (1) name, (2) student pid, and (3)
% trajectory id, landing time (s), landing speed (m/s), and orbital period
fprintf(fidw, '%s\n', name);
fprintf(fidw, '%s\n', id);
fprintf(fidw, 'traj_id, landing_time (s), landing_speed (m/s), orbital_period (s)\n');

% for each trajectory, write out its trajectory id, landing time (s),
% landing speed (m/s), and orbital period (s)
for n = 1:length(stat)
   fprintf(fidw, '%d %15.9e %15.9e %15.9e\n', n, stat{n}.final_time,...
       stat{n}.final_speed, stat{n}.orbital_period);
end % for on line 192

% close 'report.txt'
fclose(fidw);

fprintf('Done!\n');

%% concluding questions
p1a = evalc('help read_input'); % read fun read_input's description
p1b = evalc('help trajectory'); % read fun trajectory's description
p1c = 'See figure 1';           % set p1c to given string
p1d = 'See figure 2';           % set p1d to given string
p1e = 'See figure 3';           % set p1e to given string
p2a = stat(1);                  % evaluate traj. 1's stats
p2b = stat(2);                  % evaluate traj. 2's stats
p2c = stat(3);                  % evaluate traj. 3's stats
p2d = stat(4);                  % evaluate traj. 4's stats
p2e = stat(5);                  % evaluate traj. 5's stats
p2f = stat(6);                  % evaluate traj. 6's stats
p3 = evalc('type report.txt');  % read 'report.txt'

% set p4a equal to the altitude at which air drag becomes noticeable
% altitude chosen at point at which acceleration starts decreasing slowly,
% indicating the non-negligible effects of air drag
p4a = '62,750 meters';

% set p4b equal to the altitude at which the parachute deployed
% altitude chosen based on massive deceleration observed in Figure 3 at
% this altitude
p4b = '910.2 meters';

fprintf('Program complete.\n');