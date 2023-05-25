function [choiceProbabilities,weights,rpe] = LV_QLearn_Softmax_VBL(SessionData,laserSide,alpha,beta,bias,alphaL,betaL,biasL)
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
weights = zeros(2,SessionData.nTrials);      %assume 0 for starting conditions (could fit)
rpe = zeros(size(weights));
laser=SessionData.Laser;


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
for n = 1:SessionData.nTrials-1
    %compute rpe
    if laser(i)==0
        alphaRule=alpha;
    else
        alphaRule=alphaL;
    end
    
    switch choices(n)
        case 1
            rpe(1,n) = (rewards(1,n)) - weights(1,n); %compute rpe (negative rpe for 0uL rewards
            rpe(2,n) = (0) - weights(1,n);
            if rewards(1,n)==0
                weights(1, n+1) = weights(1,n) + alphaRule*rpe(1,n);     %update chosen
                weights(2, n+1) = weights(2,n);     % update unchosen with 0
            else
                weights(1, n+1) = weights(1,n) + alphaRule*rpe(1,n);     %update chosen
                weights(2, n+1) = weights(2,n);     % update unchosen with 0
            end
        case 2
            rpe(1,n) = (0) - weights(2,n); %compute rpe (negative rpe for 0uL rewards
            rpe(2,n) = rewards(2,n) - weights(2,n);
            if rewards(2,n)==0
                weights(1, n+1) = weights(1,n);     %update chosen
                weights(2, n+1) = weights(2,n) + alphaRule*rpe(2,n);     % update unchosen with 0
            else
                weights(1, n+1) = weights(1,n);     %update chosen
                weights(2, n+1) = weights(2,n) + alphaRule*rpe(2,n);     % update unchosen with 0
            end
            
    end
    if weights(1, n+1)<0
        weights(1, n+1)=0;
    end
    if weights(2, n+1) <0
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
            -(betaL*(weights(1,i)-weights(2,i))) )+biasL;
        
        choiceProbabilities(2,i)= 1/...
            ( 1+exp(1)^...
            -(betaL*(weights(2,i)-weights(1,i))) )+biasL;
    else % If the laser is off
        choiceProbabilities(1,i)= 1/...
            ( 1+exp(1)^...
            -(beta*(weights(1,i)-weights(2,i))) )+bias;
        
        choiceProbabilities(2,i)= 1/...
            ( 1+exp(1)^...
            -(beta*(weights(2,i)-weights(1,i))) )+bias;
    end
    
end