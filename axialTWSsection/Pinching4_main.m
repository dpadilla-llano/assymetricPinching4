%==========================================================================
% File Name: Pinching4_main.m
% Description: A simple main program to call Pinching4.
%
%                                 Prepared by Jiazhen Leng (jleng1@jhu.edu)
%                                                 Johns Hopkins University
%==========================================================================
%========== Initialize Matlab Environment =================================
% clear all
% close all
clc

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

% Read input parameters (all user specified for pinching4 in C++)
MDL = Pinching4_cycpush_0_mat0;

%========== Call Pinching4 ================================================
force = Pinching4(MDL);

%========== Post Process (plot) ===========================================
% Simple plot to show the force/stress vs. displacement/strain curve
figure(1)
plot(MDL.d,force,'b.-')
grid('on')

% Step by step plot to show the force/stress vs. displacement/strain curve
% xmin = 1.2*min(MDL.d);
% xmax = 1.2*max(MDL.d);
% ymin = 1.2*min(force);
% ymax = 1.2*max(force);
% figure(2)
% for i = 1:length(MDL.d)
%     if (mod(i,2) == 1)
%         plot(MDL.d(i),force(i),'b.');
%         grid('on')
%         xlim([xmin xmax]) 
%         ylim([ymin ymax])
%     else
%         plot(MDL.d(i),force(i),'r.');
%         xlim([xmin xmax]) 
%         ylim([ymin ymax]) 
%     end
%     hold on
%     pause(0.1)
% end


















