%% Option Prediction
clc,clear
%% 处理数据得到Option1024

% addpath('data_Files');
% load('OptionTable')
% rmpath('data_Files')
% Option = OptionTable;

% Option(Option(:,13)==0,:) = [];
% for i = 1 : size(Option,1)
%     i %#ok<NOPTS>
%     
%     Price = Option(i,1); % 市场价格
%     Strike = Option(i,10); % 执行价格
%     Rate = Option(i,12); % 无风险利率
%     Time = Option(i,13); % 时间
%     k = 10;
%     AnsCall = [];
%     AnsPut = [];
%     for CallPrice = linspace(Option(i,16),Option(i,17), k)  % 看涨期权价格
%         if CallPrice ~= 0
%             Volatility = blsimpv(Price, Strike, Rate, Time, CallPrice, [], 0, [], {'Call'});
%             if isnan(Volatility) == 0
%                 AnsCall = [AnsCall ; Volatility, CallPrice]; %#ok<AGROW>
%             end
%         end
%     end
%     for PutPrice = linspace(Option(i,18),Option(i,19), k)   % 看跌期权价格
%         if PutPrice ~= 0
%             Volatility = blsimpv(Price, Strike, Rate, Time, PutPrice, [], 0, [], {'Put'});
%             if isnan(Volatility) == 0
%                 AnsPut = [AnsPut ; Volatility, PutPrice]; %#ok<AGROW>
%             end
%         end
%     end
%     if isempty(AnsCall) == 1 || isempty(AnsPut) == 1
%         Option(i,22) = 1;
%     else
%         Option(i,14) = mean(AnsCall(:,2));
%         Option(i,15) = mean(AnsPut(:,2));
%     end
%     Ans = [AnsCall ; AnsPut];
%     if isempty(Ans) == 0
%         Option(i,20) = min(Ans(:,1));
%         Option(i,21) = max(Ans(:,1));
%     end
% end
% save('Option1024','Option')
%% 筛选期权-分为三组：in-the-money, at-the-money and out-of-the-money
addpath('m_Files_Option');
% 用xlsread导入CallandPutOption.xlsx
addpath('data_Files');
[OptionNum,OptionStr,OptionAll] = xlsread('CallandPutOption.xlsx');
% load('OptionTable')
% Option = OptionTable;
load('Option1024')
rmpath('data_Files')
% [Num,Str,All] = xlsread('F:\structural change model\option2015\option2015\CallandPutOption.xlsx');
% OptionNum = Num;
% OptionStr = Str;
% OptionAll = All;
% OptionAll{2,5} = 1;
% 删除OptionStr,OptionAll中所有距到期日时间为0的行
OptionStr(cellfun(@(x) isequal(x,0),OptionAll(:,13)) , :) = [];
OptionAll(cellfun(@(x) isequal(x,0),OptionAll(:,13)) , :) = [];
% 删除OptionNum中所有距到期日时间为0的行
OptionNum(OptionNum(:,13)==0 , :) = [];
% 把距离到期日转化为1/250
OptionNum(:,13) = OptionNum(:,13)/365;
% addpath('data_Files');
% load('Option1024')
% rmpath('data_Files')
OptionNum(:,5) = datenum(OptionNum(:,[4,2,3])); % 把到期日换成数字
OptionNum(:,9) = datenum(OptionNum(:,[8,6,7])); % 把当前日期换成数字
OptionNum(:,20:22) = Option(:,20:22); % 依次为隐含波动率最小值、隐含波动率最大值、隐含波动率是否满足call或put期权价格（1表示至少有一个不满足）
% c1 = OptionNum(:,1); %c1标的资产的价格
% fprintf('标的资产的最低价格为%2g。\n',min(c1) ); % 1992.67
% fprintf('标的资产的最高价格为%2g。\n',max(c1)  ); % 2131.72
% fprintf('标的资产的平均价格为%2g。\n',mean(c1)   ); % 2081.29
% fprintf('标的资产的价格中位数为%2g。\n',median(c1)  ); % 2090.41
% fprintf('标的资产的价格众数为%2g。\n',mode(c1)   ); % 2056.15
% fprintf('标的资产的价格标准差为%2g。\n',std(c1)  ); % 33.8823
% fprintf('标的资产的价格1/4分位数为%2g。\n',prctile(c1,5)  ); % 2019.42
% fprintf('标的资产的价格3/4分位数为%2g。\n',prctile(c1,95)  ); % 2127
% % 查看5个月SP500指数的分布图
% [y,x] = hist(c1,50);
% y=y/length(c1)/mean(diff(x));
% figure;
% bar(x,y,1)
% % 主要集中在2110附近
% c2 = OptionNum(:,10); %c2执行价格
% % 查看5个月期权执行价格的分布图
% fprintf('执行价格最低为%2g。\n',min(c2) ); % 100
% fprintf('执行价格最高为%2g。\n',max(c2)  ); % 3500
% fprintf('执行价格平均为%2g。\n',mean(c2)   ); % 1753.99
% fprintf('执行价格中位数为%2g。\n',median(c2)  ); % 1805
% fprintf('执行价格众数为%2g。\n',mode(c2)   ); % 2100
% fprintf('执行价格标准差为%2g。\n',std(c2)  ); % 434.796
% fprintf('执行价格1/4分位数为%2g。\n',prctile(c2,5)  ); % 925
% fprintf('执行价格3/4分位数为%2g。\n',prctile(c2,95)  ); % 2325
% [y,x] = hist(c2,50);
% y=y/length(c2)/mean(diff(x)); 
% figure;
% bar(x,y,1)
% % 执行价格主要还是集中在1500-2500比较多
% c3 = OptionNum(:,5); %c3到期日
% fprintf('期权到期日的最近为%2g。\n',min(c3) );
% fprintf('期权到期日的最远为%2g。\n',max(c3)  );
% % 5个月期权到期日的分布图
% figure;
% [y,x] = hist(c3,100);
% bar(x,y,1)
% dateaxis('x' , 10)
% bar(x,y,1)
% % 到期日主要还是集中在2015年到期的比较多，最远是2017年到期的
% 将行按到期日-标的价格-当前日排序
OptionSet = sortrows(OptionNum, [5,10,9]);
% 观察有多少种期权
optionFirstRank = listFirstRank(OptionSet);% optionFirstRank表示每一种期权的第一个数据的序号
fprintf('一共有%2g种期权。\n',numel(optionFirstRank) );
% 观察每种期权的数据量
optionEachNum = listEachNum(OptionSet,optionFirstRank); % optionEachNum表示每种期权的数据量
fprintf('每种期权的数据量最少为%2g。\n',min(optionEachNum) );
fprintf('每种期权的数据量最多为%2g。\n',max(optionEachNum)  );
% % 每种期权数据量的分布图
% figure;
% [y,x] = hist(optionEachNum,100);
% bar(x,y,1)
% dateaxis('x' , 10)
% % 找到数据量最少的期权的第一个序号
% optionFirstRank(optionEachNum == min(optionEachNum),:); 
% % 都是2015/5/29当日才发售的期权，由于我们的数据截止到2015/5/29，所以该类期权由于数据量小应该舍弃
% 新增第23列为该期权含有的数据量
for i = 1 : size(optionFirstRank)-1
    OptionSet( optionFirstRank(i):optionFirstRank(i+1)-1 , 23 ) = optionEachNum(i);
