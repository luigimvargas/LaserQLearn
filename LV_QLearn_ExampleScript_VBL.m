%% Example script for running Q model fitting and plotting

    if ~exist('SessionData','var')
       disp('load up a Bpod Session')
       uiopen 
    end
    %%
    results=table({'model'},2,3,'VariableNames',{'ModelName','MedianAcc','Likelihood'});
    
    %Split SessionData into LaserOn and LaserOff eventually
    LaserOnTrials=find(SessionData.Laser==0);
    
    splitNum=480;
    
    SessionDataTrain=struct();
    SessionDataTrain.choiceHistory=SessionData.choiceHistory(1:splitNum);
    SessionDataTrain.BlockTypes=SessionData.BlockTypes(1:splitNum);
    SessionDataTrain.nTrials=splitNum;
    SessionDataTrain.Rewarded=SessionData.Rewarded(1:splitNum);
    SessionDataTrain.TrialSettings=SessionData.TrialSettings(1:splitNum);
    
    SessionDataTest=struct();
    SessionDataTest.choiceHistory=SessionData.choiceHistory(splitNum+1:SessionData.nTrials);
    SessionDataTest.BlockTypes=SessionData.BlockTypes(splitNum+1:SessionData.nTrials);
    SessionDataTest.nTrials=SessionData.nTrials-splitNum;
    SessionDataTest.Rewarded=SessionData.Rewarded(splitNum+1:SessionData.nTrials);
    SessionDataTest.TrialSettings=SessionData.TrialSettings(splitNum+1:SessionData.nTrials);
    %% Test Softmax
    softmaxResult=fitQModel_VB(SessionDataTrain,'SoftMax');
    plotVB(softmaxResult);
    %% Test Softmax Accuracy
    accuracyList=zeros(1,2000);
    for i=1:2000
        accuracyList(i)=modelAccuracy_VB(SessionData,softmaxResult.alpha,false,'SoftMax',softmaxResult.beta);
    end
    figure()
    histogram(accuracyList);
    results.ModelName(1)={'SoftMax'};
    results.MedianAcc(1)=median(accuracyList);
    results.Likelihood(1)=softmaxResult.likelihood;
    
    hold on
    title('Measuring Accuracy of Softmax 2000 times')
    ylabel(' # of occurences')
    xlabel('Accuracy')
    hold off;
    modelAccuracy_VB(SessionDataTest,softmaxResult.alpha,true,'SoftMax',softmaxResult.beta);
    %% Test Softmax Decay
    softDecayResult=fitQModel_VB(SessionData,'SoftDec');
    plotVB(softDecayResult);
    
        accuracyList=zeros(1,2000);
    for i=1:2000
        accuracyList(i)=modelAccuracy_VB(SessionData,softDecayResult.alpha,false,'SoftDec',softDecayResult.beta,softDecayResult.decay);
    end
    results.ModelName(2)={'SoftDec'};
    results.MedianAcc(2)=median(accuracyList);
    results.Likelihood(2)=softDecayResult.likelihood;
    figure()
    histogram(accuracyList);
    hold on
    title('Measuring Accuracy of Softmax Decay 2000 times')
    ylabel(' # of occurences')
    xlabel('Accuracy')
    hold off;
    modelAccuracy_VB(SessionData,softDecayResult.alpha,true,'SoftDec',softDecayResult.beta,softDecayResult.decay);
    %% Test Softmax Decay with inverse alpha
    dec2wayResult=fitQModel_VB(SessionData,'Dec2way');
    plotVB(dec2wayResult);
    
    accuracyList=zeros(1,5000);
    for i=1:5000
        accuracyList(i)=modelAccuracy_VB(SessionData,dec2wayResult.alpha,false,'Dec2way',dec2wayResult.beta,dec2wayResult.decay,dec2wayResult.invAlpha);
    end
    results.ModelName(3)={'Dec2way'};
    results.MedianAcc(3)=median(accuracyList);
    results.Likelihood(3)=dec2wayResult.likelihood;
    figure()
    histogram(accuracyList);
    hold on
    title('Measuring Accuracy of Softmax with inverse alpha and decay 5000 times')
    ylabel(' # of occurences')
    xlabel('Accuracy')
    hold off;
    modelAccuracy_VB(SessionData,dec2wayResult.alpha,true,'Dec2way',dec2wayResult.beta,dec2wayResult.decay,dec2wayResult.invAlpha);
    %% Test Inverse alpha without decay
    invAlphaResult=fitQModel_VB(SessionData,'Alpha2W');
    plotVB(invAlphaResult);
    
        accuracyList=zeros(1,2000);
    for i=1:2000
        accuracyList(i)=modelAccuracy_VB(SessionData,invAlphaResult.alpha,false,'Alpha2W',invAlphaResult.beta,invAlphaResult.decay,invAlphaResult.invAlpha);
    end
    results.ModelName(4)={'Alpha2W'};
    results.MedianAcc(4)=median(accuracyList);
    results.Likelihood(4)=invAlphaResult.likelihood;
    figure()
    histogram(accuracyList);
    hold on
    title('Measuring Accuracy of Softmax with inverse alpha 2000 times')
    ylabel(' # of occurences')
    xlabel('Accuracy')
    hold off;
