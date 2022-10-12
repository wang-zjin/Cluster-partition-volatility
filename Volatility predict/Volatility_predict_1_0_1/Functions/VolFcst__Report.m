% Report forecast volatility as figures or tables
%
% Input:
%
%        rv                      Realised volatility as true volatility
%
%        results_folder          The folder name to save results, like 'results_NORMAL_NIKKIE_size750_20220811'
%
%        Time_Outsample          Time for out-of-sample, like
%                                [2021,05,18;2022,05,18], the first row is
%                                the starting date, the second row is the
%                                end date. If only one row, like
%                                [2021,05,18], then the default end date is
%                                the last date of input data.
%
%        vf_GARCH                Volatility forecast by GARCH
%
%        vf_CPGARCH              Volatility forecast by CPGARCH
%
%        vf_CPGARCHiteration     Volatility forecast by RCPGARCH
%
%        vf_GJR                  Volatility forecast by GJR
%
%        vf_CPGJR                Volatility forecast by CPGJR
%
%        vf_CPGJRiteration       Volatility forecast by RCPGJR
%
%        vf_HAR                  Volatility forecast by HAR
%
%        vf_CPHAR                Volatility forecast by CPHAR
%
%        vf_CPHARiteration       Volatility forecast by RCPHAR
%
%        vf_RSGARCH              Volatility forecast by RSGARCH
%
%        vf_CPRSGARCH            Volatility forecast by CPRSGARCH
%
%        vf_CPRSGARCHiteration   Volatility forecast by RCPRSGARCH
%
%    insample_fitness_GARCHs     In-sample fitness of GARCH, CPGARCH,
%                                RCPGARCH
%
%    insample_fitness_GJRs       In-sample fitness of GJR, CPGJR,
%                                RCPGJR
%
%    insample_fitness_HARs       In-sample fitness of HAR, CPHAR,
%                                RCPHAR
%
%    insample_fitness_RSGARCHs   In-sample fitness of RSGARCH, CPRSGARCH,
%                                RCPRSGARCH
%
%    para_GARCH                  Estimated parameters of GARCH, CPGARCH,
%                                RCPGARCH
%
%    para_GJR                    Estimated parameters of GJR, CPGJR,
%                                RCPGJR
%
%    para_HAR                    Estimated parameters of HAR, CPHAR,
%                                RCPHAR
%
%    para_RSGARCH                Estimated parameters of RSGARCH, CPRSGARCH,
%                                RCPRSGARCH
%
%    transM_RSGARCH              Estimated transition matrix of RSGARCH
%
%    K_GARCH                     Cluster number of CPGARCH
%
%    K_HAR                       Cluster number of CPHAR
%
%    K_GJR                       Cluster number of CPGJR
%
%    K_RSGARCH                   Cluster number of CPRSGARCH
%
%    vol_persis                  Volatility persistence of GARCH
%
%    ismae_GARCH                 In-sample MAE of GARCH
%
%    ismae_GJR                   In-sample MAE of GJR
%
%    ismae_HAR                   In-sample MAE of HAR
%
%    ismae_RSGARCH               In-sample MAE of RSGARCH
%
%    ismae_CPGARCH               In-sample MAE of CPGARCH
%
%    ismae_CPGJR                 In-sample MAE of CPGJR
%
%    ismae_CPHAR                 In-sample MAE of CPHAR
%
%    ismae_CPRSGARCH             In-sample MAE of CPRSGARCH
%
%    ismae_CPGARCHiteration      In-sample MAE of RCPGARCH
%
%    ismae_CPGJRiteration        In-sample MAE of RCPGJR
%
%    ismae_CPHARiteration        In-sample MAE of RCPHAR
%
%    ismae_CPRSGARCHiteration    In-sample MAE of RCPRSGARCH
%
%    isrmse_GARCH                In-sample RMSE of GARCH
%
%    isrmse_GJR                  In-sample RMSE of GJR
%
%    isrmse_HAR                  In-sample RMSE of HAR
%
%    isrmse_RSGARCH              In-sample RMSE of RSGARCH
%
%    isrmse_CPGARCH              In-sample RMSE of CPGARCH
%
%    isrmse_CPGJR                In-sample RMSE of CPGJR
%
%    isrmse_CPHAR                In-sample RMSE of CPHAR
%
%    isrmse_CPRSGARCH            In-sample RMSE of CPRSGARCH
%
%    isrmse_CPGARCHiteration     In-sample RMSE of RCPGARCH
%
%    isrmse_CPGJRiteration       In-sample RMSE of RCPGJR
%
%    isrmse_CPHARiteration       In-sample RMSE of RCPHAR
%
%    isrmse_CPRSGARCHiteration   In-sample RMSE of RCPRSGARCH

