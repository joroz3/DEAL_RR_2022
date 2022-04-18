function [maxpower, distance_output, filename] = BatteryModel(input_place_holder_to_zero)

valuetoignore= input_place_holder_to_zero*0; %ModelCenter MBSE is not happy when a MATLAB function does not have inputs

%Select Flight Data Folder
userpath('C:\ModelCenter MBSE Analyses\DEAL_RR_2022\Flight Data')

%Input Data
    filename = uigetfile({'*.*'},'Select a file','C:\ModelCenter MBSE Analyses\DEAL_RR_2022\Flight Data');
    %filename = uigetfile({'*.*'});
    [~,~,f_ext] = fileparts(filename);
    if f_ext == ".xlsx" %Import needed data from Excel
        %From BAT sheet import 'Volt' and 'CurrTot' and 'EnrgTot' and 'TimeUS'
        BAT=xlsread(filename, 'BAT');
        V_Real = BAT(:,3); %Volts
        I_Real = BAT (:,6); %Amps
        Enrg_Real = BAT(:,7); %W*s
        Time = BAT(:,2);

        %From AETR sheet import 'Thr'
        AETR=xlsread(filename,'AETR');
        Throt_Real = AETR(:,5); %Percentage of the total thrust (range of 0-100%)

        %From ASRP import 'Airspeed'
        ARSP=xlsread(filename,'ASRP');
        Speed_Real = ARSP(:,3);
    elseif f_ext == ".mat" %Import needed data from the MAT file
        load(filename, 'BAT', 'AETR', 'ASRP');
        V_Real = BAT(:,3); %Volts
        I_Real = BAT(:,6); %Amps
        Enrg_Real = BAT(:,7); %kW*hrs
        Time = BAT(:,2);

        %From AETR sheet import 'Thr'
        Throt_Real = AETR(:,5); %Percentage of the total, which is '100'?

        %From ASRP import 'Airspeed'
        Speed_Real = ASRP(:,3);
    else
        error("Incorrect file type, please choose an Excel or MAT file.");
    end

    
%Official specs for the battery we're using
    V = [12.6 12.45 12.33 12.25 12.07 11.95 11.86 11.74 11.62 11.56 11.51 11.45 11.39 11.36 11.3 11.24 11.18 11.12 11.06 10.83 9.82];
    Soc = [100 95 90 85 80 75 70 65 60 55 50 45 40 35 30 25 20 15 10 5 0];
    Ahr = 2200; %Amp-hour rating of battery
    V_theor_min = 9.82;
    Vmax = max(V_Real); %Accounts for battery not being fully charged
    Vmin = V_theor_min - min(V_Real); %Accounts for battery not fully discharging
    if Vmin < 0
        Vmin = 0;
    end
    Etot = (Vmax - Vmin) * Ahr / 3600; %Ws


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
        Time(i) = (Time(i) - Baseline_Time) * 10^-6;
    end

    Power_Real = zeros(length(Enrg_Real), 1);
    for i = 2 : length(Enrg_Real)
        Power_Real(i) = (Enrg_Real(i) - Enrg_Real(i-1)) / (Time(i) - Time(i-1)) * 10;
    end
    
    
%Downsizing real throttle so it has the same length as everything else
    %There are 5 throttle  for every 2 power, need to discard three
    Throt_Interpolated = zeros(length(Enrg_Real), 1);
    j = 0; %We'll end up discarding the last point
    for i = 1 : length(Throt_Interpolated)
        if rem(i, 2) == 0 && j < length(Throt_Real) - 2
            j = j + 2;
            Throt_Interpolated(i) = (Throt_Real(j) + Throt_Real(j-1)) / 2;
        elseif rem(i, 2) ~= 0 && j < length(Throt_Real) - 3
            j = j + 3;
            Throt_Interpolated(i) = (Throt_Real(j) + Throt_Real(j-1) + Throt_Real(j-2)) / 3;
        elseif j < length(Throt_Real)
            j = j + 1;
            Throt_Interpolated(i) = Throt_Real(j);
        end
    end
    
    
