function [fp_num] = Num_Der_Cent(x,y)
drl=length(y);
fp_num=nan*zeros(1,drl);
for i= 2:drl-1
        fp_num(i)=(y(i+1)-y(i-1))/(x(i+1)-x(i-1));

end
