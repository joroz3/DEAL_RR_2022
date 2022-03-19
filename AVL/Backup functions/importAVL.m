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
