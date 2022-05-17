clc,clear
%% ��������
addpath('data_Files'); % add 'data_Files' folder to the search path
load('sample')
logRet = sample(:,4);% ������
start_long = 5044;
start_short = 7058;
endTime = 7559; 
TimeLine = datenum(sample(:,1:3));
T = length(logRet); 
%% Unit root test
% ADF test
%  h = 0 indicate that tests fail to reject the null hypothesis of a unit root against the trend-stationary alternative.
%% ARCHЧӦ����
errors = logRet - mean(logRet); % Returns fluctuate at constant level
[h,pValue,stat,cValue] = archtest(errors,'Alpha',[0.01; 0.05; 0.1]);  % Engle test for residual heteroscedasticity
pValue=roundn(pValue,-2);stat=roundn(stat,-2);cValue=roundn(cValue,-2);
table(h,pValue,stat,cValue)
%% GARCH��������
addpath('m_Files_GARCHfamily')
sigma2=estimateGARCH(logRet,garch(1,1));
%% ����������ͼ��,figure1
figure;
plot(TimeLine, sigma2, 'k')
xlim([TimeLine(1),TimeLine(end)])
xlabel('Year')
ylabel('Volatility')
dateaxis('x' , 10, TimeLine(1))
set(gcf,'Position',[500 500 900 300]);
%% ���ŷָ
addpath('m_Files_ClusterPartition');
addpath('results_Files');
% [LB,J,D] = Fisher_div_sqr(T,sigma2,5);  
% save('F:\structural change model\programming\programming\20210326\results_Files\GARCHCP2018','LB','J','D','sigma2'); 
load('GARCHCP2018');% D��ֱ��    LB��������ʧ����   J�����һ������ķָ��
% ����Ƿ����һ����Ϊһ������
test1ElementCluster(J,T,250)
% Clusterͳ���� �����һ��,figure2
CPstatisticFigure(sigma2,TimeLine,5,7309,endTime)
% Graphicȷ�������� K,figure3
ClusterNumberGraphic(LB,T,800)
% Slopeȷ��������,figure4
ClusterNumberSlope(LB,T,800)
% ������Ϣͳ����,figure5
ClusterNumberInforStatistic(LB,T,800)
% GARCH-CPģ��,figure6-8
addpath('m_Files_VaR');
sigma2_CP = Vol_ClusterPartition(sigma2,331,J);
figureVolatility(sigma2_CP,TimeLine,'Volatility');
sigma2_CP = Vol_ClusterPartition(sigma2,100,J);
figureVolatility(sigma2_CP,TimeLine,'Volatility');
sigma2_CP = Vol_ClusterPartition(sigma2,30,J);
figureVolatility(sigma2_CP,TimeLine,'Volatility');
%% ��ģ��VaR��ʵ�������ʵĶԱ�
addpath('results_Files');
load('ShortHSVaR')
figureVaR(hVaR(:,[3,5,7]),logRet(start_short:end),TimeLine(start_short:end));
load('ShortVaCovVaR')
figureVaR(pVaR(:,[3,5,7]),logRet(start_short:end),TimeLine(start_short:end));
load('ShortGARCHVaR')
figureVaR(GARCHVaR(:,[3,5,7]),logRet(start_short:end),TimeLine(start_short:end));
load('ShortEGARCHVaR')
figureVaR(EGARCHVaR(:,[3,5,7]),logRet(start_short:end),TimeLine(start_short:end));
load('ShortRSGARCHVaR')
figureVaR(RSGARCHVaR(:,[3,5,7]),logRet(start_short:end),TimeLine(start_short:end));
load('ShortGARCHclusterVaR')
figureVaR(GARCHclusterVaR1(:,[3,5,7]),logRet(start_short:end),TimeLine(start_short:end));
load('ShortEGARCHclusterVaR')
figureVaR(EGARCHclusterVaR1(:,[3,5,7]),logRet(start_short:end),TimeLine(start_short:end));

load('LongHSVaR')
figureVaR(hVaR(:,[3,5,7]),logRet(start_long:end),TimeLine(start_long:end));
load('LongVaCovVaR')
figureVaR(pVaR(:,[3,5,7]),logRet(start_long:end),TimeLine(start_long:end));
load('LongGARCHVaR')
figureVaR(GARCHVaR(:,[3,5,7]),logRet(start_long:end),TimeLine(start_long:end));
load('LongEGARCHVaR')
figureVaR(EGARCHVaR(:,[3,5,7]),logRet(start_long:end),TimeLine(start_long:end));
load('LongRSGARCHVaR')
figureVaR(RSGARCHVaR(:,[3,5,7]),logRet(start_long:end),TimeLine(start_long:end));
load('LongGARCHclusterVaR')
figureVaR(GARCHclusterVaR1(:,[3,5,7]),logRet(start_long:end),TimeLine(start_long:end));
load('LongEGARCHclusterVaR')
figureVaR(EGARCHclusterVaR1(:,[3,5,7]),logRet(start_long:end),TimeLine(start_long:end));
%% Option prediction
load('results_Files\OptionPredictionAt')
tableOptionPredict(MAE_CP,MAE_GARCH,MAE_EGARCH,MAE_RSGARCH,MSE_CP,MSE_GARCH,MSE_EGARCH,MSE_RSGARCH)
load('results_Files\OptionPredictionIn')
tableOptionPredict(MAE_CP,MAE_GARCH,MAE_EGARCH,MAE_RSGARCH,MSE_CP,MSE_GARCH,MSE_EGARCH,MSE_RSGARCH)
load('results_Files\OptionPredictionOut')
tableOptionPredict(MAE_CP,MAE_GARCH,MAE_EGARCH,MAE_RSGARCH,MSE_CP,MSE_GARCH,MSE_EGARCH,MSE_RSGARCH)

rmpath('m_Files_ClusterPartition');
rmpath('results_Files');
rmpath('m_Files_VaR');
rmpath('data_Files');
