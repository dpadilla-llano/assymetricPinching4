function [f] = Envlp3Stress(s3Strain,s3Stress,u)
%==========================================================================
% File Name: Envlp3Stress.m
% Description: Compute envelope stress for state 3, called in 
%              setTrialStrain. 
%
%                                 Prepared by Jiazhen Leng (jleng1@jhu.edu)
%                                                 Johns Hopkins University
%==========================================================================
k = 0.0;
i = 1;
f = 0.0;
while ((k==0.0||i<=3) && (i<=3)) 
    if (u>= s3Strain(i))
	    k = (s3Stress(i+1)-s3Stress(i))/(s3Strain(i+1)-s3Strain(i));
		f = s3Stress(i)+(u-s3Strain(i))*k;
    end
	i = i + 1;
end
if (k==0.0)
    if (u<s3Strain(1))
        i = 1;
    else
		i = 3;
    end
	k = (s3Stress(i+1)-s3Stress(i))/(s3Strain(i+1)-s3Strain(i));
	f = s3Stress(i)+(u-s3Strain(i))*k;
end

