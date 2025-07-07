function [state3Strain,state3Stress] = ...
          getstate3(state3Strain,state3Stress,kunload,kElasticNegDamgd,lowTstateStrain,lowTstateStress,TminStrainDmnd, ...
          envlpNegStrain,envlpNegDamgdStress,hghTstateStrain,hghTstateStress,TperElong,MDL)
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
    rrr = [];
    if (state3Strain(1)*state3Strain(4) <0.0)
        % trilinear unload reload path expected, first define point for reloading
        state3Strain(2) = lowTstateStrain*MDL.rDispN;
        if (MDL.rForceN-MDL.uForceN > 1e-8) 
            state3Stress(2) = lowTstateStress*MDL.rForceN;
            rrr = [rrr, 1];
        else
            if (TminStrainDmnd < envlpNegStrain(4))
                % st1 and st2 are local variables
                st1 = lowTstateStress*MDL.uForceN*(1.0+1e-6);
                st2 = envlpNegDamgdStress(5)*(1.0+1e-6);
                state3Stress(2) = min([st1 st2]);
                rrr = [rrr, 2];
            else
                st1 = envlpNegDamgdStress(4)*MDL.uForceN*(1.0+1e-6);
                st2 = envlpNegDamgdStress(5)*(1.0+1e-6);
                state3Stress(2) = min([st1 st2]);
                rrr = [rrr, 3];
            end
        end
        % if reload stiffness exceeds unload stiffness, reduce reload stiffness to make it equal to unload stiffness
        if ((state3Stress(2)-state3Stress(1))/(state3Strain(2)-state3Strain(1)) > kElasticNegDamgd) 
            state3Strain(2) = lowTstateStrain + (state3Stress(2)-state3Stress(1))/kElasticNegDamgd;
            rrr = [rrr, 4];
        end
        % check that reloading point is not behind point 4 
        if (state3Strain(2)>state3Strain(4)) 
            % path taken to be a straight line between points 1 and 4
            % du and df are local variables
            du = state3Strain(4) - state3Strain(1);
            df = state3Stress(4) - state3Stress(1);
            state3Strain(2) = state3Strain(1) + 0.33*du;
            state3Strain(3) = state3Strain(1) + 0.67*du;
            state3Stress(2) = state3Stress(1) + 0.33*df;
            state3Stress(3) = state3Stress(1) + 0.67*df;
            rrr = [rrr, 5];
        else
            if (TminStrainDmnd < envlpNegStrain(4)) 
                state3Stress(3) = MDL.uForceN*envlpNegDamgdStress(5);
                rrr = [rrr, 6];
            else
                state3Stress(3) = MDL.uForceN*envlpNegDamgdStress(4);
                rrr = [rrr, 7];
            end
            state3Strain(3) = hghTstateStrain - (hghTstateStress-state3Stress(3))/kunload;
            if (state3Strain(3) > state3Strain(4)) 
                % point 3 should be along a line between 2 and 4
                % du and df are local variables
                du = state3Strain(4) - state3Strain(2);
                df = state3Stress(4) - state3Stress(2);
                state3Strain(3) = state3Strain(2) + 0.5*du;
                state3Stress(3) = state3Stress(2) + 0.5*df;
                rrr = [rrr, 8];
            elseif ((state3Stress(3) - state3Stress(2))/(state3Strain(3) - state3Strain(2)) > kmax) 
                % linear unload-reload path expected
                % du and df are local variables
                du = state3Strain(4) - state3Strain(1);
                df = state3Stress(4) - state3Stress(1);
                state3Strain(2) = state3Strain(1) + 0.33*du;
                state3Strain(3) = state3Strain(1) + 0.67*du;
                state3Stress(2) = state3Stress(1) + 0.33*df;
                state3Stress(3) = state3Stress(1) + 0.67*df;
                rrr = [rrr, 9];
            elseif ((state3Strain(3) < state3Strain(2))||((state3Stress(3)-state3Stress(2))/(state3Strain(3)-state3Strain(2))<0))
                if (state3Strain(3)<0.0) 
                    % pt 3 should be along a line between 2 and 4
                    % du and df are local variables
                    du = state3Strain(4)-state3Strain(2);
                    df = state3Stress(4)-state3Stress(2);
                    state3Strain(3) = state3Strain(2) + 0.5*du;
                    state3Stress(3) = state3Stress(2) + 0.5*df;
                    rrr = [rrr, 10];
                elseif (state3Strain(2) > 0.0) 
                    % pt 2 should be along a line between 1 and 3
                    % du and df are local variables
                    du = state3Strain(3)-state3Strain(1);
                    df = state3Stress(3)-state3Stress(1);
                    state3Strain(2) = state3Strain(1) + 0.5*du;
                    state3Stress(2) = state3Stress(1) + 0.5*df;
                    rrr = [rrr, 11];
                else 
                    % avgforce and dfr are local variables
                    avgforce = 0.5*(state3Stress(3) + state3Stress(2));
                    dfr = 0.0;
                    if (avgforce < 0.0)
                        dfr = -avgforce/100;            
                    else 
                        dfr = avgforce/100;
                    end
                    % slope12 and slope34 are local variables
                    slope12 = (state3Stress(2) - state3Stress(1))/(state3Strain(2) - state3Strain(1));
                    slope34 = (state3Stress(4) - state3Stress(3))/(state3Strain(4) - state3Strain(3));
                    state3Stress(2) = avgforce - dfr;
                    state3Stress(3) = avgforce + dfr;
                    state3Strain(2) = state3Strain(1) + (state3Stress(2) - state3Stress(1))/slope12;
                    state3Strain(3) = state3Strain(4) - (state3Stress(4) - state3Stress(3))/slope34;
                    rrr = [rrr, 12];
                end
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
        rrr = [rrr, 13];
    end

    % checkslope and slope are local variables                   
    checkSlope = state3Stress(4)/state3Strain(4);
    % checkSlope = kunload;
    slope = 0.0;		

    % final check	
    i = 1;		
    while (i<4)
        % du and df are local variables
        du = state3Strain(i+1)-state3Strain(i);
        df = state3Stress(i+1)-state3Stress(i);
        if (du<0.0 || df<0.0) 
            du = state3Strain(4)-state3Strain(1);
            df = state3Stress(4)-state3Stress(1);
            state3Strain(2) = state3Strain(1) + 0.33*du;
            state3Strain(3) = state3Strain(1) + 0.67*du;
            state3Stress(2) = state3Stress(1) + 0.33*df;
            state3Stress(3) = state3Stress(1) + 0.67*df;
            slope = df/du;
            i = 4;
            rrr = [rrr, 14];
        end
        if (slope > 1e-8 && slope < checkSlope) 
            state3Strain(2) = 0.0; 
            state3Stress(2) = 0.0;
            state3Strain(3) = state3Strain(4)/2; 
            state3Stress(3) = state3Stress(4)/2;
            rrr = [rrr, 15];
        end 
        i = i + 1;
    end    
%     disp(num2str(rrr)); 
%     plot(state3Strain(1:4),state3Stress(1:4),'g','Marker','o','MarkerSize',6,'LineWidth',2)
end
    