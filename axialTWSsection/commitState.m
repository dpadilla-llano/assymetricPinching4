% function [Cstate,CstrainRate,lowCstateStrain,lowCstateStress,hghCstateStrain,hghCstateStress,CminStrainDmnd,CmaxStrainDmnd, ...
%           Cenergy,Cstress,Cstrain,CgammaK,CgammaD,CgammaF,kElasticPosDamgd,kElasticNegDamgd,uMaxDamgd,uMinDamgd, ...
%           envlpPosDamgdStress,envlpNegDamgdStress,CnCycle] = ...
%           commitState(Tstate,dstrain,TstrainRate,lowTstateStrain,lowTstateStress,hghTstateStrain,hghTstateStress, ...
%           TminStrainDmnd,TmaxStrainDmnd,Tenergy,Tstress,Tstrain,TgammaK,TgammaD,TgammaF,kElasticPos,kElasticNeg, ...
%           gammaKUsed,gammaFUsed,envlpPosStress,envlpNegStress,TnCycle)
function [Cstate,CstrainRate,lowCstateStrain,lowCstateStress,hghCstateStrain,hghCstateStress,CminStrainDmnd,CmaxStrainDmnd, ...
          Cenergy,Cstress,Cstrain,CgammaPosK,CgammaNegK,CgammaPosD,CgammaNegD,CgammaPosF,CgammaNegF,kElasticPosDamgd,kElasticNegDamgd,uMaxDamgd,uMinDamgd, ...
          envlpPosDamgdStress,envlpNegDamgdStress,CnCycle,CperElong] = ...
          commitState(Tstate,dstrain,TstrainRate,lowTstateStrain,lowTstateStress,hghTstateStrain,hghTstateStress, ...
          TminStrainDmnd,TmaxStrainDmnd,Tenergy,Tstress,Tstrain,TgammaPosK,TgammaNegK,TgammaPosD,TgammaNegD,TgammaPosF,TgammaNegF,kElasticPos,kElasticNeg, ...
          gammaPosKUsed,gammaNegKUsed,gammaPosFUsed,gammaNegFUsed,envlpPosStress,envlpNegStress,TnCycle,CgammaPosK,CgammaNegK,CgammaPosD,CgammaNegD,CgammaPosF,CgammaNegF)      
    %==========================================================================
    % File Name: commitState.m
    % Description: The trial state variables will be finalized here as a 
    %              converged step. 
    %
    %                                 Prepared by Jiazhen Leng (jleng1@jhu.edu)
    %                                                 Johns Hopkins University
    %==========================================================================
    Cstate = Tstate;

    if (dstrain>1e-12||dstrain<-(1e-12))
        CstrainRate = dstrain;
    else
        CstrainRate = TstrainRate;
    end

    lowCstateStrain = lowTstateStrain;
    lowCstateStress = lowTstateStress;
    hghCstateStrain = hghTstateStrain;
    hghCstateStress = hghTstateStress;
    CminStrainDmnd = TminStrainDmnd;
    CmaxStrainDmnd = TmaxStrainDmnd;
    Cenergy = Tenergy;

    Cstress = Tstress;
    Cstrain = Tstrain;

%     CgammaK = TgammaK;
%     CgammaD = TgammaD;
%     CgammaF = TgammaF;

    CgammaPosK = TgammaPosK;
    CgammaPosD = TgammaPosD;
    CgammaPosF = TgammaPosF;
    CgammaNegK = TgammaNegK;
    CgammaNegD = TgammaNegD;
    CgammaNegF = TgammaNegF;
    
%     CgammaPosK = max([TgammaPosK,CgammaPosK]);
%     CgammaPosD = max([TgammaPosD,CgammaPosD]);
%     CgammaPosF = max([TgammaPosF,CgammaPosF]);
%     CgammaNegK = max([TgammaNegK,CgammaNegK]);
%     CgammaNegD = max([TgammaNegD,CgammaNegD]);
%     CgammaNegF = max([TgammaNegF,CgammaNegF]);

    % Define adjusted strength and stiffness parameters
%     kElasticPosDamgd = kElasticPos*(1 - gammaKUsed);
%     kElasticNegDamgd = kElasticNeg*(1 - gammaKUsed);
% 
%     uMaxDamgd = TmaxStrainDmnd*(1 + CgammaD);   
%     uMinDamgd = TminStrainDmnd*(1 + CgammaD);
% 
%     envlpPosDamgdStress = envlpPosStress*(1-gammaFUsed);
%     envlpNegDamgdStress = envlpNegStress*(1-gammaFUsed);

    kElasticPosDamgd = kElasticPos*(1 - gammaPosKUsed);
    kElasticNegDamgd = kElasticNeg*(1 - gammaNegKUsed);
    
    uMaxDamgd = TmaxStrainDmnd*(1 + CgammaPosD);   
    uMinDamgd = TminStrainDmnd*(1 + CgammaNegD);
    
    envlpPosDamgdStress = envlpPosStress*(1-gammaPosFUsed);
    envlpNegDamgdStress = envlpNegStress*(1-gammaNegFUsed);

    CnCycle = TnCycle; % number of cycles of loading
    
%     CperElong = TperElong;

end
