% function [Tstate,TstrainRate,lowTstateStrain,lowTstateStress,hghTstateStrain,hghTstateStress,...
%           TminStrainDmnd,TmaxStrainDmnd,Tenergy,Tstrain,Tstress,TgammaD,TgammaK,TgammaF,TnCycle] = ...
%           revertToLastCommit(Cstate,CstrainRate,lowCstateStrain,lowCstateStress,hghCstateStrain,hghCstateStress, ...
%           CminStrainDmnd,CmaxStrainDmnd,Cenergy,Cstrain,Cstress,CgammaD,CgammaK,CgammaF,CnCycle)
function [Tstate,TstrainRate,lowTstateStrain,lowTstateStress,hghTstateStrain,hghTstateStress,...
          TminStrainDmnd,TmaxStrainDmnd,Tenergy,Tstrain,Tstress,TgammaPosD,TgammaNegD,TgammaPosK,TgammaNegK,TgammaPosF,TgammaNegF,TnCycle] = ...
          revertToLastCommit(Cstate,CstrainRate,lowCstateStrain,lowCstateStress,hghCstateStrain,hghCstateStress, ...
          CminStrainDmnd,CmaxStrainDmnd,Cenergy,Cstrain,Cstress,CgammaPosD,CgammaNegD,CgammaPosK,CgammaNegK,CgammaPosF,CgammaNegF,CnCycle)      
%==========================================================================
% File Name: revertToLastCommit.m
% Description: For the calculation of step other than first one, use this  
%              to get previous step information. 
%
%                                 Prepared by Jiazhen Leng (jleng1@jhu.edu)
%                                                 Johns Hopkins University
%==========================================================================
Tstate = Cstate;

TstrainRate = CstrainRate;

lowTstateStrain = lowCstateStrain;
lowTstateStress = lowCstateStress;
hghTstateStrain = hghCstateStrain;
hghTstateStress = hghCstateStress;
TminStrainDmnd = CminStrainDmnd;
TmaxStrainDmnd = CmaxStrainDmnd;
Tenergy = Cenergy;

Tstrain = Cstrain; 
Tstress = Cstress;

% TgammaD = CgammaD;
% TgammaK = CgammaK;
% TgammaF = CgammaF;

TgammaPosD = CgammaPosD;
TgammaPosK = CgammaPosK;
TgammaPosF = CgammaPosF;
TgammaNegD = CgammaNegD;
TgammaNegK = CgammaNegK;
TgammaNegF = CgammaNegF;

TnCycle = CnCycle;

% TperElong = CperElong;
