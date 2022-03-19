% Ogun Kargin   DEC 2018
function [Xnp,SM,SMshift,Cma,CLa,Cnb] =  masterAVL (c_new, b_new) 
c_new = c_new*12
b_new = b_new*12
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
fid2 = fopen('DS1.avl','w+');

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
out = runAVL ;
[Xnp,SM,SMshift,Cma,CLa,Cnb] = reduceAVL(c_new)
end