%     modelAccuracy_VB(SessionData,invAlphaResult.alpha,true,'Alpha2W',invAlphaResult.beta,invAlphaResult.decay,invAlphaResult.invAlpha);

    %% Test Q stanble
    invAlphaResult=fitQModel_VB(SessionData,'Qstable');
    plotVB(invAlphaResult);
    
    accuracyList=zeros(1,2000);
    for i=1:2000
        accuracyList(i)=modelAccuracy_VB(SessionData,invAlphaResult.alpha,false,'Qstable',invAlphaResult.beta,invAlphaResult.decay,invAlphaResult.invAlpha);
    end
    
    results.ModelName(5)={'Qstable'};
    results.MedianAcc(5)=median(accuracyList);
    results.Likelihood(5)=invAlphaResult.likelihood;
    figure()
    histogram(accuracyList);
    hold on
    title('Measuring Accuracy of QStable with decay 2000 times')
    ylabel(' # of occurences')
    xlabel('Accuracy')
    hold off;
%     modelAccuracy_VB(SessionData,invAlphaResult.alpha,true,'Qstable',invAlphaResult.beta,invAlphaResult.decay,invAlphaResult.invAlpha);

%% Testing
    
    
%% Plot Q Difference vs Choice

laserBin=table(softDecayResult.choices(1), softDecayResult.QDifferences(1),...
    'VariableNames',{'Choice','QDiff'});
noLaserBin=table(softDecayResult.choices(1), softDecayResult.QDifferences(1),...
    'VariableNames',{'Choice','QDiff'});
%Trackers for when to move on to secondary rows
LB=false;
NLB=false;
for i=1:480
   if softDecayResult.SessionData.Laser(i)==1
       if height(laserBin)==1 && LB==false
           laserBin.Choice(1)=softDecayResult.choices(i);
           laserBin.QDiff(1)=softDecayResult.QDifferences(i);
           LB=true;
       else
           laserBin.Choice(height(laserBin)+1)=softDecayResult.choices(i);
           laserBin.QDiff(height(laserBin))=softDecayResult.QDifferences(i);
       end
       
   else
       if height(noLaserBin)==1 && NLB==false
           noLaserBin.Choice(1)=softDecayResult.choices(i);
           noLaserBin.QDiff(1)=softDecayResult.QDifferences(i);
           NLB=true;
       else
           noLaserBin.Choice(height(noLaserBin)+1)=softDecayResult.choices(i);
           noLaserBin.QDiff(height(noLaserBin))=softDecayResult.QDifferences(i);
       end
   end
end
%% Subsets
sectLB1=laserBin(laserBin.QDiff < -8,:);
sectLB2=laserBin(laserBin.QDiff >= -8 & laserBin.QDiff <-4,:);
sectLB3=laserBin(laserBin.QDiff >= -4 & laserBin.QDiff < 0,:);
sectLB4=laserBin(laserBin.QDiff >= 0 & laserBin.QDiff < 4,:);
sectLB5=laserBin(laserBin.QDiff >= 4 & laserBin.QDiff < 8,:);
sectLB6=laserBin(laserBin.QDiff >8,:);

sectNLB1=noLaserBin(noLaserBin.QDiff < -8,:);
sectNLB2=noLaserBin(noLaserBin.QDiff >= -8 & noLaserBin.QDiff <-4,:);
sectNLB3=noLaserBin(noLaserBin.QDiff >= -4 & noLaserBin.QDiff < 0,:);
sectNLB4=noLaserBin(noLaserBin.QDiff >= 0 & noLaserBin.QDiff < 4,:);
sectNLB5=noLaserBin(noLaserBin.QDiff >= 4 & noLaserBin.QDiff < 8,:);
sectNLB6=noLaserBin(noLaserBin.QDiff >8,:);


%%
figure()
hold on
ylim([0 1])
xlim([0 13])
xticks([1.5 3.5 5.5 7.5 9.5 11.5])
xticklabels({'-12 to -8', '-8 to -4', '-4 to 0', '0 to 4', '4 to 8', '8 to 12'})
xlabel('Q Differences')
ylabel('Probability (Left)')


bar(1,height(sectNLB1(sectNLB1.Choice==1,:))/height(sectNLB1),'FaceColor',[0.8 0.8 0.8]);
bar(2,height(sectLB1(sectLB1.Choice==1,:))/height(sectLB1),'g','FaceAlpha',0.3);

bar(3,height(sectNLB2(sectNLB2.Choice==1,:))/height(sectNLB2),'FaceColor',[0.8 0.8 0.8]);
bar(4,height(sectLB2(sectLB2.Choice==1,:))/height(sectLB2),'g','FaceAlpha',0.3);

bar(5,height(sectNLB3(sectNLB3.Choice==1,:))/height(sectNLB3),'FaceColor',[0.8 0.8 0.8]);
bar(6,height(sectLB3(sectLB3.Choice==1,:))/height(sectLB3),'g','FaceAlpha',0.3);

bar(7,height(sectNLB4(sectNLB4.Choice==1,:))/height(sectNLB4),'FaceColor',[0.8 0.8 0.8]);
bar(8,height(sectLB4(sectLB4.Choice==1,:))/height(sectLB4),'g','FaceAlpha',0.3);

bar(9,height(sectNLB5(sectNLB5.Choice==1,:))/height(sectNLB5),'FaceColor',[0.8 0.8 0.8]);
bar(10,height(sectLB5(sectLB5.Choice==1,:))/height(sectLB5),'g','FaceAlpha',0.3);

bar(11,height(sectNLB6(sectNLB6.Choice==1,:))/height(sectNLB6),'FaceColor',[0.8 0.8 0.8]);
bar(12,height(sectLB6(sectLB6.Choice==1,:))/height(sectLB6),'g','FaceAlpha',0.3);