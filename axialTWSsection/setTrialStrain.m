% function [Tstate,Tenergy,Tstrain,lowTstateStrain,hghTstateStrain,lowTstateStress,hghTstateStress,...
%           TgammaF,TgammaK,TgammaD,dstrain,Ttangent,Tstress,state3Strain,state3Stress,...
%           state4Strain,state4Stress,kunload,elasticStrainEnergy,TminStrainDmnd,TmaxStrainDmnd,gammaKUsed,gammaFUsed,...
%           kElasticPosDamgd,kElasticNegDamgd,envlpPosDamgdStress,envlpNegDamgdStress,TnCycle] = ...          
%           setTrialStrain(strain,CstrainRate,Cstate,Cenergy,lowCstateStrain,hghCstateStrain,lowCstateStress,hghCstateStress,...
%           CminStrainDmnd,CmaxStrainDmnd,CgammaF,CgammaK,CgammaD,envlpPosStress,envlpPosStrain,...
%           kElasticPosDamgd,kElasticNegDamgd,state3Strain,state3Stress,kunload,state4Strain,state4Stress,...
%           Cstrain,uMaxDamgd,uMinDamgd,envlpNegStrain,envlpNegStress,kElasticPos,kElasticNeg,Cstress,DmgCyc,...
%           CnCycle,energyCapacity,MDL,...
%           Tstate,Tenergy,Tstrain,lowTstateStrain,hghTstateStrain,lowTstateStress,hghTstateStress,...
%           TgammaF,TgammaK,TgammaD,dstrain,Ttangent,Tstress,...
%           elasticStrainEnergy,TminStrainDmnd,TmaxStrainDmnd,gammaKUsed,gammaFUsed,...
%           envlpPosDamgdStress,envlpNegDamgdStress,TnCycle)
function [Tstate,Tenergy,Tstrain,lowTstateStrain,hghTstateStrain,lowTstateStress,hghTstateStress,...
          TgammaPosF,TgammaNegF,TgammaPosK,TgammaNegK,TgammaPosD,TgammaNegD,dstrain,Ttangent,Tstress,state3Strain,state3Stress,...
          state4Strain,state4Stress,kunload,elasticStrainEnergy,TminStrainDmnd,TmaxStrainDmnd,gammaPosKUsed,gammaNegKUsed,gammaPosFUsed,gammaNegFUsed,...
          kElasticPosDamgd,kElasticNegDamgd,envlpPosDamgdStress,envlpNegDamgdStress,TnCycle] = ...          
          setTrialStrain(strain,CstrainRate,Cstate,Cenergy,lowCstateStrain,hghCstateStrain,lowCstateStress,hghCstateStress,...
          CminStrainDmnd,CmaxStrainDmnd,CgammaPosF,CgammaNegF,CgammaPosK,CgammaNegK,CgammaPosD,CgammaNegD,envlpPosStress,envlpPosStrain,...
          kElasticPosDamgd,kElasticNegDamgd,state3Strain,state3Stress,kunload,state4Strain,state4Stress,...
          Cstrain,uMaxDamgd,uMinDamgd,envlpNegStrain,envlpNegStress,kElasticPos,kElasticNeg,Cstress,DmgCyc,...
          CnCycle,energyCapacity,MDL,...
          Tstate,Tenergy,Tstrain,lowTstateStrain,hghTstateStrain,lowTstateStress,hghTstateStress,...
          TgammaPosF,TgammaNegF,TgammaPosK,TgammaNegK,TgammaPosD,TgammaNegD,dstrain,Ttangent,Tstress,...
          elasticStrainEnergy,TminStrainDmnd,TmaxStrainDmnd,gammaPosKUsed,gammaNegKUsed,gammaPosFUsed,gammaNegFUsed,...
          envlpPosDamgdStress,envlpNegDamgdStress,TnCycle)      
    %++++++++ Need to check if I forgot any input/output      
    %==========================================================================
    % File Name: setTrialStrain.m
    % Description: This is most complicated part. It sets the displacement or 
    %              strain demand at current step as trial state and categorize 
    %              the state using strain rate. Several subroutines are called.
    %
    %                                 Prepared by Jiazhen Leng (jleng1@jhu.edu)
    %                                                 Johns Hopkins University
    %==========================================================================
    % Accept converged state as trial, strain (can be displacement too) is the
    % value we would like it to achieve
    Tstate = Cstate;
    Tenergy = Cenergy;
    Tstrain = strain;
    lowTstateStrain = lowCstateStrain;
    hghTstateStrain = hghCstateStrain;
    lowTstateStress = lowCstateStress;
    hghTstateStress = hghCstateStress;
    TminStrainDmnd = CminStrainDmnd;
    TmaxStrainDmnd = CmaxStrainDmnd;
    
