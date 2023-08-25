function [T, X, Y, Z, U, V, W] = trajectory(Xo, Yo, Zo, Uo, Vo, Wo)
%TRAJECTORY calculates the Mars lander's trajectory given its initial
%position and velocity vectors
%   Call format: trajectory(Xo, Yo, Zo, Uo, Vo, Wo)
    
    %% import global variables and define dt as a constant 0.2 seconds
    global R M G m;
    dt = 0.2;
    
    %% create initial position & velocity vectors  
    T = 0:dt:28800; % make T 8 hours long
    
    % make an X zeros vector the length of T & set the first element to Xo
    X = zeros(1, length(T));
    X(1) = Xo;
    
    % make an Y zeros vector the length of T & set the first element to Yo
    Y = zeros(1, length(T));
    Y(1) = Yo;
    
    % make an Z zeros vector the length of T & set the first element to Zo
    Z = zeros(1, length(T));
    Z(1) = Zo;
    
    % make an U zeros vector the length of T & set the first element to Uo
    U = zeros(1, length(T));
    U(1) = Uo;
    
    % make an V zeros vector the length of T & set the first element to Vo
    V = zeros(1, length(T));
    V(1) = Vo;
    
    % make an W zeros vector the length of T & set the first element to Wo
    W = zeros(1, length(T));
    W(1) = Wo;
    
    %% calculate trajectory
    n = 2;  % initialize iterative variable to 2 (beginning index + 1)
    inAir = true;   % boolean indicating whether traj. is above surface
    while(inAir)
        % store current Cd and capsule frontal area
        [Cd, area] = drag_parameters(X(n - 1), Y(n - 1), Z(n - 1));
        
        % store current thrust vectors
        [xThrust, yThrust, zThrust] =...
            thruster(T(n - 1), U(n - 1), V(n - 1), W(n - 1));
        
        % create x-velocity vector based off of given equation
        U(n) = U(n - 1) + (xThrust/m - G * M * (X(n - 1)/(X(n - 1)^2 +...
            Y(n - 1)^2 + Z(n - 1)^2)^(3/2)) - Cd *...
            (air_density(X(n - 1), Y(n - 1), Z(n - 1)) * area)/(2*m)...
            * (U(n - 1) * sqrt(U(n - 1)^2 + V(n - 1)^2 + W(n - 1)^2)))*dt;
        
        % create y-velocity vector based off of given equation
        V(n) = V(n - 1) + (yThrust/m - G * M * (Y(n - 1)/(X(n - 1)^2 +...
            Y(n - 1)^2 + Z(n - 1)^2)^(3/2)) - Cd *...
            (air_density(X(n - 1), Y(n - 1), Z(n - 1)) * area)/(2*m)...
            * (V(n - 1) * sqrt(U(n - 1)^2 + V(n - 1)^2 + W(n - 1)^2)))*dt;
        
        % create z-velocity vector based off of given equation
        W(n) = W(n - 1) + (zThrust/m - G * M * (Z(n - 1)/(X(n - 1)^2 +...
            Y(n - 1)^2 + Z(n - 1)^2)^(3/2)) - Cd *...
            (air_density(X(n - 1), Y(n - 1), Z(n - 1)) * area)/(2*m)...
            * (W(n - 1) * sqrt(U(n - 1)^2 + V(n - 1)^2 + W(n - 1)^2)))*dt;
        
        % create position vectors based off of given equations
        X(n) = X(n - 1) + U(n) * dt;
        Y(n) = Y(n - 1) + V(n) * dt;
        Z(n) = Z(n - 1) + W(n) * dt;
        
        % if the probe is still above the planets surface, increment n
        if (sqrt(X(n)^2 + Y(n)^2 + Z(n)^2) > R)
            n = n + 1;
        else % otherwise set inAir to false to break the while loop
            inAir = false;
        end % if on line 72 
    end % while on line 40
    
    % once the vectors have been created, remove any excess vector
    % elements, as well as removing last (potentially negative) element
    T(n:end) = [];
    U(n:end) = [];
    V(n:end) = [];
    W(n:end) = [];
    X(n:end) = [];
    Y(n:end) = [];
    Z(n:end) = [];
end % function trajectory