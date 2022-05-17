%% 做VaR的预测failure rate
% this m_file is used to produce all VaR tables in need
 
clear, clc
addpath('data_Files'); % add 'data_Files' folder to the search path
load('sample')
logRet = sample(:,4);
TimeLine = datenum(sample(:,1:3));
rmpath('data_Files')
ConfidenceLevel=[0.25 0.5 1 2.5 5 7.5 10]*0.01;
FigureVaRIndex=[3,5,7];% use FigureVaRIndex of ConfidenceLevel to figure VaR
%% Short-term VaR 历史模拟法与Variance-covariance
addpath('m_Files_KupiecTest');
outsampleStart = 7058;
outsampleEnd = 7559;
hVaR = zeros(size(logRet(outsampleStart:outsampleEnd),1),7);
pVaR = zeros(size(logRet(outsampleStart:outsampleEnd),1),7);
pVaRT = zeros(size(logRet(outsampleStart:outsampleEnd),1),7);
for i = outsampleStart : outsampleEnd
    %历史模拟法
    confidence = prctile(logRet(i-251:i-1), ConfidenceLevel*100);
    hVaR(i+1-outsampleStart, :) = confidence;
    %Variance-covariance
    pVaR(i+1-outsampleStart, :) = norminv(ConfidenceLevel,mean(logRet(i-251:i-1)),std(logRet(i-251:i-1)));
    %如果VaR中分位数为t分布
    pVaRT(i+1-outsampleStart, :) = tinv(ConfidenceLevel,50)*std(logRet(i-251:i-1))+mean(logRet(i-251:i-1));% 设自由度nu=50