%     TgammaF = CgammaF;
%     TgammaK = CgammaK; 
%     TgammaD = CgammaD;
    
    TgammaPosF = CgammaPosF;
    TgammaPosK = CgammaPosK; 
    TgammaPosD = CgammaPosD;
    TgammaNegF = CgammaNegF;
    TgammaNegK = CgammaNegK; 
    TgammaNegD = CgammaNegD;

    % Delta strain defined as trial strain subtract converged strain
    dstrain = Tstrain - Cstrain;
    if (dstrain<1e-12 && dstrain>-1e-12)
        dstrain = 0.0;
    end
    
%     TperElong = CperElong;

    % Determine new state if there is a change in state
    %+++++++++ Need to add this, DONE! Be careful with check
%     [lowTstateStrain,lowTstateStress,hghTstateStrain,hghTstateStress,TmaxStrainDmnd,gammaFUsed, ...
%      envlpNegDamgdStress,gammaKUsed,kElasticPosDamgd,TminStrainDmnd,envlpPosDamgdStress, ...
%      kElasticNegDamgd,Tstate] = ...
%      getstate(Tstrain,dstrain,CstrainRate,Tstate,lowTstateStrain,lowTstateStress,hghTstateStrain,hghTstateStress, ...
%      envlpPosStrain,envlpPosStress,Cstrain,TmaxStrainDmnd,uMaxDamgd,uMinDamgd,CgammaF,envlpNegStrain,envlpNegStress, ...
%      Cstress,CgammaK,kElasticPos,TminStrainDmnd,kElasticNeg,...
%      gammaFUsed,envlpNegDamgdStress,gammaKUsed,kElasticPosDamgd,envlpPosDamgdStress,kElasticNegDamgd);
    
    [lowTstateStrain,lowTstateStress,hghTstateStrain,hghTstateStress,TmaxStrainDmnd,gammaPosFUsed,gammaNegFUsed, ...
     envlpNegDamgdStress,gammaPosKUsed,gammaNegKUsed,kElasticPosDamgd,TminStrainDmnd,envlpPosDamgdStress, ...
     kElasticNegDamgd,Tstate] = ...
     getstate(Tstrain,dstrain,CstrainRate,Tstate,lowTstateStrain,lowTstateStress,hghTstateStrain,hghTstateStress, ...
     envlpPosStrain,envlpPosStress,Cstrain,TmaxStrainDmnd,uMaxDamgd,uMinDamgd,CgammaPosF,CgammaNegF,envlpNegStrain,envlpNegStress, ...
     Cstress,CgammaPosK,CgammaNegK,kElasticPos,TminStrainDmnd,kElasticNeg,...
     gammaPosFUsed,gammaNegFUsed,envlpNegDamgdStress,gammaPosKUsed,gammaNegKUsed,kElasticPosDamgd,envlpPosDamgdStress,kElasticNegDamgd);      

    switch Tstate
        case 0
            Ttangent = envlpPosStress(1)/envlpPosStrain(1);
            Tstress = Ttangent*Tstrain;
        case 1
            %+++++++++ Need to add this, DONE
            Tstress = posEnvlpStress(strain,envlpPosDamgdStress,envlpPosStrain);
            %+++++++++ Need to add this, DONE
            Ttangent = posEnvlpTangent(strain,envlpPosDamgdStress,envlpPosStrain);
        case 2
            %+++++++++ Need to add this, DONE
            Ttangent = negEnvlpTangent(strain,envlpNegDamgdStress,envlpNegStrain);
            %+++++++++ Need to add this, DONE
            Tstress = negEnvlpStress(strain,envlpNegDamgdStress,envlpNegStrain);
        case 3
            if (hghTstateStrain<0.0)
                kunload = kElasticNegDamgd;
            else
                kunload = kElasticPosDamgd;
            end	
            state3Strain(1) = lowTstateStrain;
            state3Strain(4) = hghTstateStrain;
            state3Stress(1) = lowTstateStress;
            state3Stress(4) = hghTstateStress;
            
