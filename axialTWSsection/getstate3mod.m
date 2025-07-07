function [state3Strain,state3Stress] = ...
          getstate3mod(state3Strain,state3Stress,kunload,kElasticNegDamgd,lowTstateStrain,lowTstateStress,TminStrainDmnd, ...
          envlpNegStrain,envlpNegDamgdStress,hghTstateStrain,hghTstateStress,MDL)
    %==========================================================================
    % File Name: getstate3.m
    % Description: Define the current state using trial strain and strain rate,
    %              specially for state 3. 
    %
    %                                 Prepared by Jiazhen Leng (jleng1@jhu.edu)
    %                                                 Johns Hopkins University
    %                                 Modified by Padilla-Llano David (Dec 2014)
    %==========================================================================
    % kmax is a local variable
    kmax = max([kunload kElasticNegDamgd]);
    TperElong = -(state3Stress(4) - kunload*state3Strain(4))/kunload;
    
    rrr = [];    
    if (state3Strain(1)*state3Strain(4) <0.0)
        % Trilinear unload reload path expected
        
        % Calculate Point at 3:-> End of Unloading from Negative Quadrant
        if (TminStrainDmnd < envlpNegStrain(4))
            state3Stress(3) = MDL.uForceN*envlpNegDamgdStress(5);
            rrr = [rrr,1];
        elseif (TminStrainDmnd < envlpNegStrain(3)) 
            state3Stress(3) = MDL.uForceN*envlpNegDamgdStress(4);
            rrr = [rrr,2];
        else 
            state3Stress(3) = MDL.uForceN*envlpNegDamgdStress(3);
            rrr = [rrr,3];
        end
        
        state3Strain(3) = hghTstateStrain + (-hghTstateStress + state3Stress(3))/kunload;
        % state3Strain(3) = state3Strain(4) + (state3Stress(3) - state3Stress(4))/kunload;
        
        % Check Strain at 3 is not in front of Strain at 4
        if (state3Strain(3) > state3Strain(4)) 
            state3Strain(3) = state3Strain(4) + (state3Stress(3) - state3Stress(4))/kunload;
            rrr = [rrr,4];
        end
        
        %%% Calculate Point at 2:-> Peak in the Unload-Reload path              
        if (MDL.uForceN == 0.0)
            state3Stress(2) = lowTstateStress*MDL.rForceN;
            % state3Stress(2) = envlpNegDamgdStress(2)*MDL.rForceN;
            rrr = [rrr,5];
        elseif (MDL.rForceN-MDL.uForceN > 1e-8)
            state3Stress(2) = lowTstateStress*MDL.rForceN;
            % state3Stress(2) = envlpNegDamgdStress(2)*MDL.rForceN;
            rrr = [rrr,6];
        else
            if (TminStrainDmnd < envlpNegStrain(4))
                % st1 and st2 are local variables
                st1 = lowTstateStress*MDL.uForceN*(1.0+1e-6);
                st2 = envlpNegDamgdStress(5)*(1.0+1e-6);
                state3Stress(2) = min([st1 st2]);
                rrr = [rrr,7];
            elseif (TminStrainDmnd < envlpNegStrain(3)) 
                st1 = lowTstateStress*MDL.uForceN*(1.0+1e-6);
                st2 = envlpNegDamgdStress(4)*(1.0+1e-6);
                state3Stress(2) = min([st1 st2]);
                rrr = [rrr,8];
            else
                % st1 and st2 are local variables
                st1 = envlpNegDamgdStress(3)*MDL.uForceN*(1.0+1e-6);
                st2 = envlpNegDamgdStress(5)*(1.0+1e-6);
                state3Stress(2) = min([st1 st2]);
                rrr = [rrr,9];
            end
        end
        
        % Check that Stress is less than the maximum stress from damaged backbone
        if (state3Stress(2) < envlpNegDamgdStress(3))
            state3Stress(2) = envlpNegDamgdStress(3);
            rrr = [rrr,10];       
        end
        % if (TmaxStrainDmnd > envlpPosStrain(5)) 
        %     state3Stress(3) = hghTstateStress*MDL.rForceN;
        %     rrr = [rrr,101];  
        % end
                
        % state3Strain(3) = TperElong + (lowTstateStrain - TperElong)*MDL.rDispN; 
        state3Strain(2) = TperElong + envlpNegStrain(3)*MDL.rDispN;
                
        % Correct Strain at 2 if reload stiffness exceeds kunload or is negative 
        k23 = (state3Stress(2)-state3Stress(3))/(state3Strain(2)-state3Strain(3));
        k13 = (state3Stress(1)-state3Stress(3))/(state3Strain(1)-state3Strain(3));
        
        if ((state3Strain(2) > state3Strain(3)))
            state3Strain(2) = state3Strain(3) + (state3Stress(2) - state3Stress(3))/kunload;
            rrr = [rrr,11];
        elseif (k23 > kunload)
            state3Strain(2) = state3Strain(3) + (state3Stress(2) - state3Stress(3))/kunload;
            rrr = [rrr,12];
        % elseif (k32 < kElasticPosDamgd)
        %     state3Strain(3) = state3Strain(2) + (state3Stress(3) - state3Stress(2))/kElasticPosDamgd;
        %     rrr = [rrr,13];            
        elseif ( k23 < 0 )
            % Point 3 should be lower than Point 3
            df = abs(state3Stress(3)/1000);
            state3Stress(2) = state3Stress(3) - df;            
            rrr = [rrr,13];
            if ( k23 < k13 )
                % pt 2 should be along a line between 1 and 3
                % du and df are local variables
                du = state3Strain(1)-state3Strain(3);
                df = state3Stress(1)-state3Stress(3);
                state3Strain(2) = state3Strain(3) + 0.5*du;
                state3Stress(2) = state3Stress(3) + 0.5*df;
                rrr = [rrr,14];
            end
        end                
    else
        % linear unload reload path is expected		 
        du = state3Strain(4)-state3Strain(1);
        df = state3Stress(4)-state3Stress(1);
        state3Strain(2) = state3Strain(1) + 0.33*du;
        state3Strain(3) = state3Strain(1) + 0.67*du;
        state3Stress(2) = state3Stress(1) + 0.33*df;
        state3Stress(3) = state3Stress(1) + 0.67*df;
        rrr = [rrr,15];
    end
    
    % checkslope and slope are local variables                   
    checkSlope = state3Stress(4)/state3Strain(4);
