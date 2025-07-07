% function [lowTstateStrain,lowTstateStress,hghTstateStrain,hghTstateStress,TmaxStrainDmnd,gammaFUsed, ...
%           envlpNegDamgdStress,gammaKUsed,kElasticPosDamgd,TminStrainDmnd,envlpPosDamgdStress, ...
%           kElasticNegDamgd,Tstate] = ...
%           getstate(u,du,CstrainRate,Tstate,lowTstateStrain,lowTstateStress,hghTstateStrain,hghTstateStress, ...
%           envlpPosStrain,envlpPosStress,Cstrain,TmaxStrainDmnd,uMaxDamgd,uMinDamgd,CgammaF,envlpNegStrain,envlpNegStress, ...
%           Cstress,CgammaK,kElasticPos,TminStrainDmnd,kElasticNeg,...
%           gammaFUsed,envlpNegDamgdStress,gammaKUsed,kElasticPosDamgd,envlpPosDamgdStress,kElasticNegDamgd)
function [lowTstateStrain,lowTstateStress,hghTstateStrain,hghTstateStress,TmaxStrainDmnd,gammaPosFUsed,gammaNegFUsed, ...
          envlpNegDamgdStress,gammaPosKUsed,gammaNegKUsed,kElasticPosDamgd,TminStrainDmnd,envlpPosDamgdStress, ...
          kElasticNegDamgd,Tstate] = ...
          getstate(u,du,CstrainRate,Tstate,lowTstateStrain,lowTstateStress,hghTstateStrain,hghTstateStress, ...
          envlpPosStrain,envlpPosStress,Cstrain,TmaxStrainDmnd,uMaxDamgd,uMinDamgd,CgammaPosF,CgammaNegF,envlpNegStrain,envlpNegStress, ...
          Cstress,CgammaPosK,CgammaNegK,kElasticPos,TminStrainDmnd,kElasticNeg,...
          gammaPosFUsed,gammaNegFUsed,envlpNegDamgdStress,gammaPosKUsed,gammaNegKUsed,kElasticPosDamgd,envlpPosDamgdStress,kElasticNegDamgd)      
    %getstate(Tstrain,dstrain)
    %==========================================================================
    % File Name: getstate.m
    % Description: Define the current state using trial strain and strain rate. 
    %
    %                                 Prepared by Jiazhen Leng (jleng1@jhu.edu)
    %                                                 Johns Hopkins University
    % Modified By Padilla-Llano (dapadill@vt.edu) - Dec 2014
    % Includes different damage rules for Positive and Negative Loading
    % directions for K and F
    %==========================================================================
    % cid, cis and newState are local variables
    cid = 0;
    cis = 0;
    newState = 0;
    % increment strain and strain rate differ in sign
    if (du*CstrainRate<=0.0)
        cid = 1;
    end
    % Three conditions imply the change of state
    if (u<lowTstateStrain || u>hghTstateStrain || cid)
        if (Tstate == 0) % It was Linear (Tstate=0) Response and Coming Into State 1 or 2
            if (u>hghTstateStrain)
                cis = 1;
                newState = 1;
                lowTstateStrain = envlpPosStrain(1);
                lowTstateStress = envlpPosStress(1);
                hghTstateStrain = envlpPosStrain(6);
                hghTstateStress = envlpPosStress(6);
            elseif (u<lowTstateStrain)                
                    cis = 1;
                    newState = 2;
                    lowTstateStrain = envlpNegStrain(6);
                    lowTstateStress = envlpNegStress(6);
                    hghTstateStrain = envlpNegStrain(1);
                    hghTstateStress = envlpNegStress(1);                
            end
        elseif (Tstate == 1 && du<0.0) % It was over Positive Envelope (State 1) and unloads
            cis = 1;
            if (Cstrain>TmaxStrainDmnd) 
                TmaxStrainDmnd = u - du;
            end
            if (TmaxStrainDmnd<uMaxDamgd)
                TmaxStrainDmnd = uMaxDamgd;
            end    
            if (u<uMinDamgd)
                newState = 2;