end
OptionSet(optionFirstRank(end):end, 23) = optionEachNum(end);
% OptionSet(OptionSet(:,23) <60,:) = [];% 删除数据量<60天的期权
% optionFirstRank = listFirstRank(OptionSet);% 还剩有1831种期权
% optionEachNum = listEachNum(OptionSet,optionFirstRank);% optionEachNum表示每种期权的数据量
% fprintf('每种期权的数据量最少为%2g。\n',min(optionEachNum) );
% fprintf('每种期权的数据量最多为%2g。\n',max(optionEachNum)  );
% % 每种期权数据量的分布图
% figure;[y,x] = hist(optionEachNum,100);%y=y/length(b)/mean(diff(x));
% bar(x,y,1)
% % 数据量为102的期权有700+种
% 只保留数据量为102的739支期权
OptionSet(OptionSet(:,23) <max(OptionSet(:,23)),:) = [];
optionFirstRank = listFirstRank(OptionSet); 
fprintf('一共有%2g种期权。\n',numel(optionFirstRank) );
% % 查看标的资产价格的分布
% c1 = OptionSet(:,1); %c1标的资产的价格
% fprintf('执行价格最低为%2g。\n',min(c1) );%1992.67
% fprintf('执行价格最高为%2g。\n',max(c1)  );%2131.72
% fprintf('执行价格平均为%2g。\n',mean(c1)   );%2079.58
% fprintf('执行价格中位数为%2g。\n',median(c1)  );%2089.07
% fprintf('执行价格众数为%2g。\n',mode(c1)   );%1992.67
% fprintf('执行价格标准差为%2g。\n',std(c1)  );%34.7851
% fprintf('执行价格0.05分位数为%2g。\n',prctile(c1,5)  );%2019.42
% fprintf('执行价格0.95分位数为%2g。\n',prctile(c1,95)  );%2124.61
% % 查看期权执行价格的分布
% c2 = OptionSet(:,10);
% [y,x] = hist(c2,50);%y=y/length(c2)/mean(diff(x)); 
% figure;bar(x,y,1)
% % 执行价格主要还是集中在600-2550比较多
% fprintf('执行价格最低为%2g。\n',min(c2) );%100
% fprintf('执行价格最高为%2g。\n',max(c2)  );%3500
% fprintf('执行价格平均为%2g。\n',mean(c2)   );%1617.98
% fprintf('执行价格中位数为%2g。\n',median(c2)  );%1650
% fprintf('执行价格众数为%2g。\n',mode(c2)   );%800
% fprintf('执行价格标准差为%2g。\n',std(c2)  );%607.507
% fprintf('执行价格5%分位数为%2g。\n',prctile(c2,5)  );%600
% fprintf('执行价格95%分位数为%2g。\n',prctile(c2,95)  );%2550
% % 到期日的分布
% c3 = OptionSet(:,5); %c3到期日
% fprintf('到期日最近为%2s。\n',datestr(min(c3),'yyyy-mm-dd') );%2015-06-19
% fprintf('到期日最远为%2s。\n',datestr(max(c3),'yyyy-mm-dd')  );%2017-12-15
% fprintf('到期日平均为%2s。\n',datestr(mean(c3),'yyyy-mm-dd')   );%2016-04-04
% fprintf('到期日中位数为%2s。\n',datestr(median(c3),'yyyy-mm-dd')  );%2015-12-31
% fprintf('到期日众数为%2s。\n',datestr(mode(c3),'yyyy-mm-dd')   );%2017-12-15
% fprintf('到期日0.05分位数为%2s。\n',datestr(prctile(c3,5),'yyyy-mm-dd')  );%2015-06-19
% fprintf('到期日0.95分位数为%2s。\n',datestr(prctile(c3,95),'yyyy-mm-dd')  );%2017-12-15
% % 查看距到期日时间的分布
% c4 = OptionSet(:,5)-OptionSet(:,9); %c4距到期日时间
% fprintf('距到期日时间最近为%2g。\n',min(c4) );%21
% fprintf('距到期日时间最远为%2g。\n',max(c4)  );%1078
% fprintf('距到期日时间平均为%2g。\n',mean(c4)   );%383.99
% fprintf('距到期日时间中位数为%2g。\n',median(c4)  );%288
% fprintf('距到期日时间众数为%2g。\n',mode(c4)   );%232
% fprintf('距到期日时间标准差为%2g。\n',std(c4)  );%286.154
% fprintf('距到期日时间0.05分位数为%2g。\n',prctile(c4,5)  );%64
% fprintf('距到期日时间0.95分位数为%2g。\n',prctile(c4,95)  );%1018
% % 查看risk-free rate的分布
% c5 = OptionSet(:,12);%c5 risk-free rate
% fprintf('risk-free rate最低为%2g。\n',roundn(min(c5),-4) );%0.003
% fprintf('risk-free rate最高为%2g。\n',roundn(max(c5),-4)  );%0.048
% fprintf('risk-free rate平均为%2g。\n',roundn(mean(c5),-4)   );%0.0129
% fprintf('risk-free rate中位数为%2g。\n',roundn(median(c5),-4)  );%0.013
% fprintf('risk-free rate众数为%2g。\n',roundn(mode(c5) ,-4)  );%0.01
% fprintf('risk-free rate标准差为%2g。\n',roundn(std(c5) ,-4) );%0.0081
% fprintf('risk-free rate 0.05分位数为%2g。\n',roundn(prctile(c5,5) ,-4) );%0.003
% fprintf('risk-free rate 0.95分位数为%2g。\n',roundn(prctile(c5,95),-4)  );%0.028
% % 查看call option price的分布
% c6 = OptionSet(:,15); % c6 call option price
% fprintf('call option price最低为%2g。\n',roundn(min(c6),-2) );%0
% fprintf('call option price最高为%2g。\n',roundn(max(c6),-2)  );%1528.5
% fprintf('call option price平均为%2g。\n',roundn(mean(c6),-2)   );%116.38
% fprintf('call option price中位数为%2g。\n',roundn(median(c6),-2)  );%32.35
% fprintf('call option price众数为%2g。\n',roundn(mode(c6) ,-2)  );%0.05
% fprintf('call option price标准差为%2g。\n',roundn(std(c6) ,-2) );%183.32
% fprintf('call option price 0.05分位数为%2g。\n',roundn(prctile(c6,5) ,-2) );%0.2
% fprintf('call option price 0.95分位数为%2g。\n',roundn(prctile(c6,95),-2)  );%505.66
% % 查看put option price的分布
% c7 = OptionSet(:,16); % c7 put option price
% fprintf('put option price最低为%2g。\n',roundn(min(c7),-2) );%0
% fprintf('put option price最高为%2g。\n',roundn(max(c7),-2)  );%2025.8
% fprintf('put option price平均为%2g。\n',roundn(mean(c7),-2)   );%546.3
% fprintf('put option price中位数为%2g。\n',roundn(median(c7),-2)  );%450.5
% fprintf('put option price众数为%2g。\n',roundn(mode(c7) ,-2)  );%0
% fprintf('put option price标准差为%2g。\n',roundn(std(c7) ,-2) );%476.3
% fprintf('put option price 0.05分位数为%2g。\n',roundn(prctile(c7,5) ,-2) );%0.65
% fprintf('put option price 0.95分位数为%2g。\n',roundn(prctile(c7,95),-2)  );%1452.96

