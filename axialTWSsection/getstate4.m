function [state4Strain,state4Stress] = ...
          getstate4(state4Strain,state4Stress,kunload,kElasticPosDamgd,lowTstateStrain,lowTstateStress,TmaxStrainDmnd, ...
          envlpPosStrain,envlpPosDamgdStress,hghTstateStrain,hghTstateStress,MDL)
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

    if (state4Strain(1)*state4Strain(4) <0.0)
        % trilinear unload reload path expected, first define point for reloading
        state4Strain(3) = hghTstateStrain*MDL.rDispP;
        if (MDL.uForceP == 0.0)
            state4Stress(3) = hghTstateStress*MDL.rForceP;
        elseif (MDL.rForceP-MDL.uForceP > 1e-8)
                state4Stress(3) = hghTstateStress*MDL.rForceP;      
        else
            if (TmaxStrainDmnd > envlpPosStrain(4))
                % st1 and st2 are local variables
                st1 = hghTstateStress*MDL.uForceP*(1.0+1e-6);
                st2 = envlpPosDamgdStress(5)*(1.0+1e-6);
                state4Stress(3) = max([st1 st2]);
            else
                % st1 and st2 are local variables
                st1 = envlpPosDamgdStress(4)*MDL.uForceP*(1.0+1e-6);
                st2 = envlpPosDamgdStress(5)*(1.0+1e-6);
                state4Stress(3) = max([st1 st2]);
            end
        end

        % if reload stiffness exceeds unload stiffness, reduce reload stiffness to make it equal to unload stiffness
        if ((state4Stress(4)-state4Stress(3))/(state4Strain(4)-state4Strain(3)) > kElasticPosDamgd) %21
            state4Strain(3) = hghTstateStrain - (state4Stress(4)-state4Stress(3))/kElasticPosDamgd;
        end
        % check that reloading point is not behind point 1 
        if (state4Strain(3)<state4Strain(1)) % 22
            % path taken to be a straight line between points 1 and 4
            % du and df are local variables
            du = state4Strain(4) - state4Strain(1);
            df = state4Stress(4) - state4Stress(1);
            state4Strain(2) = state4Strain(1) + 0.33*du;
            state4Strain(3) = state4Strain(1) + 0.67*du;
            state4Stress(2) = state4Stress(1) + 0.33*df;
            state4Stress(3) = state4Stress(1) + 0.67*df;
        else 
            if (TmaxStrainDmnd > envlpPosStrain(4)) 
                state4Stress(2) = MDL.uForceP*envlpPosDamgdStress(5);
            else
                state4Stress(2) = MDL.uForceP*envlpPosDamgdStress(4);
            end
            state4Strain(2) = lowTstateStrain + (-lowTstateStress + state4Stress(2))/kunload;
            if (state4Strain(2) < state4Strain(1)) %23
                % point 2 should be along a line between 1 and 3
                % du and df are local variables
                du = state4Strain(3) - state4Strain(1);
                df = state4Stress(3) - state4Stress(1);
                state4Strain(2) = state4Strain(1) + 0.5*du;
                state4Stress(2) = state4Stress(1) + 0.5*df;
            elseif ((state4Stress(3) - state4Stress(2))/(state4Strain(3) - state4Strain(2)) > kmax)%24
                % linear unload-reload path expected
                % du and df are local variables
                du = state4Strain(4) - state4Strain(1);
                df = state4Stress(4) - state4Stress(1);
                state4Strain(2) = state4Strain(1) + 0.33*du;
                state4Strain(3) = state4Strain(1) + 0.67*du;
                state4Stress(2) = state4Stress(1) + 0.33*df;
                state4Stress(3) = state4Stress(1) + 0.67*df;
            elseif ((state4Strain(3) < state4Strain(2))||((state4Stress(3)-state4Stress(2))/(state4Strain(3)-state4Strain(2))<0))%25
                if (state4Strain(2)>0.0) %251
                    % pt 2 should be along a line between 1 and 3
                    % du and df are local variables
                    du = state4Strain(3)-state4Strain(1);
                    df = state4Stress(3)-state4Stress(1);
                    state4Strain(2) = state4Strain(1) + 0.5*du;
                    state4Stress(2) = state4Stress(1) + 0.5*df;
                elseif (state4Strain(3) < 0.0) %252
                    % pt 3 should be along a line between 2 and 4
                    % du and df are local variables
                    du = state4Strain(4)-state4Strain(2);
                    df = state4Stress(4)-state4Stress(2);
                    state4Strain(3) = state4Strain(2) + 0.5*du;
                    state4Stress(3) = state4Stress(2) + 0.5*df;
                else %253
                    % avgforce and dfr are local variables
                    avgforce = 0.5*(state4Stress(3) + state4Stress(2));
                    dfr = 0.0;
                    if (avgforce < 0.0)
                        dfr = -avgforce/100;            
                    else 
                        dfr = avgforce/100;
                    end
                    % slope12 and slope34 are local variables
                    slope12 = (state4Stress(2) - state4Stress(1))/(state4Strain(2) - state4Strain(1));
                    slope34 = (state4Stress(4) - state4Stress(3))/(state4Strain(4) - state4Strain(3));
                    state4Stress(2) = avgforce - dfr;
                    state4Stress(3) = avgforce + dfr;
                    state4Strain(2) = state4Strain(1) + (state4Stress(2) - state4Stress(1))/slope12;
                    state4Strain(3) = state4Strain(4) - (state4Stress(4) - state4Stress(3))/slope34;
                end
            end
        end
    else % Case 11
        % linear unload reload path is expected		 
        du = state4Strain(4)-state4Strain(1);
        df = state4Stress(4)-state4Stress(1);
        state4Strain(2) = state4Strain(1) + 0.33*du;
        state4Strain(3) = state4Strain(1) + 0.67*du;
        state4Stress(2) = state4Stress(1) + 0.33*df;
        state4Stress(3) = state4Stress(1) + 0.67*df;
    end

    % checkslope and slope are local variables                   
    checkSlope = state4Stress(1)/state4Strain(1);
    slope = 0.0;		

    % final check	
    i = 1;		
    while (i<4)
        % du and df are local variables
        du = state4Strain(i+1)-state4Strain(i);
        df = state4Stress(i+1)-state4Stress(i);
        if (du<0.0 || df<0.0) 
            du = state4Strain(4)-state4Strain(1);
            df = state4Stress(4)-state4Stress(1);
            state4Strain(2) = state4Strain(1) + 0.33*du;
            state4Strain(3) = state4Strain(1) + 0.67*du;
            state4Stress(2) = state4Stress(1) + 0.33*df;
            state4Stress(3) = state4Stress(1) + 0.67*df;
            slope = df/du;
            i = 4;
        end
        if (slope > 1e-8 && slope < checkSlope) 
            state4Strain(2) = 0.0; 
            state4Stress(2) = 0.0;
            state4Strain(3) = state4Strain(4)/2; 
            state4Stress(3) = state4Stress(4)/2;
        end 
        i = i + 1;
    end            
end   