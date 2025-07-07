function [MODEL] = Pinching4_cycpush_0_mat0
%==========================================================================
% File Name: Pinching4_cycpush_4_mat1.m
% Description: Input Data File
%              Pinching4_cycpush_4_mat1.M contains data for 1D pinching4 
%              model under cyclic displacement loading. 
%
%                                 Prepared by Jiazhen Leng (jleng1@jhu.edu)
%                                                 Johns Hopkins University
%==========================================================================

%============== Parameter Difinition ======================================
%--- Stiffness Parameters
% (stress1p,strain1p) to  (stress4p,strain4p): 4 pts defining the envelop 
%                                              of positive loading
% (stress1n,strain1n) to  (stress4n,strain4n): 4 pts defining the envelop 
%                                              of negative loading                                          
%
%--- Pinching Parameters
% rDispP rForceP uForceP: Reloading disp, force and unloading force of 
%                            positive loading
% rDispN rForceN uForceN: Reloading disp, force and unloading force of 
%                            negative loading
%
%--- Degredation Parameters
% gammaK1 gammaK2 gammaK3 gammaK4 gammaKLimit: Define unloading stiffness 
%                                              degredation
% gammaD1 gammaD2 gammaD3 gammaD4 gammaDLimit: Define deformation demand, 
%                                              i.e. reloading stiffness
%                                              degredation
% gammaF1 gammaF2 gammaF3 gammaF4 gammaFLimit: Define envelope max strength 
%                                              degredation
% gE dmgType: Define degredation type: 'cycle' or 'energy'
%
%--- Displacement loading
% d: Assigned displacement to be achieved
%
%============== Parameter Setting =========================================
%--- Stiffness Parameters
stress1p = 1.00;
stress2p = 2.00;
stress3p = 3.00;
stress4p = 3.00;
strain1p = 0.10;	
strain2p = 0.20;
strain3p = 0.30;
strain4p = 0.60;           

stress1n = -stress1p;
stress2n = -stress2p;
stress3n = -stress3p;
stress4n = -stress4p;
strain1n = -strain1p;
strain2n = -strain2p;
strain3n = -strain3p;
strain4n = -strain4p;

%--- Pinching Parameters
rDispP = -1.0;
rForceP = 0.999; % For stability, don't set rForce as zero exactly 
uForceP = 0.998; 

rDispN	= rDispP;	
rForceN = rForceP;
uForceN = uForceP;

%--- Degredation Parameters
gammaK1 = 0.0;         
gammaK2 = 0.0;         
gammaK3 = 0.0;         
gammaK4 = 0.0;         
gammaKLimit = 0.0;         
                   
gammaD1 = 0.0;         
gammaD2 = 0.0;         
gammaD3 = 0.0;         
gammaD4 = 0.0;         
gammaDLimit = 0.0;         
                   
gammaF1 = 0.0;         
gammaF2 = 0.0;         
gammaF3 = 0.0;         
gammaF4 = 0.0;         
gammaFLimit = 0.0;          
                   
gE = 1.0;         
dmgtype = 'energy';

%--- Displacement loading
% I am defining a cyclic displacement control here
d = zeros(351,1);
for i = 1:51
    d(i) = (i - 1)*0.02;
end
for i = 52:101
    d(i) = d(51)+(i - 51)*-0.04;
end
for i = 102:151
    d(i) = d(101)+(i - 101)*0.06;
end
for i = 152:201
    d(i) = d(151)+(i - 151)*-0.08;
end
for i = 202:251
    d(i) = d(201)+(i - 201)*0.10;
end
for i = 252:301
    d(i) = d(251)+(i - 251)*-0.12;
end
for i = 302:351
    d(i) = d(301)+(i - 301)*0.06;
end

%--- Structural Data with Defined Fields
MODEL = struct('stress1p',stress1p,'strain1p',strain1p,'stress2p',stress2p,'strain2p',strain2p,'stress3p',stress3p,'strain3p',strain3p,'stress4p',stress4p,'strain4p',strain4p, ...
               'stress1n',stress1n,'strain1n',strain1n,'stress2n',stress2n,'strain2n',strain2n,'stress3n',stress3n,'strain3n',strain3n,'stress4n',stress4n,'strain4n',strain4n, ...
               'rDispP',rDispP,'rForceP',rForceP,'uForceP',uForceP,'rDispN',rDispN,'rForceN',rForceN,'uForceN',uForceN, ...
               'gammaK1',gammaK1,'gammaK2',gammaK2,'gammaK3',gammaK3,'gammaK4',gammaK4,'gammaKLimit',gammaKLimit, ...
               'gammaD1',gammaD1,'gammaD2',gammaD2,'gammaD3',gammaD3,'gammaD4',gammaD4,'gammaDLimit',gammaDLimit, ...
               'gammaF1',gammaF1,'gammaF2',gammaF2,'gammaF3',gammaF3,'gammaF4',gammaF4,'gammaFLimit',gammaFLimit,'gE',gE,'dmgtype',dmgtype, ...
               'd',d);