% 执行价格大于600，小于2550的期权有659种
OptionSetExercise = OptionSet(OptionSet(:,10) < 2550,:); 
OptionSetExercise = OptionSetExercise(OptionSetExercise(:,10) > 600,:); 
listFirstRank(OptionSetExercise); 
% 将执行价格小于1500的期权作为in the money
% 将执行价格大于2200的期权作为out of the money
% 将执行价格介于中间的期权作为at the money
OptionSetExerciseOut = OptionSetExercise(OptionSetExercise(:,10) > 2200,:);
OptionSetExerciseAt = OptionSetExercise(and(OptionSetExercise(:,10) <= 2200,OptionSetExercise(:,10) >= 1500),:);
OptionSetExerciseIn = OptionSetExercise(OptionSetExercise(:,10) < 1500,:);
numel(listFirstRank(OptionSetExerciseOut)); %98支out of the money
numel(listFirstRank(OptionSetExerciseAt)); %295支at the money
numel(listFirstRank(OptionSetExerciseIn)); %266支in the money
% 建立三个cell数组
OptionSetExerciseOutCell = cell(numel(listFirstRank(OptionSetExerciseOut)),1);
OptionSetExerciseAtCell = cell(numel(listFirstRank(OptionSetExerciseAt)),1);
OptionSetExerciseInCell = cell(numel(listFirstRank(OptionSetExerciseIn)),1);
% out of the money
optionFirstRank = listFirstRank(OptionSetExerciseOut); 
optionEachNum = listEachNum(OptionSetExerciseOut,optionFirstRank);
for i = 1 : numel(optionEachNum)
    OptionSetExerciseOutCell{i,1}=OptionSetExerciseOut(optionFirstRank(i):optionFirstRank(i)+optionEachNum(i)-1,:);
