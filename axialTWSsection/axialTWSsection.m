function [FF,DD,EE,GGG] = axialTWSsection(MDL)
    %==========================================================================
    % File Name: Pinching4.m
    % Description: A replica of pinching4 material of OpenSees in MATLAB. There
    %              is no FEM linked with it, just one DOF. In this version, it
    %              has been modified as a function to be called by the main.
    %
    %                                 Prepared by Jiazhen Leng (jleng1@jhu.edu)
    %                                                 Johns Hopkins University
    %==========================================================================
    %========== Input Data File ===============================================
    % Orginial syntax of Pinching4 in OpenSees
    % uniaxialMaterial Pinching4 $matTag $ePf1 $ePd1 $ePf2 $ePd2 $ePf3 $ePd3 $ePf4 $ePd4 
    % <$eNf1 $eNd1 $eNf2 $eNd2 $eNf3 $eNd3 $eNf4 $eNd4> 
    % $rDispP $rForceP $uForceP 
    % <$rDispN $rForceN $uForceN> 
    % $gK1 $gK2 $gK3 $gK4 $gKLim $gD1 $gD2 $gD3 $gD4 $gDLim $gF1 $gF2 $gF3 $gF4 $gFLim $gE $dmgType

    % Note: I am setting all parameters here, since MATLAB doesn't have the 
    % overloaded constructor as C++ does. All variable names aren't changed 
    % from C++.

    % Read input parameters (all user specified for pinching4 in C++) from a
    % struct called MDL

    %========= Initialization =================================================
    % Note: Actually, these parameters are defined privately inside C++ class
    % pinching4, and thus are invisible to users. Another thing to note here is
    % the setting of damage type. Two are available 'cycle' or 'energy'. DmgCyc
    % is 0 or 1 for these two options

    %+++++ Additional backbone parameters
    envlpPosStrain = zeros(1,6);
    envlpPosStress = zeros(1,6);
    envlpNegStrain = zeros(1,6);
    envlpNegStress = zeros(1,6);
    %+++++ Additional damage parameters
    % Flag for indicating whether no. of cycles are to be used for damage calculation
    % zero means 'energy' type of damage, one means 'cycle' type
    if (strcmp(MDL.dmgtype,'energy'))
        DmgCyc = 0;
    else
        DmgCyc = 1;
    end
    % Number of cycles contributing to damage calculation
    TnCycle = 0.0;
    CnCycle = 0.0;
    %+++++ Additional unloading and reloading parameters
    state3Stress = zeros(1,6);
    state3Strain = zeros(1,6);
    state4Stress = zeros(1,6);
    state4Strain = zeros(1,6);
    envlpPosDamgdStress = zeros(1,6);
    envlpNegDamgdStress = zeros(1,6); 
    %+++++ Trial state variables
    Tstress = 0.0;
    Tstrain = 0.0;
    Ttangent = 0.0;
    %+++++ Converged material history parameters
    Cstate = 0;
    Cstrain = 0.0;
    Cstress = 0.0;  
    CstrainRate = 0.0;  
    lowCstateStrain = 0.0;  
    lowCstateStress = 0.0;  
    hghCstateStrain = 0.0;  
    hghCstateStress = 0.0;  
    CminStrainDmnd = 0.0;  
    CmaxStrainDmnd = 0.0;  
    Cenergy = 0.0;  
    
%     CgammaK = 0.0;  
%     CgammaD = 0.0;  
%     CgammaF = 0.0;  
%     gammaKUsed = 0.0;  
%     gammaFUsed = 0.0;
    
    CgammaPosK = 0.0;  
    CgammaPosD = 0.0;  
    CgammaPosF = 0.0;  
    CgammaNegK = 0.0;  
    CgammaNegD = 0.0;  
    CgammaNegF = 0.0;
    gammaPosKUsed = 0.0;  
    gammaPosFUsed = 0.0;  
    gammaNegKUsed = 0.0;  
    gammaNegFUsed = 0.0;  
    
