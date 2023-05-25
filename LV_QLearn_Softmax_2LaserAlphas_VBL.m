function [choiceProbabilities,weights,rpe] = LV_QLearn_Softmax_2LaserAlphas_VB(SessionData,alpha,beta,LaserOnAlpha)
    % a softmax model where Laser On and Laser Off trials  have different
    % learning rates, temperature parameters, and bias. LaserOn is a logical
    % or binary matrix that keeps track of which updating rules to use
    % based on whether there was manipulation in a given trial. Because
    % there are potential side biases introduced based on the hemisphere of
    % the manipulation, this 

    if ~exist('SessionData','var')
        uiopen 
    end
    
    [choices,rewards]=extractChoices_VB(SessionData);
    weights = zeros(2,SessionData.nTrials);      %assume 0 for starting conditions (could fit)
    rpe = zeros(size(weights)); 
    laser = SessionData.Laser;

    %% Train Weights
    for n = 1:SessionData.nTrials-1
        %compute rpe
        switch choices(n)
            case 1
            rpe(1,n) = (rewards(1,n)) - weights(1,n); %compute rpe (negative rpe for 0uL rewards
            rpe(2,n) = (0) - weights(1,n);
            if rewards(1,n)==0
                weights(1, n+1) = weights(1,n) + LaserOnAlpha*rpe(1,n);     %update chosen
                weights(2, n+1) = weights(2,n);     % update unchosen with 0
            else
                weights(1, n+1) = weights(1,n) + alpha*rpe(1,n);     %update chosen
                weights(2, n+1) = weights(2,n);     % update unchosen with 0
            end
            case 2
            rpe(1,n) = (0) - weights(2,n); %compute rpe (negative rpe for 0uL rewards
            rpe(2,n) = rewards(2,n) - weights(2,n);
            if rewards(2,n)==0
                weights(1, n+1) = weights(1,n);     %update chosen
                weights(2, n+1) = weights(2,n) + LaserOnAlpha*rpe(2,n);     % update unchosen with 0
            else
                weights(1, n+1) = weights(1,n);     %update chosen
                weights(2, n+1) = weights(2,n) + alpha*rpe(2,n);     % update unchosen with 0
            end
            
        end
        if weights(1, n+1)<0
            weights(1, n+1)=0;
        end
        if weights(2, n+1) <0
            weights(2, n+1)=0;
        end
    end
      
    choiceProbabilities = zeros(2,SessionData.nTrials);
    
     for i=1:SessionData.nTrials
       choiceProbabilities(1,i)= 1/...
           ( 1+exp(1)^...
           -(beta*(weights(1,i)-weights(2,i))) );

       choiceProbabilities(2,i)= 1/...
           ( 1+exp(1)^...
           -(beta*(weights(2,i)-weights(1,i))) );

     end
    
end