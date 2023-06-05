function [choiceProbabilities,weights,rpe] = LV_QLearn_SoftmaxDecay_VBL(SessionData,laserSide,alpha,beta,bias,alphaL,betaL,biasL)
% Here, the unchosen port decays according to the decay rate. In mice, the
% decay rate tends to be near 1 in all cases I've seen. Instead of trying
% to fit the decay rate, we will try the model with a few intermediate
% weights. This Softmax uses a full decay rate of 1. Otherwise, the
% model is identical to the regular softmax with laser variables.

if ~exist('SessionData','var')
    uiopen
end

[choices,rewards]=extractChoices_VB(SessionData);
nTrials=length(choices);
weights = zeros(2,nTrials);      %assume 0 for starting conditions (could fit)
rpe = zeros(size(weights));
laser=SessionData.Laser;
decay=0.5; %Assume full decay of the unchosen side.


% Need to put choices in terms of contralateral and ipsilateral. Bilateral
% manipulation will use the default (1 is left, 2 is right). We will set up
% choice and outcome so choice 1 is ipsilateral and choice 2 is
% contralateral. Therefore, no changes are needed if the manipulation is on
% the left side. ** IF the manipulation is on the right, then we flip.
if laserSide=='R'
    flippedChoices=choices;
    flippedRewards=rewards;
    
    for i =1:SessionData.nTrials
        if choices(i)==1
            flippedChoices(i)=2;
        elseif choices(i)==2
            flippedChoices(i)=1;
        end
        
        flippedRewards(1,i)=rewards(2,i);
        flippedRewards(2,i)=rewards(1,i);
    end
    
    choices=flippedChoices;
    rewards=flippedRewards;
end


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
            rpe(1,n) = (rewards(1,n)) - weights(1,n); %compute rpe (negative rpe for 0uL rewards
            rpe(2,n) = (0) - weights(1,n);
            weights(1, n+1) = weights(1,n) + alphaRule*rpe(1,n);     %update chosen
            weights(2, n+1) = weights(2,n) + decay*rpe(2,n);     % update unchosen with 0
        case 2
            rpe(1,n) = (0) - weights(2,n); %compute rpe (negative rpe for 0uL rewards
            rpe(2,n) = rewards(2,n) - weights(2,n);
            weights(1, n+1) = weights(1,n) + decay*rpe(1,n);     %update chosen
            weights(2, n+1) = weights(2,n) + alphaRule*rpe(2,n);     % update unchosen with 0
    end
    if weights(1, n+1)<0
        weights(1, n+1)=0;
    end
    if weights(2, n+1)<0
        weights(2, n+1)=0;
    end
end

%After determining weights for a given alpha, calculate how the animal
%transforms value into choice probability. 
choiceProbabilities = zeros(2,SessionData.nTrials);
for i=1:SessionData.nTrials
    if laser(i)==1 % If the laser is on
        choiceProbabilities(1,i)= 1/...
            ( 1+exp(1)^...
            -(betaL*(weights(1,i)-weights(2,i)))-biasL );
        
        choiceProbabilities(2,i)= 1/...
            ( 1+exp(1)^...
            -(betaL*(weights(2,i)-weights(1,i)))+biasL );
    else % If the laser is off
        choiceProbabilities(1,i)= 1/...
            ( 1+exp(1)^...
            -(beta*(weights(1,i)-weights(2,i)))-bias );
        
        choiceProbabilities(2,i)= 1/...
            ( 1+exp(1)^...
            -(beta*(weights(2,i)-weights(1,i)))+bias );
    end
end

end