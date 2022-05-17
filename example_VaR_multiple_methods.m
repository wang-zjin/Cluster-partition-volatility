%% ����VaR����
% ��ʷģ�ⷨ������Э��������ؿ���ģ�ⷨ

clear, clc

addpath('m_Files');    % add 'm_Files' folder to the search path
addpath('m_Files_VaR');% add 'm_Files_VaR' folder to the search path
addpath('data_Files'); % add 'data_Files' folder to the search path
load('sample')
logRet=sample(:,4);

% �ʲ���ֵ
marketValuePortfolio = 1;
%��ʷ���ݵ�Histͼ
simulationResults = visualizeVar(logRet,marketValuePortfolio);

%% ��ʷģ�ⷨ
% Historical Simulation programatically
% �������� 1% �� 5% ������ˮƽ
confidence = prctile(logRet, [1 5 10]);
% ��ʷģ�ⷨ�Ŀ��ӻ�
figure;
hist2color(logRet,confidence(2), 'r', 'b');
% ��ʷģ�ⷨ 90%  95% �� 99% ˮƽ�����ռ�ֵ
hVaR = -marketValuePortfolio * confidence;
displayVaR(hVaR(1),hVaR(2),hVaR(3),'hs');

%% ����ģ�ͷ�
% Parametric
% ���� 99% 95% �� 90% ˮƽ�ķ��ռ�ֵ�����������ʷ�����̬�ֲ�
% ���� mean(returnPortfolio)���������
% ���� std(returnPortfolio)��Ϸ��գ���׼�
% ���� [.01 .05 .1] ���Ŷ���ֵ
pVaR = portvrisk(mean(logRet), std(logRet), [.01 .05 .1], marketValuePortfolio);
% ��ͼ
confidence = -pVaR / marketValuePortfolio;
figure;
hist2color(logRet, confidence(2), 'r', 'b')


%% �Ա෽��Э���
vcVaR = norminv([.01 .05 .1],mean(logRet),std(logRet)) ;

%% ���ؿ���ģ�ⷨ
addpath('m_Files_MonteCarlo');% add 'm_Files_MonteCarlo' folder to the search path
numObs = 1; % ��������
numSim = 10000; % ģ�����
% Ԥ�������뷽��
expReturn = mean(logRet);
expCov = cov(logRet);
% ����������������� rng Control the random number generator
rng(12345)
% �����ʲ������ʾ���
simulatedAssetReturns = portsim(expReturn, expCov, numObs, 1, numSim, 'Expected');
% ����ÿ��������е�������
simulatedAssetReturns = exp(squeeze(simulatedAssetReturns)) - 1;
% ģ����� numSim ��Ͷ�����������
mVaR = prctile(simulatedAssetReturns, [1 5 10]);
% ���ӻ�ģ�����
plotMonteCarlo(simulatedAssetReturns);
% ���ռ�ֵ
displayVaR(mVaR(1),mVaR(2),mVaR(3),'mcp')

%% ���ڼ��β����˶������ؿ���ģ��
% Ԥ�����������Э����ϵ��
expReturn = mean(logRet);
sigma = std(logRet);
correlation = corrcoef(logRet);
dt = 1;% time interval
numObs = 1; % ��������
numSim = 10000; % ģ�����
% ����������������� rng Control the random number generator
rng(12345)
GBM = gbm(diag(expReturn),diag(sigma), 'Correlation', correlation, 'StartState',1);
% Simulate fot numSim trials
simulatedAssetPrices = GBM.simulate(numObs, 'DeltaTime', dt, 'ntrials', numSim);
simulatedAssetReturns = tick2ret(simulatedAssetPrices, [], 'continuous');
% ����ÿ��������е�������
simulatedAssetReturns = exp(squeeze(simulatedAssetReturns)) - 1;
% ģ����� numSim ��Ͷ�����������
gbmVaR = prctile(simulatedAssetReturns, [1 5 10]);
% ���ӻ�ģ�����
figure;
plotMonteCarlo(simulatedAssetReturns);
% ���ռ�ֵ
displayVaR(gbmVaR(1),gbmVaR(2),gbmVaR(3),'mcg')






