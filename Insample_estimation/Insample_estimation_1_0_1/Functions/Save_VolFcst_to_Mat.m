% Save forecast volatility to mat file
% Input:
%        Index_Name              Index name, like "SP500", "DAX" or "FTSE"
%
%        Working_Date            To control version, like '_20220811' for
%                                date 20220811 of running time
%
%        Read_Name               Input excel name of raw index, like 'DAX_0608.xlsx'
%
%        Time_Outsample          Time for out-of-sample, like
%                                [2021,05,18;2022,05,18], the first row is
%                                the starting date, the second row is the
%                                end date. If only one row, like
%                                [2021,05,18], then the default end date is
%                                the last date of input data.
%
%        vf_GARCHs               Volatility forecast by GARCH, CPGARCH,
%                                RCPGARCH
%
%        vf_GJRs                 Volatility forecast by GJR, CPGJR,
%                                RCPGJR
%
%        vf_HARs                 Volatility forecast by HAR, CPHAR,
%                                RCPHAR
%
%        vf_RSGARCHs             Volatility forecast by RSGARCH, CPRSGARCH,
%                                RCPRSGARCH
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

function Save_VolFcst_to_Mat(Index_Name,Working_Date,Read_Name,Time_Outsample, ...
    vf_GARCHs,insample_fitness_GARCHs,para_GARCH,K_GARCH,vol_persis, ...
    vf_GJRs,insample_fitness_GJRs,para_GJR,K_GJR, ...
    vf_HARs,insample_fitness_HARs,para_HAR,K_HAR, ...
    vf_RSGARCHs,insample_fitness_RSGARCHs,para_RSGARCH,K_RSGARCH,transM_RSGARCH,varargin)

parseObj = inputParser;
functionName='Save_VolFcst_to_Mat';
addParameter(parseObj,'Window_Size',750,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Cluster_Min_Length',50,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Innovation_Distribution','NORMAL',@(x)validateattributes(x,{'string','char'},{''},functionName));
parse(parseObj,varargin{:});
window_size=parseObj.Results.Window_Size;
innovation_distribution=parseObj.Results.Innovation_Distribution;
min_length=parseObj.Results.Cluster_Min_Length;
innovation_distribution=parseObj.Results.Innovation_Distribution;

% volatility forecasts
vf_GARCH=vf_GARCHs.vf_GARCH;
vf_CPGARCH=vf_GARCHs.vf_CPGARCH;
vf_CPGARCHiteration=vf_GARCHs.vf_CPGARCHiteration;
vf_GJR=vf_GJRs.vf_GJR;
vf_CPGJR=vf_GJRs.vf_CPGJR;
vf_CPGJRiteration=vf_GJRs.vf_CPGJRiteration;
vf_RSGARCH=vf_RSGARCHs.vf_RSGARCH;
vf_CPRSGARCH=vf_RSGARCHs.vf_CPRSGARCH;
vf_CPRSGARCHiteration=vf_RSGARCHs.vf_CPRSGARCHiteration;
vf_HAR=vf_HARs.vf_HAR;
vf_CPHAR=vf_HARs.vf_CPHAR;
vf_CPHARiteration=vf_HARs.vf_CPHARiteration;

% mae & rmse
ismae_RSGARCH=insample_fitness_RSGARCHs.ismae_RSGARCH;
isrmse_RSGARCH=insample_fitness_RSGARCHs.isrmse_RSGARCH;
ismae_CPRSGARCH=insample_fitness_RSGARCHs.ismae_CPRSGARCH;
isrmse_CPRSGARCH=insample_fitness_RSGARCHs.isrmse_CPRSGARCH;
ismae_CPRSGARCHiteration=insample_fitness_RSGARCHs.ismae_CPRSGARCHiteration;
isrmse_CPRSGARCHiteration=insample_fitness_RSGARCHs.isrmse_CPRSGARCHiteration;
ismae_HAR=insample_fitness_HARs.ismae_HAR;
isrmse_HAR=insample_fitness_HARs.isrmse_HAR;
ismae_CPHAR=insample_fitness_HARs.ismae_CPHAR;
isrmse_CPHAR=insample_fitness_HARs.isrmse_CPHAR;
ismae_CPHARiteration=insample_fitness_HARs.ismae_CPHARiteration;
isrmse_CPHARiteration=insample_fitness_HARs.isrmse_CPHARiteration;
ismae_GJR=insample_fitness_GJRs.ismae_GJR;
isrmse_GJR=insample_fitness_GJRs.isrmse_GJR;
ismae_CPGJR=insample_fitness_GJRs.ismae_CPGJR;
isrmse_CPGJR=insample_fitness_GJRs.isrmse_CPGJR;
ismae_CPGJRiteration=insample_fitness_GJRs.ismae_CPGJRiteration;
isrmse_CPGJRiteration=insample_fitness_GJRs.isrmse_CPGJRiteration;
ismae_GARCH=insample_fitness_GARCHs.ismae_GARCH;
isrmse_GARCH=insample_fitness_GARCHs.isrmse_GARCH;
ismae_CPGARCH=insample_fitness_GARCHs.ismae_CPGARCH;
isrmse_CPGARCH=insample_fitness_GARCHs.isrmse_CPGARCH;
ismae_CPGARCHiteration=insample_fitness_GARCHs.ismae_CPGARCHiteration;
isrmse_CPGARCHiteration=insample_fitness_GARCHs.isrmse_CPGARCHiteration;

