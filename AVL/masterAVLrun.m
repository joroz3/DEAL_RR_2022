% Ogun Kargin   DEC 2018
function [Xnp, SM, SMshift, Cma, CLa, Cnb] =  masterAVLrun (c_new, b_new) 
c_new = c_new*12;
b_new = b_new*12;
% c_new = 8;
% b_new = 41;
s_new = b_new*c_new;

c_new = num2str(c_new,'%.2f');
b_new = num2str(b_new./2,'%.2f');
s_new = num2str(s_new./2,'%.2f');

fid = fopen('DS3.avl','r+');
A = {};
lc = 0;
for i = 1:9
line = fgetl(fid);
lc = lc+1;
A{lc} = line;
end
line = fgetl(fid);
lc = lc+1;
[token,remain] = strtok(line);
s_old = token;
[token,remain] = strtok(remain);
c_old = token;
[token,remain] = strtok(remain);
b_old = token;
line = strrep(line, c_old,c_new);
line = strrep(line, s_old,s_new);
line = strrep(line, b_old,b_new);
A{lc} = line;

for i = 1:15
line = fgetl(fid);
lc = lc+1;
A{lc} = line;
end

line = fgetl(fid);
lc=lc+1;
[token,remain] = strtok(line);
[token,remain] = strtok(remain);
[token,remain] = strtok(remain);
[token,remain] = strtok(remain);
c_old = token ;
line = strrep(line, c_old,c_new);
A{lc} = line;

for i = 1:5
line = fgetl(fid);
lc=lc+1;
A{lc}=line;
end 
line = fgetl(fid);
lc=lc+1;
line = strrep(line, c_old,c_new);
%fwrite(fid,line)
A{lc} = line;

for i = 1:5
line = fgetl(fid);
lc=lc+1;
A{lc} = line;
end 
line = fgetl(fid);
lc=lc+1;

line = strrep(line, c_old, c_new);
[token,remain] = strtok(line);
[token,remain] = strtok(remain);
line = strrep(line, token, b_new);
%fwrite(fid,line)
A{lc} = line;

i = 0;
for i = 1:55 
i = i+1;
    line = fgetl(fid);
    lc=lc+1;

A{lc}= line;
end
fclose(fid);
A{end+1}=-1;
fid2 = fopen('DS3.avl','w+');

for ind = 1:numel(A)
    if A{i+1} == -1
        fprintf(fid2,'%s', A{ind});
        break
    else
        fprintf(fid2,'%s\n', A{ind});
    end
end
fclose(fid2);

%runs AVL for 11 cases 
out = runAVL() ;
[Xnp,SM,SMshift,Cma,CLa,Cnb] = reduceAVL(c_new)
end

