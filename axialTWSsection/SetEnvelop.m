function [envlpPosStrain,envlpPosStress,envlpNegStrain,envlpNegStress,kElasticPos,kElasticNeg,energyCapacity] = SetEnvelop(MDL)
    %==========================================================================
    % File Name: SetEnvelop.m
    % Description: Compute positive and negative envelop properties for 
    %              pinching4 material. 
    %
    %                                 Prepared by Jiazhen Leng (jleng1@jhu.edu)
    %                                                 Johns Hopkins University
    %==========================================================================
    % Define six points on the backbone curve of positive and negative branches
    kPos = MDL.stress1p/MDL.strain1p;
    kNeg = MDL.stress1n/MDL.strain1n;
    k = max([kPos kNeg]);
    if (MDL.strain1p > -1.0*MDL.strain1n)
        u = 1.0e-4*MDL.strain1p;
    else
        u = -1.0e-4*MDL.strain1n;
    end

    envlpPosStrain(1) = u;
    envlpPosStress(1) = u*k;
    envlpNegStrain(1) = -u;
    envlpNegStress(1) = -u*k;

    envlpPosStrain(2) = MDL.strain1p;
    envlpPosStrain(3) = MDL.strain2p;
    envlpPosStrain(4) = MDL.strain3p;
    envlpPosStrain(5) = MDL.strain4p;

    envlpNegStrain(2) = MDL.strain1n;
    envlpNegStrain(3) = MDL.strain2n;
    envlpNegStrain(4) = MDL.strain3n;
    envlpNegStrain(5) = MDL.strain4n;

    envlpPosStress(2) = MDL.stress1p;
    envlpPosStress(3) = MDL.stress2p;
    envlpPosStress(4) = MDL.stress3p;
    envlpPosStress(5) = MDL.stress4p;

    envlpNegStress(2) = MDL.stress1n;
    envlpNegStress(3) = MDL.stress2n;
    envlpNegStress(4) = MDL.stress3n;
    envlpNegStress(5) = MDL.stress4n;

    k1 = (MDL.stress4p - MDL.stress3p)/(MDL.strain4p - MDL.strain3p);
    k2 = (MDL.stress4n - MDL.stress3n)/(MDL.strain4n - MDL.strain3n);
    
    % Review this if desire to define the slopes to be decreasing linearly 
    % to zero after point 5
    envlpPosStrain(6) = 1e+6*MDL.strain4p;
    if (k1 > 0.0)
        envlpPosStress(6) = MDL.stress4p+k1*(envlpPosStrain(6) - MDL.strain4p);
    else
        envlpPosStress(6) = MDL.stress4p*1.1; %???
    end
    envlpNegStrain(6) = 1e+6*MDL.strain4n;
    if (k2 > 0.0)
        envlpNegStress(6) = MDL.stress4n+k2*(envlpNegStrain(6) - MDL.strain4n);
    else
        envlpNegStress(6) = MDL.stress4n*1.1; %???
    end

    % define crtical material properties
    kElasticPos = envlpPosStress(2)/envlpPosStrain(2);	
    kElasticNeg = envlpNegStress(2)/envlpNegStrain(2);

    % Compute the energy of positve and negative branch by sum up 4 trapezoidal
    % areas
    energypos = 0.5*envlpPosStrain(1)*envlpPosStress(1);
    for j = 1:4		
        energypos = energypos+0.5*(envlpPosStress(j) + envlpPosStress(j+1))*(envlpPosStrain(j+1) - envlpPosStrain(j));
    end

    energyneg = 0.5*envlpNegStrain(1)*envlpNegStress(1);
    for j = 1:4		
        energyneg = energyneg+0.5*(envlpNegStress(j) + envlpNegStress(j+1))*(envlpNegStrain(j+1) - envlpNegStrain(j));
    end

    max_energy = max([energypos energyneg]);
    energyCapacity = MDL.gE*max_energy;
    
    % % Modified by Padilla-Llano (2014-12-2014)
    % energyCapacity = MDL.gE*(energypos + energyneg);       
    
end





















