function VolFcst__Report(rv,Timeline_outsample,results_folder, ...
    vf_GARCH,vf_CPGARCH,vf_CPGARCHiteration, ...
    vf_GJR,vf_CPGJR,vf_CPGJRiteration, ...
    vf_RSGARCH,vf_CPRSGARCH,vf_CPRSGARCHiteration, ...
    vf_HAR,vf_CPHAR,vf_CPHARiteration, ...
    vol_persis, K_GARCH,K_GJR,K_RSGARCH,K_HAR, ...
    ismae_GARCH,isrmse_GARCH,ismae_CPGARCH,isrmse_CPGARCH,ismae_CPGARCHiteration,isrmse_CPGARCHiteration, ...
    ismae_GJR,isrmse_GJR,ismae_CPGJR,isrmse_CPGJR,ismae_CPGJRiteration,isrmse_CPGJRiteration, ...
    ismae_RSGARCH,isrmse_RSGARCH,ismae_CPRSGARCH,isrmse_CPRSGARCH,ismae_CPRSGARCHiteration,isrmse_CPRSGARCHiteration, ...
    ismae_HAR,isrmse_HAR,ismae_CPHAR,isrmse_CPHAR,ismae_CPHARiteration,isrmse_CPHARiteration, ...
    para_HAR,para_GARCH,para_GJR,para_RSGARCH,transM_RSGARCH)

[~,~]=mkdir(results_folder); 
addpath(results_folder);

