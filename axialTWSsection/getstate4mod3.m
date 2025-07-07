function [state4Strain,state4Stress] = ...
          getstate4mod(state4Strain,state4Stress,kunload,kElasticPosDamgd,lowTstateStrain,lowTstateStress,TmaxStrainDmnd, ...
          envlpPosStrain,envlpPosDamgdStress,hghTstateStrain,hghTstateStress,TperElong,MDL)
    %==========================================================================
    % File Name: getstate4.m
    % Description: Define the current state using trial strain and strain rate,
    %              specially for state 4. 
    %
    %                                 Prepared by Jiazhen Leng (jleng1@jhu.edu)
    %                                                 Johns Hopkins University
    %==========================================================================
    % kmax is a local variable
    kmax = max([kunload kElasticPosDamgd]);
    
    rrr = [];
    if (state4Strain(1)*state4Strain(4) <0.0)
        % Trilinear unload reload path expected
        
        % Calculate Point at 2:-> End of Unloading from Negative Quadrant
        if (TmaxStrainDmnd > envlpPosStrain(4))
            state4Stress(2) = MDL.uForceP*envlpPosDamgdStress(5);
            rrr = [rrr,1];
        elseif (TmaxStrainDmnd > envlpPosStrain(3)) 
            state4Stress(2) = MDL.uForceP*envlpPosDamgdStress(4);
            rrr = [rrr,2];
        else 
            state4Stress(2) = MDL.uForceP*envlpPosDamgdStress(3);
            rrr = [rrr,3];
        end
        
        state4Strain(2) = lowTstateStrain + (-lowTstateStress + state4Stress(2))/kunload;
        
        % Check Strain at 2 is not behind Strain at 1
        if (state4Strain(2) < state4Strain(1)) 
            state4Strain(2) = state4Strain(1) + (state4Strain(2) - state4Strain(1))/kunload;
            rrr = [rrr,4];
        end
        
        %%% Calculate Point at 3:-> Peak in the Unload-Reload path
        % state4Strain(3) = TperElong*(1 - MDL.rDispP) + hghTstateStrain*MDL.rDispP;
        state4Strain(3) = TperElong + (hghTstateStrain - TperElong)*MDL.rDispP;

        if (MDL.uForceP == 0.0)
            state4Stress(3) = hghTstateStress*MDL.rForceP;
            rrr = [rrr,5];
        elseif (MDL.rForceP-MDL.uForceP > 1e-8)
            state4Stress(3) = hghTstateStress*MDL.rForceP;      
            rrr = [rrr,6];
        else
            if (TmaxStrainDmnd > envlpPosStrain(4))
                % st1 and st2 are local variables
                st1 = hghTstateStress*MDL.uForceP*(1.0+1e-6);
                st2 = envlpPosDamgdStress(5)*(1.0+1e-6);
                state4Stress(3) = max([st1 st2]);
                rrr = [rrr,7];
            else
                % st1 and st2 are local variables
                st1 = envlpPosDamgdStress(4)*MDL.uForceP*(1.0+1e-6);
                st2 = envlpPosDamgdStress(5)*(1.0+1e-6);
                state4Stress(3) = max([st1 st2]);
                rrr = [rrr,8];
            end
        end
        
        % Check that Stress is less than the maximum stress from damaged backbone
        if (state4Stress(3) > envlpPosDamgdStress(3))
            state4Stress(3) = envlpPosDamgdStress(3);
            rrr = [rrr,9];
        end
        
        % Correct Strain at 3 if reload stiffness exceeds unload stiffness
        if ((state4Stress(3) - state4Stress(2))/(state4Strain(3) - state4Strain(2)) > kElasticPosDamgd) 
            % k32 = (state4Stress(3)-state4Stress(2))/(state4Strain(3)-state4Strain(2));        
            state4Strain(3) = state4Strain(2) + (state4Stress(3) - state4Stress(2))/kElasticPosDamgd;
            rrr = [rrr,10];
        end
        
        % Check that peak point is not behind Strain at 2 or 1
        if ((state4Strain(3)<state4Strain(1)) || (state4Strain(3)<state4Strain(2)))                            
            % Correct Strain at 3 to reach calculated stress at 3 with stiffness kElasticPosDamgd
            state4Strain(3) = state4Strain(2) + (state4Stress(3)-state4Stress(2))/kElasticPosDamgd;
            rrr = [rrr,11];
        elseif ((state4Stress(3) - state4Stress(2))/(state4Strain(3) - state4Strain(2)) > kmax)
            
            rrr = [rrr,12];
        elseif ((state4Stress(3) - state4Stress(2))/(state4Strain(3) - state4Strain(2)) < 0)
            
            rrr = [rrr,13];
        end
            
        
