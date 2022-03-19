function simout_actual = myfunc_wrapper

vec = [1 2; %DOE input
       2,3;
       3,4]

[m,n] = size(vec)

storevec = []
for i = 1:1:n
    simouts = []
   for j = 1:1:n
       simout = simfunc(vec(i,1),vec(j,2))
       simouts = [simouts simout]
   end
   storevec = [storevec, simouts]
end

simout_actual = storevec
    
end 

function out  = simfunc(in1,in2) 
var1 = in1
var2 = in2
out = in1+in2
end