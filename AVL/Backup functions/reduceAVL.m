% Martin Kurien NOV 2017
% Ogun Kargin   DEC 2018
% reduceAVL.m

function [Xnp,SM,SMshift,Cma,CLa,Cnb] = reduceAVL(cbar)
cbar = 8.25;

%% INPUT variables
dirs = {
    %        './DS8_ST/';
    %        './DS7_ST/';
    %        './DS6_ST/';
    %        './DS4_ST/';
    %        './DS8_ST/';
%              './DS8_ST/';
%              './DS70_ST/';
%              './DS71_ST/'; 
%              './DS72_ST/';
             
    
             './DS1_ST/';
    %        './DS9_ST/';
    %        './DS15_ST/';
    };

lgnd  = {
    'MVP';
%     '2 pipes';
%     '2 w/ placeholders';
  %  '2 full 2 8.5';
             
    %        'digisweep5 cg2.2';
    %        'digisweep small stab';
    %        '5 tubes, 6in bottom, .25 pushed out';
    %        '5 tubes, flight test conf.';
    %        '4 tubes, flight test conf';
    %        '4 tubes, baseline conf';
    
    
    };


alpha = 0:11;
%% IMPORT Data
% imports data
avlData = {};
for i = 1:length(dirs)
    importData = [];
    for j = alpha
        fn = [dirs{i} sprintf('a%d.st', j)];
        importData = [importData, importAVL(fn)];
    end
    
    fnames = fieldnames(importData);
    for j = 1:length(fnames)
        dataTemp.(fnames{j}) = [importData.(fnames{j})];
    end

    dataTemp.Xnp = dataTemp.Xnp ./ cbar .* 100;
    dataTemp.SM = -dataTemp.Cma ./ dataTemp.CLa .* 100;

    avlData = [avlData, dataTemp];
end

Xnp = dataTemp.Xnp;
SM = dataTemp.SM;
Cma = dataTemp.Cma;
CLa = dataTemp.CLa;
Cnb = dataTemp.Cnb;

Xnp =sum(Xnp)/length(Xnp);
SMshift = max(SM)-min(SM);
SM =sum(SM)/length(SM);
Cma =sum(Cma)/length(Cma);
CLa =sum(CLa)/length(CLa);
Cnb =sum(Cnb)/length(Cnb);

end

% %% PLOT and SAVE Data
% 
% alphalbl = '\alpha (Degrees)';
% 
% 
% plotFormat(avlData, 'Alpha', 'CLtot', 'C_L',        alphalbl, 'C_L', lgnd);
% legend on
% 
% plotFormat(avlData, 'Alpha', 'Cma',   'C_m_\alpha', alphalbl, 'C_m_Alpha', lgnd);
% legend on
% 
% plotFormat(avlData, 'Alpha', 'Cnb',   'C_n_\beta',  alphalbl, 'C_n_\beta', lgnd);
% legend on
% 
% plotFormat(avlData, 'Alpha', 'elevator', 'Ruddervator Deflection', alphalbl, 'Deflection (degrees)', lgnd);
% legend on
% 
% plotFormat(avlData, 'Alpha', 'SM',  'Static Margin', alphalbl, 'Static Margin (%)', lgnd);
% legend on
% %