n=length(Timeline_outsample);
% Volatility forecasts: GARCH, CPGARCH, CPGARCH iteration, EGARCH, CPEGARCH, CPEGARCH iteration, GJRGARCH, CPGJRGARCH, CPGJRGARCH iteration, RSGARCH, CPRSGARCH, CPRSGARCH iteration, HAR, CPHAR, CPHARiteration
figure;
col=rainbow(13);
plot(Timeline_outsample,vf_GARCH, "Color",col(1,:));hold on
plot(Timeline_outsample,vf_CPGARCH, "Color",col(2,:))
plot(Timeline_outsample,vf_CPGARCHiteration, "Color",col(3,:))
plot(Timeline_outsample,vf_GJR, "Color",col(4,:));
plot(Timeline_outsample,vf_CPGJR, "Color",col(5,:))
plot(Timeline_outsample,vf_CPGJRiteration, "Color",col(6,:))
plot(Timeline_outsample,vf_RSGARCH, "Color",col(7,:));
plot(Timeline_outsample,vf_CPRSGARCH, "Color",col(8,:))
plot(Timeline_outsample,vf_CPRSGARCHiteration, "Color",col(9,:))
plot(Timeline_outsample,vf_HAR, "Color",col(10,:))
plot(Timeline_outsample,vf_CPHAR, "Color",col(11,:))
plot(Timeline_outsample,vf_CPHARiteration, "Color",col(12,:))
plot(Timeline_outsample,rv, "Color",col(13,:))
legend("GARCH","CPGARCH","GARCH Ite.", ...
    "GJRGARCH", "CPGJRGARCH", "CPGJRGARCH Ite.", ...
    "RSGARCH", "CPRSGARCH", "CPRSGARCH Ite.", ...
    "HAR","CPHAR","CPHAR Ite.","RV","Location","best");
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/volatility_forecast_allmodel.png'])
% Volatility forecasts: GARCH, CPGARCH, CPGARCH iteration
figure;
col=rainbow(4);
plot(Timeline_outsample,rv, "Color",col(4,:));hold on
plot(Timeline_outsample,vf_GARCH, "Color",col(1,:))
plot(Timeline_outsample,vf_CPGARCH, "Color",col(2,:))
plot(Timeline_outsample,vf_CPGARCHiteration, "Color",col(3,:))
legend("RV","GARCH","CPGARCH","CPGARCH Ite.");
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/volatility_forecast_garchs.png'])
% Volatility forecasts: GJR, CPGJR, CPGJR iteration
figure;
col=rainbow(4);
plot(Timeline_outsample,rv, "Color",col(4,:));hold on
plot(Timeline_outsample,vf_GJR, "Color",col(1,:))
plot(Timeline_outsample,vf_CPGJR, "Color",col(2,:))
plot(Timeline_outsample,vf_CPGJRiteration, "Color",col(3,:))
legend("RV","GJR","CPGJR","CPGJR Ite.");
saveas(gcf,[results_folder,'/volatility_forecast_gjrs.png'])
% Volatility forecasts: RSGARCH, CPRSGARCH, CPRSGARCH iteration
figure;
col=rainbow(4);
plot(Timeline_outsample,rv, "Color",col(4,:));hold on
plot(Timeline_outsample,vf_RSGARCH, "Color",col(1,:))
plot(Timeline_outsample,vf_CPRSGARCH, "Color",col(2,:))
plot(Timeline_outsample,vf_CPRSGARCHiteration, "Color",col(3,:))
legend("RV","RSGARCH","CPRSGARCH","CPRSGARCH Ite.");
saveas(gcf,[results_folder,'/volatility_forecast_rsgarchs.png'])
% Volatility forecasts: HAR, CPHAR, CPHAR iteration
figure;
col=rainbow(4);
plot(Timeline_outsample,rv, "Color",col(4,:));hold on
plot(Timeline_outsample,vf_HAR, "Color",col(1,:))
plot(Timeline_outsample,vf_CPHAR, "Color",col(2,:))
plot(Timeline_outsample,vf_CPHARiteration, "Color",col(3,:))
legend("RV","HAR","CPHAR","CPHAR Ite.");
saveas(gcf,[results_folder,'/volatility_forecast_hars.png'])
% Figure of parameters in each estimation window
% GARCH
col=rainbow(3);
figure;
subplot(2,2,1);
plot(Timeline_outsample,para_GARCH(:,1),"Color",col(1,:));
subtitle("constant")
subplot(2,2,2);
plot(Timeline_outsample,para_GARCH(:,2),"Color",col(2,:));
subtitle("ARCH")
subplot(2,2,3);
plot(Timeline_outsample,para_GARCH(:,3),"Color",col(3,:));
subtitle("GARCH")
saveas(gcf,[results_folder,'/dynamic_parameters_garch.png'])
% GJR
col=rainbow(4);
figure;
subplot(2,2,1);
plot(Timeline_outsample,para_GJR(:,1),"Color",col(1,:));
subtitle("constant")
subplot(2,2,2);
plot(Timeline_outsample,para_GJR(:,2),"Color",col(2,:));
subtitle("ARCH")
subplot(2,2,3);
plot(Timeline_outsample,para_GJR(:,3),"Color",col(3,:));
subtitle("GARCH")
subplot(2,2,4);
plot(Timeline_outsample,para_GJR(:,4),"Color",col(4,:));
subtitle("Leverage")
saveas(gcf,[results_folder,'/dynamic_parameters_gjr.png'])
% RSGARCH
figure;
col=rainbow(2);
subplot(2,2,1);
plot(Timeline_outsample,reshape(para_RSGARCH(1,1,:),n,1),"Color",col(1,:));hold on
plot(Timeline_outsample,reshape(para_RSGARCH(2,1,:),n,1),"Color",col(2,:));
legend("Regime 1","Regime 2")
subtitle("\omega")
subplot(2,2,2);
plot(Timeline_outsample,reshape(para_RSGARCH(1,2,:),n,1),"Color",col(1,:));hold on
plot(Timeline_outsample,reshape(para_RSGARCH(2,2,:),n,1),"Color",col(2,:));
legend("Regime 1","Regime 2")
subtitle("arch parameter")
subplot(2,2,3);
plot(Timeline_outsample,reshape(para_RSGARCH(1,3,:),n,1),"Color",col(1,:));hold on
plot(Timeline_outsample,reshape(para_RSGARCH(2,3,:),n,1),"Color",col(2,:));
legend("Regime 1","Regime 2")
subtitle("garch parameter")
subplot(2,2,4);
plot(Timeline_outsample,reshape(transM_RSGARCH(1,1,:),n,1),"Color",col(1,:));hold on
plot(Timeline_outsample,reshape(transM_RSGARCH(2,2,:),n,1),"Color",col(2,:));
legend("Regime 1","Regime 2")
subtitle("transfer matrix")
saveas(gcf,[results_folder,'/dynamic_parameters_rsgarch.png'])
% HAR
col=rainbow(7);
figure;
subplot(2,4,1);
plot(Timeline_outsample,para_HAR(:,1),"Color",col(1,:));
subtitle("constant")
subplot(2,4,2);
plot(Timeline_outsample,para_HAR(:,2),"Color",col(2,:));
subtitle("v_{t-1}")
subplot(2,4,3);
plot(Timeline_outsample,para_HAR(:,3),"Color",col(3,:));
subtitle("v_{t-5}")
subplot(2,4,4);
plot(Timeline_outsample,para_HAR(:,4),"Color",col(4,:));
subtitle("v_{t-22}")
subplot(2,4,5);
plot(Timeline_outsample,para_HAR(:,5),"Color",col(5,:));
subtitle("b_J")
subplot(2,4,6);
plot(Timeline_outsample,para_HAR(:,6),"Color",col(6,:));
subtitle("a_1")
subplot(2,4,7);
plot(Timeline_outsample,para_HAR(:,7),"Color",col(7,:));
subtitle("a_2")
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/dynamic_parameters_har.png'])
% Figure of optimal cluster number in each estimation window
figure;
col=rainbow(4);
plot(Timeline_outsample,K_GARCH,"Color",col(1,:));hold on
plot(Timeline_outsample,K_GJR,"Color",col(2,:));hold on
plot(Timeline_outsample,K_RSGARCH,"Color",col(3,:));
plot(Timeline_outsample,K_HAR,"Color",col(4,:));
legend("GARCH","GJRGARCH","RSGARCH","HAR")
saveas(gcf,[results_folder,'/dynamic_optimal_cluster_number.png'])
% Figure of in-sample MAE and MSE
figure;
col=rainbow(12);
plot(Timeline_outsample,ismae_GARCH,"Color",col(1,:));hold on
plot(Timeline_outsample,ismae_CPGARCH,"Color",col(2,:));
plot(Timeline_outsample,ismae_CPGARCHiteration,"Color",col(3,:));
plot(Timeline_outsample,ismae_GJR,"Color",col(4,:));
plot(Timeline_outsample,ismae_CPGJR,"Color",col(5,:));
plot(Timeline_outsample,ismae_CPGJRiteration,"Color",col(6,:));
plot(Timeline_outsample,ismae_RSGARCH,"Color",col(7,:));
plot(Timeline_outsample,ismae_CPRSGARCH,"Color",col(8,:));
plot(Timeline_outsample,ismae_CPRSGARCHiteration,"Color",col(9,:));
plot(Timeline_outsample,ismae_HAR,"Color",col(10,:));
plot(Timeline_outsample,ismae_CPHAR,"Color",col(11,:));
plot(Timeline_outsample,ismae_CPHARiteration,"Color",col(12,:));
legend("GARCH","CPGARCH","CPGARCH Ite.", ...
    "GJR","CPGJR","CPGJR Ite.", ...
    "RSGARCH","CPRSGARCH","CPRSGARCH Ite.", ...
    "HAR","CPHAR","CPHAR Ite.")
