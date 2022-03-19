
%% Matlab Function to size the aircraft
function [wing_loading, power_loading, wingloadv, pwrloadv, b_new, c_new] = MBSE_Aircraft_Sizing(span, m_chord, S_TO, MTOW)

AR = span/m_chord;

%Assumptions
CLmax = 0.97;
h = 1050;           % Elevation of Atlanta
CD0 = 0.09;
e = 0.8;
K1 = 1/pi/AR/e;
eta = 0.8;
k_to = 1.1;

%Initialize Variables
n = 20;
m = 3;
V_max = linspace(35, 45, m);
wing_loadings = linspace(1,3, n);

optimal_wingload = 0;
optimal_power = 0;

tol = 0.5;

for j = 1:m
    MS_power_loading = zeros(1,length(wing_loadings));
    TO_power_loading = zeros(1,length(wing_loadings));
    for i = 1:length(wing_loadings)
        MS_power_loading(i) = max_speed(V_max(j),h,CD0,K1,wing_loadings(i),eta);
        TO_power_loading(i) = takeoff_distance(h,S_TO,wing_loadings(i),eta,CLmax,k_to);
        
        if (abs(MS_power_loading(i) - TO_power_loading(i)) < tol) && (MS_power_loading(i)*TO_power_loading(i)*wing_loadings(i) > 0)
            optimal_wingload = wing_loadings(i);
            optimal_power = (MS_power_loading(i) + TO_power_loading(i))*(1.05/2);
        end
    end
    
%     plot(wing_loadings,MS_power_loading)
%     xlim([1,3])
%     ylim([0,40])
%     hold on
%     plot(wing_loadings,TO_power_loading,'--')
end

wing_loading = optimal_wingload;
power_loading = optimal_power;

span= sqrt((MTOW/wing_loading)*AR);
m_chord = span/AR;

b_new=span;
c_new=m_chord;

% wing_span = (1/wing_loading)*TOW/m_chord;
% batt_power = (1/power_loading)*TOW;

wingloadv=abs(MTOW/(m_chord*span))-wing_loading; %wing loading verification
instlthr=power_loading*MTOW; %Installed thrust
pwrloadv=(instlthr/MTOW)-power_loading; %Power Loading verification

file = fopen('dimensions.txt','w');
fprintf(file,'Span:%d feet \n',b_new);
fprintf(file,'Chord:%d feet',c_new);
%fwrite(file, fh)
fclose(file);
end

function p_to_w_ratio = max_speed(V,h,CD0,K1,wing_loading,eta)
[~,~,rho,~,~] = atmosphere(h);
q = rho*V^2/2;
p_to_w_ratio = V/eta*(q/wing_loading)*(K1*(wing_loading/q)^2+CD0)/550*745;
end

function p_to_w_ratio = takeoff_distance(h,S_TO,wing_loading,eta,CLmax,k_to)
[~,~,rho,~,~] = atmosphere(h);
stall_speed = (2*wing_loading/rho/CLmax)^0.5;
takeoff_speed = stall_speed*k_to;
p_to_w_ratio = takeoff_speed/2^0.5/eta*1.1^2*wing_loading/(32.2*S_TO*rho*CLmax)/550*745;
end

% 1976 US Standard Atmosphere
% http://www.atmosculator.com/The%20Standard%20Atmosphere.html?
% David Pate and Michael Patterson
%
%INPUTS
%  h = altitude in feet
%OUTPUTS
%  temp = temperature in °R
%  pres = pressure in lb/ft^2
%  rho = density in slug/ft^3
%  mu = viscosity in slug/(ft-s)
%  a = sound speed ft/s assuming R=1716 ft-lb/(slugs-°R) and gamma = 1.4

function [temp,pres,rho,mu,a] = atmosphere(h)

dims = size(h);     %what shape is h?
h = h(:);           %turns it into a column vector

R = 1716;
gamma = 1.4;


T_SL = 518.69;      %°R
T0 = 491.6;         %°R
p_SL = 2116.2;      %lb/ft^2
rho_SL = .0023769;  %slug/ft^3
mu0 = 3.58394051e-7;    %slug/(ft-s)
% 3.7373e-7;    %slug/(ft-s)
S = 199;            %Sutherland's Constant °R

a = h <= 36809;
    theta(a) = 1 - h(a) ./ 145442;
    delta(a) = (1 - h(a) ./ 145442).^5.255876;
    sigma(a) = (1 - h(a) ./ 145442).^4.255876;
    

% Isothermal
b = (36089 < h) & (h <= 65617);
    theta(b) = 0.751865;
    delta(b) = 0.223361 .* exp(-(h(b)-36089)./20806);
    sigma(b) = 0.297076 .* exp(-(h(b)-36089)./20806);
    

% (Inversion)
c = (65617 < h) & (h <= 104987);
    theta(c) = 0.682457 + h(c) ./ 945374;
    delta(c) = (0.988626 + h(c) ./ 652600).^(-34.16320);
    sigma(c) = (0.978261 + h(c) ./ 659515).^(-35.16320);


% (Inversion)
d = (104987 < h) & (h <= 154199);
    theta(d) = 0.482561 + h(d) ./ 337634;
    delta(d) = (0.898309 + h(d) ./ 181373).^(-12.20114);
    sigma(d) = (0.857003 + h(d) ./ 190115).^(-13.20114);


% (Isothermal)
e = (154199 < h) & (h <= 167323);
    theta(e) = 0.939268;
    delta(e) = 0.00109456 .* exp(-(h(e)-154199)./25992);
    sigma(e) = 0.00116533 .* exp(-(h(e)-154199)./25992);


f = (167323 < h) & (h <= 232940);
    theta(f) = 1.434843 - h(f) ./ 337634;
    delta(f) = (0.838263 - h(f) ./ 577922).^12.20114;
    sigma(f) = (0.798990 - h(f) ./ 606330).^11.20114;


g = (232940 < h) & (h <= 278386);
    theta(g) = 1.237723 - h(g) ./ 472687;
    delta(g) = (0.917131 - h(g) ./ 637919).^17.08160;
    sigma(g) = (0.900194 - h(g) ./ 649922).^16.08160;


temp = theta .* T_SL;
pres = delta .* p_SL;
rho = sigma .* rho_SL;
mu = mu0 .* (temp/T0).^(3/2) .* (T0 + S) ./ (temp + S);
    
temp = reshape(temp,dims);  %turns these into the form of input h
pres = reshape(pres,dims); 
rho = reshape(rho,dims); 
mu = reshape(mu,dims); 
a = (gamma .* R .* temp).^(0.5);
end