% TIME
datatable=readtable(Read_Name);
if size(Time_Outsample,1)>1
    Start_Outsample=Time_Outsample(1,:);
    End_Outsample=Time_Outsample(2,:);
    oos_index=and(datatable.Date>=datetime(Start_Outsample(1),Start_Outsample(2),Start_Outsample(3)),...
                  datatable.Date<=datetime(End_Outsample(1),End_Outsample(2),End_Outsample(3)));
else
    Start_Outsample=Time_Outsample(1,:);
    oos_index=datatable.Date>=datetime(Start_Outsample(1),Start_Outsample(2),Start_Outsample(3));
end

% out-of-sample returns
I=find(oos_index==1);
Ret_outsample=datatable.Return(I);

% TIME
datatable=readtable(Read_Name);
if size(Time_Outsample,1)>1
    Start_Outsample=Time_Outsample(1,:);
    End_Outsample=Time_Outsample(2,:);
    oos_index=and(datatable.Date>=datetime(Start_Outsample(1),Start_Outsample(2),Start_Outsample(3)),...
                  datatable.Date<=datetime(End_Outsample(1),End_Outsample(2),End_Outsample(3)));
else
    Start_Outsample=Time_Outsample(1,:);
    oos_index=datatable.Date>=datetime(Start_Outsample(1),Start_Outsample(2),Start_Outsample(3));
end

% save part
Excel_Name=['Volatility_forecast_',Index_Name,Working_Date,'.xlsx'];
Mat_Name=['VolFcst_',innovation_distribution,'_',Index_Name,'_size',num2str(window_size),Working_Date];
results_folder=['results_',[innovation_distribution,'_',Index_Name,'_size',num2str(window_size),Working_Date]];
[~,~]=mkdir(results_folder); 
addpath(results_folder);
rv=datatable.RV(oos_index);
Timeline_outsample=datatable.Date(oos_index);

% save data
save(strcat(results_folder,'/',Mat_Name), ...
    "Timeline_outsample","Ret_outsample", "results_folder",...
    "rv","vf_GARCH","vf_CPGARCH","vf_CPGARCHiteration", ...
    "vf_GJR","vf_CPGJR","vf_CPGJRiteration", ...
    "vf_RSGARCH","vf_CPRSGARCH","vf_CPRSGARCHiteration", ...
    "vf_HAR","vf_CPHAR","vf_CPHARiteration", ...
    "vol_persis", "K_GARCH","K_GJR","K_RSGARCH","K_HAR", ...
    "para_HAR","para_GARCH","para_GJR","para_RSGARCH","transM_RSGARCH", ...
    "ismae_GARCH","isrmse_GARCH","ismae_CPGARCH","isrmse_CPGARCH","ismae_CPGARCHiteration","isrmse_CPGARCHiteration", ...
    "ismae_GJR","isrmse_GJR","ismae_CPGJR","isrmse_CPGJR","ismae_CPGJRiteration","isrmse_CPGJRiteration", ...
    "ismae_RSGARCH","isrmse_RSGARCH","ismae_CPRSGARCH","isrmse_CPRSGARCH","ismae_CPRSGARCHiteration","isrmse_CPRSGARCHiteration", ...
    "ismae_HAR","isrmse_HAR","ismae_CPHAR","isrmse_CPHAR","ismae_CPHARiteration","isrmse_CPHARiteration");
Output_Table=table(Timeline_outsample,vf_GARCH,vf_CPGARCH,vf_CPGARCHiteration, ...
    vf_GJR,vf_CPGJR,vf_CPGJRiteration,vf_RSGARCH,vf_CPRSGARCH,vf_CPRSGARCHiteration, ...
    vf_HAR,vf_CPHAR,vf_CPHARiteration,'VariableNames',{'Date','vf_GARCH','vf_CPGARCH','vf_CPGARCHiteration', ...
    'vf_GJR','vf_CPGJR','vf_CPGJRiteration','vf_RSGARCH','vf_CPRSGARCH','vf_CPRSGARCHiteration', ...
    'vf_HAR','vf_CPHAR','vf_CPHARiteration'});
writetable(Output_Table,strcat(results_folder,'/',Excel_Name));
end
