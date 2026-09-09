%% KESTREL-5 Conceptual Engine
% Initial design assumptions

clear;

%% Propellant
propellant.oxidizer = "LOX";
propellant.fuel = "RP-1";

%% Engine Design Point
engine.targetThrust = 5000;            % N
engine.chamberPressure = 3.0e6;       % Pa
engine.mixtureRatio = 2.5;            % O/F
engine.expansionRatio = 15.0;         % Ae/At

%% Environment
environment.g0 = 9.80665;             % m/s^2
environment.seaLevelPressure = 101325; % Pa
environment.vacuumPressure = 0;        % Pa
