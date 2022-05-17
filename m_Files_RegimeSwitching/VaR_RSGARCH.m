%% Regime Switching GARCH模型VaR
function backtest = VaR_RSGARCH(start,till,ret,sigma2)


backtest1 = zeros(length(start:till),1);
backtest2 = zeros(length(start:till),1);
backtest3 = zeros(length(start:till),1);
for i = 1 : length(backtest1)
    PortReturn = mean(   ret(start+i-1-250:start+i-1-1)  );
    PortRisk = sqrt(   sigma2( start+i-1 ) );   
    norminv(0.05,0,1)*PortRisk + PortReturn;
    % 等价于 norminv(0.05,PortReturn,PortRisk)
    
    ValueAtRisk1 = exp( norminv(0.01,PortReturn,PortRisk) ) - 1;
    ValueAtRisk2 = exp( norminv(0.05,PortReturn,PortRisk) ) - 1;
    ValueAtRisk3 = exp( norminv(0.1,PortReturn,PortRisk) ) - 1;
    backtest1(i) = ValueAtRisk1;
    backtest2(i) = ValueAtRisk2;
    backtest3(i) = ValueAtRisk3;
end
backtest.backtest1 = backtest1;
backtest.backtest2 = backtest2;
backtest.backtest3 = backtest3;