%% 各种VaR方法
% 历史模拟法，方差协方差法，蒙特卡洛模拟法

clear, clc

addpath('m_Files');    % add 'm_Files' folder to the search path
addpath('m_Files_VaR');% add 'm_Files_VaR' folder to the search path
addpath('data_Files'); % add 'data_Files' folder to the search path
load('sample')
logRet=sample(:,4);

% 资产价值
marketValuePortfolio = 1;
%历史数据的Hist图
simulationResults = visualizeVar(logRet,marketValuePortfolio);

%% 历史模拟法
% Historical Simulation programatically
% 收益率在 1% 与 5% 的置信水平
confidence = prctile(logRet, [1 5 10]);
% 历史模拟法的可视化
figure;
hist2color(logRet,confidence(2), 'r', 'b');
% 历史模拟法 90%  95% 与 99% 水平的在险价值
hVaR = -marketValuePortfolio * confidence;
displayVaR(hVaR(1),hVaR(2),hVaR(3),'hs');

%% 参数模型法
% Parametric
% 计算 99% 95% 和 90% 水平的风险价值，假设收益率服从正态分布
% 输入 mean(returnPortfolio)组合收益率
% 输入 std(returnPortfolio)组合风险（标准差）
% 输入 [.01 .05 .1] 置信度阈值
pVaR = portvrisk(mean(logRet), std(logRet), [.01 .05 .1], marketValuePortfolio);
% 画图
confidence = -pVaR / marketValuePortfolio;
figure;
hist2color(logRet, confidence(2), 'r', 'b')


%% 自编方差协方差法
vcVaR = norminv([.01 .05 .1],mean(logRet),std(logRet)) ;

%% 蒙特卡罗模拟法
addpath('m_Files_MonteCarlo');% add 'm_Files_MonteCarlo' folder to the search path
numObs = 1; % 样本个数
numSim = 10000; % 模拟个数
% 预期期望与方差
expReturn = mean(logRet);
expCov = cov(logRet);
% 随机生成数种子设置 rng Control the random number generator
rng(12345)
% 生成资产收益率矩阵
simulatedAssetReturns = portsim(expReturn, expCov, numObs, 1, numSim, 'Expected');
% 计算每个随机序列的收益率
simulatedAssetReturns = exp(squeeze(simulatedAssetReturns)) - 1;
% 模拟次数 numSim 个投资组合收益率
mVaR = prctile(simulatedAssetReturns, [1 5 10]);
% 可视化模拟组合
plotMonteCarlo(simulatedAssetReturns);
% 在险价值
displayVaR(mVaR(1),mVaR(2),mVaR(3),'mcp')

%% 基于几何布朗运动的蒙特卡洛模拟
% 预期期望、方差、协方差系数
expReturn = mean(logRet);
sigma = std(logRet);
correlation = corrcoef(logRet);
dt = 1;% time interval
numObs = 1; % 样本个数
numSim = 10000; % 模拟个数
% 随机生成数种子设置 rng Control the random number generator
rng(12345)
GBM = gbm(diag(expReturn),diag(sigma), 'Correlation', correlation, 'StartState',1);
% Simulate fot numSim trials
simulatedAssetPrices = GBM.simulate(numObs, 'DeltaTime', dt, 'ntrials', numSim);
simulatedAssetReturns = tick2ret(simulatedAssetPrices, [], 'continuous');
% 计算每个随机序列的收益率
simulatedAssetReturns = exp(squeeze(simulatedAssetReturns)) - 1;
% 模拟次数 numSim 个投资组合收益率
gbmVaR = prctile(simulatedAssetReturns, [1 5 10]);
% 可视化模拟组合
figure;
plotMonteCarlo(simulatedAssetReturns);
% 在险价值
displayVaR(gbmVaR(1),gbmVaR(2),gbmVaR(3),'mcg')






