function tableOptionPredict(MAE_CP,MAE_GARCH,MAE_EGARCH,MAE_RSGARCH,MSE_CP,MSE_GARCH,MSE_EGARCH,MSE_RSGARCH)
 
format long
Model={'GARCH';[];'EGARCH';[];'RSGARCH';[];'Cluster Partition';[]};
MAE_Call=[roundn(mean(MAE_GARCH(:,1)),-2);roundn(std(MAE_GARCH(:,1)),-2);roundn(mean(MAE_EGARCH(:,1)),-2);roundn(std(MAE_EGARCH(:,1)),-2);...
    roundn(mean(MAE_RSGARCH(:,1)),-2);roundn(std(MAE_RSGARCH(:,1)),-2);roundn(mean(MAE_CP(:,1)),-2);roundn(std(MAE_CP(:,1)),-3)];
MAE_Put=[roundn(mean(MAE_GARCH(:,2)),-2);roundn(std(MAE_GARCH(:,2)),-2);roundn(mean(MAE_EGARCH(:,2)),-2);roundn(std(MAE_EGARCH(:,2)),-2);...
    roundn(mean(MAE_RSGARCH(:,2)),-2);roundn(std(MAE_RSGARCH(:,2)),-2);roundn(mean(MAE_CP(:,2)),-2);roundn(std(MAE_CP(:,2)),-2)];
MSE_Call=[roundn(mean(MSE_GARCH(:,1)),-2);roundn(std(MSE_GARCH(:,1)),-2);roundn(mean(MSE_EGARCH(:,1)),-2);roundn(std(MSE_EGARCH(:,1)),-2);...
    roundn(mean(MSE_RSGARCH(:,1)),-2);roundn(std(MSE_RSGARCH(:,1)),-2);roundn(mean(MSE_CP(:,1)),-2);roundn(std(MSE_CP(:,1)),-2)];
MSE_Put=[roundn(mean(MSE_GARCH(:,2)),-2);roundn(std(MSE_GARCH(:,2)),-2);roundn(mean(MSE_EGARCH(:,2)),-2);roundn(std(MSE_EGARCH(:,2)),-2);...
    roundn(mean(MSE_RSGARCH(:,2)),-2);roundn(std(MSE_RSGARCH(:,2)),-2);roundn(mean(MSE_CP(:,2)),-2);roundn(std(MSE_CP(:,2)),-2)];
table(Model,MAE_Call,MAE_Put,MSE_Call,MSE_Put)


% fprintf('用Cluster Partition模型估计出来的看涨期权价格MAE为%2g。\n',mean(MAE_CP(:,1))  );%2.40363
% fprintf('用Cluster Partition模型估计出来的看涨期权价格MAE标准差为%2g。\n',std(MAE_CP(:,1))  );%1.29983
% fprintf('用Cluster Partition模型估计出来的看跌期权价格MAE为%2g。\n',mean(MAE_CP(:,2))  );%35.8409
% fprintf('用Cluster Partition模型估计出来的看跌期权价格MAE标准差为%2g。\n',std(MAE_CP(:,2))  );%34.7614
% fprintf('用Cluster Partition模型估计出来的看涨期权价格MSE为%2g。\n',mean(MSE_CP(:,1))  );%174.005
% fprintf('用Cluster Partition模型估计出来的看涨期权价格MSE标准差为%2g。\n',std(MSE_CP(:,1))  );%103.655
% fprintf('用Cluster Partition模型估计出来的看跌期权价格MSE为%2g。\n',mean(MSE_CP(:,2))  );%2603.08
% fprintf('用Cluster Partition模型估计出来的看跌期权价格MSE标准差为%2g。\n',std(MSE_CP(:,2))  );%4249.13
% fprintf('用GARCH模型估计出来的看涨期权价格MAE为%2g。\n',mean(MAE_GARCH(:,1))  );%28.7299
% fprintf('用GARCH模型估计出来的看涨期权价格MAE标准差为%2g。\n',std(MAE_GARCH(:,1))  );%31.1237
% fprintf('用GARCH模型估计出来的看跌期权价格MAE为%2g。\n',mean(MAE_GARCH(:,2))  );%61.3002
% fprintf('用GARCH模型估计出来的看跌期权价格MAE标准差为%2g。\n',std(MAE_GARCH(:,2))  );%62.3814
% fprintf('用GARCH模型估计出来的看涨期权价格MSE为%2g。\n',mean(MSE_GARCH(:,1))  );%2057.37
% fprintf('用GARCH模型估计出来的看涨期权价格MSE标准差为%2g。\n',std(MSE_GARCH(:,1))  );%4166.09
% fprintf('用GARCH模型估计出来的看跌期权价格MSE为%2g。\n',mean(MSE_GARCH(:,2))  );%7692.15
% fprintf('用GARCH模型估计出来的看跌期权价格MSE标准差为%2g。\n',std(MSE_GARCH(:,2))  );%14289.8
% fprintf('用EGARCH模型估计出来的看涨期权价格MAE为%2g。\n',mean(MAE_EGARCH(:,1))  );%28.644
% fprintf('用EGARCH模型估计出来的看涨期权价格MAE标准差为%2g。\n',std(MAE_EGARCH(:,1))  );%30.9312
% fprintf('用EGARCH模型估计出来的看跌期权价格MAE为%2g。\n',mean(MAE_EGARCH(:,2))  );%61.2143
% fprintf('用EGARCH模型估计出来的看跌期权价格MAE标准差为%2g。\n',std(MAE_EGARCH(:,2))  );%62.2313
% fprintf('用EGARCH模型估计出来的看涨期权价格MSE为%2g。\n',mean(MSE_EGARCH(:,1))  );%2038.33
% fprintf('用EGARCH模型估计出来的看涨期权价格MSE标准差为%2g。\n',std(MSE_EGARCH(:,1))  );%4107.11
% fprintf('用EGARCH模型估计出来的看跌期权价格MSE为%2g。\n',mean(MSE_EGARCH(:,2))  );%7662.52
% fprintf('用EGARCH模型估计出来的看跌期权价格MSE标准差为%2g。\n',std(MSE_EGARCH(:,2))  );%14207.8
% fprintf('用RSGARCH模型估计出来的看涨期权价格MAE为%2g。\n',mean(MAE_RSGARCH(:,1))  );%16.4321
% fprintf('用RSGARCH模型估计出来的看涨期权价格MAE标准差为%2g。\n',std(MAE_RSGARCH(:,1))  );%21.5605
% fprintf('用RSGARCH模型估计出来的看跌期权价格MAE为%2g。\n',mean(MAE_RSGARCH(:,2))  );%45.9537
% fprintf('用RSGARCH模型估计出来的看跌期权价格MAE标准差为%2g。\n',std(MAE_RSGARCH(:,2))  );%51.4403
% fprintf('用RSGARCH模型估计出来的看涨期权价格MSE为%2g。\n',mean(MSE_RSGARCH(:,1))  );%6017.71
% fprintf('用RSGARCH模型估计出来的看涨期权价格MSE标准差为%2g。\n',std(MSE_RSGARCH(:,1))  );%10341.6
% fprintf('用RSGARCH模型估计出来的看跌期权价格MSE为%2g。\n',mean(MSE_RSGARCH(:,2))  );%9785.36
% fprintf('用RSGARCH模型估计出来的看跌期权价格MSE标准差为%2g。\n',std(MSE_RSGARCH(:,2))  );%16148.1