%         %%% NOTE-DPADILLA: The following if may not be enter ever --- Check!
%         % if reload stiffness exceeds unload stiffness, reduce reload stiffness
%         % to make it equal to unload stiffness
% %         if ((state4Stress(4)-state4Stress(3))/(state4Strain(4)-state4Strain(3)) > kElasticPosDamgd) 
% %             state4Strain(3) = hghTstateStrain - (state4Stress(4)-state4Stress(3))/kElasticPosDamgd;
% %             rrr = [rrr,5];
% %         end
%         if ((state4Stress(3)-state4Stress(2))/(state4Strain(3)-state4Strain(2)) > kElasticPosDamgd) 
%             state4Strain(3) = TperElong + (state4Stress(3)-state4Stress(2))/kElasticPosDamgd;
%             rrr = [rrr,5];
%         end
%         
%         % check that reloading point is not behind point 1 
%         if (state4Strain(3)<state4Strain(1)) 
%             % path taken to be a straight line between points 1 and 4
%             % du and df are local variables
%             du = state4Strain(4) - state4Strain(1);
%             df = state4Stress(4) - state4Stress(1);
%             state4Strain(2) = state4Strain(1) + 0.33*du;
%             state4Strain(3) = state4Strain(1) + 0.67*du;
%             state4Stress(2) = state4Stress(1) + 0.33*df;
%             state4Stress(3) = state4Stress(1) + 0.67*df;
%             rrr = [rrr,6];
%         else
% %             if (TmaxStrainDmnd > envlpPosStrain(4)) 
% %                 state4Stress(2) = MDL.uForceP*envlpPosDamgdStress(5);
% %                 rrr = [rrr,7];
% %             else
% %                 state4Stress(2) = MDL.uForceP*envlpPosDamgdStress(4);
% %                 rrr = [rrr,8];
% %             end
% 
%             if (TmaxStrainDmnd > envlpPosStrain(4))
%                 state4Stress(2) = MDL.uForceP*envlpPosDamgdStress(5);
%                 rrr = [rrr,7];
%             elseif (TmaxStrainDmnd > envlpPosStrain(3)) 
%                 state4Stress(2) = MDL.uForceP*envlpPosDamgdStress(4);
%                 rrr = [rrr,8];
%             else 
%                 state4Stress(2) = MDL.uForceP*envlpPosDamgdStress(3);
%                 rrr = [rrr,9];
%             end
% 
% %             if (TmaxStrainDmnd > envlpPosStrain(5)) 
% %                 state4Stress(2) = MDL.uForceP*envlpPosDamgdStress(5);
% %                 rrr = [rrr,7];
% %             else
% %                 state4Stress(2) = MDL.uForceP*envlpPosDamgdStress(3);
% %                 rrr = [rrr,8];
% %             end            
% 
%             state4Strain(2) = lowTstateStrain + (-lowTstateStress + state4Stress(2))/kunload;
% 
%             if (state4Strain(2) < state4Strain(1)) 
%                 % point 2 should be along a line between 1 and 3
%                 % du and df are local variables
%                 du = state4Strain(3) - state4Strain(1);
%                 df = state4Stress(3) - state4Stress(1);
%                 state4Strain(2) = state4Strain(1) + 0.5*du;
%                 state4Stress(2) = state4Stress(1) + 0.5*df;
%                 rrr = [rrr,10];
%             elseif ((state4Stress(3) - state4Stress(2))/(state4Strain(3) - state4Strain(2)) > kmax) % ??
%                 % linear unload-reload path expected
%                 % du and df are local variables
%                 du = state4Strain(4) - state4Strain(1);
%                 df = state4Stress(4) - state4Stress(1);
%                 state4Strain(2) = state4Strain(1) + 0.33*du;
%                 state4Strain(3) = state4Strain(1) + 0.67*du;
%                 state4Stress(2) = state4Stress(1) + 0.33*df;
%                 state4Stress(3) = state4Stress(1) + 0.67*df;
%                 rrr = [rrr,11];
%             elseif ((state4Strain(3) < state4Strain(2))||((state4Stress(3)-state4Stress(2))/(state4Strain(3)-state4Strain(2))<0))
%                 if (state4Strain(2)>0.0) 
%                     % pt 2 should be along a line between 1 and 3
%                     % du and df are local variables
%                     du = state4Strain(3)-state4Strain(1);
%                     df = state4Stress(3)-state4Stress(1);
%                     state4Strain(2) = state4Strain(1) + 0.5*du;
%                     state4Stress(2) = state4Stress(1) + 0.5*df;
%                     rrr = [rrr,12];
%                 elseif (state4Strain(3) < 0.0) 
%                     % pt 3 should be along a line between 2 and 4
%                     % du and df are local variables
%                     du = state4Strain(4)-state4Strain(2);
%                     df = state4Stress(4)-state4Stress(2);
%                     state4Strain(3) = state4Strain(2) + 0.5*du;
%                     state4Stress(3) = state4Stress(2) + 0.5*df;
%                     rrr = [rrr,13];
%                 else 
%                     % avgforce and dfr are local variables
%                     avgforce = 0.5*(state4Stress(3) + state4Stress(2));
%                     dfr = 0.0;
%                     if (avgforce < 0.0)
%                         dfr = -avgforce/100;            
%                     else 
%                         dfr = avgforce/100;
%                     end
%                     % slope12 and slope34 are local variables
%                     slope12 = (state4Stress(2) - state4Stress(1))/(state4Strain(2) - state4Strain(1));
%                     slope34 = (state4Stress(4) - state4Stress(3))/(state4Strain(4) - state4Strain(3));
%                     state4Stress(2) = avgforce - dfr;
%                     state4Stress(3) = avgforce + dfr;
%                     state4Strain(2) = state4Strain(1) + (state4Stress(2) - state4Stress(1))/slope12;
%                     state4Strain(3) = state4Strain(4) - (state4Stress(4) - state4Stress(3))/slope34;
%                     rrr = [rrr,14];
%                 end
%             end
%         end
    else
        % linear unload reload path is expected		 
        du = state4Strain(4)-state4Strain(1);
        df = state4Stress(4)-state4Stress(1);
        state4Strain(2) = state4Strain(1) + 0.33*du;
        state4Strain(3) = state4Strain(1) + 0.67*du;
        state4Stress(2) = state4Stress(1) + 0.33*df;
        state4Stress(3) = state4Stress(1) + 0.67*df;
        rrr = [rrr,15];
    end

    % checkslope and slope are local variables                   
    checkSlope = state4Stress(1)/state4Strain(1);
    checkSlope = kunload;
    
    slope = 0.0;		

    % Final Check: Enforces monotonic Increasing Load-Response through
    % State 4 if TperElong is zero
    i = 1;		
    while (i<4) 
        % du and df are local variables
        du = state4Strain(i+1)-state4Strain(i);
        df = state4Stress(i+1)-state4Stress(i);

        if (du<0.0 || df<0.0) && (TperElong >= 0)
            du = state4Strain(4)-state4Strain(1);
            df = state4Stress(4)-state4Stress(1);
            state4Strain(2) = state4Strain(1) + 0.33*du;
            state4Strain(3) = state4Strain(1) + 0.67*du;
            state4Stress(2) = state4Stress(1) + 0.33*df;
            state4Stress(3) = state4Stress(1) + 0.67*df;
            slope = df/du;
            i = 4;
            rrr = [rrr,16];
        end
        
        % If the slope from Start to End of State 4 is less than the slope
        % from zero to point 1 of state4 then unload to zero and load
        % linearly to point 4 of state4
        if (slope > 1e-8 && slope < checkSlope) 
            state4Strain(2) = 0.0; 
            state4Stress(2) = 0.0;
            state4Strain(3) = state4Strain(4)/2; 
            state4Stress(3) = state4Stress(4)/2;
            rrr = [rrr,17];
        end 
        i = i + 1;        
    end
    disp(num2str(rrr));
%     disp(num2str(state4Strain,4));disp(num2str(state4Stress,4))
end   