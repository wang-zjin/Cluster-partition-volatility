% This exercise is to forecast volatility via different methods, campared with actual volatilities measured by high-frequency realised volatility

% Out-of-sample forecasts are from 2018-5-18 to 2019-5-18. Rolling estimation window size is 750 and forecast one-day ahead.
% The difference between this file and "exercise_VolForecastRV_1_0_1.mlx" in folder "Volatility_predict_1_0_1_1Y_WS750" is we want to change forecast time to 2018-05-18 to 2019-05-18 and we want to omit RSGARCH
% We separate GARCH, GJR, HAR and HAR-a into different functions to calculate corresponding volatility, VolFcst_GARCH, VolFcst_GJR and VolFcst_HAR. Then you have to use Save_VolFcst_to_Mat to save results.
clear,clc
%% SP500
addpath("Functions/")
tic
Read_Name='SP500_0608.xlsx';
Time_Outsample=[2019,05,18;2020,05,18];
rv=get_rv(Read_Name,Time_Outsample);
Index_Name = 'SP500';
Working_Date = '20240321';
Window_Size = 1000;
results_folder = get_results_folder(Index_Name,Working_Date);
Timeline_outsample = get_datetime_outofsample(Read_Name,Time_Outsample);
results_GARCH=VolFcst_GARCH(Read_Name,Time_Outsample);
results_CPGARCH=VolFcst_CPGARCH(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_ICPGARCH=VolFcst_ICPGARCH(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_GJR=VolFcst_GJR(Read_Name,Time_Outsample);
results_CPGJR=VolFcst_CPGJR(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_ICPGJR=VolFcst_ICPGJR(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_HAR=VolFcst_HAR(Read_Name,Time_Outsample);
results_CPHAR=VolFcst_CPHAR(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_ICPHAR=VolFcst_ICPHAR(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_HAR_a=VolFcst_HAR_a(Read_Name,Time_Outsample);
results_CPHAR_a=VolFcst_CPHAR_a(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_ICPHAR_a=VolFcst_ICPHAR_a(Read_Name,Time_Outsample,'Cluster_Min_Length',100);

% Save forecast volatility
Model_Name={'GARCH','CPGARCH','ICPGARCH',...
        'GJR','CPGJR','ICPGJR', ... 
        'HAR','CPHAR','ICPHAR',...
        'HAR_a','CPHAR_a','ICPHAR_a'};
for i=1:12
    save([results_folder,'/','VolFcst_NORMAL_',Index_Name, ...
        '_',Model_Name{i},'_size',num2str(Window_Size),'_',Working_Date],['results_',Model_Name{i}]);
end
Output_Table=table(Timeline_outsample,sqrt(results_GARCH.vf_GARCH),sqrt(results_CPGARCH.vf_CPGARCH),sqrt(results_ICPGARCH.vf_ICPGARCH), ...
    sqrt(results_GJR.vf_GJR),sqrt(results_CPGJR.vf_CPGJR),sqrt(results_ICPGJR.vf_ICPGJR), ... sqrt(results_RSGARCH.vf_RSGARCH),sqrt(results_CPRSGARCH.vf_CPRSGARCH),sqrt(results_ICPRSGARCH.vf_ICPRSGARCH), ...
    sqrt(results_HAR.vf_HAR),sqrt(results_CPHAR.vf_CPHAR),sqrt(results_ICPHAR.vf_ICPHAR), ...
    sqrt(results_HAR_a.vf_HAR_a),sqrt(results_CPHAR_a.vf_CPHAR_a),sqrt(results_ICPHAR_a.vf_ICPHAR_a), ...
    'VariableNames',{'Date','vf_GARCH','vf_CPGARCH','vf_ICPGARCH', ...
    'vf_GJR','vf_CPGJR','vf_ICPGJR', ...
    'vf_HAR','vf_CPHAR','vf_ICPHAR', ...
    'vf_HAR_a','vf_CPHAR_a','vf_ICPHAR_a'});
writetable(Output_Table,[results_folder,'/','Volatility_Forecast_',Working_Date,'.xlsx']);
Output_Table=table(Timeline_outsample,results_GARCH.ismae_GARCH,results_CPGARCH.ismae_CPGARCH,results_ICPGARCH.ismae_ICPGARCH, ...
    results_GJR.ismae_GJR,results_CPGJR.ismae_CPGJR,results_ICPGJR.ismae_ICPGJR, ... 
    results_HAR.ismae_HAR,results_CPHAR.ismae_CPHAR,results_ICPHAR.ismae_ICPHAR, ...
    results_HAR_a.ismae_HAR_a,results_CPHAR_a.ismae_CPHAR_a,results_ICPHAR_a.ismae_ICPHAR_a, ...
    'VariableNames',{'Date','ismae_GARCH','ismae_CPGARCH','ismae_ICPGARCH', ...
    'ismae_GJR','ismae_CPGJR','ismae_ICPGJR', ...
    'ismae_HAR','ismae_CPHAR','ismae_ICPHAR', ...
    'ismae_HAR_a','ismae_CPHAR_a','ismae_ICPHAR_a'});
writetable(Output_Table,[results_folder,'/','Insample_MAE_',Working_Date,'.xlsx']);
Output_Table=table(Timeline_outsample,results_GARCH.isrmse_GARCH,results_CPGARCH.isrmse_CPGARCH,results_ICPGARCH.isrmse_ICPGARCH, ...
    results_GJR.isrmse_GJR,results_CPGJR.isrmse_CPGJR,results_ICPGJR.isrmse_ICPGJR, ... 
    results_HAR.isrmse_HAR,results_CPHAR.isrmse_CPHAR,results_ICPHAR.isrmse_ICPHAR, ...
    results_HAR_a.isrmse_HAR_a,results_CPHAR_a.isrmse_CPHAR_a,results_ICPHAR_a.isrmse_ICPHAR_a, ...
    'VariableNames',{'Date','isrmse_GARCH','isrmse_CPGARCH','isrmse_ICPGARCH', ...
    'isrmse_GJR','isrmse_CPGJR','isrmse_ICPGJR', ...
    'isrmse_HAR','isrmse_CPHAR','isrmse_ICPHAR', ...
    'isrmse_HAR_a','isrmse_CPHAR_a','isrmse_ICPHAR_a'});
writetable(Output_Table,[results_folder,'/','Insample_RMSE_',Working_Date,'.xlsx']);
Output_Table=table(Timeline_outsample,results_CPGARCH.K, ...
    results_CPGJR.K, ... 
    results_CPHAR.K, ...
    results_CPHAR_a.isrmse_CPHAR_a, ...
    'VariableNames',{'Date','K_CPGARCH',...
    'K_CPGJR',...
    'K_CPHAR',...
    'K_CPHAR_a'});
writetable(Output_Table,[results_folder,'/','K_',Working_Date,'.xlsx']);

% Load forecast volatility
for i=1:12
    load([results_folder,'/','VolFcst_NORMAL_',Index_Name, ...
        '_',Model_Name{i},'_size',num2str(Window_Size),'_',Working_Date]);
end
% Volatility forecasts: GARCH, CPGARCH, ICPGARCH,
% GJR, CPGJR, ICPGJR, 
% HAR, CPHAR, ICPHAR, HAR-a, CPHAR-a, ICPHAR-a
figure;
col=rainbow(13);
plot(Timeline_outsample,sqrt(results_GARCH.vf_GARCH)*sqrt(250), "Color",col(1,:));hold on
plot(Timeline_outsample,sqrt(results_CPGARCH.vf_CPGARCH)*sqrt(250), "Color",col(2,:))
plot(Timeline_outsample,sqrt(results_ICPGARCH.vf_ICPGARCH)*sqrt(250), "Color",col(3,:))
plot(Timeline_outsample,sqrt(results_GJR.vf_GJR)*sqrt(250), "Color",col(4,:));
plot(Timeline_outsample,sqrt(results_CPGJR.vf_CPGJR)*sqrt(250), "Color",col(5,:))
plot(Timeline_outsample,sqrt(results_ICPGJR.vf_ICPGJR)*sqrt(250), "Color",col(6,:))
plot(Timeline_outsample,sqrt(results_HAR.vf_HAR)*sqrt(250), "Color",col(7,:))
plot(Timeline_outsample,sqrt(results_CPHAR.vf_CPHAR)*sqrt(250), "Color",col(8,:))
plot(Timeline_outsample,sqrt(results_ICPHAR.vf_ICPHAR)*sqrt(250), "Color",col(9,:))
plot(Timeline_outsample,sqrt(results_HAR_a.vf_HAR_a)*sqrt(250), "Color",col(10,:))
plot(Timeline_outsample,sqrt(results_CPHAR_a.vf_CPHAR_a)*sqrt(250), "Color",col(11,:))
plot(Timeline_outsample,sqrt(results_ICPHAR_a.vf_ICPHAR_a)*sqrt(250), "Color",col(12,:))
plot(Timeline_outsample,sqrt(rv)*sqrt(250), "Color",col(13,:))
legend("GARCH","CPGARCH","ICPGARCH", ...
    "GJRGARCH", "CPGJRGARCH", "ICPGJRGARCH", ...
    "HAR","CPHAR","CPHAR", "HAR-a","CPHAR-a","ICPHAR-a", ...
    "RV","Location","best");
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/volatility_forecast_allmodel.png'])

% Volatility forecasts: GARCH  CPGARCH, CPGARCH iteration
figure;
col=rainbow(4);
plot(Timeline_outsample,sqrt(rv)*sqrt(250), "Color",col(4,:));hold on
plot(Timeline_outsample,sqrt(results_GARCH.vf_GARCH)*sqrt(250), "Color",col(1,:))
plot(Timeline_outsample,sqrt(results_CPGARCH.vf_CPGARCH)*sqrt(250), "Color",col(2,:))
plot(Timeline_outsample,sqrt(results_ICPGARCH.vf_ICPGARCH)*sqrt(250), "Color",col(3,:))
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/volatility_forecast_garchs.png'])

% Volatility forecasts: GJR, CPGJR, CPGJR iteration
figure;
col=rainbow(4);
plot(Timeline_outsample,sqrt(rv)*sqrt(250), "Color",col(4,:));hold on
plot(Timeline_outsample,sqrt(results_GJR.vf_GJR)*sqrt(250), "Color",col(1,:))
plot(Timeline_outsample,sqrt(results_CPGJR.vf_CPGJR)*sqrt(250), "Color",col(2,:))
plot(Timeline_outsample,sqrt(results_ICPGJR.vf_ICPGJR)*sqrt(250), "Color",col(3,:))
legend("RV","GJR","CPGJR","ICPGJR",'Location','best');
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/volatility_forecast_gjrs.png'])

% Volatility forecasts: HAR, CPHAR, ICPHAR
figure;
col=rainbow(4);
plot(Timeline_outsample,sqrt(rv)*sqrt(250), "Color",col(4,:));hold on
plot(Timeline_outsample,sqrt(results_HAR.vf_HAR)*sqrt(250), "Color",col(1,:))
plot(Timeline_outsample,sqrt(results_CPHAR.vf_CPHAR)*sqrt(250), "Color",col(2,:))
plot(Timeline_outsample,sqrt(results_ICPHAR.vf_ICPHAR)*sqrt(250), "Color",col(3,:))
legend("RV","HAR","CPHAR","ICPHAR",'Location','best');
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/volatility_forecast_hars.png'])

% Volatility forecasts: HAR-a, CPHAR-a, ICPHAR-a
figure;
col=rainbow(4);
plot(Timeline_outsample,sqrt(rv)*sqrt(250), "Color",col(4,:));hold on
plot(Timeline_outsample,sqrt(results_HAR_a.vf_HAR_a)*sqrt(250), "Color",col(1,:))
plot(Timeline_outsample,sqrt(results_CPHAR_a.vf_CPHAR_a)*sqrt(250), "Color",col(2,:))
plot(Timeline_outsample,sqrt(results_ICPHAR_a.vf_ICPHAR_a)*sqrt(250), "Color",col(3,:))
legend("RV","HAR-a","CPHAR-a","ICPHAR-a",'Location','best');
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/volatility_forecast_haras.png'])

% Figure of parameters in each estimation window
% GARCH
col=rainbow(3);
figure;
subplot(2,2,1);
plot(Timeline_outsample,results_GARCH.para(:,1),"Color",col(1,:));
subtitle("constant")
subplot(2,2,2);
plot(Timeline_outsample,results_GARCH.para(:,2),"Color",col(2,:));
subtitle("ARCH")
subplot(2,2,3);
plot(Timeline_outsample,results_GARCH.para(:,3),"Color",col(3,:));
subtitle("GARCH")
saveas(gcf,[results_folder,'/dynamic_parameters_garch.png'])

% Figure of optimal cluster number in each estimation window
figure;
col=rainbow(4);
plot(Timeline_outsample,results_CPGARCH.K,"Color",col(1,:));hold on
plot(Timeline_outsample,results_CPGJR.K,"Color",col(2,:));
plot(Timeline_outsample,results_CPHAR.K,"Color",col(3,:));
plot(Timeline_outsample,results_CPHAR_a.K,"Color",col(4,:));
legend("GARCH","GJRGARCH","HAR","HAR-a")
saveas(gcf,[results_folder,'/dynamic_optimal_cluster_number.png'])

% Figure of in-sample MAE and MSE
figure;
col=rainbow(12);
plot(Timeline_outsample,results_GARCH.ismae_GARCH,"Color",col(1,:));hold on
plot(Timeline_outsample,results_CPGARCH.ismae_CPGARCH,"Color",col(2,:));
plot(Timeline_outsample,results_ICPGARCH.ismae_ICPGARCH,"Color",col(3,:));
plot(Timeline_outsample,results_GJR.ismae_GJR,"Color",col(4,:));
plot(Timeline_outsample,results_CPGJR.ismae_CPGJR,"Color",col(5,:));
plot(Timeline_outsample,results_ICPGJR.ismae_ICPGJR,"Color",col(6,:));
plot(Timeline_outsample,results_HAR.ismae_HAR,"Color",col(7,:));
plot(Timeline_outsample,results_CPHAR.ismae_CPHAR,"Color",col(8,:));
plot(Timeline_outsample,results_ICPHAR.ismae_ICPHAR,"Color",col(9,:));
plot(Timeline_outsample,results_HAR_a.ismae_HAR_a,"Color",col(10,:));
plot(Timeline_outsample,results_CPHAR_a.ismae_CPHAR_a,"Color",col(11,:));
plot(Timeline_outsample,results_ICPHAR_a.ismae_ICPHAR_a,"Color",col(12,:));
legend("GARCH","CPGARCH","ICPGARCH", ...
    "GJR","CPGJR","ICPGJR", ...
    "HAR","CPHAR","ICPHAR","HAR-a","CPHAR-a","ICPHAR-a")
title("in-sample MAE")
saveas(gcf,[results_folder,'/insample_mae.png'])
figure;
col=rainbow(12);
plot(Timeline_outsample,results_GARCH.isrmse_GARCH,"Color",col(1,:));hold on
plot(Timeline_outsample,results_CPGARCH.isrmse_CPGARCH,"Color",col(2,:));
plot(Timeline_outsample,results_ICPGARCH.isrmse_ICPGARCH,"Color",col(3,:));
plot(Timeline_outsample,results_GJR.isrmse_GJR,"Color",col(4,:));
plot(Timeline_outsample,results_CPGJR.isrmse_CPGJR,"Color",col(5,:));
plot(Timeline_outsample,results_ICPGJR.isrmse_ICPGJR,"Color",col(6,:));
plot(Timeline_outsample,results_HAR.isrmse_HAR,"Color",col(7,:));
plot(Timeline_outsample,results_CPHAR.isrmse_CPHAR,"Color",col(8,:));
plot(Timeline_outsample,results_ICPHAR.isrmse_ICPHAR,"Color",col(9,:));
plot(Timeline_outsample,results_HAR_a.isrmse_HAR_a,"Color",col(10,:));
plot(Timeline_outsample,results_CPHAR_a.isrmse_CPHAR_a,"Color",col(11,:));
plot(Timeline_outsample,results_ICPHAR_a.isrmse_ICPHAR_a,"Color",col(12,:));
legend("GARCH","CPGARCH","ICPGARCH", ...
    "GJR","CPGJR","ICPGJR", ...
    "HAR","CPHAR","ICPHAR","HAR-a","CPHAR-a","ICPHAR-a")
title("in-sample RMSE")
saveas(gcf,[results_folder,'/insample_rmse.png'])

% MAE & RMSE
MAE=[mean(abs(sqrt(results_GARCH.vf_GARCH)-sqrt(rv)));mean(abs(sqrt(results_CPGARCH.vf_CPGARCH)-sqrt(rv)));mean(abs(sqrt(results_ICPGARCH.vf_ICPGARCH)-sqrt(rv)))
    mean(abs(sqrt(results_GJR.vf_GJR)-sqrt(rv)));mean(abs(sqrt(results_CPGJR.vf_CPGJR)-sqrt(rv)));mean(abs(sqrt(results_ICPGJR.vf_ICPGJR)-sqrt(rv)))%mean(abs(sqrt(results_RSGARCH.vf_RSGARCH)-sqrt(rv)));mean(abs(sqrt(results_CPRSGARCH.vf_CPRSGARCH)-sqrt(rv)));mean(abs(sqrt(results_ICPRSGARCH.vf_ICPRSGARCH)-sqrt(rv)))
    mean(abs(sqrt(results_HAR.vf_HAR)-sqrt(rv)));mean(abs(sqrt(results_CPHAR.vf_CPHAR)-sqrt(rv)));mean(abs(sqrt(results_ICPHAR.vf_ICPHAR)-sqrt(rv)))
    mean(abs(sqrt(results_HAR_a.vf_HAR_a)-sqrt(rv)));mean(abs(sqrt(results_CPHAR_a.vf_CPHAR_a)-sqrt(rv)));mean(abs(sqrt(results_ICPHAR_a.vf_ICPHAR_a)-sqrt(rv)))]*sqrt(250);
RMSE=sqrt([mean((sqrt(results_GARCH.vf_GARCH)-sqrt(rv)).^2);mean((sqrt(results_CPGARCH.vf_CPGARCH)-sqrt(rv)).^2);mean((sqrt(results_ICPGARCH.vf_ICPGARCH)-sqrt(rv)).^2)
    mean((sqrt(results_GJR.vf_GJR)-sqrt(rv)).^2);mean((sqrt(results_CPGJR.vf_CPGJR)-sqrt(rv)).^2);mean((sqrt(results_ICPGJR.vf_ICPGJR)-sqrt(rv)).^2)%mean((sqrt(results_RSGARCH.vf_RSGARCH)-sqrt(rv)).^2);mean((sqrt(results_CPRSGARCH.vf_CPRSGARCH)-sqrt(rv)).^2);mean((sqrt(results_ICPRSGARCH.vf_ICPRSGARCH)-sqrt(rv)).^2)
    mean((sqrt(results_HAR.vf_HAR)-sqrt(rv)).^2);mean((sqrt(results_CPHAR.vf_CPHAR)-sqrt(rv)).^2);mean((sqrt(results_ICPHAR.vf_ICPHAR)-sqrt(rv)).^2) 
    mean((sqrt(results_HAR_a.vf_HAR_a)-sqrt(rv)).^2);mean((sqrt(results_CPHAR_a.vf_CPHAR_a)-sqrt(rv)).^2);mean((sqrt(results_ICPHAR_a.vf_ICPHAR_a)-sqrt(rv)).^2)])*sqrt(250);
outsample_mae_rmse_allmodel=table(MAE,RMSE,'RowNames',{'GARCH','CPGARCH','ICPGARCH',...
    'GJRGARCH','CPGJRGARCH','ICPGJRGARCH.', ...
    'HAR','CPHAR','ICPHAR','HAR-a','CPHAR-a','ICPHAR-a'})
ftxt=fopen([results_folder,'/outsample_mae_rmse_allmodel.txt'],'w+');
table2latex(outsample_mae_rmse_allmodel,ftxt)
fclose(ftxt);

% DM test
fcst=readtable(['Volatility_Forecast_',Working_Date,'.xlsx']);
dm_test=nan(12,12);
for i=1:12
    for j=1:12
        dm_test(i,j)=dmtest(table2array(fcst(:,i+1))-sqrt(rv),table2array(fcst(:,j+1))-sqrt(rv));
    end
end
dm_table=table(dm_test, ...
    'RowNames',{'GARCH','CPGARCH','ICPGARCH', ...
    'GJR','CPGJR','ICPGJR', ...
    'HAR','CPHAR','ICPHAR', 'HAR-a','CPHAR-a','ICPHAR-a'})
ftxt=fopen([results_folder,'/dm_test.txt'],'w+');
table2latex(dm_table,ftxt)
fclose(ftxt);
toc
close all
%% DAX
addpath("Functions/")
tic
Read_Name='DAX_0608.xlsx';
Time_Outsample=[2018,05,18;2019,05,18];
rv=get_rv(Read_Name,Time_Outsample);
Index_Name = 'DAX';
Working_Date = '20240321';
Window_Size = 1000;
results_folder = get_results_folder(Index_Name,Working_Date);
Timeline_outsample = get_datetime_outofsample(Read_Name,Time_Outsample);
results_GARCH=VolFcst_GARCH(Read_Name,Time_Outsample);
results_CPGARCH=VolFcst_CPGARCH(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_ICPGARCH=VolFcst_ICPGARCH(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_GJR=VolFcst_GJR(Read_Name,Time_Outsample);
results_CPGJR=VolFcst_CPGJR(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_ICPGJR=VolFcst_ICPGJR(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_HAR=VolFcst_HAR(Read_Name,Time_Outsample);
results_CPHAR=VolFcst_CPHAR(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_ICPHAR=VolFcst_ICPHAR(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_HAR_a=VolFcst_HAR_a(Read_Name,Time_Outsample);
results_CPHAR_a=VolFcst_CPHAR_a(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_ICPHAR_a=VolFcst_ICPHAR_a(Read_Name,Time_Outsample,'Cluster_Min_Length',100);

% Save forecast volatility
Model_Name={'GARCH','CPGARCH','ICPGARCH',...
        'GJR','CPGJR','ICPGJR', ... 
        'HAR','CPHAR','ICPHAR',...
        'HAR_a','CPHAR_a','ICPHAR_a'};
for i=1:12
    save([results_folder,'/','VolFcst_NORMAL_',Index_Name, ...
        '_',Model_Name{i},'_size',num2str(Window_Size),'_',Working_Date],['results_',Model_Name{i}]);
end
Output_Table=table(Timeline_outsample,sqrt(results_GARCH.vf_GARCH),sqrt(results_CPGARCH.vf_CPGARCH),sqrt(results_ICPGARCH.vf_ICPGARCH), ...
    sqrt(results_GJR.vf_GJR),sqrt(results_CPGJR.vf_CPGJR),sqrt(results_ICPGJR.vf_ICPGJR), ... sqrt(results_RSGARCH.vf_RSGARCH),sqrt(results_CPRSGARCH.vf_CPRSGARCH),sqrt(results_ICPRSGARCH.vf_ICPRSGARCH), ...
    sqrt(results_HAR.vf_HAR),sqrt(results_CPHAR.vf_CPHAR),sqrt(results_ICPHAR.vf_ICPHAR), ...
    sqrt(results_HAR_a.vf_HAR_a),sqrt(results_CPHAR_a.vf_CPHAR_a),sqrt(results_ICPHAR_a.vf_ICPHAR_a), ...
    'VariableNames',{'Date','vf_GARCH','vf_CPGARCH','vf_ICPGARCH', ...
    'vf_GJR','vf_CPGJR','vf_ICPGJR', ...
    'vf_HAR','vf_CPHAR','vf_ICPHAR', ...
    'vf_HAR_a','vf_CPHAR_a','vf_ICPHAR_a'});
writetable(Output_Table,[results_folder,'/','Volatility_Forecast_',Working_Date,'.xlsx']);
Output_Table=table(Timeline_outsample,results_GARCH.ismae_GARCH,results_CPGARCH.ismae_CPGARCH,results_ICPGARCH.ismae_ICPGARCH, ...
    results_GJR.ismae_GJR,results_CPGJR.ismae_CPGJR,results_ICPGJR.ismae_ICPGJR, ... 
    results_HAR.ismae_HAR,results_CPHAR.ismae_CPHAR,results_ICPHAR.ismae_ICPHAR, ...
    results_HAR_a.ismae_HAR_a,results_CPHAR_a.ismae_CPHAR_a,results_ICPHAR_a.ismae_ICPHAR_a, ...
    'VariableNames',{'Date','ismae_GARCH','ismae_CPGARCH','ismae_ICPGARCH', ...
    'ismae_GJR','ismae_CPGJR','ismae_ICPGJR', ...
    'ismae_HAR','ismae_CPHAR','ismae_ICPHAR', ...
    'ismae_HAR_a','ismae_CPHAR_a','ismae_ICPHAR_a'});
writetable(Output_Table,[results_folder,'/','Insample_MAE_',Working_Date,'.xlsx']);
Output_Table=table(Timeline_outsample,results_GARCH.isrmse_GARCH,results_CPGARCH.isrmse_CPGARCH,results_ICPGARCH.isrmse_ICPGARCH, ...
    results_GJR.isrmse_GJR,results_CPGJR.isrmse_CPGJR,results_ICPGJR.isrmse_ICPGJR, ... 
    results_HAR.isrmse_HAR,results_CPHAR.isrmse_CPHAR,results_ICPHAR.isrmse_ICPHAR, ...
    results_HAR_a.isrmse_HAR_a,results_CPHAR_a.isrmse_CPHAR_a,results_ICPHAR_a.isrmse_ICPHAR_a, ...
    'VariableNames',{'Date','isrmse_GARCH','isrmse_CPGARCH','isrmse_ICPGARCH', ...
    'isrmse_GJR','isrmse_CPGJR','isrmse_ICPGJR', ...
    'isrmse_HAR','isrmse_CPHAR','isrmse_ICPHAR', ...
    'isrmse_HAR_a','isrmse_CPHAR_a','isrmse_ICPHAR_a'});
writetable(Output_Table,[results_folder,'/','Insample_RMSE_',Working_Date,'.xlsx']);
Output_Table=table(Timeline_outsample,results_CPGARCH.K, ...
    results_CPGJR.K, ... 
    results_CPHAR.K, ...
    results_CPHAR_a.isrmse_CPHAR_a, ...
    'VariableNames',{'Date','K_CPGARCH',...
    'K_CPGJR',...
    'K_CPHAR',...
    'K_CPHAR_a'});
writetable(Output_Table,[results_folder,'/','K_',Working_Date,'.xlsx']);

% Load forecast volatility
for i=1:12
    load([results_folder,'/','VolFcst_NORMAL_',Index_Name, ...
        '_',Model_Name{i},'_size',num2str(Window_Size),'_',Working_Date]);
end
% Volatility forecasts: GARCH, CPGARCH, ICPGARCH,
% GJR, CPGJR, ICPGJR, 
% HAR, CPHAR, ICPHAR, HAR-a, CPHAR-a, ICPHAR-a
figure;
col=rainbow(13);
plot(Timeline_outsample,sqrt(results_GARCH.vf_GARCH)*sqrt(250), "Color",col(1,:));hold on
plot(Timeline_outsample,sqrt(results_CPGARCH.vf_CPGARCH)*sqrt(250), "Color",col(2,:))
plot(Timeline_outsample,sqrt(results_ICPGARCH.vf_ICPGARCH)*sqrt(250), "Color",col(3,:))
plot(Timeline_outsample,sqrt(results_GJR.vf_GJR)*sqrt(250), "Color",col(4,:));
plot(Timeline_outsample,sqrt(results_CPGJR.vf_CPGJR)*sqrt(250), "Color",col(5,:))
plot(Timeline_outsample,sqrt(results_ICPGJR.vf_ICPGJR)*sqrt(250), "Color",col(6,:))
plot(Timeline_outsample,sqrt(results_HAR.vf_HAR)*sqrt(250), "Color",col(7,:))
plot(Timeline_outsample,sqrt(results_CPHAR.vf_CPHAR)*sqrt(250), "Color",col(8,:))
plot(Timeline_outsample,sqrt(results_ICPHAR.vf_ICPHAR)*sqrt(250), "Color",col(9,:))
plot(Timeline_outsample,sqrt(results_HAR_a.vf_HAR_a)*sqrt(250), "Color",col(10,:))
plot(Timeline_outsample,sqrt(results_CPHAR_a.vf_CPHAR_a)*sqrt(250), "Color",col(11,:))
plot(Timeline_outsample,sqrt(results_ICPHAR_a.vf_ICPHAR_a)*sqrt(250), "Color",col(12,:))
plot(Timeline_outsample,sqrt(rv)*sqrt(250), "Color",col(13,:))
legend("GARCH","CPGARCH","ICPGARCH", ...
    "GJRGARCH", "CPGJRGARCH", "ICPGJRGARCH", ...
    "HAR","CPHAR","CPHAR", "HAR-a","CPHAR-a","ICPHAR-a", ...
    "RV","Location","best");
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/volatility_forecast_allmodel.png'])

% Volatility forecasts: GARCH  CPGARCH, CPGARCH iteration
figure;
col=rainbow(4);
plot(Timeline_outsample,sqrt(rv)*sqrt(250), "Color",col(4,:));hold on
plot(Timeline_outsample,sqrt(results_GARCH.vf_GARCH)*sqrt(250), "Color",col(1,:))
plot(Timeline_outsample,sqrt(results_CPGARCH.vf_CPGARCH)*sqrt(250), "Color",col(2,:))
plot(Timeline_outsample,sqrt(results_ICPGARCH.vf_ICPGARCH)*sqrt(250), "Color",col(3,:))
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/volatility_forecast_garchs.png'])

% Volatility forecasts: GJR, CPGJR, CPGJR iteration
figure;
col=rainbow(4);
plot(Timeline_outsample,sqrt(rv)*sqrt(250), "Color",col(4,:));hold on
plot(Timeline_outsample,sqrt(results_GJR.vf_GJR)*sqrt(250), "Color",col(1,:))
plot(Timeline_outsample,sqrt(results_CPGJR.vf_CPGJR)*sqrt(250), "Color",col(2,:))
plot(Timeline_outsample,sqrt(results_ICPGJR.vf_ICPGJR)*sqrt(250), "Color",col(3,:))
legend("RV","GJR","CPGJR","ICPGJR",'Location','best');
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/volatility_forecast_gjrs.png'])

% Volatility forecasts: HAR, CPHAR, ICPHAR
figure;
col=rainbow(4);
plot(Timeline_outsample,sqrt(rv)*sqrt(250), "Color",col(4,:));hold on
plot(Timeline_outsample,sqrt(results_HAR.vf_HAR)*sqrt(250), "Color",col(1,:))
plot(Timeline_outsample,sqrt(results_CPHAR.vf_CPHAR)*sqrt(250), "Color",col(2,:))
plot(Timeline_outsample,sqrt(results_ICPHAR.vf_ICPHAR)*sqrt(250), "Color",col(3,:))
legend("RV","HAR","CPHAR","ICPHAR",'Location','best');
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/volatility_forecast_hars.png'])

% Volatility forecasts: HAR-a, CPHAR-a, ICPHAR-a
figure;
col=rainbow(4);
plot(Timeline_outsample,sqrt(rv)*sqrt(250), "Color",col(4,:));hold on
plot(Timeline_outsample,sqrt(results_HAR_a.vf_HAR_a)*sqrt(250), "Color",col(1,:))
plot(Timeline_outsample,sqrt(results_CPHAR_a.vf_CPHAR_a)*sqrt(250), "Color",col(2,:))
plot(Timeline_outsample,sqrt(results_ICPHAR_a.vf_ICPHAR_a)*sqrt(250), "Color",col(3,:))
legend("RV","HAR-a","CPHAR-a","ICPHAR-a",'Location','best');
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/volatility_forecast_haras.png'])

% Figure of parameters in each estimation window
% GARCH
col=rainbow(3);
figure;
subplot(2,2,1);
plot(Timeline_outsample,results_GARCH.para(:,1),"Color",col(1,:));
subtitle("constant")
subplot(2,2,2);
plot(Timeline_outsample,results_GARCH.para(:,2),"Color",col(2,:));
subtitle("ARCH")
subplot(2,2,3);
plot(Timeline_outsample,results_GARCH.para(:,3),"Color",col(3,:));
subtitle("GARCH")
saveas(gcf,[results_folder,'/dynamic_parameters_garch.png'])

% Figure of optimal cluster number in each estimation window
figure;
col=rainbow(4);
plot(Timeline_outsample,results_CPGARCH.K,"Color",col(1,:));hold on
plot(Timeline_outsample,results_CPGJR.K,"Color",col(2,:));
plot(Timeline_outsample,results_CPHAR.K,"Color",col(3,:));
plot(Timeline_outsample,results_CPHAR_a.K,"Color",col(4,:));
legend("GARCH","GJRGARCH","HAR","HAR-a")
saveas(gcf,[results_folder,'/dynamic_optimal_cluster_number.png'])

% Figure of in-sample MAE and MSE
figure;
col=rainbow(12);
plot(Timeline_outsample,results_GARCH.ismae_GARCH,"Color",col(1,:));hold on
plot(Timeline_outsample,results_CPGARCH.ismae_CPGARCH,"Color",col(2,:));
plot(Timeline_outsample,results_ICPGARCH.ismae_ICPGARCH,"Color",col(3,:));
plot(Timeline_outsample,results_GJR.ismae_GJR,"Color",col(4,:));
plot(Timeline_outsample,results_CPGJR.ismae_CPGJR,"Color",col(5,:));
plot(Timeline_outsample,results_ICPGJR.ismae_ICPGJR,"Color",col(6,:));
plot(Timeline_outsample,results_HAR.ismae_HAR,"Color",col(7,:));
plot(Timeline_outsample,results_CPHAR.ismae_CPHAR,"Color",col(8,:));
plot(Timeline_outsample,results_ICPHAR.ismae_ICPHAR,"Color",col(9,:));
plot(Timeline_outsample,results_HAR_a.ismae_HAR_a,"Color",col(10,:));
plot(Timeline_outsample,results_CPHAR_a.ismae_CPHAR_a,"Color",col(11,:));
plot(Timeline_outsample,results_ICPHAR_a.ismae_ICPHAR_a,"Color",col(12,:));
legend("GARCH","CPGARCH","ICPGARCH", ...
    "GJR","CPGJR","ICPGJR", ...
    "HAR","CPHAR","ICPHAR","HAR-a","CPHAR-a","ICPHAR-a")
title("in-sample MAE")
saveas(gcf,[results_folder,'/insample_mae.png'])
figure;
col=rainbow(12);
plot(Timeline_outsample,results_GARCH.isrmse_GARCH,"Color",col(1,:));hold on
plot(Timeline_outsample,results_CPGARCH.isrmse_CPGARCH,"Color",col(2,:));
plot(Timeline_outsample,results_ICPGARCH.isrmse_ICPGARCH,"Color",col(3,:));
plot(Timeline_outsample,results_GJR.isrmse_GJR,"Color",col(4,:));
plot(Timeline_outsample,results_CPGJR.isrmse_CPGJR,"Color",col(5,:));
plot(Timeline_outsample,results_ICPGJR.isrmse_ICPGJR,"Color",col(6,:));
plot(Timeline_outsample,results_HAR.isrmse_HAR,"Color",col(7,:));
plot(Timeline_outsample,results_CPHAR.isrmse_CPHAR,"Color",col(8,:));
plot(Timeline_outsample,results_ICPHAR.isrmse_ICPHAR,"Color",col(9,:));
plot(Timeline_outsample,results_HAR_a.isrmse_HAR_a,"Color",col(10,:));
plot(Timeline_outsample,results_CPHAR_a.isrmse_CPHAR_a,"Color",col(11,:));
plot(Timeline_outsample,results_ICPHAR_a.isrmse_ICPHAR_a,"Color",col(12,:));
legend("GARCH","CPGARCH","ICPGARCH", ...
    "GJR","CPGJR","ICPGJR", ...
    "HAR","CPHAR","ICPHAR","HAR-a","CPHAR-a","ICPHAR-a")
title("in-sample RMSE")
saveas(gcf,[results_folder,'/insample_rmse.png'])

% MAE & RMSE
MAE=[mean(abs(sqrt(results_GARCH.vf_GARCH)-sqrt(rv)));mean(abs(sqrt(results_CPGARCH.vf_CPGARCH)-sqrt(rv)));mean(abs(sqrt(results_ICPGARCH.vf_ICPGARCH)-sqrt(rv)))
    mean(abs(sqrt(results_GJR.vf_GJR)-sqrt(rv)));mean(abs(sqrt(results_CPGJR.vf_CPGJR)-sqrt(rv)));mean(abs(sqrt(results_ICPGJR.vf_ICPGJR)-sqrt(rv)))%mean(abs(sqrt(results_RSGARCH.vf_RSGARCH)-sqrt(rv)));mean(abs(sqrt(results_CPRSGARCH.vf_CPRSGARCH)-sqrt(rv)));mean(abs(sqrt(results_ICPRSGARCH.vf_ICPRSGARCH)-sqrt(rv)))
    mean(abs(sqrt(results_HAR.vf_HAR)-sqrt(rv)));mean(abs(sqrt(results_CPHAR.vf_CPHAR)-sqrt(rv)));mean(abs(sqrt(results_ICPHAR.vf_ICPHAR)-sqrt(rv)))
    mean(abs(sqrt(results_HAR_a.vf_HAR_a)-sqrt(rv)));mean(abs(sqrt(results_CPHAR_a.vf_CPHAR_a)-sqrt(rv)));mean(abs(sqrt(results_ICPHAR_a.vf_ICPHAR_a)-sqrt(rv)))]*sqrt(250);
RMSE=sqrt([mean((sqrt(results_GARCH.vf_GARCH)-sqrt(rv)).^2);mean((sqrt(results_CPGARCH.vf_CPGARCH)-sqrt(rv)).^2);mean((sqrt(results_ICPGARCH.vf_ICPGARCH)-sqrt(rv)).^2)
    mean((sqrt(results_GJR.vf_GJR)-sqrt(rv)).^2);mean((sqrt(results_CPGJR.vf_CPGJR)-sqrt(rv)).^2);mean((sqrt(results_ICPGJR.vf_ICPGJR)-sqrt(rv)).^2)%mean((sqrt(results_RSGARCH.vf_RSGARCH)-sqrt(rv)).^2);mean((sqrt(results_CPRSGARCH.vf_CPRSGARCH)-sqrt(rv)).^2);mean((sqrt(results_ICPRSGARCH.vf_ICPRSGARCH)-sqrt(rv)).^2)
    mean((sqrt(results_HAR.vf_HAR)-sqrt(rv)).^2);mean((sqrt(results_CPHAR.vf_CPHAR)-sqrt(rv)).^2);mean((sqrt(results_ICPHAR.vf_ICPHAR)-sqrt(rv)).^2) 
    mean((sqrt(results_HAR_a.vf_HAR_a)-sqrt(rv)).^2);mean((sqrt(results_CPHAR_a.vf_CPHAR_a)-sqrt(rv)).^2);mean((sqrt(results_ICPHAR_a.vf_ICPHAR_a)-sqrt(rv)).^2)])*sqrt(250);
outsample_mae_rmse_allmodel=table(MAE,RMSE,'RowNames',{'GARCH','CPGARCH','ICPGARCH',...
    'GJRGARCH','CPGJRGARCH','ICPGJRGARCH.', ...
    'HAR','CPHAR','ICPHAR','HAR-a','CPHAR-a','ICPHAR-a'})
ftxt=fopen([results_folder,'/outsample_mae_rmse_allmodel.txt'],'w+');
table2latex(outsample_mae_rmse_allmodel,ftxt)
fclose(ftxt);

% DM test
fcst=readtable(['Volatility_Forecast_',Working_Date,'.xlsx']);
dm_test=nan(12,12);
for i=1:12
    for j=1:12
        dm_test(i,j)=dmtest(table2array(fcst(:,i+1))-sqrt(rv),table2array(fcst(:,j+1))-sqrt(rv));
    end
end
dm_table=table(dm_test, ...
    'RowNames',{'GARCH','CPGARCH','ICPGARCH', ...
    'GJR','CPGJR','ICPGJR', ...
    'HAR','CPHAR','ICPHAR', 'HAR-a','CPHAR-a','ICPHAR-a'})
ftxt=fopen([results_folder,'/dm_test.txt'],'w+');
table2latex(dm_table,ftxt)
fclose(ftxt);
toc
close all
%% FTSE
tic
addpath("Functions/")
Read_Name='FTSE_0608.xlsx';
Time_Outsample=[2018,05,18;2019,05,18];
rv=get_rv(Read_Name,Time_Outsample);
Index_Name = 'FTSE';
Working_Date = '20240321';
Window_Size = 1000;
results_folder = get_results_folder(Index_Name,Working_Date);
Timeline_outsample = get_datetime_outofsample(Read_Name,Time_Outsample);
results_GARCH=VolFcst_GARCH(Read_Name,Time_Outsample);
results_CPGARCH=VolFcst_CPGARCH(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_ICPGARCH=VolFcst_ICPGARCH(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_GJR=VolFcst_GJR(Read_Name,Time_Outsample);
results_CPGJR=VolFcst_CPGJR(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_ICPGJR=VolFcst_ICPGJR(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_HAR=VolFcst_HAR(Read_Name,Time_Outsample);
results_CPHAR=VolFcst_CPHAR(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_ICPHAR=VolFcst_ICPHAR(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_HAR_a=VolFcst_HAR_a(Read_Name,Time_Outsample);
results_CPHAR_a=VolFcst_CPHAR_a(Read_Name,Time_Outsample,'Cluster_Min_Length',100);
results_ICPHAR_a=VolFcst_ICPHAR_a(Read_Name,Time_Outsample,'Cluster_Min_Length',100);

% Save forecast volatility
Model_Name={'GARCH','CPGARCH','ICPGARCH',...
        'GJR','CPGJR','ICPGJR', ... 
        'HAR','CPHAR','ICPHAR',...
        'HAR_a','CPHAR_a','ICPHAR_a'};
for i=1:12
    save([results_folder,'/','VolFcst_NORMAL_',Index_Name, ...
        '_',Model_Name{i},'_size',num2str(Window_Size),'_',Working_Date],['results_',Model_Name{i}]);
end
Output_Table=table(Timeline_outsample,sqrt(results_GARCH.vf_GARCH),sqrt(results_CPGARCH.vf_CPGARCH),sqrt(results_ICPGARCH.vf_ICPGARCH), ...
    sqrt(results_GJR.vf_GJR),sqrt(results_CPGJR.vf_CPGJR),sqrt(results_ICPGJR.vf_ICPGJR), ... sqrt(results_RSGARCH.vf_RSGARCH),sqrt(results_CPRSGARCH.vf_CPRSGARCH),sqrt(results_ICPRSGARCH.vf_ICPRSGARCH), ...
    sqrt(results_HAR.vf_HAR),sqrt(results_CPHAR.vf_CPHAR),sqrt(results_ICPHAR.vf_ICPHAR), ...
    sqrt(results_HAR_a.vf_HAR_a),sqrt(results_CPHAR_a.vf_CPHAR_a),sqrt(results_ICPHAR_a.vf_ICPHAR_a), ...
    'VariableNames',{'Date','vf_GARCH','vf_CPGARCH','vf_ICPGARCH', ...
    'vf_GJR','vf_CPGJR','vf_ICPGJR', ...
    'vf_HAR','vf_CPHAR','vf_ICPHAR', ...
    'vf_HAR_a','vf_CPHAR_a','vf_ICPHAR_a'});
writetable(Output_Table,[results_folder,'/','Volatility_Forecast_',Working_Date,'.xlsx']);
Output_Table=table(Timeline_outsample,results_GARCH.ismae_GARCH,results_CPGARCH.ismae_CPGARCH,results_ICPGARCH.ismae_ICPGARCH, ...
    results_GJR.ismae_GJR,results_CPGJR.ismae_CPGJR,results_ICPGJR.ismae_ICPGJR, ... 
    results_HAR.ismae_HAR,results_CPHAR.ismae_CPHAR,results_ICPHAR.ismae_ICPHAR, ...
    results_HAR_a.ismae_HAR_a,results_CPHAR_a.ismae_CPHAR_a,results_ICPHAR_a.ismae_ICPHAR_a, ...
    'VariableNames',{'Date','ismae_GARCH','ismae_CPGARCH','ismae_ICPGARCH', ...
    'ismae_GJR','ismae_CPGJR','ismae_ICPGJR', ...
    'ismae_HAR','ismae_CPHAR','ismae_ICPHAR', ...
    'ismae_HAR_a','ismae_CPHAR_a','ismae_ICPHAR_a'});
writetable(Output_Table,[results_folder,'/','Insample_MAE_',Working_Date,'.xlsx']);
Output_Table=table(Timeline_outsample,results_GARCH.isrmse_GARCH,results_CPGARCH.isrmse_CPGARCH,results_ICPGARCH.isrmse_ICPGARCH, ...
    results_GJR.isrmse_GJR,results_CPGJR.isrmse_CPGJR,results_ICPGJR.isrmse_ICPGJR, ... 
    results_HAR.isrmse_HAR,results_CPHAR.isrmse_CPHAR,results_ICPHAR.isrmse_ICPHAR, ...
    results_HAR_a.isrmse_HAR_a,results_CPHAR_a.isrmse_CPHAR_a,results_ICPHAR_a.isrmse_ICPHAR_a, ...
    'VariableNames',{'Date','isrmse_GARCH','isrmse_CPGARCH','isrmse_ICPGARCH', ...
    'isrmse_GJR','isrmse_CPGJR','isrmse_ICPGJR', ...
    'isrmse_HAR','isrmse_CPHAR','isrmse_ICPHAR', ...
    'isrmse_HAR_a','isrmse_CPHAR_a','isrmse_ICPHAR_a'});
writetable(Output_Table,[results_folder,'/','Insample_RMSE_',Working_Date,'.xlsx']);
Output_Table=table(Timeline_outsample,results_CPGARCH.K, ...
    results_CPGJR.K, ... 
    results_CPHAR.K, ...
    results_CPHAR_a.isrmse_CPHAR_a, ...
    'VariableNames',{'Date','K_CPGARCH',...
    'K_CPGJR',...
    'K_CPHAR',...
    'K_CPHAR_a'});
writetable(Output_Table,[results_folder,'/','K_',Working_Date,'.xlsx']);

% Load forecast volatility
for i=1:12
    load([results_folder,'/','VolFcst_NORMAL_',Index_Name, ...
        '_',Model_Name{i},'_size',num2str(Window_Size),'_',Working_Date]);
end
% Volatility forecasts: GARCH, CPGARCH, ICPGARCH,
% GJR, CPGJR, ICPGJR, 
% HAR, CPHAR, ICPHAR, HAR-a, CPHAR-a, ICPHAR-a
figure;
col=rainbow(13);
plot(Timeline_outsample,sqrt(results_GARCH.vf_GARCH)*sqrt(250), "Color",col(1,:));hold on
plot(Timeline_outsample,sqrt(results_CPGARCH.vf_CPGARCH)*sqrt(250), "Color",col(2,:))
plot(Timeline_outsample,sqrt(results_ICPGARCH.vf_ICPGARCH)*sqrt(250), "Color",col(3,:))
plot(Timeline_outsample,sqrt(results_GJR.vf_GJR)*sqrt(250), "Color",col(4,:));
plot(Timeline_outsample,sqrt(results_CPGJR.vf_CPGJR)*sqrt(250), "Color",col(5,:))
plot(Timeline_outsample,sqrt(results_ICPGJR.vf_ICPGJR)*sqrt(250), "Color",col(6,:))
plot(Timeline_outsample,sqrt(results_HAR.vf_HAR)*sqrt(250), "Color",col(7,:))
plot(Timeline_outsample,sqrt(results_CPHAR.vf_CPHAR)*sqrt(250), "Color",col(8,:))
plot(Timeline_outsample,sqrt(results_ICPHAR.vf_ICPHAR)*sqrt(250), "Color",col(9,:))
plot(Timeline_outsample,sqrt(results_HAR_a.vf_HAR_a)*sqrt(250), "Color",col(10,:))
plot(Timeline_outsample,sqrt(results_CPHAR_a.vf_CPHAR_a)*sqrt(250), "Color",col(11,:))
plot(Timeline_outsample,sqrt(results_ICPHAR_a.vf_ICPHAR_a)*sqrt(250), "Color",col(12,:))
plot(Timeline_outsample,sqrt(rv)*sqrt(250), "Color",col(13,:))
legend("GARCH","CPGARCH","ICPGARCH", ...
    "GJRGARCH", "CPGJRGARCH", "ICPGJRGARCH", ...
    "HAR","CPHAR","CPHAR", "HAR-a","CPHAR-a","ICPHAR-a", ...
    "RV","Location","best");
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/volatility_forecast_allmodel.png'])

% Volatility forecasts: GARCH  CPGARCH, CPGARCH iteration
figure;
col=rainbow(4);
plot(Timeline_outsample,sqrt(rv)*sqrt(250), "Color",col(4,:));hold on
plot(Timeline_outsample,sqrt(results_GARCH.vf_GARCH)*sqrt(250), "Color",col(1,:))
plot(Timeline_outsample,sqrt(results_CPGARCH.vf_CPGARCH)*sqrt(250), "Color",col(2,:))
plot(Timeline_outsample,sqrt(results_ICPGARCH.vf_ICPGARCH)*sqrt(250), "Color",col(3,:))
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/volatility_forecast_garchs.png'])

% Volatility forecasts: GJR, CPGJR, CPGJR iteration
figure;
col=rainbow(4);
plot(Timeline_outsample,sqrt(rv)*sqrt(250), "Color",col(4,:));hold on
plot(Timeline_outsample,sqrt(results_GJR.vf_GJR)*sqrt(250), "Color",col(1,:))
plot(Timeline_outsample,sqrt(results_CPGJR.vf_CPGJR)*sqrt(250), "Color",col(2,:))
plot(Timeline_outsample,sqrt(results_ICPGJR.vf_ICPGJR)*sqrt(250), "Color",col(3,:))
legend("RV","GJR","CPGJR","ICPGJR",'Location','best');
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/volatility_forecast_gjrs.png'])

% Volatility forecasts: HAR, CPHAR, ICPHAR
figure;
col=rainbow(4);
plot(Timeline_outsample,sqrt(rv)*sqrt(250), "Color",col(4,:));hold on
plot(Timeline_outsample,sqrt(results_HAR.vf_HAR)*sqrt(250), "Color",col(1,:))
plot(Timeline_outsample,sqrt(results_CPHAR.vf_CPHAR)*sqrt(250), "Color",col(2,:))
plot(Timeline_outsample,sqrt(results_ICPHAR.vf_ICPHAR)*sqrt(250), "Color",col(3,:))
legend("RV","HAR","CPHAR","ICPHAR",'Location','best');
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/volatility_forecast_hars.png'])

% Volatility forecasts: HAR-a, CPHAR-a, ICPHAR-a
figure;
col=rainbow(4);
plot(Timeline_outsample,sqrt(rv)*sqrt(250), "Color",col(4,:));hold on
plot(Timeline_outsample,sqrt(results_HAR_a.vf_HAR_a)*sqrt(250), "Color",col(1,:))
plot(Timeline_outsample,sqrt(results_CPHAR_a.vf_CPHAR_a)*sqrt(250), "Color",col(2,:))
plot(Timeline_outsample,sqrt(results_ICPHAR_a.vf_ICPHAR_a)*sqrt(250), "Color",col(3,:))
legend("RV","HAR-a","CPHAR-a","ICPHAR-a",'Location','best');
set(gcf,'Position',[500 500 900 300]);
saveas(gcf,[results_folder,'/volatility_forecast_haras.png'])

% Figure of parameters in each estimation window
% GARCH
col=rainbow(3);
figure;
subplot(2,2,1);
plot(Timeline_outsample,results_GARCH.para(:,1),"Color",col(1,:));
subtitle("constant")
subplot(2,2,2);
plot(Timeline_outsample,results_GARCH.para(:,2),"Color",col(2,:));
subtitle("ARCH")
subplot(2,2,3);
plot(Timeline_outsample,results_GARCH.para(:,3),"Color",col(3,:));
subtitle("GARCH")
saveas(gcf,[results_folder,'/dynamic_parameters_garch.png'])

% Figure of optimal cluster number in each estimation window
figure;
col=rainbow(4);
plot(Timeline_outsample,results_CPGARCH.K,"Color",col(1,:));hold on
plot(Timeline_outsample,results_CPGJR.K,"Color",col(2,:));
plot(Timeline_outsample,results_CPHAR.K,"Color",col(3,:));
plot(Timeline_outsample,results_CPHAR_a.K,"Color",col(4,:));
legend("GARCH","GJRGARCH","HAR","HAR-a")
saveas(gcf,[results_folder,'/dynamic_optimal_cluster_number.png'])

% Figure of in-sample MAE and MSE
figure;
col=rainbow(12);
plot(Timeline_outsample,results_GARCH.ismae_GARCH,"Color",col(1,:));hold on
plot(Timeline_outsample,results_CPGARCH.ismae_CPGARCH,"Color",col(2,:));
plot(Timeline_outsample,results_ICPGARCH.ismae_ICPGARCH,"Color",col(3,:));
plot(Timeline_outsample,results_GJR.ismae_GJR,"Color",col(4,:));
plot(Timeline_outsample,results_CPGJR.ismae_CPGJR,"Color",col(5,:));
plot(Timeline_outsample,results_ICPGJR.ismae_ICPGJR,"Color",col(6,:));
plot(Timeline_outsample,results_HAR.ismae_HAR,"Color",col(7,:));
plot(Timeline_outsample,results_CPHAR.ismae_CPHAR,"Color",col(8,:));
plot(Timeline_outsample,results_ICPHAR.ismae_ICPHAR,"Color",col(9,:));
plot(Timeline_outsample,results_HAR_a.ismae_HAR_a,"Color",col(10,:));
plot(Timeline_outsample,results_CPHAR_a.ismae_CPHAR_a,"Color",col(11,:));
plot(Timeline_outsample,results_ICPHAR_a.ismae_ICPHAR_a,"Color",col(12,:));
legend("GARCH","CPGARCH","ICPGARCH", ...
    "GJR","CPGJR","ICPGJR", ...
    "HAR","CPHAR","ICPHAR","HAR-a","CPHAR-a","ICPHAR-a")
title("in-sample MAE")
saveas(gcf,[results_folder,'/insample_mae.png'])
figure;
col=rainbow(12);
plot(Timeline_outsample,results_GARCH.isrmse_GARCH,"Color",col(1,:));hold on
plot(Timeline_outsample,results_CPGARCH.isrmse_CPGARCH,"Color",col(2,:));
plot(Timeline_outsample,results_ICPGARCH.isrmse_ICPGARCH,"Color",col(3,:));
plot(Timeline_outsample,results_GJR.isrmse_GJR,"Color",col(4,:));
plot(Timeline_outsample,results_CPGJR.isrmse_CPGJR,"Color",col(5,:));
plot(Timeline_outsample,results_ICPGJR.isrmse_ICPGJR,"Color",col(6,:));
plot(Timeline_outsample,results_HAR.isrmse_HAR,"Color",col(7,:));
plot(Timeline_outsample,results_CPHAR.isrmse_CPHAR,"Color",col(8,:));
plot(Timeline_outsample,results_ICPHAR.isrmse_ICPHAR,"Color",col(9,:));
plot(Timeline_outsample,results_HAR_a.isrmse_HAR_a,"Color",col(10,:));
plot(Timeline_outsample,results_CPHAR_a.isrmse_CPHAR_a,"Color",col(11,:));
plot(Timeline_outsample,results_ICPHAR_a.isrmse_ICPHAR_a,"Color",col(12,:));
legend("GARCH","CPGARCH","ICPGARCH", ...
    "GJR","CPGJR","ICPGJR", ...
    "HAR","CPHAR","ICPHAR","HAR-a","CPHAR-a","ICPHAR-a")
title("in-sample RMSE")
saveas(gcf,[results_folder,'/insample_rmse.png'])

% MAE & RMSE
MAE=[mean(abs(sqrt(results_GARCH.vf_GARCH)-sqrt(rv)));mean(abs(sqrt(results_CPGARCH.vf_CPGARCH)-sqrt(rv)));mean(abs(sqrt(results_ICPGARCH.vf_ICPGARCH)-sqrt(rv)))
    mean(abs(sqrt(results_GJR.vf_GJR)-sqrt(rv)));mean(abs(sqrt(results_CPGJR.vf_CPGJR)-sqrt(rv)));mean(abs(sqrt(results_ICPGJR.vf_ICPGJR)-sqrt(rv)))%mean(abs(sqrt(results_RSGARCH.vf_RSGARCH)-sqrt(rv)));mean(abs(sqrt(results_CPRSGARCH.vf_CPRSGARCH)-sqrt(rv)));mean(abs(sqrt(results_ICPRSGARCH.vf_ICPRSGARCH)-sqrt(rv)))
    mean(abs(sqrt(results_HAR.vf_HAR)-sqrt(rv)));mean(abs(sqrt(results_CPHAR.vf_CPHAR)-sqrt(rv)));mean(abs(sqrt(results_ICPHAR.vf_ICPHAR)-sqrt(rv)))
    mean(abs(sqrt(results_HAR_a.vf_HAR_a)-sqrt(rv)));mean(abs(sqrt(results_CPHAR_a.vf_CPHAR_a)-sqrt(rv)));mean(abs(sqrt(results_ICPHAR_a.vf_ICPHAR_a)-sqrt(rv)))]*sqrt(250);
RMSE=sqrt([mean((sqrt(results_GARCH.vf_GARCH)-sqrt(rv)).^2);mean((sqrt(results_CPGARCH.vf_CPGARCH)-sqrt(rv)).^2);mean((sqrt(results_ICPGARCH.vf_ICPGARCH)-sqrt(rv)).^2)
    mean((sqrt(results_GJR.vf_GJR)-sqrt(rv)).^2);mean((sqrt(results_CPGJR.vf_CPGJR)-sqrt(rv)).^2);mean((sqrt(results_ICPGJR.vf_ICPGJR)-sqrt(rv)).^2)%mean((sqrt(results_RSGARCH.vf_RSGARCH)-sqrt(rv)).^2);mean((sqrt(results_CPRSGARCH.vf_CPRSGARCH)-sqrt(rv)).^2);mean((sqrt(results_ICPRSGARCH.vf_ICPRSGARCH)-sqrt(rv)).^2)
    mean((sqrt(results_HAR.vf_HAR)-sqrt(rv)).^2);mean((sqrt(results_CPHAR.vf_CPHAR)-sqrt(rv)).^2);mean((sqrt(results_ICPHAR.vf_ICPHAR)-sqrt(rv)).^2) 
    mean((sqrt(results_HAR_a.vf_HAR_a)-sqrt(rv)).^2);mean((sqrt(results_CPHAR_a.vf_CPHAR_a)-sqrt(rv)).^2);mean((sqrt(results_ICPHAR_a.vf_ICPHAR_a)-sqrt(rv)).^2)])*sqrt(250);
outsample_mae_rmse_allmodel=table(MAE,RMSE,'RowNames',{'GARCH','CPGARCH','ICPGARCH',...
    'GJRGARCH','CPGJRGARCH','ICPGJRGARCH.', ...
    'HAR','CPHAR','ICPHAR','HAR-a','CPHAR-a','ICPHAR-a'})
ftxt=fopen([results_folder,'/outsample_mae_rmse_allmodel.txt'],'w+');
table2latex(outsample_mae_rmse_allmodel,ftxt)
fclose(ftxt);

% DM test
fcst=readtable(['Volatility_Forecast_',Working_Date,'.xlsx']);
dm_test=nan(12,12);
for i=1:12
    for j=1:12
        dm_test(i,j)=dmtest(table2array(fcst(:,i+1))-sqrt(rv),table2array(fcst(:,j+1))-sqrt(rv));
    end
end
dm_table=table(dm_test, ...
    'RowNames',{'GARCH','CPGARCH','ICPGARCH', ...
    'GJR','CPGJR','ICPGJR', ...
    'HAR','CPHAR','ICPHAR', 'HAR-a','CPHAR-a','ICPHAR-a'})
ftxt=fopen([results_folder,'/dm_test.txt'],'w+');
table2latex(dm_table,ftxt)
fclose(ftxt);
toc
close all