%     CperElong = 0.0;

    %+++++ Trial material history parameters
    Tstate = 0;
    dstrain = 0.0;
    TstrainRate = 0.0;
    lowTstateStrain = 0.0;
    lowTstateStress = 0.0;
    hghTstateStrain = 0.0;
    hghTstateStress = 0.0;
    TminStrainDmnd = 0.0;
    TmaxStrainDmnd = 0.0;
    Tenergy = 0.0;
    
%     TgammaK = 0.0;
%     TgammaD = 0.0;
%     TgammaF = 0.0;
    
    TgammaPosK = 0.0;
    TgammaPosD = 0.0;
    TgammaPosF = 0.0;
    TgammaNegK = 0.0;
    TgammaNegD = 0.0;
    TgammaNegF = 0.0;
    
%     TperElong = 0.0;
    
    %+++++ Strength and stiffness parameters
    kElasticPos = 0.0;
    kElasticNeg = 0.0;
    kElasticPosDamgd = 0.0;
    kElasticNegDamgd = 0.0;
    uMaxDamgd = 0.0;
    uMinDamgd = 0.0;
    %+++++ Energy parameters
    energyCapacity = 0.0;
    kunload = 0.0;
    elasticStrainEnergy = 0.0;
    %+++++ Force vector
    force = zeros(length(MDL.d),1);
    %+++++ Displacement vector
    displ = zeros(length(MDL.d),1);
    %+++++ Energy vector
    energ = zeros(length(MDL.d),1);

    %========= Calculate the Envelope =========================================
    [envlpPosStrain,envlpPosStress,envlpNegStrain,envlpNegStress,kElasticPos,kElasticNeg,energyCapacity] = SetEnvelop(MDL);

    %========= Compute the Force at Each Displacement Step ====================
    for i = 1:length(MDL.d)
%         if ((i == 1217) || (i == 1257) || (i == 1259) || (i == 1296) || (i == 1332) || (i == 1375) || (i == 1510) || (i == 1561) )
%            1; 
%         end
        if ((i == 1258) || (i == 1296) || (i == 1376) || (i==1447) || (i == 1510) || (i == 1561) )
           1; 
        end
        
        % Step 1: retrieve last step information
        if (i == 1)
            % revert to start values
%             [Cstate,Cstrain,Cstress,CstrainRate,lowCstateStrain,lowCstateStress,hghCstateStrain,hghCstateStress, ...
%              CminStrainDmnd,CmaxStrainDmnd,Cenergy,CgammaK,CgammaD,CgammaF,CnCycle, ...
%              Ttangent,dstrain,gammaKUsed,gammaFUsed,kElasticPosDamgd,kElasticNegDamgd,uMaxDamgd,uMinDamgd] = ...
%              revertToStart(envlpPosStrain,envlpPosStress,envlpNegStrain,envlpNegStress,kElasticPos,kElasticNeg);
            
            [Cstate,Cstrain,Cstress,CstrainRate,lowCstateStrain,lowCstateStress,hghCstateStrain,hghCstateStress, ...
             CminStrainDmnd,CmaxStrainDmnd,Cenergy,CgammaPosK,CgammaNegK,CgammaPosD,CgammaNegD,CgammaPosF,CgammaNegF,CnCycle, ...
             Ttangent,dstrain,gammaPosKUsed,gammaNegKUsed,gammaPosFUsed,gammaNegFUsed,kElasticPosDamgd,kElasticNegDamgd,uMaxDamgd,uMinDamgd] = ...
             revertToStart(envlpPosStrain,envlpPosStress,envlpNegStrain,envlpNegStress,kElasticPos,kElasticNeg); 
        else
            % revert to last converged/committed step