end
addpath('m_Files_VaR');
tableVaRPredict(hVaR,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);%历史模拟法
%                            CL1     CL2     CL3    CL4     CL5     CL6     CL7     Accuracy
%                            ____    ____    ___    ____    ____    ____    ____    ________
% 
%     Confidence Level(%)    0.25     0.5      1     2.5       5     7.5      10       NaN  
%     Failures                  2       3      7      21      35      52      67    0.9468  
%     Kupiec Statistics      0.38    0.09    0.7    4.87    3.68    5.33    5.72       NaN
tableVaRPredict(pVaR,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);%Variance-covariance
%                             CL1      CL2      CL3     CL4     CL5     CL6     CL7    Accuracy
%                            _____    _____    _____    ____    ____    ____    ___    ________
% 
%     Confidence Level(%)     0.25      0.5        1     2.5       5     7.5     10       NaN  
%     Failures                  13       15       18      27      37      42     43    0.9445  
%     Kupiec Statistics      37.57    28.97    20.35    12.9    5.22    0.53    1.2       NaN  
tableVaRPredict(pVaRT,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);%如果VaR中分位数为t分布
%                             CL1      CL2      CL3      CL4     CL5     CL6     CL7    Accuracy
%                            _____    _____    _____    _____    ____    ____    ___    ________
% 
%     Confidence Level(%)     0.25      0.5        1      2.5       5     7.5     10       NaN  
%     Failures                  13       14       18       26      36      42     43    0.9454  
%     Kupiec Statistics      37.57    25.41    20.35    11.35    4.42    0.53    1.2       NaN  
figureVaR(hVaR(:,FigureVaRIndex),logRet(outsampleStart:outsampleEnd),TimeLine(outsampleStart:outsampleEnd));
figureVaR(pVaR(:,FigureVaRIndex),logRet(outsampleStart:outsampleEnd),TimeLine(outsampleStart:outsampleEnd));
figureVaR(pVaRT(:,FigureVaRIndex),logRet(outsampleStart:outsampleEnd),TimeLine(outsampleStart:outsampleEnd));
save('results_Files\ShortHSVaR','hVaR','logRet','outsampleStart','outsampleEnd')
save('results_Files\ShortVaCovVaR','pVaR','pVaRT','logRet','outsampleStart','outsampleEnd')
rmpath('m_Files_VaR');
%% Short-term GARCH VaR 
addpath('m_Files_VaR');
addpath('m_Files_GARCHfamily');
GARCHVaR = GARCHVaRPredict(logRet,outsampleStart,outsampleEnd,250,1,'Normal',ConfidenceLevel);
tableVaRPredict(GARCHVaR,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
% (TIME: 1min)
%                             CL1     CL2     CL3     CL4     CL5     CL6     CL7     Accuracy
%                            _____    ___    _____    ____    ____    ____    ____    ________
% 
%     Confidence Level(%)     0.25    0.5        1     2.5       5     7.5      10       NaN  
%     Failures                  10     13       15      18      28      39      45    0.9522  
%     Kupiec Statistics      24.17     22    13.08    2.14    0.34    0.05    0.62       NaN  
%------ VaR中收益为t分布,以1个单位预测VaR 
% (TIME: 3min)
GARCHVaR = GARCHVaRPredict(logRet,outsampleStart,outsampleEnd,250,1,'T',ConfidenceLevel);
tableVaRPredict(GARCHVaR,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
%                             CL1      CL2      CL3     CL4     CL5     CL6    CL7     Accuracy
%                            _____    _____    _____    ____    ____    ___    ____    ________
% 
%     Confidence Level(%)     0.25      0.5        1     2.5       5    7.5      10       NaN  
%     Failures                   9       12       14      17      27     38      45    0.9539  
%     Kupiec Statistics      20.09    18.75    10.92    1.46    0.15      0    0.62       NaN      NaN 
%------ VaR中收益为t分布,以5个单位预测VaR 
% (TIME: 2min)
GARCHVaR = GARCHVaRPredict(logRet,outsampleStart,outsampleEnd,250,5,'T',ConfidenceLevel);
tableVaRPredict(GARCHVaR,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
%                             CL1     CL2    CL3     CL4     CL5     CL6     CL7     Accuracy
%                            _____    ___    ____    ____    ____    ____    ____    ________
% 
%     Confidence Level(%)     0.25    0.5       1     2.5       5     7.5      10       NaN  
%     Failures                  10     13      13      17      30      40      45    0.9522  
%     Kupiec Statistics      24.17     22    8.91    1.46    0.95    0.16    0.62       NaN  
%------ VaR中收益为t分布,以10个单位预测VaR
% (TIME: 1min)
GARCHVaR = GARCHVaRPredict(logRet,outsampleStart,outsampleEnd,250,10,'T',ConfidenceLevel);
tableVaRPredict(GARCHVaR,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
%                             CL1      CL2     CL3     CL4     CL5     CL6     CL7     Accuracy
%                            _____    _____    ____    ____    ____    ____    ____    ________
% 
%     Confidence Level(%)     0.25      0.5       1     2.5       5     7.5      10      NaN   
%     Failures                  11       12      12      17      27      35      44    0.955   
%     Kupiec Statistics      28.46    18.75    7.05    1.46    0.15    0.21    0.88      NaN 
%------ 结束调试
figureVaR(GARCHVaR(:,FigureVaRIndex),logRet(outsampleStart:outsampleEnd),TimeLine(outsampleStart:outsampleEnd));
save('results_Files\ShortGARCHVaR','GARCHVaR','logRet','outsampleStart','outsampleEnd')
rmpath('m_Files_VaR');
%% Short-term EGARCH VaR (TIME: 1min)
addpath('m_Files_VaR');
[EGARCHVaR,~] = EGARCHVaRPredict(logRet,outsampleStart,outsampleEnd,300,1,'Normal',ConfidenceLevel);
tableVaRPredict(EGARCHVaR,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
% Normal:
%                             CL1     CL2     CL3     CL4     CL5     CL6     CL7     Accuracy
%                            _____    ___    _____    ____    ____    ____    ____    ________
% 
%     Confidence Level(%)     0.25    0.5        1     2.5       5     7.5      10       NaN  
%     Failures                  10     13       15      24      31      37      45    0.9502  
%     Kupiec Statistics      24.17     22    13.08    8.49    1.36    0.01    0.62       NaN 
[EGARCHVaR,VarianceEstimate] = EGARCHVaRPredict(logRet,outsampleStart,outsampleEnd,300,1,'T',ConfidenceLevel);
tableVaRPredict(EGARCHVaR,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
% T:
%                             CL1      CL2      CL3     CL4     CL5     CL6     CL7    Accuracy
%                            _____    _____    _____    ____    ____    ____    ___    ________
% 
%     Confidence Level(%)     0.25      0.5        1     2.5       5     7.5     10      NaN   
%     Failures                  10       11       14      22      31      34     43    0.953   
%     Kupiec Statistics      24.17    15.67    10.92    5.98    1.36    0.39    1.2      NaN   
figureVaR(EGARCHVaR(:,FigureVaRIndex),logRet(outsampleStart:outsampleEnd),TimeLine(outsampleStart:outsampleEnd));
% figure;
% plot(TimeLine(outsampleStart:outsampleEnd),VarianceEstimate)
% dateaxis('x' , 12)
% max(VarianceEstimate)
% VarianceEstimate>10
save('results_Files\ShortEGARCHVaR','EGARCHVaR','logRet','outsampleStart','outsampleEnd')
rmpath('m_Files_VaR');
%% Short-term Regime Switching GARCH VaR 
addpath('m_Files_VaR');
tic;rng(123);RSGARCHVaR = RSGARCHVaRPredict(logRet,outsampleStart,outsampleEnd,250,1,'Normal',ConfidenceLevel);
tableVaRPredict(RSGARCHVaR,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
toc;
% (TIME: 31.50min)
figureVaR(RSGARCHVaR(:,FigureVaRIndex),logRet(outsampleStart:outsampleEnd),TimeLine(outsampleStart:outsampleEnd));
%                            CL1      CL2      CL3      CL4     CL5     CL6    CL7     Accuracy
%                            ____    _____    _____    _____    ____    ___    ____    ________
% 
%     Confidence Level(%)    0.25      0.5        1      2.5       5    7.5      10      NaN   
%     Failures                 24       26       28       35      41     49      57    0.926   
%     Kupiec Statistics      97.2    75.71    51.37    27.94    8.97    3.4    0.98      NaN  
% 有问题:结果比GARCH差太多
%--------实验程序
%------ VaR中收益为normal分布,以10个单位预测VaR
tic;rng(123);RSGARCHVaR = RSGARCHVaRPredict(logRet,outsampleStart,outsampleEnd,250,10,'Normal',ConfidenceLevel);tic;
% (TIME: ? min)
tableVaRPredict(RSGARCHVaR,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
%                             CL1       CL2     CL3      CL4      CL5     CL6     CL7     Accuracy
%                            ______    _____    ____    _____    _____    ____    ____    ________
% 
%     Confidence Level(%)      0.25      0.5       1      2.5        5     7.5      10       NaN  
%     Failures                   25       25      31       42       46      55      60    0.9192  
%     Kupiec Statistics      103.24    70.98    62.3    44.38    14.86    7.65    2.01       NaN  
tic;rng(123);RSGARCHVaR = RSGARCHVaRPredict(logRet,outsampleStart,outsampleEnd,250,10,'T',ConfidenceLevel);toc;
%(TIME: 6 min)
tableVaRPredict(RSGARCHVaR,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
%                             CL1      CL2      CL3      CL4      CL5     CL6     CL7     Accuracy
%                            _____    _____    _____    _____    _____    ____    ____    ________
% 
%     Confidence Level(%)     0.25      0.5        1      2.5        5     7.5      10       NaN  
%     Failures                  23       25       30       42       45      55      60    0.9203  
%     Kupiec Statistics      91.25    70.98    58.58    44.38    13.58    7.65    2.01       NaN 
% 正态分布1个单位预测VaR表现最好
%--------结束实验
save('results_Files\ShortRSGARCHVaR','RSGARCHVaR','logRet','outsampleStart','outsampleEnd')
rmpath('m_Files_VaR');
%% Short-term Regime Switching GARCH VaR (Haas Model) (TIME: 15min)
addpath('m_Files_VaR');
addpath('m_Files_swgarch');
tic;rng(123);RSGARCHVaR = RSGARCHVaRPredict_Haas(logRet,outsampleStart,outsampleEnd,250,1,'Normal',ConfidenceLevel);toc;
% (TIME: 23min)
tableVaRPredict(RSGARCHVaR,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
%                            CL1     CL2     CL3     CL4      CL5      CL6      CL7     Accuracy
%                            ____    ____    ____    ____    _____    _____    _____    ________
% 
%     Confidence Level(%)    0.25     0.5       1     2.5        5      7.5       10       NaN  
%     Failures                  4       5       6       8       11       15       19    0.9806  
%     Kupiec Statistics       3.8    1.92    0.18    1.94    10.46    18.78    27.59       NaN 
% input parameters=[0.1 0.1 0.92;0.05 0.05 0.7] 但是图像仍有问题
%                            CL1     CL2     CL3     CL4     CL5     CL6     CL7     Accuracy
%                            ____    ____    ____    ____    ____    ____    ____    ________
% 
%     Confidence Level(%)    0.25     0.5       1     2.5       5     7.5      10       NaN  
%     Failures                  6       7       9      17      26      37      39    0.9599  
%     Kupiec Statistics      9.33    5.42    2.58    1.46    0.03    0.01    2.98       NaN
figureVaR(RSGARCHVaR(:,FigureVaRIndex),logRet(outsampleStart:outsampleEnd),TimeLine(outsampleStart:outsampleEnd));
% input parameters=[0.1 0.1 0.82;0.05 0.05 0.7] 图像没问题 这个是最好的
%                             CL1      CL2     CL3     CL4     CL5     CL6     CL7     Accuracy
%                            _____    _____    ____    ____    ____    ____    ____    ________
% 
%     Confidence Level(%)     0.25      0.5       1     2.5       5     7.5      10       NaN  
%     Failures                   8       10      13      15      21      28      38    0.9622  
%     Kupiec Statistics      16.24    12.78    8.91    0.46    0.74    2.92    3.57       NaN  
% 有问题
%------ VaR中收益为t分布,以1个单位预测VaR 图像和运算都有问题
tic;rng(123);RSGARCHVaR = RSGARCHVaRPredict_Haas(logRet,outsampleStart,outsampleEnd,250,1,'T',ConfidenceLevel);toc;
figureVaR(RSGARCHVaR(:,FigureVaRIndex),logRet(outsampleStart:outsampleEnd),TimeLine(outsampleStart:outsampleEnd));
% (TIME: 2hours)
save('results_Files\ShortRSGARCHVaR','RSGARCHVaR','logRet','outsampleStart','outsampleEnd')
rmpath('m_Files_swgarch');
rmpath('m_Files_VaR');
%% Short-term GARCH Cluster Partition VaR (TIME: 30min)
addpath('m_Files_ClusterPartition');
addpath('m_Files_VaR');
tic
[GARCHclusterVaR1,GARCHclusterVaR2] = GARCHclusterVaRPredict(logRet,outsampleStart,outsampleEnd,500);
% ret 长度为500
tableVaRPredict(GARCHclusterVaR1,logRet,outsampleStart,outsampleEnd,2);
%     0.005    0.01    0.025    0.05    0.075     0.1       NaN
%        10      12       18      24       36      41    0.9532
%     12.78    7.05     2.14    0.05     0.08    1.99       NaN
tableVaRPredict(GARCHclusterVaR2,logRet,outsampleStart,outsampleEnd,2);
%     0.005    0.01    0.025    0.05    0.075     0.1       NaN
%        12      13       18      29       37      47    0.9482
%     18.75    8.91     2.14    0.61     0.01    0.23       NaN
toc
rmpath('m_Files_VaR');
rmpath('m_Files_ClusterPartition');
figureVaR(GARCHclusterVaR1(:,FigureVaRIndex),logRet(outsampleStart:outsampleEnd),TimeLine(outsampleStart:outsampleEnd));
figureVaR(GARCHclusterVaR2(:,FigureVaRIndex),logRet(outsampleStart:outsampleEnd),TimeLine(outsampleStart:outsampleEnd));
save('results_Files\ShortGARCHclusterVaR','GARCHclusterVaR1','GARCHclusterVaR2','logRet','outsampleStart','outsampleEnd')
%% Short-term EGARCH Cluster Partition VaR (TIME: 55min)
addpath('m_Files_ClusterPartition');
addpath('m_Files_VaR');
tic
[EGARCHclusterVaR1,EGARCHclusterVaR2] = EGARCHclusterVaRPredict(logRet,outsampleStart,outsampleEnd,500,1,'Normal',ConfidenceLevel);toc
tableVaRPredict(EGARCHclusterVaR1,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
%                           CL1       CL2      CL3      CL4     CL5      CL6     CL7     Accuracy
%                          ______    _____    _____    _____    ____    _____    ____    ________
% 
%     Confidence Level     0.9975    0.995     0.99    0.975    0.95    0.925     0.9       NaN  
%     Failures                 10       12       15       21      37       47      58    0.9431  
%     Kupiec Statistics     24.17    18.75    13.08     4.87    5.22     2.34    1.29       NaN 
tableVaRPredict(EGARCHclusterVaR2,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
%                           CL1       CL2      CL3      CL4     CL5      CL6     CL7     Accuracy
%                          ______    _____    _____    _____    ____    _____    ____    ________
% 
%     Confidence Level     0.9975    0.995     0.99    0.975    0.95    0.925     0.9       NaN  
%     Failures                 11       13       15       21      30       42      49    0.9485  
%     Kupiec Statistics     28.46       22    13.08     4.87    0.95     0.53    0.03       NaN  
figureVaR(EGARCHclusterVaR1(:,[3,5,7]),logRet(outsampleStart:outsampleEnd),TimeLine(outsampleStart:outsampleEnd));
figureVaR(EGARCHclusterVaR2(:,[3,5,7]),logRet(outsampleStart:outsampleEnd),TimeLine(outsampleStart:outsampleEnd));

rmpath('m_Files_VaR');
rmpath('m_Files_ClusterPartition');
save('results_Files\ShortEGARCHclusterVaR',...
    'EGARCHclusterVaR1','EGARCHclusterVaR2','logRet','outsampleStart','outsampleEnd')
%% Short-term GARCH Cluster Partition Iteration VaR 
addpath('m_Files_ClusterPartition');
addpath('m_Files_VaR');
addpath('m_Files_GARCHfamily');
[CPGARCHIterationVaR,vF1] = GARCHclusterIterationVaRPredict(logRet,outsampleStart,outsampleEnd,250,50);% (TIME :  12.28 hours)
tableVaRPredict(CPGARCHIterationVaR,logRet,outsampleStart,outsampleEnd,2);
%     0.005     0.01    0.025    0.05    0.075     0.1       NaN
%        15       20       24      27       38      47    0.9432
%     28.97    25.79     8.49    0.15        0    0.23       NaN
figureVaR(CPGARCHIterationVaR(:,[3,5,7]),logRet(outsampleStart:outsampleEnd),TimeLine(outsampleStart:outsampleEnd));
%------下面这段属于调试程序
[CPGARCHIterationVaR,vF1] = GARCHclusterIterationVaRPredict(logRet,outsampleStart,outsampleEnd,250,50,'T');% (TIME :  4.21 hours)
tableVaRPredict(CPGARCHIterationVaR,logRet,outsampleStart,outsampleEnd,2);
save('F:\structural change model\programming\programming\20210326\results_Files\ShortCPGARCHIterationVaR50T',...
    'CPGARCHIterationVaR','vF1','logRet','outsampleStart','outsampleEnd')
%     0.005     0.01    0.025    0.05    0.075     0.1       NaN
%        14       18       24      27       38      45    0.9449
%     25.41    20.35     8.49    0.15        0    0.62       NaN
[CPGARCHIterationVaR,vF1] = GARCHclusterIterationVaRPredict(logRet,outsampleStart,outsampleEnd,250,22,'T');% (TIME :  ? hours)
tableVaRPredict(CPGARCHIterationVaR,logRet,outsampleStart,outsampleEnd,2);
%     0.005    0.01    0.025    0.05    0.075    0.1        NaN
%        13      17       25      33       38     46     0.9429
%        22    17.8     9.88    2.39        0    0.4        NaN
save('F:\structural change model\programming\programming\20210326\results_Files\ShortCPGARCHIterationVaR22T',...
    'CPGARCHIterationVaR','vF1','logRet','outsampleStart','outsampleEnd')
tic
[CPGARCHIterationVaR,vF1] = GARCHclusterIterationVaRPredict(logRet,outsampleStart,outsampleEnd,250,5,'T');% (TIME :  ? hours)
tableVaRPredict(CPGARCHIterationVaR,logRet,outsampleStart,outsampleEnd,2);
toc
%     0.005    0.01    0.025    0.05    0.075     0.1       NaN
%        12      13       19      31       41      47    0.9459
%     18.75    8.91     2.94    1.36     0.31    0.23       NaN
save('F:\structural change model\programming\programming\20210326\results_Files\ShortCPGARCHIterationVaR5T',...
    'CPGARCHIterationVaR','vF1','logRet','outsampleStart','outsampleEnd')
%------调试结束
[CPGARCHIterationVaR,vF1] = GARCHclusterIterationVaRPredict(logRet,outsampleStart,outsampleEnd,250,22);% (TIME : 8.19hours)
tableVaRPredict(CPGARCHIterationVaR,logRet,outsampleStart,outsampleEnd,2);
figureVaR(CPGARCHIterationVaR(:,[3,5,7]),logRet(outsampleStart:outsampleEnd),TimeLine(outsampleStart:outsampleEnd));
%     0.005     0.01    0.025    0.05    0.075    0.1        NaN
%        14       21       26      33       39     46     0.9406
%     25.41    28.67    11.35    2.39     0.05    0.4        NaN

tic
[CPGARCHIterationVaR,vF1] = GARCHclusterIterationVaRPredict(logRet,outsampleStart,outsampleEnd,250,5);% (TIME : 63.92hours)
tableVaRPredict(CPGARCHIterationVaR,logRet,outsampleStart,outsampleEnd,2);
toc
figureVaR(CPGARCHIterationVaR(:,[3,5,7]),logRet(outsampleStart:outsampleEnd),TimeLine(outsampleStart:outsampleEnd));
%     0.005    0.01    0.025    0.05    0.075     0.1       NaN
%        13      13       22      32       41      48    0.9439
%        22    8.91     5.98    1.84     0.31    0.11       NaN

tic
[CPGARCHIterationVaR,vF1] = GARCHclusterIterationVaRPredict(logRet,outsampleStart,outsampleEnd,250,1);% (TIME : hours)
tableVaRPredict(CPGARCHIterationVaR,logRet,outsampleStart,outsampleEnd,2);
toc
figureVaR(CPGARCHIterationVaR(:,FigureVaRIndex),logRet(outsampleStart:outsampleEnd),TimeLine(outsampleStart:outsampleEnd));

rmpath('m_Files_VaR');
rmpath('m_Files_ClusterPartition');
save('F:\structural change model\programming\programming\20210326\results_Files\ShortCPGARCHIterationVaR',...
    'CPGARCHIterationVaR50T','vF1','logRet','outsampleStart','outsampleEnd')
%% Long-term VaR
addpath('m_Files_VaR');
addpath('m_Files_KupiecTest');
outsampleStart = 5044;
outsampleEnd = 7559;
hVaR = zeros(size(logRet(outsampleStart:outsampleEnd),1),7);
pVaR = zeros(size(logRet(outsampleStart:outsampleEnd),1),7);
for i = outsampleStart : outsampleEnd
    %历史模拟法
    confidence = prctile(logRet(i-251:i-1), ConfidenceLevel);
    hVaR(i+1-outsampleStart, :) = confidence;
    %参数模型法
    pVaR(i+1-outsampleStart, :) = norminv(ConfidenceLevel,mean(logRet(i-251:i-1)),std(logRet(i-251:i-1)));
end
% 历史模拟法
tableVaRPredict(hVaR,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
figureVaR(hVaR(:,FigureVaRIndex),logRet(outsampleStart:end),TimeLine(outsampleStart:end));
%     0.005    0.01    0.025    0.05    0.075     0.1       NaN
%        15      26       70     120      188     246    0.9559
%      0.44    0.03     0.79    0.29        0    0.14       NaN
%                            CL1     CL2      CL3      CL4      CL5       CL6       CL7      Accuracy
%                            ____    ____    _____    _____    ______    ______    ______    ________
% 
%     Confidence Level(%)    0.25     0.5        1      2.5         5       7.5        10       NaN  
%     Failures                 11      11       11       11        11        11        11    0.9956  
%     Kupiec Statistics      2.88    0.21    10.21    66.57    181.51    306.25    437.25       NaN  
% Variance-covariance
tableVaRPredict(pVaR,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
figureVaR(pVaR(:,FigureVaRIndex),logRet(outsampleStart:end),TimeLine(outsampleStart:end));
%     0.005     0.01    0.025    0.05    0.075      0.1       NaN
%        43       59       91     133      177      204    0.9532
%     45.23    33.35    11.34    0.43      0.8    10.63       NaN
%                             CL1      CL2      CL3      CL4     CL5     CL6      CL7     Accuracy
%                            _____    _____    _____    _____    ____    ____    _____    ________
% 
%     Confidence Level(%)     0.25      0.5        1      2.5       5     7.5       10      NaN   
%     Failures                  33       43       59       91     133     177      204    0.958   
%     Kupiec Statistics      56.24    45.21    33.32    11.32    0.42    0.81    10.67      NaN  
save('results_Files\LongHSVaR','hVaR','logRet','outsampleStart','outsampleEnd')
save('results_Files\LongVaCovVaR', 'pVaR','logRet','outsampleStart','outsampleEnd')
rmpath('m_Files_VaR');
%% Long-term GARCH VaR
addpath('m_Files_VaR');
addpath('m_Files_GARCHfamily');
% GARCHVaR = GARCHVaRPredict(logRet,outsampleStart,outsampleEnd,250);
tic;GARCHVaR = GARCHVaRPredict(logRet,outsampleStart,outsampleEnd,250,1,'Normal',ConfidenceLevel);toc;
tableVaRPredict(GARCHVaR,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
figureVaR(GARCHVaR(:,FigureVaRIndex),logRet(outsampleStart:end),TimeLine(outsampleStart:end));
%     0.005     0.01    0.025    0.05    0.075     0.1       NaN
%        45       61       99     148      199     247    0.9471
%     50.29    36.88    18.14    3.91      0.6    0.09       NaN
%                             CL1      CL2      CL3      CL4     CL5     CL6     CL7    Accuracy
%                            _____    _____    _____    _____    ____    ____    ___    ________
% 
%     Confidence Level(%)     0.25      0.5        1      2.5       5     7.5     10       NaN  
%     Failures                  36       48       62      101     145     206    245    0.9522  
%     Kupiec Statistics      66.52    58.19    38.67    20.03    2.93    1.65    0.2       NaN  
save('results_Files\LongGARCHVaR','GARCHVaR','logRet','outsampleStart','outsampleEnd')
rmpath('m_Files_GARCHfamily');
rmpath('m_Files_VaR');
%% Long-term EGARCH VaR
addpath('m_Files_VaR');
tic;EGARCHVaR = EGARCHVaRPredict(logRet,outsampleStart,outsampleEnd,250,1,'Normal',ConfidenceLevel);toc;
tableVaRPredict(EGARCHVaR,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
figureVaR(EGARCHVaR(:,FigureVaRIndex),logRet(outsampleStart:end),TimeLine(outsampleStart:end));
% (TIME: 3min)
%     0.005     0.01    0.025    0.05    0.075      0.1       NaN
%        32       46       78     119      164      200    0.9577
%     21.06    14.01     3.46    0.39     3.65    12.56       NaN
%                             CL1      CL2      CL3      CL4      CL5     CL6     CL7     Accuracy
%                            _____    _____    _____    _____    _____    ____    ____    ________
% 
%     Confidence Level(%)     0.25      0.5        1      2.5        5     7.5      10       NaN  
%     Failures                  30       50       69      119      165     206     256    0.9492  
%     Kupiec Statistics      46.52    63.68    52.28    40.79    11.73    1.65    0.08       NaN  
save('results_Files\LongEGARCHVaR','EGARCHVaR','logRet','outsampleStart','outsampleEnd')
rmpath('m_Files_VaR');
%% Long-term Regime Switching GARCH VaR
addpath('m_Files_VaR');
% RSGARCHVaR = RSGARCHVaRPredict(logRet,outsampleStart,outsampleEnd,250);
% tableVaRPredict(RSGARCHVaR,logRet,outsampleStart,outsampleEnd,2);
% %      0.005      0.01    0.025     0.05    0.075     0.1       NaN
% %         96       111      154      210      252     297    0.9258
% %     226.16    160.82    97.01    49.82    20.93    8.66       NaN
tic;RSGARCHVaR = RSGARCHVaRPredict_Haas(logRet,outsampleStart,outsampleEnd,250,1,'Normal',ConfidenceLevel);toc;
% (TIME: 2.5h)
tableVaRPredict(RSGARCHVaR,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
figureVaR(RSGARCHVaR(:,FigureVaRIndex),logRet(outsampleStart:end),TimeLine(outsampleStart:end));
%                             CL1      CL2      CL3     CL4     CL5     CL6      CL7     Accuracy
%                            _____    _____    _____    ____    ____    ____    _____    ________
% 
%     Confidence Level(%)     0.25      0.5        1     2.5       5     7.5       10       NaN  
%     Failures                  28       41       57      75     129     173      204    0.9599  
%     Kupiec Statistics      40.37    40.34    29.93    2.24    0.08    1.46    10.67       NaN  
save('results_Files\LongRSGARCHVaR','RSGARCHVaR','logRet','outsampleStart','outsampleEnd')
rmpath('m_Files_VaR');
%% Long-term GARCH Cluster Partition VaR
addpath('m_Files_ClusterPartition');
addpath('m_Files_VaR');
[GARCHclusterVaR1,GARCHclusterVaR2] = GARCHclusterVaRPredict(logRet,outsampleStart,outsampleEnd,500,1,'Normal',ConfidenceLevel);
% ret 长度为500
tableVaRPredict(GARCHclusterVaR1,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
%     0.005     0.01    0.025    0.05    0.075     0.1       NaN
%        41       56       88     143      196     228    0.9502
%     40.36    28.31     9.16    2.38      0.3    2.53       NaN
tableVaRPredict(GARCHclusterVaR2,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
%     0.005     0.01    0.025    0.05    0.075    0.1        NaN
%        45       56       88     140      180    236     0.9506
%     50.29    28.31     9.16    1.63     0.44    1.1        NaN
[GARCHclusterVaR1,GARCHclusterVaR2] = GARCHclusterVaRPredict(logRet,outsampleStart,outsampleEnd,500);
% ret 长度为250
save('results_Files\LongGARCHclusterVaR','GARCHclusterVaR1','GARCHclusterVaR2','logRet','outsampleStart','outsampleEnd')
rmpath('m_Files_VaR');
rmpath('m_Files_ClusterPartition');
%% Long-term EGARCH cluster VaR
addpath('m_Files_ClusterPartition');
addpath('m_Files_GARCHfamily');
addpath('m_Files_VaR');
[EGARCHclusterVaR1,EGARCHclusterVaR2] = EGARCHclusterVaRPredict(logRet,outsampleStart,outsampleEnd,500,1,'Normal',ConfidenceLevel);
tableVaRPredict(EGARCHclusterVaR1,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
%                           CL1       CL2      CL3      CL4      CL5      CL6     CL7     Accuracy
%                          ______    _____    _____    _____    _____    _____    ____    ________
% 
%     Confidence Level     0.9975    0.995     0.99    0.975     0.95    0.925     0.9       NaN  
%     Failures                 35       47       70      115      177      221     275    0.9466  
%     Kupiec Statistics     63.06    55.53    54.39    35.69    19.58     5.69    2.35       NaN  
tableVaRPredict(EGARCHclusterVaR2,logRet,outsampleStart,outsampleEnd,ConfidenceLevel);
%                           CL1       CL2      CL3      CL4     CL5      CL6     CL7     Accuracy
%                          ______    _____    _____    _____    ____    _____    ____    ________
% 
%     Confidence Level     0.9975    0.995     0.99    0.975    0.95    0.925     0.9      NaN   
%     Failures                 30       41       57      100     154      197     232    0.954   
%     Kupiec Statistics     46.54    40.36    29.96    19.09    6.23     0.39    1.74      NaN  
figureVaR(EGARCHclusterVaR2(:,FigureVaRIndex),logRet(outsampleStart:end),TimeLine(outsampleStart:end));
save('results_Files\LongEGARCHclusterVaR','EGARCHclusterVaR1','EGARCHclusterVaR2','logRet','outsampleStart','outsampleEnd')
rmpath('m_Files_VaR');
rmpath('m_Files_ClusterPartition');

rmpath('m_Files_ClusterPartition');
rmpath('m_Files_KupiecTest');