%                 gammaFUsed = CgammaF;                
%                 for i = 1:6
%                     envlpNegDamgdStress(i) = envlpNegStress(i)*(1.0-gammaFUsed);                    
%                 end
                gammaNegFUsed = CgammaNegF;
                for i = 1:6                    
                    envlpNegDamgdStress(i) = envlpNegStress(i)*(1.0-gammaNegFUsed);
                end
                lowTstateStrain = envlpNegStrain(6);
                lowTstateStress = envlpNegStress(6);
                hghTstateStrain = envlpNegStrain(1);
                hghTstateStress = envlpNegStress(1);
            else
                newState = 3;
                lowTstateStrain = uMinDamgd;
%                 gammaFUsed = CgammaF;    
%                 for i = 1:6
%                     envlpNegDamgdStress(i) = envlpNegStress(i)*(1.0-gammaFUsed);
%                 end
                gammaNegFUsed = CgammaNegF;    
                for i = 1:6                    
                    envlpNegDamgdStress(i) = envlpNegStress(i)*(1.0-gammaNegFUsed);
                end
                % call negEnvlpStress(u,envlpNegDamgdStress,envlpNegStrain)
                lowTstateStress = negEnvlpStress(uMinDamgd,envlpNegDamgdStress,envlpNegStrain);
                hghTstateStrain = Cstrain;
                hghTstateStress = Cstress;
            end
%             gammaKUsed = CgammaK;            
%             kElasticPosDamgd = kElasticPos*(1.0-gammaKUsed);
            gammaPosKUsed = CgammaPosK;
            kElasticPosDamgd = kElasticPos*(1.0-gammaPosKUsed);
        elseif (Tstate == 2 && du>0.0) % It was over Negative Envelope (State 2) and unloads
            cis = 1;
            if (Cstrain<TminStrainDmnd)
                TminStrainDmnd = Cstrain;
            end
            if (TminStrainDmnd>uMinDamgd) 
                TminStrainDmnd = uMinDamgd;
            end
            if (u>uMaxDamgd) 
                newState = 1;
%                 gammaFUsed = CgammaF;
%                 for i = 1:6
%                     envlpPosDamgdStress(i) = envlpPosStress(i)*(1.0-gammaFUsed);
%                 end
                gammaPosFUsed = CgammaPosF;
                for i = 1:6
                    envlpPosDamgdStress(i) = envlpPosStress(i)*(1.0-gammaPosFUsed);
                end
                lowTstateStrain = envlpPosStrain(1);
                lowTstateStress = envlpPosStress(1);
                hghTstateStrain = envlpPosStrain(6);
                hghTstateStress = envlpPosStress(6);
            else
                newState = 4;
                lowTstateStrain = Cstrain;
                lowTstateStress = Cstress;
                hghTstateStrain = uMaxDamgd;
%                 gammaFUsed = CgammaF;
%                 for i = 1:6
%                     envlpPosDamgdStress(i) = envlpPosStress(i)*(1.0-gammaFUsed);
%                 end
                gammaPosFUsed = CgammaPosF;
                for i = 1:6
                    envlpPosDamgdStress(i) = envlpPosStress(i)*(1.0-gammaPosFUsed);
                end
                % call posEnvlpStress(u,envlpPosDamgdStress,envlpPosStrain)
                hghTstateStress = posEnvlpStress(uMaxDamgd,envlpPosDamgdStress,envlpPosStrain);
            end
