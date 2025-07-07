function [k] = negEnvlpTangent(u,envlpNegDamgdStress,envlpNegStrain)
%==========================================================================
% File Name: negEnvlpTangent.m
% Description: Compute negative envelope tangent, called in setTrialStrain. 
%
%                                 Prepared by Jiazhen Leng (jleng1@jhu.edu)
%                                                 Johns Hopkins University
%==========================================================================
k = 0.0;
i = 1;
% envlpNegDamgdStress and envlpNegStrain are set in getstate()
while (k==0.0 && i<=5)             
    if (u>=envlpNegStrain(i+1))
	    k = (envlpNegDamgdStress(i)-envlpNegDamgdStress(i+1))/(envlpNegStrain(i)-envlpNegStrain(i+1));
    end
    i = i+1;
end

if (k==0.0)
	k = (envlpNegDamgdStress(5) - envlpNegDamgdStress(6))/(envlpNegStrain(5)-envlpNegStrain(6));
end
