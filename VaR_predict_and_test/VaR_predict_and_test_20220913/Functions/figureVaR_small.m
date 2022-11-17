% To draw a subfigure in VaR plot
%
% Input:
%
%        VaR                     Predicted VaR
%
%        ret                     Log return of out-of-sample
%
%           TimeLine             Out-of-sample time
%
% Output:
%

function figureVaR_small(VaR,ret,TimeLine)
plot(TimeLine, ret, 'k' )
hold on 
plot(TimeLine, VaR(:,1), 'k:')
hold on 
plot(TimeLine, VaR(:,2),'k-.')
hold on 
plot(TimeLine, VaR(:,3),'k--')
xlim([TimeLine(1),TimeLine(end)])
%xlabel('Year')
%ylabel('Value at Risk')
% str1 = 'VaR Estimation by Volatility Structural Change Model with K=';
% str2 = num2str(K);
% MakeTitle = strcat(str1,str2);
% title(MakeTitle)
%legend('Real loss','99% Confidence Level','95% Confidence Level','90% Confidence Level','Location', 'best')
dateaxis('x' , 12)
%set(gcf,'Position',[500 500 900 300]);
end

