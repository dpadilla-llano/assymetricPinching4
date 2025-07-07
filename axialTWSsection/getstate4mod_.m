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
    %                                 Modified by Padilla-Llano David (Dec 2014)
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
        % state4Strain(2) = state4Strain(1) + (state4Stress(2) - state4Stress(1))/kunload;
        
        % Check Strain at 2 is not behind Strain at 1
        if (state4Strain(2) < state4Strain(1)) 
            state4Strain(2) = state4Strain(1) + (state4Stress(2) - state4Stress(1))/kunload;
            rrr = [rrr,4];
        end
        
        %%% Calculate Point at 3:-> Peak in the Unload-Reload path              
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
            elseif (TmaxStrainDmnd > envlpPosStrain(3)) 
                st1 = hghTstateStress*MDL.uForceP*(1.0+1e-6);
                st2 = envlpPosDamgdStress(4)*(1.0+1e-6);
                state4Stress(3) = max([st1 st2]);
                rrr = [rrr,8];
            else
                % st1 and st2 are local variables
                st1 = envlpPosDamgdStress(3)*MDL.uForceP*(1.0+1e-6);
                st2 = envlpPosDamgdStress(5)*(1.0+1e-6);
                state4Stress(3) = max([st1 st2]);
                rrr = [rrr,9];
            end
        end
        
        % Check that Stress is less than the maximum stress from damaged backbone
        if (state4Stress(3) > envlpPosDamgdStress(3))
            state4Stress(3) = envlpPosDamgdStress(3);
            rrr = [rrr,10];
        end

        state4Strain(3) = TperElong*(1 - MDL.rDispP) + hghTstateStrain*MDL.rDispP;
        % state4Strain(3) = TperElong + (hghTstateStrain - TperElong)*MDL.rDispP;
        % Check that Strain is not bigger than the 
%         state4Strain(3) = min([ TperElong + (hghTstateStrain - TperElong)*MDL.rDispP; ...
%                                 state4Strain(2) + (state4Stress(3) - state4Stress(2))/kElasticPosDamgd ]);
        
        % Correct Strain at 3 if reload stiffness exceeds kunload or is negative 
        k32 = (state4Stress(3)-state4Stress(2))/(state4Strain(3)-state4Strain(2));
        k42 = (state4Stress(4)-state4Stress(2))/(state4Strain(4)-state4Strain(2));
        
        if ((state4Strain(3) < state4Strain(2)))
            state4Strain(3) = state4Strain(2) + (state4Stress(3) - state4Stress(2))/kunload;
            rrr = [rrr,11];
        elseif (k32 > kunload)
            state4Strain(3) = state4Strain(2) + (state4Stress(3) - state4Stress(2))/kunload;
            rrr = [rrr,12];
        % elseif (k32 < kElasticPosDamgd)
        %     state4Strain(3) = state4Strain(2) + (state4Stress(3) - state4Stress(2))/kElasticPosDamgd;
        %     rrr = [rrr,13];            
        elseif ( k32 < 0 )
            % Point 3 should be higher than Point 2
            df = state4Stress(2)/1000;
            state4Stress(3) = state4Stress(2) + df;            
            rrr = [rrr,13];
            if ( k32 < k42 )
                % pt 3 should be along a line between 2 and 4
                % du and df are local variables
                du = state4Strain(4)-state4Strain(2);
                df = state4Stress(4)-state4Stress(2);
                state4Strain(3) = state4Strain(2) + 0.5*du;
                state4Stress(3) = state4Stress(2) + 0.5*df;
                rrr = [rrr,14];
            end
        end     
    else
        % linear unload reload path is expected		 
        du = state4Strain(4)-state4Strain(1);
        df = state4Stress(4)-state4Stress(1);
        state4Strain(2) = state4Strain(1) + 0.33*du;
        state4Strain(3) = state4Strain(1) + 0.67*du;
        state4Stress(2) = state4Stress(1) + 0.33*df;
        state4Stress(3) = state4Stress(1) + 0.67*df;
        rrr = [rrr,14];
    end

    % checkslope and slope are local variables                   
    % checkSlope = state4Stress(1)/state4Strain(1);
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
            rrr = [rrr,17];
        end
        
        % If the slope from Start to End of State 4 is less than the slope
        % from zero to point 1 of state4 then unload to zero and load
        % linearly to point 4 of state4
        if (slope > 1e-8 && slope < checkSlope) 
            state4Strain(2) = 0.0; 
            state4Stress(2) = 0.0;
            state4Strain(3) = state4Strain(4)/2; 
            state4Stress(3) = state4Stress(4)/2;
            rrr = [rrr,18];
        end 
        i = i + 1;        
    end
	disp(num2str(rrr));
%     plot(state4Strain(1:4),state4Stress(1:4),'r:','Marker','o','MarkerSize',6,'LineWidth',2)
%     disp(num2str(state4Stress(3)));
%     disp(num2str(state4Strain,4));disp(num2str(state4Stress,4))
end   