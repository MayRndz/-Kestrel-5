%% KESTREL-5 Main Analysis
% Conceptual 5-kN LOX/RP-1 liquid rocket engine

clear;
clc;

%% Load design inputs
inputs;

%% Display baseline design
fprintf('\n');
fprintf('========================================\n');
fprintf('           KESTREL-5 ENGINE\n');
fprintf('========================================\n');

fprintf('Propellant:        %s / %s\n', ...
    propellant.oxidizer, propellant.fuel);

fprintf('Target thrust:     %.1f kN\n', ...
    engine.targetThrust / 1000);

fprintf('Chamber pressure:  %.2f MPa\n', ...
    engine.chamberPressure / 1e6);

fprintf('Mixture ratio:     %.2f\n', ...
    engine.mixtureRatio);

fprintf('Expansion ratio:   %.1f\n', ...
    engine.expansionRatio);

fprintf('========================================\n');

