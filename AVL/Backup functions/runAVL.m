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
    [status,result] = dos(strcat(avlLocation,' < ',scriptfile,'.run'))%,'-echo');
    toc
    
    % move plot.ps to output directory
    [status,result] = dos(['move /y ', '.\plot.ps' ,' ', directory, '\']);
end
out = 'runAVL is done.'
end

