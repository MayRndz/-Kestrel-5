%% KESTREL-5 Thermochemistry

% This file will determine the combustion properties required

clear;

%% Load design inputs
inputs;

%% Display analysis information

fprintf('\n');
fprintf('========================================\n');
fprintf('        THERMOCHEMISTRY ANALYSIS\n');
fprintf('========================================\n');

fprintf('Oxidizer:          %s\n', propellant.oxidizer);
fprintf('Fuel:              %s\n', propellant.fuel);
fprintf('Mixture ratio:     %.2f O/F\n', engine.mixtureRatio);
fprintf('Chamber pressure:  %.2f MPa\n', ...
    engine.chamberPressure / 1e6);

fprintf('========================================\n');

%% Thermochemical Properties from NASA CEA

% CEA equilibrium results
thermo.chamberTemperature = 3533.36;    % K
thermo.gamma = 1.1348;
thermo.molecularWeight = 22.882;        % kg/kmol

% Universal gas constant
thermo.Runiversal = 8314.462618;        % J/(kmol*K)

% Specific gas constant
thermo.R = thermo.Runiversal / thermo.molecularWeight;

% Characteristic velocity from CEA
thermo.cStar = 1783.9;                  % m/s

%%Thermochemical Properties

fprintf('\n');
fprintf('Thermochemical Properties\n');
fprintf('----------------------------------------\n');

fprintf('Chamber temperature: %.1f K\n', ...
    thermo.chamberTemperature);

fprintf('Specific heat ratio: %.3f\n', ...
    thermo.gamma);

fprintf('Molecular weight:    %.2f kg/kmol\n', ...
    thermo.molecularWeight);

fprintf('Specific gas constant: %.2f J/(kg*K)\n', ...
    thermo.R);

fprintf('Characteristic velocity: %.1f m/s\n', ...
    thermo.cStar);

fprintf('========================================\n');
