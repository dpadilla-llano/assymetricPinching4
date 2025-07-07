function [k] = Envlp4Tangent(s4Strain,s4Stress,u)
%==========================================================================
% File Name: Envlp4Tangent.m
% Description: Compute envelope tangent for state 4, called in 
%              setTrialStrain. 
%
%                                 Prepared by Jiazhen Leng (jleng1@jhu.edu)
%                                                 Johns Hopkins University
%==========================================================================
k = 0.0;
i = 1;
while ((k==0.0||i<=3) && (i<=3)) 
    if (u>= s4Strain(i)) 
		k = (s4Stress(i+1)-s4Stress(i))/(s4Strain(i+1)-s4Strain(i));
    end
	i = i+1;
end
if (k==0.0)
    if (u<s4Strain(1))
		i = 1;
    else
		i = 3;
    end
	k = (s4Stress(i+1)-s4Stress(i))/(s4Strain(i+1)-s4Strain(i));	
end
