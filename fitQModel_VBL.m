function [result] = fitQModel_VBL(SessionData,model)
    % GOAL: This Q Model is being made as a separate group of alogrithms
    % that can more easily be made to account for propogation of laser and
    % side-of-manipulation information in cases where unilateral manipulation
    % is used. We want to test for an effect of laser on choice as it
    % relates to value. 

    % Inputs: 
    % 1. SessionData is 2-choice serial reversal session data from BPod. Meant 
    % for use with the LV_VolumeBlocks behavioral code.
    % 2. Model is a 7-letter code for the type of choice algorithm to use.
    % The possible choices are as follows:
    
    % 'SoftMax' = a softmax model where choice probability is proportional
    % to the Q Value of the choice. Proportionality depends on beta
    % parameter. High beta exploits value differences, low beta does not. 
    % A bias parameter captures the tendency of an animal to choose a given
    % side irrespective of value. These three parameters, alpha, beta, and
    % bias, are solved for separately for trials where laser is or isn't
    % present. A change in these values for laser trials implies an effect
    % of the laser on choice and value estimation. 
    
    % 'SoftDec' = a softmax model where the value of the choice that isn't
    % chosen decays to zero. There is an RPE for unchosen choice.
    % Otherwise, it's the same model as above.

    
    % Outputs: Result Matrix with Fitted Model parameters,
    % Trial-by-trial RPEs & Qvalues, & Model Likelihood
    
    % 1. Alpha is the learning rate. 
    % 2. Beta is the explore/exploit parameter.
    %    Beta < 1 is exploratory, Beta > 1 is exploitative.
    %    If testing epsilon model, beta will be set to 1.
    % 3. Bias is the tendency to choose a given side. Positive values bias
    %    to the contralateral side; negative values bias to the ipsilateral
    %    side.
    % 4. Decay is the fitted decay rate for models that include decay. Decay 
    %    will be set to 0 for models that don't include decay rates.
    % 5. Choice Probabilities is the probability of selecting each choice
    %    according to the Q value and beta parameter.
    % 6. RPEs is a matrix containing trial-by-trial RPEs for each choice. 
    %    Depending on the model used, there will or won't be an RPE for
    %    each choice
    % 7. QValues is a matrix containing the trial-by-trial Q value of each
    %    choice. Top row is for the left choice, bottom row is for right
    %    choice.
    % 8. QSums is the trial-by-trial sum of the Q value for each choice
    % 9. QDifferences is the trial-by-trial absolute difference between
    %    each of the choices
    % 10. Likelihood is a measure of the likelihood of the model. Higher is
    %    better.
    
    % Coded by Luigim Vargas. May 25, 2023.

%% Initiate parameters for fitting
    Aeq=[];
    beq=[];
    Aineq=[];
    bineq=[];
    lb = [0 0 -1 0 0 -1];    % lower limits for alpha, beta, bias, and laser variants
    ub = [1 10 1 1 10 1];  % upper limits for alpha, beta, bias, and laser variants
    inx = [rand(1) rand(1) 0 rand(1) rand(1) 0]; % starting points to fit from (shouldn't matter)

    options = optimset('Display','on','MaxIter',5000000,'TolFun',1e-15,'TolX',1e-15,...
        'DiffMaxChange',1e-2,'DiffMinChange',1e-6,'MaxFunEvals',5000000,...
        'LargeScale','off');
    %% Define algorithm and options for fitting
    % Inputs(1:4) are alpha, beta, decay rate, and inverse alpha
    tester = @(inputs)compareModelFit_VBL(SessionData,model,...
        inputs(1),inputs(2),inputs(3),inputs(4),inputs(5),inputs(6));
    problem = createOptimProblem('fmincon','objective',tester,'x0', inx,...
        'lb',lb,'ub',ub,'Aeq',Aeq,'beq',beq,'Aineq',Aineq,'bineq',bineq,'options',options);
    ms = MultiStart;
    k = 200;

    warning off;
    %% Fit parameters according to the model and behavioral data
    [inputs, loglike, exitflag, output, solutions] = run(ms,problem,k);
    %% Create output for results
    if model=='SoftMax'
        [choiceProbabilities, Qvalues,RPEs]=LV_QLearn_Softmax_VBL(SessionData,...
        inputs(1),inputs(2),inputs(3),inputs(4),inputs(5),inputs(6));
    end
    if model=='SoftDec' 
        [choiceProbabilities, Qvalues,RPEs]=LV_QLearn_SoftmaxDecay_VBL(SessionData,...
        inputs(1),inputs(2),inputs(3),inputs(4),inputs(5),inputs(6));
    end
    QSums=zeros(1,SessionData.nTrials);
    QDiffs=zeros(1,SessionData.nTrials);
    for i=1:SessionData.nTrials
        QSums(i)=Qvalues(1,i)+Qvalues(2,i);
        QDiffs(i)=Qvalues(2,i)-Qvalues(1,i);
    end
    
    [choices,rewards]=extractChoices_VBL(SessionData);
    
    result.solutions=solutions;
    result.output=output;
    result.exitflag=exitflag;
    result.model = model;
    result.alpha = inputs(1);
    result.beta = inputs(2);
    result.bias = inputs(3);
    result.alphaL = inputs(4);
    result.betaL = inputs(5);
    result.biasL = inputs(6);
    result.choiceProbabilities = choiceProbabilities;
    result.RPEs = RPEs;
    result.Qvalues = Qvalues;
    result.QSums = QSums;
    result.QDifferences = QDiffs;
    result.likelihood = loglike; 
    result.choices = choices;
    result.rewards = rewards;
    result.SessionData = SessionData;

end