end
% at the money
optionFirstRank = listFirstRank(OptionSetExerciseAt); 
optionEachNum = listEachNum(OptionSetExerciseAt,optionFirstRank);
for i = 1 : numel(optionEachNum)
    OptionSetExerciseAtCell{i,1}=OptionSetExerciseAt(optionFirstRank(i):optionFirstRank(i)+optionEachNum(i)-1,:);
end
% in the money
optionFirstRank = listFirstRank(OptionSetExerciseIn); 
optionEachNum = listEachNum(OptionSetExerciseIn,optionFirstRank);
for i = 1 : numel(optionEachNum)
    OptionSetExerciseInCell{i,1}=OptionSetExerciseIn(optionFirstRank(i):optionFirstRank(i)+optionEachNum(i)-1,:);
end
%% 对in-the-money期权价格预测
addpath('m_Files_Option');
addpath('m_Files_ClusterPartition');
% 数据预处理:重新计算期权价格
OptionSetExerciseInCell=checkOpPrice(OptionSetExerciseInCell);
% 期权价格预测
[MAE_CP,MAE_GARCH,MAE_EGARCH,MAE_RSGARCH,MSE_CP,MSE_GARCH,MSE_EGARCH,MSE_RSGARCH] =...
    optionPricePredict(OptionSetExerciseInCell);
