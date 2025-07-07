% function [TnCycle,TgammaK,TgammaD,TgammaF] = ...
%           updateDmg(strain,dstrain,TmaxStrainDmnd,TminStrainDmnd,envlpPosStrain,envlpNegStrain, ...
%           CnCycle,Tenergy,energyCapacity,DmgCyc,elasticStrainEnergy,envlpPosDamgdStress,envlpNegDamgdStress, ...
%           kElasticPos,kElasticNeg,TnCycle,TgammaK,TgammaD,TgammaF,MDL)
function [TnCycle,TgammaPosK,TgammaNegK,TgammaPosD,TgammaNegD,TgammaPosF,TgammaNegF] = ...
          updateDmg(strain,dstrain,TmaxStrainDmnd,TminStrainDmnd,envlpPosStrain,envlpNegStrain, ...
          CnCycle,Tenergy,energyCapacity,DmgCyc,elasticStrainEnergy,envlpPosDamgdStress,envlpNegDamgdStress, ...
          kElasticPos,kElasticNeg,TnCycle,TgammaPosK,TgammaNegK,TgammaPosD,TgammaNegD,TgammaPosF,TgammaNegF,MDL)      
    %==========================================================================
    % File Name: updateDmg.m
    % Description: This subroutine is used to update the damage parameters 
    %              after a trial state is set. 
    %
    %                                 Prepared by Jiazhen Leng (jleng1@jhu.edu)
    %                                                 Johns Hopkins University
    %==========================================================================
    % tes, umaxAbs and uultAbs are local variables
    tes = 0.0;
    umaxAbs = max([TmaxStrainDmnd -TminStrainDmnd]);
    uultAbs = max([envlpPosStrain(5) -envlpNegStrain(5)]);
    TnCycle = CnCycle + abs(dstrain)/(4*umaxAbs);

    if ((strain<uultAbs && strain>-uultAbs)&& Tenergy < energyCapacity)
    %     TgammaK = MDL.gammaK1*power((umaxAbs/uultAbs),MDL.gammaK3);
    %     TgammaD = MDL.gammaD1*power((umaxAbs/uultAbs),MDL.gammaD3);
    %     TgammaF = MDL.gammaF1*power((umaxAbs/uultAbs),MDL.gammaF3);
    % 
    %     if (Tenergy > elasticStrainEnergy && DmgCyc == 0)
    %         tes = ((Tenergy-elasticStrainEnergy)/energyCapacity);
    %         TgammaK = TgammaK + MDL.gammaK2*power(tes,MDL.gammaK4);
    %         TgammaD = TgammaD + MDL.gammaD2*power(tes,MDL.gammaD4);
    %         TgammaF = TgammaF + MDL.gammaF2*power(tes,MDL.gammaF4);
    %     elseif (DmgCyc == 1) 
    %         TgammaK = TgammaK + MDL.gammaK2*power(TnCycle,MDL.gammaK4);
    %         TgammaD = TgammaD + MDL.gammaD2*power(TnCycle,MDL.gammaD4);
    %         TgammaF = TgammaF + MDL.gammaF2*power(TnCycle,MDL.gammaF4);
    %     end       
    %     % kminP, kminN, kmin, gammaKLimEnv and k1 are local variables
    %     %kminP = (posEnvlpStress(TmaxStrainDmnd)/TmaxStrainDmnd);
    %     kminP = (posEnvlpStress(TmaxStrainDmnd,envlpPosDamgdStress,envlpPosStrain)/TmaxStrainDmnd);
    %     %kminN = (negEnvlpStress(TminStrainDmnd)/TminStrainDmnd);
    %     kminN = (negEnvlpStress(TminStrainDmnd,envlpNegDamgdStress,envlpNegStrain)/TminStrainDmnd);
    %     kmin = max([kminP/kElasticPos kminN/kElasticNeg]);
    %     gammaKLimEnv = max([0.0 (1.0-kmin)]);
    % 
    %     k1 = min([TgammaK MDL.gammaKLimit]);
    %     TgammaK = min([k1 gammaKLimEnv]);
    %     TgammaD = min([TgammaD MDL.gammaDLimit]);
    %     TgammaF = min([TgammaF MDL.gammaFLimit]);

        TgammaPosK = MDL.gammaPosK1*power((umaxAbs/uultAbs),MDL.gammaPosK3);
        TgammaPosD = MDL.gammaPosD1*power((umaxAbs/uultAbs),MDL.gammaPosD3);
        TgammaPosF = MDL.gammaPosF1*power((umaxAbs/uultAbs),MDL.gammaPosF3);
        TgammaNegK = MDL.gammaNegK1*power((umaxAbs/uultAbs),MDL.gammaNegK3);
        TgammaNegD = MDL.gammaNegD1*power((umaxAbs/uultAbs),MDL.gammaNegD3);
        TgammaNegF = MDL.gammaNegF1*power((umaxAbs/uultAbs),MDL.gammaNegF3);

        if (Tenergy > elasticStrainEnergy && DmgCyc == 0)
            tes = ((Tenergy-elasticStrainEnergy)/energyCapacity);
            TgammaPosK = TgammaPosK + MDL.gammaPosK2*power(tes,MDL.gammaPosK4);
            TgammaPosD = TgammaPosD + MDL.gammaPosD2*power(tes,MDL.gammaPosD4);
            TgammaPosF = TgammaPosF + MDL.gammaPosF2*power(tes,MDL.gammaPosF4);
            TgammaNegK = TgammaNegK + MDL.gammaNegK2*power(tes,MDL.gammaNegK4);
            TgammaNegD = TgammaNegD + MDL.gammaNegD2*power(tes,MDL.gammaNegD4);
            TgammaNegF = TgammaNegF + MDL.gammaNegF2*power(tes,MDL.gammaNegF4);                        
        elseif (DmgCyc == 1) 
            TgammaPosK = TgammaPosK + MDL.gammaPosK2*power(TnCycle,MDL.gammaPosK4);
            TgammaPosD = TgammaPosD + MDL.gammaPosD2*power(TnCycle,MDL.gammaPosD4);
            TgammaPosF = TgammaPosF + MDL.gammaPosF2*power(TnCycle,MDL.gammaPosF4);
            TgammaNegK = TgammaNegK + MDL.gammaNegK2*power(TnCycle,MDL.gammaNegK4);
            TgammaNegD = TgammaNegD + MDL.gammaNegD2*power(TnCycle,MDL.gammaNegD4);
            TgammaNegF = TgammaNegF + MDL.gammaNegF2*power(TnCycle,MDL.gammaNegF4);        
        end    
        
        gammaKLimEnvPos = max([0.0 (1.0-(((posEnvlpStress(TmaxStrainDmnd,envlpPosDamgdStress,envlpPosStrain)/TmaxStrainDmnd))/kElasticPos))]);
        gammaKLimEnvNeg = max([0.0 (1.0-(((negEnvlpStress(TminStrainDmnd,envlpNegDamgdStress,envlpNegStrain)/TminStrainDmnd))/kElasticNeg))]);
        
        TgammaPosK = min([min([TgammaPosK MDL.gammaPosKLimit]) gammaKLimEnvPos]);
        TgammaPosD = min([TgammaPosD MDL.gammaPosDLimit]);
        TgammaPosF = min([TgammaPosF MDL.gammaPosFLimit]);
        TgammaNegK = min([min([TgammaNegK MDL.gammaNegKLimit]) gammaKLimEnvNeg]);
        TgammaNegD = min([TgammaNegD MDL.gammaNegDLimit]);
        TgammaNegF = min([TgammaNegF MDL.gammaNegFLimit]);
        
