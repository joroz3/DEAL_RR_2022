
fid1 =fopen('DS3.avl')
fid2 = fopen('DS2.avl')
vec = []
for i = 1:1:90
line1 = fgetl(fid1)
line2 = fgetl(fid2)
num = isequal(line1,line2)
vec = [vec, num]
end