%             [Tstate,TstrainRate,lowTstateStrain,lowTstateStress,hghTstateStrain,hghTstateStress,...
%              TminStrainDmnd,TmaxStrainDmnd,Tenergy,Tstrain,Tstress,TgammaD,TgammaK,TgammaF,TnCycle] = ...
%              revertToLastCommit(Cstate,CstrainRate,lowCstateStrain,lowCstateStress,hghCstateStrain,hghCstateStress, ...
%              CminStrainDmnd,CmaxStrainDmnd,Cenergy,Cstrain,Cstress,CgammaD,CgammaK,CgammaF,CnCycle);
         
            [Tstate,TstrainRate,lowTstateStrain,lowTstateStress,hghTstateStrain,hghTstateStress,...
             TminStrainDmnd,TmaxStrainDmnd,Tenergy,Tstrain,Tstress,TgammaPosD,TgammaNegD,TgammaPosK,TgammaNegK,TgammaPosF,TgammaNegF,TnCycle] = ...
             revertToLastCommit(Cstate,CstrainRate,lowCstateStrain,lowCstateStress,hghCstateStrain,hghCstateStress, ...
             CminStrainDmnd,CmaxStrainDmnd,Cenergy,Cstrain,Cstress,CgammaPosD,CgammaNegD,CgammaPosK,CgammaNegK,CgammaPosF,CgammaNegF,CnCycle);      
        end

        % Step 2: set current trial step information, most complicated part
        % In this MATLAB specified displacement is the deformation/strain.
%         [Tstate,Tenergy,Tstrain,lowTstateStrain,hghTstateStrain,lowTstateStress,hghTstateStress,...
%          TgammaF,TgammaK,TgammaD,dstrain,Ttangent,Tstress,state3Strain,state3Stress,...
%          state4Strain,state4Stress,kunload,elasticStrainEnergy,TminStrainDmnd,TmaxStrainDmnd,gammaKUsed,gammaFUsed,...
%          kElasticPosDamgd,kElasticNegDamgd,envlpPosDamgdStress,envlpNegDamgdStress,TnCycle] = ...          
%          setTrialStrain(MDL.d(i),CstrainRate,Cstate,Cenergy,lowCstateStrain,hghCstateStrain,lowCstateStress,hghCstateStress,...
%          CminStrainDmnd,CmaxStrainDmnd,CgammaF,CgammaK,CgammaD,envlpPosStress,envlpPosStrain,...
%          kElasticPosDamgd,kElasticNegDamgd,state3Strain,state3Stress,kunload,state4Strain,state4Stress,...
%          Cstrain,uMaxDamgd,uMinDamgd,envlpNegStrain,envlpNegStress,kElasticPos,kElasticNeg,Cstress,DmgCyc,...
%          CnCycle,energyCapacity,MDL,...
%          Tstate,Tenergy,Tstrain,lowTstateStrain,hghTstateStrain,lowTstateStress,hghTstateStress,...
%          TgammaF,TgammaK,TgammaD,dstrain,Ttangent,Tstress,...
%          elasticStrainEnergy,TminStrainDmnd,TmaxStrainDmnd,gammaKUsed,gammaFUsed,...
%          envlpPosDamgdStress,envlpNegDamgdStress,TnCycle);
     
        [Tstate,Tenergy,Tstrain,lowTstateStrain,hghTstateStrain,lowTstateStress,hghTstateStress,...
         TgammaPosF,TgammaNegF,TgammaPosK,TgammaNegK,TgammaPosD,TgammaNegD,dstrain,Ttangent,Tstress,state3Strain,state3Stress,...
         state4Strain,state4Stress,kunload,elasticStrainEnergy,TminStrainDmnd,TmaxStrainDmnd,gammaPosKUsed,gammaNegKUsed,gammaPosFUsed,gammaNegFUsed,...
         kElasticPosDamgd,kElasticNegDamgd,envlpPosDamgdStress,envlpNegDamgdStress,TnCycle] = ...          
         setTrialStrain(MDL.d(i),CstrainRate,Cstate,Cenergy,lowCstateStrain,hghCstateStrain,lowCstateStress,hghCstateStress,...
         CminStrainDmnd,CmaxStrainDmnd,CgammaPosF,CgammaNegF,CgammaPosK,CgammaNegK,CgammaPosD,CgammaNegD,envlpPosStress,envlpPosStrain,...
         kElasticPosDamgd,kElasticNegDamgd,state3Strain,state3Stress,kunload,state4Strain,state4Stress,...
         Cstrain,uMaxDamgd,uMinDamgd,envlpNegStrain,envlpNegStress,kElasticPos,kElasticNeg,Cstress,DmgCyc,...
         CnCycle,energyCapacity,MDL,...
         Tstate,Tenergy,Tstrain,lowTstateStrain,hghTstateStrain,lowTstateStress,hghTstateStress,...
         TgammaPosF,TgammaNegF,TgammaPosK,TgammaNegK,TgammaPosD,TgammaNegD,dstrain,Ttangent,Tstress,...
         elasticStrainEnergy,TminStrainDmnd,TmaxStrainDmnd,gammaPosKUsed,gammaNegKUsed,gammaPosFUsed,gammaNegFUsed,...
         envlpPosDamgdStress,envlpNegDamgdStress,TnCycle);

        % Step 3: finish this current step information 
