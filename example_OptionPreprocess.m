%% 处理数据得到Option1024

addpath('data_Files');
load('OptionTable')
rmpath('data_Files')
Option = OptionTable;

addpath('m_Files_Option');
% 删除到期的数据
Option(Option(:,13)==0,:) = [];
% 把距离到期日转化为1/250
Option(:,13) = Option(:,13)/250;
% 新增第23列为该期权含有的数据量
for i = 1 : size(optionFirstRank)-1
    OptionSet( optionFirstRank(i):optionFirstRank(i+1)-1 , 23 ) = optionEachNum(i);
end
OptionSet(optionFirstRank(end):end, 23) = optionEachNum(end);
OptionSet(OptionSet(:,23) <60,:) = [];% 删除数据量<60天的期权
for T = 1: size(underlydingOption,1)
        
        % option parameter
        rfRate = underlydingOption(T,12); % risk-free rate
        Price = underlydingOption(T,1)*exp(rfRate/250); % stock price
        Strike = underlydingOption(T,10); % strike price
        Time = underlydingOption(T,13); % time to maturuty date
        
        k = 10;
        AnsCall = [];
        for CallPrice = linspace(underlydingOption(i,16)-20,underlydingOption(i,17)+20, k)  % 看涨期权价格
            if CallPrice > 0
                Volatility = blsimpv(Price, Strike, rfRate, Time, CallPrice, [], 0, [], {'Call'});
                if isnan(Volatility) == 0
                    AnsCall = [AnsCall ; Volatility, CallPrice]; %#ok<AGROW>
                end
            end
        end
        kk = 0;
        while isempty(AnsCall) ==1
            kk = kk + Price/100;
            for CallPrice = linspace(underlydingOption(i,16)-kk,underlydingOption(i,17)+kk, k)  % 看涨期权价格
                if CallPrice > 0
                    Volatility = blsimpv(Price, Strike, rfRate, Time, CallPrice, [], 0, [], {'Call'});
                    if isnan(Volatility) == 0
                        AnsCall = [AnsCall ; Volatility, CallPrice]; %#ok<AGROW>
                    end
                end
            end
        end
        if isempty(AnsCall) == 1
            underlydingOption(i,22) = 1;
        else
            underlydingOption(i,22) = 0;
            underlydingOption(i,20) = min(AnsCall(:,1));
            underlydingOption(i,21) = max(AnsCall(:,1));
            underlydingOption(i,14) = mean(AnsCall(:,2));
            underlydingOption(i,11) = mean(underlydingOption(i,20:21));
        end
end
    
save('Option1024','Option')