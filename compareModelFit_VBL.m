%% Compare Model Fit
function [acc]=compareModelFit_VB(SessionData,alpha,doWePlot,whichModel,beta,decay,invAlpha)
    if ~exist('SessionData','var')
       uiopen 
    end
    %% Check Model Fit    
    [choices,rewards]=extractChoices_VB(SessionData);
    weightedChoices = zeros(1,length(choices));
    if whichModel=='Alpha2W'
        [choiceProbabilities, weights,~]=LV_QLearn_Softmax_2wayalpha_VB(SessionData,alpha,beta,invAlpha);
        wcL=find(weightedChoices==1);
        wcR=find(weightedChoices==2);
        choices = choices - 1;
        acc = -(transpose(choices(:))*log(choiceProbabilities(2,:))' + transpose((1-choices(:)))*log(choiceProbabilities(1,:))') ; %note that this is matrix multiplication so we get 1 values which will be a sum. See mtimes in matlab help
    elseif whichModel=='Dec2way'
        [choiceProbabilities, weights,~]=LV_QLearn_SoftmaxDecay_2wayalpha_VB(SessionData,alpha,beta,decay,invAlpha);
        wcL=find(weightedChoices==1);
        wcR=find(weightedChoices==2);
        choices = choices - 1;
        acc = -(transpose(choices(:))*log(choiceProbabilities(2,:))' + transpose((1-choices(:)))*log(choiceProbabilities(1,:))') ; %note that this is matrix multiplication so we get 1 values which will be a sum. See mtimes in matlab help
    elseif whichModel=='SoftMax'
        [choiceProbabilities, weights,~]=LV_QLearn_Softmax_VB(SessionData,alpha,beta);
        wcL=find(weightedChoices==1);
        wcR=find(weightedChoices==2);
        choices = choices - 1;
        acc = -(transpose(choices(:))*log(choiceProbabilities(2,:))' + transpose((1-choices(:)))*log(choiceProbabilities(1,:))') ; %note that this is matrix multiplication so we get 1 values which will be a sum. See mtimes in matlab help
    elseif whichModel=='SoftDec'
        [choiceProbabilities, weights,~]=LV_QLearn_SoftmaxDecay_VB(SessionData,alpha,beta,decay);
        wcL=find(weightedChoices==1);
        wcR=find(weightedChoices==2);
        choices = choices - 1;
        acc = -(transpose(choices(:))*log(choiceProbabilities(2,:))' + transpose((1-choices(:)))*log(choiceProbabilities(1,:))') ;%note that this is matrix multiplication so we get 1 values which will be a sum. See mtimes in matlab help
    elseif whichModel=='Qstable'
        [choiceProbabilities, weights,~]=LV_QLearn_QstableDecay_VB(SessionData,alpha,decay);
        wcL=find(weightedChoices==1);
        wcR=find(weightedChoices==2);
        choices = choices - 1;
        acc = -(transpose(choices(:))*log(choiceProbabilities(2,:))' + transpose((1-choices(:)))*log(choiceProbabilities(1,:))') ;%note that this is matrix multiplication so we get 1 values which will be a sum. See mtimes in matlab help
    
    end

    if doWePlot==true
        figure()
        hold on;
        plot(1:SessionData.nTrials,(rewards(1,1:SessionData.nTrials)),'Color','b','LineWidth',3);
            plot(1:SessionData.nTrials,(rewards(2,1:SessionData.nTrials)),'Color','o','LineWidth',3);
        xlabel('Trial Number')
        ylabel('Q Value')
        ylim([0 14])

%         legend({'Left Port','Center Port','Right Port','Unrewarded Trial','Exploit'},'AutoUpdate','off','Location','southwest')
%         legend('boxoff')
        history1=find(choices==0);
        history2=find(choices==1);
        scatter(history1,ones(1,length(history1))*12.5,'b','filled')
        scatter(history2,ones(1,length(history2))*12.5,'o','filled')
% 

            plot(1:SessionData.nTrials,weights(1,:),'--','Color','b','LineWidth',2.5);
            plot(1:SessionData.nTrials,weights(2,:),'--','Color','o','LineWidth',2.5);
        scatter(wcL,ones(1,length(wcL))*13,'b')
        scatter(wcR,ones(1,length(wcR))*13,'o')
        
        str=['Accuracy: ',num2str(acc), '       Alpha: ',num2str(alpha)];
        if whichModel=='SoftDec'
            str=['Accuracy: ',num2str(acc), '       Alpha: ',num2str(alpha), '       Beta: ' num2str(beta)];
        end
        if whichModel=='SoftMax'
            str=['Accuracy: ',num2str(acc), '       Alpha: ',num2str(alpha), '       Beta: ' num2str(beta)];
        end
        text(90,13.5,str)
    end
    
end