title("in-sample MAE")
saveas(gcf,[results_folder,'/insample_mae.png'])
figure;
plot(Timeline_outsample,isrmse_GARCH,"Color",col(1,:));hold on
plot(Timeline_outsample,isrmse_CPGARCH,"Color",col(2,:));
plot(Timeline_outsample,isrmse_CPGARCHiteration,"Color",col(3,:));
plot(Timeline_outsample,isrmse_GJR,"Color",col(4,:));
plot(Timeline_outsample,isrmse_CPGJR,"Color",col(5,:));
plot(Timeline_outsample,isrmse_CPGJRiteration,"Color",col(6,:));
plot(Timeline_outsample,isrmse_RSGARCH,"Color",col(7,:));
plot(Timeline_outsample,isrmse_CPRSGARCH,"Color",col(8,:));
plot(Timeline_outsample,isrmse_CPRSGARCHiteration,"Color",col(9,:));
plot(Timeline_outsample,isrmse_HAR,"Color",col(10,:));
plot(Timeline_outsample,isrmse_CPHAR,"Color",col(11,:));
plot(Timeline_outsample,isrmse_CPHARiteration,"Color",col(12,:));
legend("GARCH","CPGARCH","CPGARCH Ite.", ...
    "GJR","CPGJR","CPGJR Ite.", ...
    "RSGARCH","CPRSGARCH","CPRSGARCH Ite.", ...
    "HAR","CPHAR","CPHAR Ite.")
