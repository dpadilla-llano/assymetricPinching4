function [f] = posEnvlpStress(u,envlpPosDamgdStress,envlpPosStrain)
%==========================================================================
% File Name: posEnvlpStress.m
% Description: Compute postive envelope stress, called in setTrialStrain. 
%
%                                 Prepared by Jiazhen Leng (jleng1@jhu.edu)
%                                                 Johns Hopkins University
%==========================================================================
k = 0.0;
i = 1;
f = 0.0;
% envlpPosDamgdStress and envlpPosStrain are set in getstate
while (k==0.0 && i<=5)   	 
    if (u<=envlpPosStrain(i+1))
	    k = (envlpPosDamgdStress(i+1)-envlpPosDamgdStress(i))/(envlpPosStrain(i+1)-envlpPosStrain(i));
		f = envlpPosDamgdStress(i) + (u-envlpPosStrain(i))*k;
    end
	i = i+1;
end      

if (k==0.0)
    k = (envlpPosDamgdStress(6) - envlpPosDamgdStress(5))/(envlpPosStrain(6) - envlpPosStrain(5));
	f = envlpPosDamgdStress(6) + k*(u-envlpPosStrain(6));
end