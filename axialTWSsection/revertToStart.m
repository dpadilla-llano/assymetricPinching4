% function [Cstate,Cstrain,Cstress,CstrainRate,lowCstateStrain,lowCstateStress,hghCstateStrain,hghCstateStress, ...
%           CminStrainDmnd,CmaxStrainDmnd,Cenergy,CgammaK,CgammaD,CgammaF,CnCycle, ...
%           Ttangent,dstrain,gammaKUsed,gammaFUsed,kElasticPosDamgd,kElasticNegDamgd,uMaxDamgd,uMinDamgd] = ...
%           revertToStart(envlpPosStrain,envlpPosStress,envlpNegStrain,envlpNegStress,kElasticPos,kElasticNeg)
function [Cstate,Cstrain,Cstress,CstrainRate,lowCstateStrain,lowCstateStress,hghCstateStrain,hghCstateStress, ...
          CminStrainDmnd,CmaxStrainDmnd,Cenergy,CgammaPosK,CgammaNegK,CgammaPosD,CgammaNegD,CgammaPosF,CgammaNegF,CnCycle, ...
          Ttangent,dstrain,gammaPosKUsed,gammaNegKUsed,gammaPosFUsed,gammaNegFUsed,kElasticPosDamgd,kElasticNegDamgd,uMaxDamgd,uMinDamgd] = ...
          revertToStart(envlpPosStrain,envlpPosStress,envlpNegStrain,envlpNegStress,kElasticPos,kElasticNeg)      
%==========================================================================
% File Name: revertToStart.m
% Description: For the first step calculation, use this to get previous 
%              step information. Actually it is more like IC here. 
%
%                                 Prepared by Jiazhen Leng (jleng1@jhu.edu)
%                                                 Johns Hopkins University
%==========================================================================
Cstate = 0;
Cstrain = 0.0;
Cstress = 0.0;
CstrainRate = 0.0;
lowCstateStrain = envlpNegStrain(1);
lowCstateStress = envlpNegStress(1);
hghCstateStrain = envlpPosStrain(1);
hghCstateStress = envlpPosStress(1);
CminStrainDmnd = envlpNegStrain(2);
CmaxStrainDmnd = envlpPosStrain(2);
Cenergy = 0.0;

% CgammaK = 0.0;
% CgammaD = 0.0;
% CgammaF = 0.0;

CgammaPosK = 0.0;  
CgammaPosD = 0.0;  
CgammaPosF = 0.0;  
CgammaNegK = 0.0;  
CgammaNegD = 0.0;  
CgammaNegF = 0.0;

CnCycle = 0.0;

Ttangent = envlpPosStress(1)/envlpPosStrain(1);
dstrain = 0.0;   

% gammaKUsed = 0.0;
% gammaFUsed = 0.0;

gammaPosKUsed = 0.0;  
gammaPosFUsed = 0.0;  
gammaNegKUsed = 0.0;  
gammaNegFUsed = 0.0;  

kElasticPosDamgd = kElasticPos;
kElasticNegDamgd = kElasticNeg;
uMaxDamgd = CmaxStrainDmnd;
uMinDamgd = CminStrainDmnd;

% CperElong = 0.0;