title("in-sample RMSE")
saveas(gcf,[results_folder,'/insample_rmse.png'])
% MAE & RMSE
MAE=[mean(abs(vf_GARCH-rv));mean(abs(vf_CPGARCH-rv));mean(abs(vf_CPGARCHiteration-rv))
    mean(abs(vf_GJR-rv));mean(abs(vf_CPGJR-rv));mean(abs(vf_CPGJRiteration-rv))
    mean(abs(vf_RSGARCH-rv));mean(abs(vf_CPRSGARCH-rv));mean(abs(vf_CPRSGARCHiteration-rv))
    mean(abs(vf_HAR-rv));mean(abs(vf_CPHAR-rv));mean(abs(vf_CPHARiteration-rv))]*100000;
RMSE=sqrt([mean((vf_GARCH-rv).^2);mean((vf_CPGARCH-rv).^2);mean((vf_CPGARCHiteration-rv).^2)
    mean((vf_GJR-rv).^2);mean((vf_CPGJR-rv).^2);mean((vf_CPGJRiteration-rv).^2)
    mean((vf_RSGARCH-rv).^2);mean((vf_CPRSGARCH-rv).^2);mean((vf_CPRSGARCHiteration-rv).^2)
    mean((vf_HAR-rv).^2);mean((vf_CPHAR-rv).^2);mean((vf_CPHARiteration-rv).^2)])*100000;
outsample_mae_rmse_allmodel=table(MAE,RMSE,'RowNames',{'GARCH','CPGARCH','GARCH Ite.',...
    'GJRGARCH','CPGJRGARCH','CPGJRGARCH Ite.', ...
    'RSGARCH','CPRSGARCH','CPRSGARCH Ite.','HAR','CPHAR','HAR Ite.'})
ftxt=fopen([results_folder,'/outsample_mae_rmse_allmodel.txt'],'w+');
table2latex(outsample_mae_rmse_allmodel,ftxt)
fclose(ftxt);
% MAE & RMSE without RSGARCH
MAE=[mean(abs(vf_GARCH-rv));mean(abs(vf_CPGARCH-rv));mean(abs(vf_CPGARCHiteration-rv))
    mean(abs(vf_GJR-rv));mean(abs(vf_CPGJR-rv));mean(abs(vf_CPGJRiteration-rv))
    mean(abs(vf_HAR-rv));mean(abs(vf_CPHAR-rv));mean(abs(vf_CPHARiteration-rv))]*100000;
RMSE=sqrt([mean((vf_GARCH-rv).^2);mean((vf_CPGARCH-rv).^2);mean((vf_CPGARCHiteration-rv).^2)
    mean((vf_GJR-rv).^2);mean((vf_CPGJR-rv).^2);mean((vf_CPGJRiteration-rv).^2)
    mean((vf_HAR-rv).^2);mean((vf_CPHAR-rv).^2);mean((vf_CPHARiteration-rv).^2)])*100000;
outsample_mae_rmse_exclude_rsgarch=table(MAE,RMSE,'RowNames',{'GARCH','CPGARCH','GARCH Ite.', ...
    'GJRGARCH','CPGJRGARCH','CPGJRGARCH Ite.', ...
    'HAR','CPHAR','HAR Ite.'})
ftxt=fopen([results_folder,'/outsample_mae_rmse_exclude_rsgarch.txt'],'w+');
table2latex(outsample_mae_rmse_exclude_rsgarch,ftxt)
fclose(ftxt);
%DM test
dm_test=table([normcdf(dmtest(vf_GARCH-rv,vf_CPGARCH-rv),0,1); normcdf(dmtest(vf_GARCH-rv,vf_CPGARCHiteration-rv),0,1)
    normcdf(dmtest(vf_GARCH-rv,vf_GJR-rv),0,1);normcdf(dmtest(vf_GARCH-rv,vf_CPGJR-rv),0,1);normcdf(dmtest(vf_GARCH-rv,vf_CPGJRiteration-rv),0,1)
    normcdf(dmtest(vf_GARCH-rv,vf_RSGARCH-rv),0,1);normcdf(dmtest(vf_GARCH-rv,vf_CPRSGARCH-rv),0,1);normcdf(dmtest(vf_GARCH-rv,vf_CPRSGARCHiteration-rv),0,1)
    normcdf(dmtest(vf_GARCH-rv,vf_HAR-rv),0,1);normcdf(dmtest(vf_GARCH-rv,vf_CPHAR-rv),0,1);normcdf(dmtest(vf_GARCH-rv,vf_CPHARiteration-rv),0,1)], ...
    'RowNames',{'CPGARCH','GARCH Ite.', ...
    'GJRGARCH','CPGJRGARCH','CPGJRGARCH Ite.', ...
    'RSGARCH','CPRSGARCH','CPRSGARCH Ite.', ...
    'HAR','CPHAR','HAR Ite.'})