tableOptionPredict(MAE_CP,MAE_GARCH,MAE_EGARCH,MAE_RSGARCH,MSE_CP,MSE_GARCH,MSE_EGARCH,MSE_RSGARCH)
save('results_Files\OptionPredictionIn','OptionSetExerciseInCell','MAE_CP','MAE_GARCH','MAE_EGARCH','MAE_RSGARCH','MSE_CP','MSE_GARCH','MSE_EGARCH','MSE_RSGARCH')
rmpath('m_Files_ClusterPartition');
rmpath('m_Files_Option');
%            Model           MAE_Call    MAE_Put    MSE_Call    MSE_Put
%     ___________________    ________    _______    ________    _______
% 
%     'GARCH'                8.28         8.07      306.28        264.1
%     []                     1.59        14.09       92.02       824.15
%     'EGARCH'               8.28         8.07      306.28        264.1
%     []                     1.59        14.09       92.02       824.15
%     'RSGARCH'              7.07         6.63      821.16       689.03
%     []                     2.96        11.55      1676.5      1778.35
%     'Cluster Partition'    2.32         7.75       243.8       188.86
%     []                     1.21        11.17       87.81       630.89
%% 对at-the-money期权价格预测
addpath('m_Files_Option');
addpath('m_Files_ClusterPartition');
% 数据预处理:重新计算期权价格
OptionSetExerciseAtCell=checkOpPrice(OptionSetExerciseAtCell);
% 期权价格预测
[MAE_CP,MAE_GARCH,MAE_EGARCH,MAE_RSGARCH,MSE_CP,MSE_GARCH,MSE_EGARCH,MSE_RSGARCH] =...
    optionPricePredict(OptionSetExerciseAtCell);
tableOptionPredict(MAE_CP,MAE_GARCH,MAE_EGARCH,MAE_RSGARCH,MSE_CP,MSE_GARCH,MSE_EGARCH,MSE_RSGARCH)
save('F:\structural change model\programming\programming\20210326\results_Files\OptionPredictionAt',...
    'OptionSetExerciseAtCell','MAE_CP','MAE_GARCH','MAE_EGARCH','MAE_RSGARCH','MSE_CP','MSE_GARCH','MSE_EGARCH','MSE_RSGARCH')
rmpath('m_Files_ClusterPartition');
rmpath('m_Files_Option');
%            Model           MAE_Call    MAE_Put    MSE_Call    MSE_Put 
%     ___________________    ________    _______    ________    ________
% 
%     'GARCH'                28.73        61.3       2057.37     7692.15
%     []                     31.12       62.38       4166.09    14289.79
%     'EGARCH'               28.64       61.21       2038.33     7662.52
%     []                     30.93       62.23       4107.11     14207.8
%     'RSGARCH'              16.74       45.67       5779.59     9463.26
%     []                     20.78       50.86      10460.38    15701.96
%     'Cluster Partition'      2.4       35.84           174     2603.08
%     []                       1.3       34.76        103.66     4249.13
%% 对out-of-the-money期权价格预测
addpath('m_Files_Option');
addpath('m_Files_ClusterPartition');
% 数据预处理:重新计算期权价格
OptionSetExerciseOutCell=checkOpPrice(OptionSetExerciseOutCell);
% 期权价格预测
[MAE_CP,MAE_GARCH,MAE_EGARCH,MAE_RSGARCH,MSE_CP,MSE_GARCH,MSE_EGARCH,MSE_RSGARCH] =...
    optionPricePredict(OptionSetExerciseOutCell);
tableOptionPredict(MAE_CP,MAE_GARCH,MAE_EGARCH,MAE_RSGARCH,MSE_CP,MSE_GARCH,MSE_EGARCH,MSE_RSGARCH)
% save('F:\structural change model\programming\programming\20210326\results_Files\OptionPredictionOut',...
save('results_Files\OptionPredictionOut',...
    'OptionSetExerciseOutCell','MAE_CP','MAE_GARCH','MAE_EGARCH','MAE_RSGARCH','MSE_CP','MSE_GARCH','MSE_EGARCH','MSE_RSGARCH')
rmpath('m_Files_ClusterPartition');
rmpath('m_Files_Option');
%            Model           MAE_Call    MAE_Put    MSE_Call    MSE_Put 
%     ___________________    ________    _______    ________    ________
% 
%     'GARCH'                35.83       74.35      2642.73     10333.57
%     []                     36.99       67.18      5350.35     16149.23
%     'EGARCH'               35.82       74.35      2640.79     10330.08
%     []                     36.97       67.16      5341.63     16136.49
%     'RSGARCH'              21.24       58.43      5102.86     10731.05
%     []                     26.81        56.7      8667.71     15598.29
%     'Cluster Partition'     2.34       41.21        13.75      3045.13
%     []                      1.38       32.23         8.41       3550.9
