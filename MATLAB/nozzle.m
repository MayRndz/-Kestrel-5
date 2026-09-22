% throat/exit areas from 1D isentropic flow theory using a constant gamma

%cCEA's numbers are used afterward, in the validation section.

clear; clc;

% (CEA results)

thermo.chamberPressure   = 30e5;       % Pa   
thermo.chamberTemperature = 3533.36;   % K
thermo.gamma             = 1.1348;     % constant-gamma approximation 
thermo.molecularWeight   = 22.882;     % kg/kmol
thermo.Runiversal        = 8314.462618;% J/(kmol*K)
thermo.R                 = thermo.Runiversal / thermo.molecularWeight; % J/(kg*K)
thermo.cStar             = 1783.9;     % m/s, from CEA

%% Targets

design.thrust  = 5000;      % N
design.epsilon = 15;        % Ae/At
design.Pamb    = 101325;    % Pa

% Solve the area-Mach relation 

g = thermo.gamma;
areaMachResidual = @(M) (1./M) .* ( (2/(g+1)) .* (1 + (g-1)/2 .* M.^2) ).^((g+1)/(2*(g-1))) - design.epsilon;

nozzle.exitMach = fzero(areaMachResidual, 3.5);

%% Isentropic relations 

nozzle.exitTemperature = thermo.chamberTemperature / (1 + (g-1)/2 * nozzle.exitMach^2);      % K
nozzle.exitPressure    = thermo.chamberPressure   / (1 + (g-1)/2 * nozzle.exitMach^2)^(g/(g-1)); % Pa

%% Exit velocity

nozzle.exitVelocity = nozzle.exitMach * sqrt(g * thermo.R * nozzle.exitTemperature); % m/s

%% Solve for throat area

nozzle.throatArea = design.thrust / ...
    ( (thermo.chamberPressure/thermo.cStar) * nozzle.exitVelocity ...
    + design.epsilon * (nozzle.exitPressure - design.Pamb) );   % m^2

nozzle.exitArea   = design.epsilon * nozzle.throatArea;            % m^2

nozzle.throatDiameter = 2 * sqrt(nozzle.throatArea/pi) * 1000;     % mm
nozzle.exitDiameter   = 2 * sqrt(nozzle.exitArea/pi) * 1000;       % mm

%% Verify thrust

nozzle.massFlow = thermo.chamberPressure * nozzle.throatArea / thermo.cStar;  % kg/s

nozzle.thrustCheck = nozzle.massFlow * nozzle.exitVelocity + ...
    (nozzle.exitPressure - design.Pamb) * nozzle.exitArea;                   % N

%% Display

fprintf('KESTREL-5 Nozzle Model (constant-gamma, gamma = %.4f)\n', g);
fprintf('----------------------------------------------------\n');
fprintf('Exit Mach number:        %.3f\n', nozzle.exitMach);
fprintf('Exit temperature:        %.2f K\n', nozzle.exitTemperature);
fprintf('Exit pressure:           %.5f bar\n', nozzle.exitPressure/1e5);
fprintf('Exit velocity:           %.1f m/s\n', nozzle.exitVelocity);
fprintf('Mass flow rate:          %.4f kg/s\n', nozzle.massFlow);
fprintf('Throat area:             %.3e m^2\n', nozzle.throatArea);
fprintf('Throat diameter:         %.2f mm\n', nozzle.throatDiameter);
fprintf('Exit area:               %.3e m^2\n', nozzle.exitArea);
fprintf('Exit diameter:           %.2f mm\n', nozzle.exitDiameter);
fprintf('Thrust (check):          %.1f N (target %.0f N)\n', nozzle.thrustCheck, design.thrust);
fprintf('======================================================\n');

%% Comparison against CEA (Validation)

fprintf('\nComparison vs. CEA equilibrium (epsilon = 15):\n');
fprintf('  Me:  model = %.3f   CEA = 3.340   diff = %.2f%%\n', ...
    nozzle.exitMach, 100*(nozzle.exitMach-3.340)/3.340);
fprintf('  Pe:  model = %.5f bar   CEA = 0.25707 bar   diff = %.2f%%\n', ...
    nozzle.exitPressure/1e5, 100*(nozzle.exitPressure/1e5-0.25707)/0.25707);
fprintf('  Te:  model = %.2f K   CEA = 2082.47 K   diff = %.2f%%\n', ...
    nozzle.exitTemperature, 100*(nozzle.exitTemperature-2082.47)/2082.47);

save('kestrel5_nozzle_results.mat', 'thermo', 'design', 'nozzle');