%             TperElong = -(state3Stress(4) - kunload*state3Strain(4))/kunload;
            
            %+++++++++ Need to add this, DONE
            [state3Strain,state3Stress] = ...
             getstate3mod(state3Strain,state3Stress,kunload,kElasticNegDamgd,lowTstateStrain,lowTstateStress,TminStrainDmnd, ...
             envlpNegStrain,envlpNegDamgdStress,hghTstateStrain,hghTstateStress,MDL);
            %+++++++++ Need to add this, DONE
            Ttangent = Envlp3Tangent(state3Strain,state3Stress,strain);
            %+++++++++ Need to add this, DONE
            Tstress = Envlp3Stress(state3Strain,state3Stress,strain);
        case 4
            if (lowTstateStrain<0.0)
                kunload = kElasticNegDamgd;
            else
                kunload = kElasticPosDamgd;
            end	
            state4Strain(1) = lowTstateStrain;
            state4Strain(4) = hghTstateStrain;
            state4Stress(1) = lowTstateStress;
            state4Stress(4) = hghTstateStress;
                                   
            %+++++++++ Need to add this, DONE
            [state4Strain,state4Stress] = ...
             getstate4mod5(state4Strain,state4Stress,kunload,kElasticPosDamgd,lowTstateStrain,lowTstateStress,TmaxStrainDmnd, ...
             envlpPosStrain,envlpPosDamgdStress,hghTstateStrain,hghTstateStress,MDL);
%              getstate4mod5(state4Strain,state4Stress,kunload,kElasticPosDamgd,lowTstateStrain,lowTstateStress,TmaxStrainDmnd, ...
%              envlpPosStrain,envlpPosDamgdStress,hghTstateStrain,hghTstateStress,MDL);
            %+++++++++ Need to add this, DONE
            Ttangent = Envlp4Tangent(state4Strain,state4Stress,strain);
            %+++++++++ Need to add this, DONE
            Tstress = Envlp4Stress(state4Strain,state4Stress,strain);
    end

    % denergy is a local variable in this subroutine, the increment of elastic
    % strain energy
    denergy = 0.5*(Tstress+Cstress)*dstrain;
    if (Tstrain>0.0)
        elasticStrainEnergy = 0.5*Tstress/kElasticPosDamgd*Tstress;
    else
        elasticStrainEnergy = 0.5*Tstress/kElasticNegDamgd*Tstress;
    end

    Tenergy = Cenergy + denergy;
    %+++++++++ Need to add this, DONE
%     [TnCycle,TgammaK,TgammaD,TgammaF] = ...
%      updateDmg(Tstrain,dstrain,TmaxStrainDmnd,TminStrainDmnd,envlpPosStrain,envlpNegStrain, ...
%      CnCycle,Tenergy,energyCapacity,DmgCyc,elasticStrainEnergy,envlpPosDamgdStress,envlpNegDamgdStress, ...
%      kElasticPos,kElasticNeg,TnCycle,TgammaK,TgammaD,TgammaF,MDL);
    
    [TnCycle,TgammaPosK,TgammaNegK,TgammaPosD,TgammaNegD,TgammaPosF,TgammaNegF] = ...
     updateDmg(Tstrain,dstrain,TmaxStrainDmnd,TminStrainDmnd,envlpPosStrain,envlpNegStrain, ...
     CnCycle,Tenergy,energyCapacity,DmgCyc,elasticStrainEnergy,envlpPosDamgdStress,envlpNegDamgdStress, ...
     kElasticPos,kElasticNeg,TnCycle,TgammaPosK,TgammaNegK,TgammaPosD,TgammaNegD,TgammaPosF,TgammaNegF,MDL);
end