%             gammaKUsed = CgammaK;
%             kElasticNegDamgd = kElasticNeg*(1.0-gammaKUsed);
            gammaNegKUsed = CgammaNegK;
            kElasticNegDamgd = kElasticNeg*(1.0-gammaNegKUsed);
        elseif (Tstate ==3) % It was over UnloadingPos-ReloadingNeg (State 3) and...
            if (u<lowTstateStrain) % ... Continues Loading over State 2
                cis = 1;
                newState = 2;
                lowTstateStrain = envlpNegStrain(6);
                hghTstateStrain = envlpNegStrain(1);
                lowTstateStress = envlpNegDamgdStress(6);
                hghTstateStress = envlpNegDamgdStress(1);
            elseif (u>uMaxDamgd && du>0.0) % ... Unloads drastically to State 1
                cis = 1;
                newState = 1;
                lowTstateStrain = envlpPosStrain(1);
                lowTstateStress = envlpPosStress(1);
                hghTstateStrain = envlpPosStrain(6);
                hghTstateStress = envlpPosStress(6);
            elseif (du>0.0) % ... Unloads Slowly And goes into UnloadingNeg-ReloadingPos (State 4)
                cis = 1;
                newState = 4;
                lowTstateStrain = Cstrain;
                lowTstateStress = Cstress;
                hghTstateStrain = uMaxDamgd;
%                 gammaFUsed = CgammaF;
%                 for i = 1:6
%                     envlpPosDamgdStress(i) = envlpPosStress(i)*(1.0-gammaFUsed);
%                 end
                gammaPosFUsed = CgammaPosF;
                for i = 1:6
                    envlpPosDamgdStress(i) = envlpPosStress(i)*(1.0-gammaPosFUsed);
                end
                % call posEnvlpStress(u,envlpPosDamgdStress,envlpPosStrain)
                hghTstateStress = posEnvlpStress(uMaxDamgd,envlpPosDamgdStress,envlpPosStrain);
%                 gammaKUsed = CgammaK;
%                 kElasticNegDamgd = kElasticNeg*(1.0-gammaKUsed);
                gammaNegKUsed = CgammaNegK;
                kElasticNegDamgd = kElasticNeg*(1.0-gammaNegKUsed);
            end                
        elseif (Tstate == 4) % It was over UnloadingNeg-ReloadingPos (State 4) and...
            if (u>hghTstateStrain) % ... Continues Loading over State 1
                cis = 1;
                newState = 1;
                lowTstateStrain = envlpPosStrain(1);
                lowTstateStress = envlpPosDamgdStress(1);
                hghTstateStrain = envlpPosStrain(6);
                hghTstateStress = envlpPosDamgdStress(6);
            elseif (u<uMinDamgd && du <0.0) % ... Unloads drastically to State 2
                cis = 1;
                newState = 2;
                lowTstateStrain = envlpNegStrain(6);
                lowTstateStress = envlpNegDamgdStress(6);
                hghTstateStrain = envlpNegStrain(1);
                hghTstateStress = envlpNegDamgdStress(1);
            elseif (du<0.0) % ... Unloads Slowly And goes into UnloadingPos-ReloadingNeg (State 3)
                cis = 1;
                newState = 3;
                lowTstateStrain = uMinDamgd;
%                 gammaFUsed = CgammaF;         
%                 for i = 1:6
%                     envlpNegDamgdStress(i) = envlpNegStress(i)*(1.0-gammaFUsed);
%                 end
                gammaNegFUsed = CgammaNegF;         
                for i = 1:6
                    envlpNegDamgdStress(i) = envlpNegStress(i)*(1.0-gammaNegFUsed);
                end
                % call negEnvlpStress(u,envlpNegDamgdStress,envlpNegStrain)
                lowTstateStress = negEnvlpStress(uMinDamgd,envlpNegDamgdStress,envlpNegStrain);
                hghTstateStrain = Cstrain;
                hghTstateStress = Cstress;    
%                 gammaKUsed = CgammaK;
%                 kElasticPosDamgd = kElasticPos*(1.0-gammaKUsed);
                gammaPosKUsed = CgammaPosK;
                kElasticPosDamgd = kElasticPos*(1.0-gammaPosKUsed);
            end
        end
    end
    
    if (cis) 
        Tstate = newState;
    end
end
 