%         [Cstate,CstrainRate,lowCstateStrain,lowCstateStress,hghCstateStrain,hghCstateStress,CminStrainDmnd,CmaxStrainDmnd, ...
%          Cenergy,Cstress,Cstrain,CgammaK,CgammaD,CgammaF,kElasticPosDamgd,kElasticNegDamgd,uMaxDamgd,uMinDamgd, ...
%          envlpPosDamgdStress,envlpNegDamgdStress,CnCycle] = ...
%          commitState(Tstate,dstrain,TstrainRate,lowTstateStrain,lowTstateStress,hghTstateStrain,hghTstateStress, ...
%          TminStrainDmnd,TmaxStrainDmnd,Tenergy,Tstress,Tstrain,TgammaK,TgammaD,TgammaF,kElasticPos,kElasticNeg, ...
%          gammaKUsed,gammaFUsed,envlpPosStress,envlpNegStress,TnCycle);
        
        [Cstate,CstrainRate,lowCstateStrain,lowCstateStress,hghCstateStrain,hghCstateStress,CminStrainDmnd,CmaxStrainDmnd, ...
         Cenergy,Cstress,Cstrain,CgammaPosK,CgammaNegK,CgammaPosD,CgammaNegD,CgammaPosF,CgammaNegF,kElasticPosDamgd,kElasticNegDamgd,uMaxDamgd,uMinDamgd, ...
         envlpPosDamgdStress,envlpNegDamgdStress,CnCycle] = ...
         commitState(Tstate,dstrain,TstrainRate,lowTstateStrain,lowTstateStress,hghTstateStrain,hghTstateStress, ...
         TminStrainDmnd,TmaxStrainDmnd,Tenergy,Tstress,Tstrain,TgammaPosK,TgammaNegK,TgammaPosD,TgammaNegD,TgammaPosF,TgammaNegF,kElasticPos,kElasticNeg, ...
         gammaPosKUsed,gammaNegKUsed,gammaPosFUsed,gammaNegFUsed,envlpPosStress,envlpNegStress,TnCycle,CgammaPosK,CgammaNegK,CgammaPosD,CgammaNegD,CgammaPosF,CgammaNegF);

        % The returned stress/force of committed state is what we look for
        force(i) = Cstress; 
        displ(i) = Cstrain;
        energ(i) = Cenergy;
        GGG(i,:) = [gammaPosFUsed, CgammaPosF, gammaNegFUsed, CgammaNegF];
    end

    FF = force;
    DD = displ;
    EE = energ;

end