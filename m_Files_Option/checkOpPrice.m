function OptionSetExerciseAtCell=checkOpPrice(OptionSetExerciseAtCell)

t1=cputime;
for i=1:numel(OptionSetExerciseAtCell)
%     i %#ok<NOPRT>
    t2=cputime;
    fprintf('The check process is %2.2f%% and will finish in %6.2f minutes.\n',...
        i/numel(OptionSetExerciseAtCell)*100,... 
        (t2-t1)*(numel(OptionSetExerciseAtCell)/i-1)/60);
    % extract option
    underlydingOption=OptionSetExerciseAtCell{i,1};
    
    for T = 1: size(underlydingOption,1)
        
        % option parameter
        rfRate = underlydingOption(T,12); % risk-free rate
        Price = underlydingOption(T,1)*exp(rfRate/250); % stock price
        Strike = underlydingOption(T,10); % strike price
        Time = underlydingOption(T,13); % time to maturuty date
        
        k = 10;
        AnsCall = [];
        for CallPrice = linspace(underlydingOption(T,16)-20,underlydingOption(T,17)+20, k)  % 看涨期权价格
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
            for CallPrice = linspace(underlydingOption(T,16)-kk,underlydingOption(T,17)+kk, k)  % 看涨期权价格
                if CallPrice > 0
                    Volatility = blsimpv(Price, Strike, rfRate, Time, CallPrice, [], 0, [], {'Call'});
                    if isnan(Volatility) == 0
                        AnsCall = [AnsCall ; Volatility, CallPrice]; %#ok<AGROW>
                    end
                end
            end
        end
        if isempty(AnsCall) == 1
            underlydingOption(T,22) = 1;
        else
            underlydingOption(T,22) = 0;
            underlydingOption(T,20) = min(AnsCall(:,1));
            underlydingOption(T,21) = max(AnsCall(:,1));
            underlydingOption(T,14) = mean(AnsCall(:,2));
            underlydingOption(T,11) = mean(underlydingOption(T,20:21));
        end
    end
    OptionSetExerciseAtCell{i,1}=underlydingOption;
end