%% KESTREL-5 Regenerative Cooling Thermal Model (Throat Station)

clear; clc;

%% --- Inputs  from thermochemistry.m / nozzle.m ----

thermo.chamberPressure    = 30e5;      % Pa
thermo.chamberTemperature = 3533.36;   % K   
thermo.cStar              = 1783.9;    % m/s

% CEA throat properties
throat.gamma        = 1.1318;
throat.cp           = 6511.7;          % J/(kg*K)   [6.5117 kJ/(kg*K)]
throat.k_gas        = 1.43122;         % W/(m*K)    [14.3122 mW/(cm*K)]
throat.Pr           = 0.4791;
throat.mu           = 1.0531e-4;       % Pa*s       [1.0531 millipoise]

% Nozzle geometry
nozzle.throatDiameter = 0.03988;       % m  (39.88 mm)
nozzle.throatArea     = 1.249e-3;      % m^2
nozzle.massFlow       = 2.1003;        % kg/s 

design.OF = 2.5;                       

%% design assumptions

geom.rc_over_rt   = 1.5;               
geom.wallThickness = 1.0e-3;           % m
geom.wallConductivity = 350;           % W/(m*K)

geom.nChannels    = 60;               
geom.channelWidth = 1.0e-3;            % m 
geom.channelHeight= 1.5e-3;            % m 

%% --- RP-1 coolant properties ---

coolant.rho = 810;         % kg/m^3
coolant.cp  = 1880;        % J/(kg*K)
coolant.mu  = 1.4e-3;      % Pa*s
coolant.k   = 0.109;       % W/(m*K)
coolant.T_in = 300;        % K
coolant.codingLimitT = 450; % K

%% --- Derived geometry ----

rt = nozzle.throatDiameter/2;
rc = geom.rc_over_rt * rt;

Ac_channel = geom.channelWidth * geom.channelHeight;               % m^2
Ac_total   = geom.nChannels * Ac_channel;                          % m^2
Dh = 2*geom.channelWidth*geom.channelHeight / (geom.channelWidth+geom.channelHeight);

mdotFuel = nozzle.massFlow / (design.OF + 1);   % kg/s

coolant.velocity = mdotFuel / (coolant.rho * Ac_total);            % m/s
coolant.Re = coolant.rho * coolant.velocity * Dh / coolant.mu;
coolant.Pr = coolant.cp * coolant.mu / coolant.k;

% heating case
coolant.Nu = 0.023 * coolant.Re^0.8 * coolant.Pr^0.4;
coolant.h  = coolant.Nu * coolant.k / Dh;    % W/(m^2*K)

%% --- Adiabatic wall temperature ---

M = 1.0;                       
g = throat.gamma;
r = throat.Pr^(1/3);           

T0 = thermo.chamberTemperature; 
T_aw = T0 * (1 + r*(g-1)/2*M^2) / (1 + (g-1)/2*M^2);

%% --- Unit conversion factors for the Bartz correlation ---

BTU_PER_J   = 1/1055.05585;
LBM_PER_KG  = 2.20462;
FT_PER_M    = 3.28084;
IN_PER_M    = 39.3701;
PSIA_PER_PA = 1/6894.76;
R_PER_K     = 1.8;             
gc          = 32.174;          

% h_g conversion factor
BTU_IN2_S_R_TO_W_M2_K = (1/BTU_PER_J) * (IN_PER_M^2) * R_PER_K;

Dt_in    = nozzle.throatDiameter * IN_PER_M;
rc_in    = rc * IN_PER_M;
mu_eng   = throat.mu * LBM_PER_KG / FT_PER_M;              % lbm/(ft*s)
cp_eng   = throat.cp * BTU_PER_J / LBM_PER_KG / R_PER_K;    % Btu/(lbm*R)
Pc_psia  = thermo.chamberPressure * PSIA_PER_PA;
cstar_fts= thermo.cStar * FT_PER_M;

AtOverA = 1.0; 

%% --- Bartz h_g as a function of guessed wall temperature ---

bartz_hg = @(Twg) local_bartz(Twg, T0, g, M, Dt_in, rc_in, mu_eng, cp_eng, ...
    throat.Pr, Pc_psia, gc, cstar_fts, AtOverA) * BTU_IN2_S_R_TO_W_M2_K;

%% --- Coupled heat balance ---

residual = @(Twg) bartz_hg(Twg)*(T_aw - Twg) - ...
    coolant.h * ( (Twg - bartz_hg(Twg)*(T_aw-Twg)*geom.wallThickness/geom.wallConductivity) - coolant.T_in );

T_wg = fzero(residual, 1000);   % K

h_g = bartz_hg(T_wg);
q_flux = h_g * (T_aw - T_wg);                                      % W/m^2
T_wc = T_wg - q_flux*geom.wallThickness/geom.wallConductivity;     % K
q_check = coolant.h * (T_wc - coolant.T_in);                        % W/m^2

%% --- Display ---

fprintf('KESTREL-5 Regenerative Cooling -- Throat Station\n');
fprintf('--------------------------------------------------\n');
fprintf('Adiabatic wall temperature (T_aw):  %.1f K\n', T_aw);
fprintf('Gas-side film coeff (h_g):          %.0f W/(m^2*K)\n', h_g);
fprintf('Gas-side wall temperature (T_wg):   %.1f K\n', T_wg);
fprintf('Coolant-side wall temp (T_wc):      %.1f K\n', T_wc);
fprintf('Heat flux (gas-side):               %.3e W/m^2\n', q_flux);
fprintf('Heat flux (coolant-side, check):    %.3e W/m^2\n', q_check);
fprintf('\nCoolant channel design (ASSUMED geometry):\n');
fprintf('  Channels: %d, %.1fmm x %.1fmm, Dh = %.2f mm\n', ...
    geom.nChannels, geom.channelWidth*1000, geom.channelHeight*1000, Dh*1000);
fprintf('  Fuel (coolant) mass flow:         %.4f kg/s\n', mdotFuel);
fprintf('  Coolant velocity:                 %.2f m/s\n', coolant.velocity);
fprintf('  Coolant Reynolds number:          %.0f\n', coolant.Re);
fprintf('  Coolant-side film coeff (h_c):    %.0f W/(m^2*K)\n', coolant.h);
fprintf('\nMargin checks:\n');
fprintf('  Gas-side wall temp vs. ~800-1000K copper-alloy limit: %.1f K\n', T_wg);
fprintf('  Coolant bulk temp vs. %.0f K coking limit (single-point, no marching): %.1f K\n', ...
    coolant.codingLimitT, coolant.T_in);
fprintf('====================================================\n');

save('kestrel5_thermal_results.mat', 'thermo', 'throat', 'nozzle', 'geom', 'coolant', ...
    'T_aw', 'h_g', 'T_wg', 'T_wc', 'q_flux');

%% --- Local Bartz function ---
function hg_raw = local_bartz(Twg, T0, g, M, Dt_in, rc_in, mu_eng, cp_eng, Pr, Pc_psia, gc, cstar_fts, AtOverA)
    sigma = ( 0.5*(Twg/T0)*(1+(g-1)/2*M^2) + 0.5 )^(-0.68) * (1+(g-1)/2*M^2)^(-0.12);
    hg_raw = (0.026/Dt_in^0.2) * (mu_eng^0.2 * cp_eng / Pr^0.6) * ...
             (Pc_psia*gc/cstar_fts)^0.8 * (Dt_in/rc_in)^0.1 * AtOverA^0.9 * sigma;
end