%     checkSlope = kunload;
    slope = 0.0;		

    % Final Check: Enforces monotonic Increasing Load-Response through
    % State 4 if TperElong is zero
    i = 1;		
    while (i<4) 
        % du and df are local variables
        du = state3Strain(i+1)-state3Strain(i);
        df = state3Stress(i+1)-state3Stress(i);

        if (du<0.0 || df<0.0) && (TperElong <= 0)
            du = state3Strain(4)-state3Strain(1);
            df = state3Stress(4)-state3Stress(1);
            state3Strain(2) = state3Strain(1) + 0.33*du;
            state3Strain(3) = state3Strain(1) + 0.67*du;
            state3Stress(2) = state3Stress(1) + 0.33*df;
            state3Stress(3) = state3Stress(1) + 0.67*df;
            slope = df/du;
            i = 4;
            rrr = [rrr,17];
        end
        
        % If the slope from Start to End of State 4 is less than the slope
        % from zero to point 1 of state4 then unload to zero and load
        % linearly to point 4 of state4
        if (slope > 1e-8 && slope < checkSlope) 
            state3Strain(2) = 0.0; 
            state3Stress(2) = 0.0;
            state3Strain(3) = state3Strain(4)/2; 
            state3Stress(3) = state3Stress(4)/2;
            rrr = [rrr,18];
        end 
        i = i + 1;        
    end    
%     disp(num2str(rrr));
%     plot(state4Strain(1:4),state4Stress(1:4),'r','Marker','o','MarkerSize',6,'LineWidth',2)
end
    