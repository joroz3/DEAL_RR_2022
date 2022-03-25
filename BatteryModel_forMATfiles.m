clear
%Inputs
    Distance_Requirement = 500; %meters
    filename = '20-08-07_11-58-08.bin-504329.mat';
    
%Official specs for the battery we're using
    V = [12.6 12.45 12.33 12.25 12.07 11.95 11.86 11.74 11.62 11.56 11.51 11.45 11.39 11.36 11.3 11.24 11.18 11.12 11.06 10.83 9.82];
    Soc = [100 95 90 85 80 75 70 65 60 55 50 45 40 35 30 25 20 15 10 5 0];
    Ahr = 2500; %Amp-hours
    Vmax = 12.6;
    Vmin = 9.82;
    Etot = Ahr * (Vmax - Vmin) / 1000; %kH*hrs
%Import all of the needed data from the Excel sheets here
    %From BAT sheet import 'Volt' and 'CurrTot' and 'EnrgTot' and 'TimeUS' as really long arrays
    %Add in log below actually importing them - delete placeholder arrays
    load(filename);
    V_Real = BAT(:,3); %Volts
    I_Real = BAT(:,6); %Amps
    Enrg_Real = BAT(:,7); %kW*hrs
    Time = BAT(:,2);
    
    %From AETR sheet import 'Thr'
    Throt_Real = AETR(:,5); %Percentage of the total, which is '100'?
    
    %From ASRP import 'Airspeed'
    Speed_Real = ARSP(:,3);
       
%Mapping the voltage data to percentages, based off sigmoid fit of battery
    SOC_Real = zeros(length(V_Real), 1);
    for i = 1 : length(V_Real)
        SOC_Real(i) = 93.2421 / (1 + (V_Real(i) / 11.499 ) ^ -38.9019);
        if SOC_Real(i) < 0
            %Because of fluctuations, often end up with negative numbers
            SOC_Real(i) = 0;
        end
    end

%Converting Energy and Time units
    %Note that the Pixhawk records time in milliseconds from the roughly 2019
    %Energy has units of Watthours whch are converted to Watts for power_real
    Baseline_Time = Time(1);
    for i = 1 : length(Time)
        Time(i) = (Time(i) - Baseline_Time) * 10^-7;
    end

    Power_Real = zeros(length(Enrg_Real), 1);
    for i = 2 : length(Enrg_Real)
        Power_Real(i) = 3600 * (Enrg_Real(i) - Enrg_Real(i-1)) / (Time(i) - Time(i-1)); %Watts
    end

%Downsizing Throttle so we can plot it
    %Note there are 5 throttle points for every 2 power points
    %So we discard every other point, and every 5th point
    Throt_Interpolated = zeros(1, length(Enrg_Real));
    j = 1; %We'll end up discarding the last point
    for i = 1 : length(Throt_Interpolated)
        if rem(i, 2) == 0
            j = j + 3;
        else
            j = j + 2;
        end
        Throt_Interpolated(i) = Throt_Real(j);
    end
    %The model's values of Throttle
    power = zeros(100,1);
    for i = 1:100
        power(i) = 449.4087 + 5379.0868 / (1 + (i / 54.8455) ^ -14.8085);
    end
    
%Distance travelled versus energy usage
    Distance_Travelled = zeros(length(Enrg_Real), 1);
    for i = 2 : length(Distance_Travelled)
        Distance_Travelled(i) = (Speed_Real(i)) * (Time(i) - Time(i-1)) + Distance_Travelled(i-1);
        %Units are meters?
    end
    
    Vavg = mean(Speed_Real);
    Distance_Optimal = Vavg * Time(length(Time));
    
%Verification and Predictions
    diff = (Distance_Optimal - Distance_Travelled(length(Distance_Travelled))) / Distance_Optimal;

    if diff > 10
       fprintf("Battery performance exceeded tolerance, the battery is no longer operating at its optimum. Please check or replace the battery and motor.\n"); 
    else
       fprintf("Battery performance was within tolerance of optimal conditions.\n"); 

    end

    if Distance_Travelled(length(Distance_Travelled)) > Distance_Requirement
        fprintf("Aircraft was able to travel the required distance. Requirement met.\n");
    else
        fprintf("The distance requirement was not met.\n");
    end
    
%Graphs
    subplot(3,1,1)
    plot(1:100, power, "LineWidth",3)
    hold on
    scatter(Throt_Interpolated,Power_Real)
    xlabel("Throttle ");
    ylabel('Power(watts)');
    title('Throttle vs Power')

    subplot(3,1,2)
    plot (Soc,V,"LineWidth",3,"Color","b")
    hold on
    plot (SOC_Real,V_Real,"LineWidth",3,"Color","r")
    xlabel('Capacity %');
    ylabel('Voltage (V)');
    title('Voltage VS. State of Charge')
    legend('Predicted','Real','Location','southeast')

    subplot(3,1,3)
    plot (Distance_Travelled, Enrg_Real,"LineWidth",3,"Color","r")
    hold on
    plot ([0 Distance_Optimal], [0 Etot],"LineWidth",3,"Color","b")
    xlabel('Total Distance Travelled (m)');
    ylabel('Energy Used (kWh)');
    title('Distance vs. Energy Consumed')
    legend('Predicted','Real','Location','southeast')