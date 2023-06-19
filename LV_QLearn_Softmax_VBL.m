function [choiceProbabilities,Qvalues,rpe] = LV_QLearn_Softmax_VBL(SessionData,alpha,beta,bias,alphaL,betaL,biasL)
% a softmax model where Laser On and Laser Off trials  have different
% learning rates, temperature parameters, and bias. LaserOn is a logical
% or binary matrix that keeps track of which updating rules to use
% based on whether there was manipulation in a given trial. Because
% there are potential side biases introduced based on the hemisphere of
% the manipulation, this

if ~exist('SessionData','var')
    uiopen
end

[choices,rewards]=extractChoices_VBL(SessionData);
Qvalues = zeros(2,SessionData.nTrials);      %assume 0 for starting conditions (could fit)
rpe = zeros(size(Qvalues));
laser=SessionData.Laser;

%% Train Weights
for n = 1:SessionData.nTrials-1
    %compute rpe
    if laser(n)==0
        alphaRule=alpha;
    else
        alphaRule=alphaL;
    end
    
    switch choices(n)
        case 1
            rpe(1,n) = (rewards(1,n)) - Qvalues(1,n); %compute rpe (negative rpe for 0uL rewards
            rpe(2,n) = (0) - Qvalues(1,n);
            if rewards(1,n)==0
                Qvalues(1, n+1) = Qvalues(1,n) + alphaRule*rpe(1,n);     %update chosen
                Qvalues(2, n+1) = Qvalues(2,n);     % update unchosen with 0
            else
                Qvalues(1, n+1) = Qvalues(1,n) + alphaRule*rpe(1,n);     %update chosen
                Qvalues(2, n+1) = Qvalues(2,n);     % update unchosen with 0
            end
        case 2
            rpe(1,n) = (0) - Qvalues(2,n); %compute rpe (negative rpe for 0uL rewards
            rpe(2,n) = rewards(2,n) - Qvalues(2,n);
            if rewards(2,n)==0
                Qvalues(1, n+1) = Qvalues(1,n);     %update chosen
                Qvalues(2, n+1) = Qvalues(2,n) + alphaRule*rpe(2,n);     % update unchosen with 0
            else
                Qvalues(1, n+1) = Qvalues(1,n);     %update chosen
                Qvalues(2, n+1) = Qvalues(2,n) + alphaRule*rpe(2,n);     % update unchosen with 0
            end
            
    end
    if Qvalues(1, n+1)<0
        Qvalues(1, n+1)=0;
    end
    if Qvalues(2, n+1) <0
        Qvalues(2, n+1)=0;
    end
end

%After determining weights for a given alpha, calculate how the animal
%transforms value into choice probability. 
choiceProbabilities = zeros(2,SessionData.nTrials);
for i=1:SessionData.nTrials
    if laser(i)==1 % If the laser is on
        choiceProbabilities(1,i)= 1/...
            ( 1+exp(1)^-(betaL*(Qvalues(1,i)-Qvalues(2,i)) -biasL) );
        
        choiceProbabilities(2,i)= 1/...
            ( 1+exp(1)^-(betaL*(Qvalues(2,i)-Qvalues(1,i)) +biasL) );
        
    else % If the laser is off
        choiceProbabilities(1,i)= 1/...
            ( 1+exp(1)^-(beta*(Qvalues(1,i)-Qvalues(2,i)) -bias) );
        
        choiceProbabilities(2,i)= 1/...
            ( 1+exp(1)^-(beta*(Qvalues(2,i)-Qvalues(1,i)) +bias) );
    end
    
end