%         TgammaPosK = min([TgammaPosK MDL.gammaPosKLimit]);
%         TgammaPosD = min([TgammaPosD MDL.gammaPosDLimit]);
%         TgammaPosF = min([TgammaPosF MDL.gammaPosFLimit]);
%         TgammaNegK = min([TgammaNegK MDL.gammaNegKLimit]);
%         TgammaNegD = min([TgammaNegD MDL.gammaNegDLimit]);
%         TgammaNegF = min([TgammaNegF MDL.gammaNegFLimit]);

    elseif (strain<uultAbs && strain>-uultAbs)
    %     % kminP, kminN, kmin, gammaKLimEnv and k1 are local variables
    %     kminP = (posEnvlpStress(TmaxStrainDmnd,envlpPosDamgdStress,envlpPosStrain)/TmaxStrainDmnd);
    %     kminN = (negEnvlpStress(TminStrainDmnd,envlpNegDamgdStress,envlpNegStrain)/TminStrainDmnd);
    %     kmin = max([kminP/kElasticPos kminN/kElasticNeg]);
    %     gammaKLimEnv = max([0.0 (1.0-kmin)]);
    % 
    %     TgammaK = min([MDL.gammaKLimit gammaKLimEnv]);
    %     TgammaD = min([TgammaD MDL.gammaDLimit]);
    %     TgammaF = min([TgammaF MDL.gammaFLimit]);
%         disp([num2str(strain) '|' num2str(uultAbs)]);
        gammaKLimEnvPos = max([0.0 (1.0-(((posEnvlpStress(TmaxStrainDmnd,envlpPosDamgdStress,envlpPosStrain)/TmaxStrainDmnd))/kElasticPos))]);
        gammaKLimEnvNeg = max([0.0 (1.0-(((negEnvlpStress(TminStrainDmnd,envlpNegDamgdStress,envlpNegStrain)/TminStrainDmnd))/kElasticNeg))]);
        
        TgammaPosK = min([gammaKLimEnvPos MDL.gammaPosKLimit]);
        TgammaPosD = min([TgammaPosD MDL.gammaPosDLimit]);
        TgammaPosF = min([TgammaPosF MDL.gammaPosFLimit]);
        TgammaNegK = min([gammaKLimEnvNeg MDL.gammaNegKLimit]);
        TgammaNegD = min([TgammaNegD MDL.gammaNegDLimit]);
        TgammaNegF = min([TgammaNegF MDL.gammaNegFLimit]);
    
%         TgammaPosK = min([TgammaPosK MDL.gammaPosKLimit]);
%         TgammaPosD = min([TgammaPosD MDL.gammaPosDLimit]);
%         TgammaPosF = min([TgammaPosF MDL.gammaPosFLimit]);
%         TgammaNegK = min([TgammaNegK MDL.gammaNegKLimit]);
%         TgammaNegD = min([TgammaNegD MDL.gammaNegDLimit]);
%         TgammaNegF = min([TgammaNegF MDL.gammaNegFLimit]);
    
    end
% disp(num2str((Tenergy-elasticStrainEnergy)/energyCapacity))
end