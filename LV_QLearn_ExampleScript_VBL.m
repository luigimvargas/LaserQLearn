%% Example script for running Q model fitting and plotting

    if ~exist('SessionData','var')
       disp('load up a Bpod Session')
       uiopen 
    end
    %%
    results=table({'model'},2,3,'VariableNames',{'ModelName','MedianAcc','Likelihood'});

    %% Test Softmax
    softmaxResult=fitQModel_VBL(SessionData,'SoftMax','L');
    plotVBL(softmaxResult);
    %% Test Softmax Accuracy
    accuracyList=zeros(1,2000);
    for i=1:2000
        accuracyList(i)=modelAccuracy_VBL(softmaxResult);
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
    %% Test Softmax Decay
    softDecayResult=fitQModel_VBL(SessionData,'SoftDec','R');
    plotVBL(softDecayResult);
    %% Test Softmax with full decay accuracy
    accuracyList=zeros(1,2000);
    for i=1:2000
        accuracyList(i)=modelAccuracy_VBL(softDecayResult);
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