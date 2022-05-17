%% Option Prediction
clc,clear
%% �������ݵõ�Option1024

% addpath('data_Files');
% load('OptionTable')
% rmpath('data_Files')
% Option = OptionTable;

% Option(Option(:,13)==0,:) = [];
% for i = 1 : size(Option,1)
%     i %#ok<NOPTS>
%     
%     Price = Option(i,1); % �г��۸�
%     Strike = Option(i,10); % ִ�м۸�
%     Rate = Option(i,12); % �޷�������
%     Time = Option(i,13); % ʱ��
%     k = 10;
%     AnsCall = [];
%     AnsPut = [];
%     for CallPrice = linspace(Option(i,16),Option(i,17), k)  % ������Ȩ�۸�
%         if CallPrice ~= 0
%             Volatility = blsimpv(Price, Strike, Rate, Time, CallPrice, [], 0, [], {'Call'});
%             if isnan(Volatility) == 0
%                 AnsCall = [AnsCall ; Volatility, CallPrice]; %#ok<AGROW>
%             end
%         end
%     end
%     for PutPrice = linspace(Option(i,18),Option(i,19), k)   % ������Ȩ�۸�
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
%% ɸѡ��Ȩ-��Ϊ���飺in-the-money, at-the-money and out-of-the-money
addpath('m_Files_Option');
% ��xlsread����CallandPutOption.xlsx
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
% ɾ��OptionStr,OptionAll�����оൽ����ʱ��Ϊ0����
OptionStr(cellfun(@(x) isequal(x,0),OptionAll(:,13)) , :) = [];
OptionAll(cellfun(@(x) isequal(x,0),OptionAll(:,13)) , :) = [];
% ɾ��OptionNum�����оൽ����ʱ��Ϊ0����
OptionNum(OptionNum(:,13)==0 , :) = [];
% �Ѿ��뵽����ת��Ϊ1/250
OptionNum(:,13) = OptionNum(:,13)/365;
% addpath('data_Files');
% load('Option1024')
% rmpath('data_Files')
OptionNum(:,5) = datenum(OptionNum(:,[4,2,3])); % �ѵ����ջ�������
OptionNum(:,9) = datenum(OptionNum(:,[8,6,7])); % �ѵ�ǰ���ڻ�������
OptionNum(:,20:22) = Option(:,20:22); % ����Ϊ������������Сֵ���������������ֵ�������������Ƿ�����call��put��Ȩ�۸�1��ʾ������һ�������㣩
% c1 = OptionNum(:,1); %c1����ʲ��ļ۸�
% fprintf('����ʲ�����ͼ۸�Ϊ%2g��\n',min(c1) ); % 1992.67
% fprintf('����ʲ�����߼۸�Ϊ%2g��\n',max(c1)  ); % 2131.72
% fprintf('����ʲ���ƽ���۸�Ϊ%2g��\n',mean(c1)   ); % 2081.29
% fprintf('����ʲ��ļ۸���λ��Ϊ%2g��\n',median(c1)  ); % 2090.41
% fprintf('����ʲ��ļ۸�����Ϊ%2g��\n',mode(c1)   ); % 2056.15
% fprintf('����ʲ��ļ۸��׼��Ϊ%2g��\n',std(c1)  ); % 33.8823
% fprintf('����ʲ��ļ۸�1/4��λ��Ϊ%2g��\n',prctile(c1,5)  ); % 2019.42
% fprintf('����ʲ��ļ۸�3/4��λ��Ϊ%2g��\n',prctile(c1,95)  ); % 2127
% % �鿴5����SP500ָ���ķֲ�ͼ
% [y,x] = hist(c1,50);
% y=y/length(c1)/mean(diff(x));
% figure;
% bar(x,y,1)
% % ��Ҫ������2110����
% c2 = OptionNum(:,10); %c2ִ�м۸�
% % �鿴5������Ȩִ�м۸�ķֲ�ͼ
% fprintf('ִ�м۸����Ϊ%2g��\n',min(c2) ); % 100
% fprintf('ִ�м۸����Ϊ%2g��\n',max(c2)  ); % 3500
% fprintf('ִ�м۸�ƽ��Ϊ%2g��\n',mean(c2)   ); % 1753.99
% fprintf('ִ�м۸���λ��Ϊ%2g��\n',median(c2)  ); % 1805
% fprintf('ִ�м۸�����Ϊ%2g��\n',mode(c2)   ); % 2100
% fprintf('ִ�м۸��׼��Ϊ%2g��\n',std(c2)  ); % 434.796
% fprintf('ִ�м۸�1/4��λ��Ϊ%2g��\n',prctile(c2,5)  ); % 925
% fprintf('ִ�м۸�3/4��λ��Ϊ%2g��\n',prctile(c2,95)  ); % 2325
% [y,x] = hist(c2,50);
% y=y/length(c2)/mean(diff(x)); 
% figure;
% bar(x,y,1)
% % ִ�м۸���Ҫ���Ǽ�����1500-2500�Ƚ϶�
% c3 = OptionNum(:,5); %c3������
% fprintf('��Ȩ�����յ����Ϊ%2g��\n',min(c3) );
% fprintf('��Ȩ�����յ���ԶΪ%2g��\n',max(c3)  );
% % 5������Ȩ�����յķֲ�ͼ
% figure;
% [y,x] = hist(c3,100);
% bar(x,y,1)
% dateaxis('x' , 10)
% bar(x,y,1)
% % ��������Ҫ���Ǽ�����2015�굽�ڵıȽ϶࣬��Զ��2017�굽�ڵ�
% ���а�������-��ļ۸�-��ǰ������
OptionSet = sortrows(OptionNum, [5,10,9]);
% �۲��ж�������Ȩ
optionFirstRank = listFirstRank(OptionSet);% optionFirstRank��ʾÿһ����Ȩ�ĵ�һ�����ݵ����
fprintf('һ����%2g����Ȩ��\n',numel(optionFirstRank) );
% �۲�ÿ����Ȩ��������
optionEachNum = listEachNum(OptionSet,optionFirstRank); % optionEachNum��ʾÿ����Ȩ��������
fprintf('ÿ����Ȩ������������Ϊ%2g��\n',min(optionEachNum) );
fprintf('ÿ����Ȩ�����������Ϊ%2g��\n',max(optionEachNum)  );
% % ÿ����Ȩ�������ķֲ�ͼ
% figure;
% [y,x] = hist(optionEachNum,100);
% bar(x,y,1)
% dateaxis('x' , 10)
% % �ҵ����������ٵ���Ȩ�ĵ�һ�����
% optionFirstRank(optionEachNum == min(optionEachNum),:); 
% % ����2015/5/29���ղŷ��۵���Ȩ���������ǵ����ݽ�ֹ��2015/5/29�����Ը�����Ȩ����������СӦ������
% ������23��Ϊ����Ȩ���е�������
for i = 1 : size(optionFirstRank)-1
    OptionSet( optionFirstRank(i):optionFirstRank(i+1)-1 , 23 ) = optionEachNum(i);
