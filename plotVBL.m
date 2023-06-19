function plotVBL(result)
%%
    [choices,~]=extractChoices_VBL(result.SessionData);
    whichModel=result.model;
    SessionData=result.SessionData;
    maxReward=result.SessionData.TrialSettings(1).GUI.RewardAmountLarge;
    scatterSize=SessionData.nTrials/30;
    unrewardedTrials=find(cell2mat(SessionData.Rewarded)==0);
    orange = [1 0.5 0.5];
        hold on;
%         plot(1:SessionData.nTrials,(rewards(1,1:SessionData.nTrials)),'Color','b','LineWidth',3);
%             plot(1:SessionData.nTrials,(rewards(2,1:SessionData.nTrials)),'Color','r','LineWidth',3);
        xlabel('Trial Number')
        ylabel('Q Value')
        ylim([0 maxReward+1])

        legend({'Left Choice','Right Choice','LeftQValue','RightQValue'},'AutoUpdate','off','Location','southwest')
        legend('boxoff')
        history1=find(choices==1);
        history2=find(choices==2);
        scatter(history1,ones(1,length(history1))*maxReward+0.2,scatterSize,'b','filled')
        scatter(history2,ones(1,length(history2))*maxReward+0.2,scatterSize,orange,'filled')
        scatter(unrewardedTrials,ones(1,length(unrewardedTrials))*maxReward+0.4,scatterSize,'s','k','filled')
% 

            plot(1:SessionData.nTrials,result.Qvalues(1,:),'--','Color','b','LineWidth',2.5);
            plot(1:SessionData.nTrials,result.Qvalues(2,:),'--','Color',orange,'LineWidth',2.5);
%         scatter(wcL,ones(1,length(wcL))*13,'b')
%         scatter(wcR,ones(1,length(wcR))*13,'g')
        
        legend({'Left Choice','Right Choice','Unrewarded Trial','LeftQValue','RightQValue'},...
            'AutoUpdate','off','Location','southeastoutside')
        legend('boxoff')
        str=['       Alpha: ',num2str(result.alpha)];
        if whichModel=='SoftDec'
            str=['Likelihood: ',num2str(result.likelihood)...
                '    Alpha: ',num2str(result.alpha), '    Beta: ' num2str(result.beta),...
                '    Bias: ' num2str(result.bias), '    Alpha L: ' num2str(result.alphaL),...
                '    Beta L: ',num2str(result.betaL), '    Bias L: ' num2str(result.biasL)];
        end
        
        if whichModel=='SoftMax'
            str=['Likelihood: ',num2str(result.likelihood)...
                '    Alpha: ',num2str(result.alpha), '    Beta: ' num2str(result.beta),...
                '    Bias: ' num2str(result.bias), '    Alpha L: ' num2str(result.alphaL),...
                '    Beta L: ',num2str(result.betaL), '    Bias L: ' num2str(result.biasL)];
        end

        
        text(-20,13,str,'FontSize',7)
end
    