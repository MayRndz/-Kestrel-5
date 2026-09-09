% Conceptual design parameters
% All values are initial assumptions that will be changed
% as the analysis develops.

%% Propellant
propellant.oxidizer = "LOX";
propellant.fuel = "RP-1";

%% Engine Design Point
engine.targetThrust = 5000;          % N
engine.chamberPressure = 3e6;        % Pa
engine.mixtureRatio = 2.5;           % O/F
engine.expansionRatio = 15;          % Ae/At

%% Environment
environment.g0 = 9.80665;             % m/s^2
environment.seaLevelPressure = 101325; % Pa
environment.vacuumPressure = 0;       % Pa

%% Analysis Assumptions
assumptions.isentropicNozzle = true;
assumptions.steadyFlow = true;
assumptions.oneDimensionalFlow = true;
assumptions.uniformChamberPressure = true;
assumptions.idealGasNozzle = true;