end
OptionSet(optionFirstRank(end):end, 23) = optionEachNum(end);
% OptionSet(OptionSet(:,23) <60,:) = [];% ɾ��������<60�����Ȩ
% optionFirstRank = listFirstRank(OptionSet);% ��ʣ��1831����Ȩ
% optionEachNum = listEachNum(OptionSet,optionFirstRank);% optionEachNum��ʾÿ����Ȩ��������
% fprintf('ÿ����Ȩ������������Ϊ%2g��\n',min(optionEachNum) );
% fprintf('ÿ����Ȩ�����������Ϊ%2g��\n',max(optionEachNum)  );
% % ÿ����Ȩ�������ķֲ�ͼ
% figure;[y,x] = hist(optionEachNum,100);%y=y/length(b)/mean(diff(x));
% bar(x,y,1)
% % ������Ϊ102����Ȩ��700+��
% ֻ����������Ϊ102��739֧��Ȩ
OptionSet(OptionSet(:,23) <max(OptionSet(:,23)),:) = [];
optionFirstRank = listFirstRank(OptionSet); 
fprintf('һ����%2g����Ȩ��\n',numel(optionFirstRank) );
% % �鿴����ʲ��۸�ķֲ�
% c1 = OptionSet(:,1); %c1����ʲ��ļ۸�
% fprintf('ִ�м۸����Ϊ%2g��\n',min(c1) );%1992.67
% fprintf('ִ�м۸����Ϊ%2g��\n',max(c1)  );%2131.72
% fprintf('ִ�м۸�ƽ��Ϊ%2g��\n',mean(c1)   );%2079.58
% fprintf('ִ�м۸���λ��Ϊ%2g��\n',median(c1)  );%2089.07
% fprintf('ִ�м۸�����Ϊ%2g��\n',mode(c1)   );%1992.67
% fprintf('ִ�м۸��׼��Ϊ%2g��\n',std(c1)  );%34.7851
% fprintf('ִ�м۸�0.05��λ��Ϊ%2g��\n',prctile(c1,5)  );%2019.42
% fprintf('ִ�м۸�0.95��λ��Ϊ%2g��\n',prctile(c1,95)  );%2124.61
% % �鿴��Ȩִ�м۸�ķֲ�
% c2 = OptionSet(:,10);
% [y,x] = hist(c2,50);%y=y/length(c2)/mean(diff(x)); 
% figure;bar(x,y,1)
% % ִ�м۸���Ҫ���Ǽ�����600-2550�Ƚ϶�
% fprintf('ִ�м۸����Ϊ%2g��\n',min(c2) );%100
% fprintf('ִ�м۸����Ϊ%2g��\n',max(c2)  );%3500
% fprintf('ִ�м۸�ƽ��Ϊ%2g��\n',mean(c2)   );%1617.98
% fprintf('ִ�м۸���λ��Ϊ%2g��\n',median(c2)  );%1650
% fprintf('ִ�м۸�����Ϊ%2g��\n',mode(c2)   );%800
% fprintf('ִ�м۸��׼��Ϊ%2g��\n',std(c2)  );%607.507
% fprintf('ִ�м۸�5%��λ��Ϊ%2g��\n',prctile(c2,5)  );%600
% fprintf('ִ�м۸�95%��λ��Ϊ%2g��\n',prctile(c2,95)  );%2550
% % �����յķֲ�
% c3 = OptionSet(:,5); %c3������
% fprintf('���������Ϊ%2s��\n',datestr(min(c3),'yyyy-mm-dd') );%2015-06-19
% fprintf('��������ԶΪ%2s��\n',datestr(max(c3),'yyyy-mm-dd')  );%2017-12-15
% fprintf('������ƽ��Ϊ%2s��\n',datestr(mean(c3),'yyyy-mm-dd')   );%2016-04-04
% fprintf('��������λ��Ϊ%2s��\n',datestr(median(c3),'yyyy-mm-dd')  );%2015-12-31
% fprintf('����������Ϊ%2s��\n',datestr(mode(c3),'yyyy-mm-dd')   );%2017-12-15
% fprintf('������0.05��λ��Ϊ%2s��\n',datestr(prctile(c3,5),'yyyy-mm-dd')  );%2015-06-19
% fprintf('������0.95��λ��Ϊ%2s��\n',datestr(prctile(c3,95),'yyyy-mm-dd')  );%2017-12-15
% % �鿴�ൽ����ʱ��ķֲ�
% c4 = OptionSet(:,5)-OptionSet(:,9); %c4�ൽ����ʱ��
% fprintf('�ൽ����ʱ�����Ϊ%2g��\n',min(c4) );%21
% fprintf('�ൽ����ʱ����ԶΪ%2g��\n',max(c4)  );%1078
% fprintf('�ൽ����ʱ��ƽ��Ϊ%2g��\n',mean(c4)   );%383.99
% fprintf('�ൽ����ʱ����λ��Ϊ%2g��\n',median(c4)  );%288
% fprintf('�ൽ����ʱ������Ϊ%2g��\n',mode(c4)   );%232
% fprintf('�ൽ����ʱ���׼��Ϊ%2g��\n',std(c4)  );%286.154
% fprintf('�ൽ����ʱ��0.05��λ��Ϊ%2g��\n',prctile(c4,5)  );%64
% fprintf('�ൽ����ʱ��0.95��λ��Ϊ%2g��\n',prctile(c4,95)  );%1018
% % �鿴risk-free rate�ķֲ�
% c5 = OptionSet(:,12);%c5 risk-free rate
% fprintf('risk-free rate���Ϊ%2g��\n',roundn(min(c5),-4) );%0.003
% fprintf('risk-free rate���Ϊ%2g��\n',roundn(max(c5),-4)  );%0.048
% fprintf('risk-free rateƽ��Ϊ%2g��\n',roundn(mean(c5),-4)   );%0.0129
% fprintf('risk-free rate��λ��Ϊ%2g��\n',roundn(median(c5),-4)  );%0.013
% fprintf('risk-free rate����Ϊ%2g��\n',roundn(mode(c5) ,-4)  );%0.01
% fprintf('risk-free rate��׼��Ϊ%2g��\n',roundn(std(c5) ,-4) );%0.0081
% fprintf('risk-free rate 0.05��λ��Ϊ%2g��\n',roundn(prctile(c5,5) ,-4) );%0.003
% fprintf('risk-free rate 0.95��λ��Ϊ%2g��\n',roundn(prctile(c5,95),-4)  );%0.028
% % �鿴call option price�ķֲ�
% c6 = OptionSet(:,15); % c6 call option price
% fprintf('call option price���Ϊ%2g��\n',roundn(min(c6),-2) );%0
% fprintf('call option price���Ϊ%2g��\n',roundn(max(c6),-2)  );%1528.5
% fprintf('call option priceƽ��Ϊ%2g��\n',roundn(mean(c6),-2)   );%116.38
% fprintf('call option price��λ��Ϊ%2g��\n',roundn(median(c6),-2)  );%32.35
% fprintf('call option price����Ϊ%2g��\n',roundn(mode(c6) ,-2)  );%0.05
% fprintf('call option price��׼��Ϊ%2g��\n',roundn(std(c6) ,-2) );%183.32
% fprintf('call option price 0.05��λ��Ϊ%2g��\n',roundn(prctile(c6,5) ,-2) );%0.2
% fprintf('call option price 0.95��λ��Ϊ%2g��\n',roundn(prctile(c6,95),-2)  );%505.66
% % �鿴put option price�ķֲ�
% c7 = OptionSet(:,16); % c7 put option price
% fprintf('put option price���Ϊ%2g��\n',roundn(min(c7),-2) );%0
% fprintf('put option price���Ϊ%2g��\n',roundn(max(c7),-2)  );%2025.8
% fprintf('put option priceƽ��Ϊ%2g��\n',roundn(mean(c7),-2)   );%546.3
% fprintf('put option price��λ��Ϊ%2g��\n',roundn(median(c7),-2)  );%450.5
% fprintf('put option price����Ϊ%2g��\n',roundn(mode(c7) ,-2)  );%0
% fprintf('put option price��׼��Ϊ%2g��\n',roundn(std(c7) ,-2) );%476.3
% fprintf('put option price 0.05��λ��Ϊ%2g��\n',roundn(prctile(c7,5) ,-2) );%0.65
% fprintf('put option price 0.95��λ��Ϊ%2g��\n',roundn(prctile(c7,95),-2)  );%1452.96