ftxt=fopen([results_folder,'/dm_test.txt'],'w+');
table2latex(dm_test,ftxt)
fclose(ftxt);
% Test of actual forecast: actual_volatility = a + (b+1)*forecast_volatility
% Null hypothesis: a=0, b+1=1
[~,bint_GARCH,~,~,stats_GARCH]=regress(rv,[ones(size(rv)) vf_GARCH]);
[~,bint_CPGARCH,~,~,stats_CPGARCH]=regress(rv,[ones(size(rv)) vf_CPGARCH]);
[~,bint_CPGARCHiteration,~,~,stats_CPGARCHiteration]=regress(rv,[ones(size(rv)) vf_CPGARCHiteration]);
[~,bint_GJRGARCH,~,~,stats_GJRGARCH]=regress(rv,[ones(size(rv)) vf_GJR]);
[~,bint_CPGJRGARCH,~,~,stats_CPGJRGARCH]=regress(rv,[ones(size(rv)) vf_CPGJR]);
[~,bint_CPGJRGARCHiteration,~,~,stats_CPGJRGARCHiteration]=regress(rv,[ones(size(rv)) vf_CPGJRiteration]);
[~,bint_RSGARCH,~,~,stats_RSGARCH]=regress(rv,[ones(size(rv)) vf_RSGARCH]);
[~,bint_CPRSGARCH,~,~,stats_CPRSGARCH]=regress(rv,[ones(size(rv)) vf_CPRSGARCH]);
[~,bint_CPRSGARCHiteration,~,~,stats_CPRSGARCHiteration]=regress(rv,[ones(size(rv)) vf_CPRSGARCHiteration]);
[~,bint_HAR,~,~,stats_HAR]=regress(rv,[ones(size(rv)) vf_HAR]);
[~,bint_CPHAR,~,~,stats_CPHAR]=regress(rv,[ones(size(rv)) vf_CPHAR]);
[~,bint_CPHARiteration,~,~,stats_CPHARiteration]=regress(rv,[ones(size(rv)) vf_CPHARiteration]);
low_bound=[bint_GARCH(end,1);bint_CPGARCH(end,1);bint_CPGARCHiteration(end,1);
    bint_GJRGARCH(end,1);bint_CPGJRGARCH(end,1);bint_CPGJRGARCHiteration(end,1);
    bint_RSGARCH(end,1);bint_CPRSGARCH(end,1);bint_CPRSGARCHiteration(end,1)
    bint_HAR(end,1);bint_CPHAR(end,1);bint_CPHARiteration(end,1)];
upper_bound=[bint_GARCH(end,2);bint_CPGARCH(end,2);bint_CPGARCHiteration(end,2);
    bint_GJRGARCH(end,2);bint_CPGJRGARCH(end,2);bint_CPGJRGARCHiteration(end,2);
    bint_RSGARCH(end,2);bint_CPRSGARCH(end,2);bint_CPRSGARCHiteration(end,2)
    bint_HAR(end,2);bint_CPHAR(end,2);bint_CPHARiteration(end,2)];
R2=[stats_GARCH(1);stats_CPGARCH(1);stats_CPGARCHiteration(1);
    stats_GJRGARCH(1);stats_CPGJRGARCH(1);stats_CPGJRGARCHiteration(1);
    stats_RSGARCH(1);stats_CPRSGARCH(1);stats_CPRSGARCHiteration(1)
    stats_HAR(1);stats_CPHAR(1);stats_CPHARiteration(1)];
test_of_actual_forecast=table(low_bound,upper_bound,R2,'RowNames',{'GARCH','CPGARCH','GARCH Ite.', ...
    'GJRGARCH','CPGJRGARCH','CPGJRGARCH Ite.', ...
    'RSGARCH','CPRSGARCH','CPRSGARCH Ite.','HAR','CPHAR','HAR Ite.'})
ftxt=fopen([results_folder,'/test_of_actual_forecast.txt'],'w+');
table2latex(test_of_actual_forecast,ftxt)
fclose(ftxt);
% Figure of volatility persistence
figure;
plot(Timeline_outsample,vol_persis);
dateaxis('x',12)
title("volatility persistence")
saveas(gcf,[results_folder,'/volatility_persistence.png'])
end