%Finding the model's predicted values of throttle to plot against the real
    power = zeros(100,1);
    for i = 1:100
        power(i) = 0.22470435 + 1.3447717 / (1 + (i / 54.8455) ^ -14.8085);
    end
    
    
%Distance travelled versus energy usage
    Distance_Travelled = zeros(length(Enrg_Real), 1);
    for i = 2 : length(Distance_Travelled)
        Distance_Travelled(i) = (Speed_Real(i)) * (Time(i) - Time(i-1)) + Distance_Travelled(i-1);
        %Units are meters?
    end
    
    Vel_avg = mean(Speed_Real);
    Distance_Optimal = Vel_avg * Time(length(Time));
    

%Outputs for ModelCenter (Requirement Verification)
    maxpower = max(Power_Real);
    distance_output = Distance_Travelled(length(Distance_Travelled));


%Predictions and Analysis
    dis_diff = (Distance_Optimal - Distance_Travelled(length(Distance_Travelled))) / Distance_Optimal * 100;
    en_dif = (Etot - Enrg_Real(length(Enrg_Real))) / Etot * 100;
    preds = strings([1, 7]);
    preds(1, 1) = maxpower;
    preds(1, 2) = distance_output;
    
    if dis_diff > 10 && Distance_Travelled(length(Distance_Travelled)) < Distance_Optimal
        preds(1, 3) = Distance_Optimal;
        preds(1, 4) = "The aircraft flight range was out of the optimum range. If weather conditions were normal, please check the battery and motor energy consumption levels."; 
    else
       preds(1, 3) = Distance_Optimal;
       preds(1, 4) = "Range was within tolerance of the optimum."; 
    end
    
    if en_dif > 10 && Enrg_Real(length(Enrg_Real)) < Etot
        preds(1, 5) = Enrg_Real(length(Enrg_Real));
        preds(1, 6) = Etot;
        preds(1, 7) = "Ensure battery was fully charged and the aircraft was flying during this flight, strapped down flights will not pass this test.";
    elseif en_dif > 10 && Enrg_Real(length(Enrg_Real)) > Etot
        preds(1, 5) = Enrg_Real(length(Enrg_Real));
        preds(1, 6) = Etot;
        preds(1, 7) = "The aircraft drew more energy than normal, either the motor or battery may need maintenance.";
    else
        preds(1, 5) = Enrg_Real(length(Enrg_Real));
        preds(1, 6) = Etot;
        preds(1, 7) = "Battery energy consumption was within the normal range, performance is at its optimum.";
    end

%Output Graphs
    fig_1 = figure('visible','off');
    plot(1:100, power, "LineWidth",3);
    hold on
    scatter(Throt_Interpolated,Power_Real);
    xlabel("Throttle ");
    ylabel('Power(watts)');
    title('Throttle vs Power');
    
    fig_2 = figure('visible','off');
    plot (Soc,V,"LineWidth",3,"Color","b");
    hold on
    plot (SOC_Real,V_Real,"LineWidth",3,"Color","r");
    xlabel('Capacity %');
    ylabel('Voltage (V)');
    title('Voltage VS. State of Charge');
    legend('Predicted','Real','Location','southeast');

    fig_3 = figure('visible','off');
    plot ([0 Distance_Optimal], [0 Etot],"LineWidth",3,"Color","b");
    hold on
    plot (Distance_Travelled, Enrg_Real,"LineWidth",3,"Color","r");
    xlabel('Total Distance Travelled (m)');
    ylabel('Energy Used (W*s)');
    title('Distance vs. Energy Consumed');
    legend('Predicted','Real','Location','southeast');
    
    saveas(fig_1,'Power_vs_Throttle','jpg');
    saveas(fig_2,'Voltage_vs_SOC','jpg');
    saveas(fig_3,'Distance_vs_EnergyUsage','jpg');
    
%Output Data
    Data_Table = array2table(preds);
    Data_Table.Properties.VariableNames = {'Maximum Power', 'Real Distance', 'Theoretical Distance', 'Distance Analysis', 'Energy Consumption', 'Theoretical Energy Consumption', 'Energy Analysis'};
end