% ִ�м۸����600��С��2550����Ȩ��659��
OptionSetExercise = OptionSet(OptionSet(:,10) < 2550,:); 
OptionSetExercise = OptionSetExercise(OptionSetExercise(:,10) > 600,:); 
listFirstRank(OptionSetExercise); 
% ��ִ�м۸�С��1500����Ȩ��Ϊin the money
% ��ִ�м۸����2200����Ȩ��Ϊout of the money
% ��ִ�м۸�����м����Ȩ��Ϊat the money
OptionSetExerciseOut = OptionSetExercise(OptionSetExercise(:,10) > 2200,:);
OptionSetExerciseAt = OptionSetExercise(and(OptionSetExercise(:,10) <= 2200,OptionSetExercise(:,10) >= 1500),:);
OptionSetExerciseIn = OptionSetExercise(OptionSetExercise(:,10) < 1500,:);
numel(listFirstRank(OptionSetExerciseOut)); %98֧out of the money
numel(listFirstRank(OptionSetExerciseAt)); %295֧at the money
numel(listFirstRank(OptionSetExerciseIn)); %266֧in the money
% ��������cell����
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
%% ��in-the-money��Ȩ�۸�Ԥ��
addpath('m_Files_Option');
addpath('m_Files_ClusterPartition');
% ����Ԥ����:���¼�����Ȩ�۸�
OptionSetExerciseInCell=checkOpPrice(OptionSetExerciseInCell);
% ��Ȩ�۸�Ԥ��
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
%% ��at-the-money��Ȩ�۸�Ԥ��
addpath('m_Files_Option');
addpath('m_Files_ClusterPartition');
% ����Ԥ����:���¼�����Ȩ�۸�
OptionSetExerciseAtCell=checkOpPrice(OptionSetExerciseAtCell);
% ��Ȩ�۸�Ԥ��
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
%% ��out-of-the-money��Ȩ�۸�Ԥ��
addpath('m_Files_Option');
addpath('m_Files_ClusterPartition');
% ����Ԥ����:���¼�����Ȩ�۸�
OptionSetExerciseOutCell=checkOpPrice(OptionSetExerciseOutCell);
% ��Ȩ�۸�Ԥ��
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
