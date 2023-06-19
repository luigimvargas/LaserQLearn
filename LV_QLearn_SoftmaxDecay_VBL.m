function [choiceProbabilities,Qvalues,rpe] = LV_QLearn_SoftmaxDecay_VBL(SessionData,alpha,beta,bias,alphaL,betaL,biasL)
% Here, the unchosen port decays according to the decay rate. In mice, the
% decay rate tends to be near 1 in all cases I've seen. Instead of trying
% to fit the decay rate, we will try the model with a few intermediate
% weights. This Softmax uses a full decay rate of 1. Otherwise, the
% model is identical to the regular softmax with laser variables.

if ~exist('SessionData','var')
    uiopen
end

[choices,rewards]=extractChoices_VBL(SessionData);
nTrials=length(choices);
Qvalues = zeros(2,nTrials);      %assume 0 for starting conditions (could fit)
rpe = zeros(size(Qvalues));
laser=SessionData.Laser;
decay=0.5; %Assume full decay of the unchosen side.


%% Train Weights
for n = 1:nTrials-1
    if laser(n)==0
        alphaRule=alpha;
    else
        alphaRule=alphaL;
    end
    
    %compute rpe
    switch choices(n)
        case 1
            rpe(1,n) = (rewards(1,n)) - Qvalues(1,n); %compute rpe (negative rpe for 0uL rewards
            rpe(2,n) = (0) - Qvalues(1,n);
            Qvalues(1, n+1) = Qvalues(1,n) + alphaRule*rpe(1,n);     %update chosen
            Qvalues(2, n+1) = Qvalues(2,n) + decay*rpe(2,n);     % update unchosen with 0
        case 2
            rpe(1,n) = (0) - Qvalues(2,n); %compute rpe (negative rpe for 0uL rewards
            rpe(2,n) = rewards(2,n) - Qvalues(2,n);
            Qvalues(1, n+1) = Qvalues(1,n) + decay*rpe(1,n);     %update chosen
            Qvalues(2, n+1) = Qvalues(2,n) + alphaRule*rpe(2,n);     % update unchosen with 0
    end
    if Qvalues(1, n+1)<0
        Qvalues(1, n+1)=0;
    end
    if Qvalues(2, n+1)<0
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