% Joseph Moster DEC 2011
% Martin Kurien NOV 2017
% Ogun Kargin   DEC 2018
% runAVL.m
function [out] = runAVL()
%% INPUT variables
% nums = {'1', '2','3','4'};
nums = {'1'};
%
for i = 1:length(nums)
    directory = sprintf('.\\DS%s_ST', nums{i});
    filename = sprintf('.\\DS%s', nums{i});
    
    % directory = '.\Baseline2_ST';
    % filename  = '.\Batman_baseline2';
    
    % Define name and location of script file
    scriptfile = strcat(directory, '\avlScript');
    % Define name and location of script file
    runfile = '.\alpha_sweep';
    cases = 12;
    % Location of avl
    avlDir = '.\\';
    avlLocation = strcat('"', avlDir, 'avl.exe', '"');
    plotLocation = strcat('"', avlDir, 'plot.ps', '"');
    % Define output file base name
    outfile = strcat(directory, '\a');
    %% Directory Preparation
    %Purge Directory of interfering files
    [status,result] =dos(strcat('del ',directory,'\*.st'));
    [status,result] =dos(strcat('del ',directory,'\*.sb'));
    [status,result] =dos(strcat('del ',directory,'\*.run'));
    [status,result] =dos(strcat('del ',directory,'\*.eig'));
    [status,result] =dos(strcat('del ',directory,'\*.ps'));
    %% Create run file
    %Open the file with write permission
    fid = fopen(strcat(scriptfile,'.run'), 'w');
    
    %Load the AVL definition of the aircraft
    fprintf(fid, 'LOAD %s\n', strcat(filename,'.avl'));
    %Disable Graphics
    fprintf(fid, 'PLOP\ng\n\n');
    %Open the OPER menu
    fprintf(fid, '%s\n',   'OPER');
    fprintf(fid, '%s\n',   'd2 pm 0');
    
    isHidden = false;
    
    for i = 1:cases
        % Set next case
        fprintf(fid, 'a a %d\n',    i - 1);
        % Run the Case
        fprintf(fid, '%s\n',   'x');
        % Save ST data
        fprintf(fid, '%s\n',   'st');
        fprintf(fid, '%s%d%s\n', outfile, i - 1, '.st');
        % Save SB data
        fprintf(fid, '%s\n',   'sb');
        fprintf(fid, '%s%d%s\n', outfile, i  - 1, '.sb');
        % Plot Trefftz to plot.ps
        fprintf(fid, '%s\n',   't');
        if ~isHidden
            fprintf(fid, '%s\n',   'p');
            fprintf(fid, '%s\n',   'd');
            isHidden = true;
        end
        fprintf(fid, '%s\n',   'h');
        fprintf(fid, '%s\n',   '');
        
    end
    
    
    %Drop out of OPER menu
    fprintf(fid, '%s\n',   '');
    
    %Quit Program
    fprintf(fid, 'Quit\n');
    
    %Close File
    fclose(fid);
    %% Execute Run
    % Run AVL using
    
    tic
    str = ['iterating']
    [status,result] = dos(strcat(avlLocation,' < ',scriptfile,'.run'))%,'-echo');
    toc
    
    % move plot.ps to output directory
    [status,result] = dos(['move /y ', '.\plot.ps' ,' ', directory, '\']);
end
out = 'runAVL is done.'
end

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
function data = importAVL(filename)
fileID = fopen(filename,'r');
out1 = part1(fileID);
fclose(fileID);

fileID = fopen(filename,'r');
out2 = part2(fileID);
fclose(fileID);

fileID = fopen(filename,'r');
out3 = part3(fileID);
fclose(fileID);

strctfields = [out1(:, 1);
    out1(4:6, 3);
    out1(9:11, 3);
    out2(1:6, 1);
    out2(8:end, 1);
    out2(1:5, 3);
    out2(7:end, 3);
    out2(8:end, 5);
    out3(:, 1)];

strctval    = [out1(:, 2);
    out1(4:6, 4);
    out1(9:11, 4);
    out2(1:6, 2);
    out2(8:end, 2);
    out2(1:5, 4);
    out2(7:end, 4);
    out2(8:end, 6);
    out3(:, 2)];

for i = 1:numel(strctfields)
    try
        if i ==65
            data.Xnp =  strctval{i};
        else
            data.(strctfields{i}) = strctval{i};
        end
    catch
    end
end

end

function out1 = part1(fileID)
%% Initialize variables.
delimiter = {' ','=','|'};
startRow = 11;
endRow = 22;

%% Format string for each line of text:
%   column1: text (%s)
%	column2: double (%f)
%   column3: text (%s)
%	column4: double (%f)
%   column5: text (%s)
%	column6: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%f%s%f%s%f%*s%*s%*s%*s%*s%*s%*s%[^\n\r]';

%% Open the text file.

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
textscan(fileID, '%[^\n\r]', startRow(1)-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'EmptyValue' ,NaN,'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    textscan(fileID, '%[^\n\r]', startRow(block)-1, 'WhiteSpace', '', 'ReturnOnError', false);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'EmptyValue' ,NaN,'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
dataArray([2, 4, 6]) = cellfun(@(x) num2cell(x), dataArray([2, 4, 6]), 'UniformOutput', false);
out1 = [dataArray{1:end-1}];
end

function out2 = part2(fileID)
delimiter = {' ','=','|'};

startRow = 27;
endRow = 45;


%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%*s%*s%*s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
textscan(fileID, '%[^\n\r]', startRow(1)-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    textscan(fileID, '%[^\n\r]', startRow(block)-1, 'WhiteSpace', '', 'ReturnOnError', false);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[2,4,6]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end


%% Split data into numeric and cell columns.
rawNumericColumns = raw(:, [2,4,6]);
rawCellColumns = raw(:, [1,3,5]);


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
out2 = raw;

end

function out3 = part3(fileID)
%% Initialize variables.
delimiter = {'='};
startRow = 50;
endRow = 52;


%% Format string for each line of text:
%   column3: text (%s)
%	column4: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%f%[^\n\r]';

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
arr = textscan(fileID, '%[^\n\r]', startRow(1)-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    textscan(fileID, '%[^\n\r]', startRow(block)-1, 'WhiteSpace', '', 'ReturnOnError', false);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
dataArray(2) = cellfun(@(x) num2cell(x), dataArray(2), 'UniformOutput', false);
out3 = [dataArray{1:end-1}];

end
function plotFormat(avlData, fieldx, fieldy, name, xlbl, ylbl, lgnd)


% Create figure
figure1 = figure;
x0 = 1;
y0 = 1;
width  = 6.5;
height = 6.5 ;
set(gcf,'units','inches','position',[x0,y0,width,height])
set(gcf,'color','w');

% Create axes
axes1 = axes('Parent',figure1);

% Create plot
hold on
m = length(avlData);
for i = 1:m
    plot(avlData{i}.(fieldx), avlData{i}.(fieldy),'LineWidth',2);
end
% plot([0, 12], [0, 0], '--r', 'linewidth', 1.5);


set(axes1,'FontName','Times New Roman','FontSize',18);

xlabel(xlbl);
% ylabel(ylbl);
ylabel(ylbl);
% xlim([0 11])
% title(name);
 legend(lgnd, 'Location', 'EastOutside', 'Box', 'Off');

filename = name(name ~= '\');
% saveas(gcf,[filename, '.png'])
end


