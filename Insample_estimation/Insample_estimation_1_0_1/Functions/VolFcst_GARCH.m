% Forecast volatility by GARCH, CPGARCH, RCPGARCH
%
% Input:
%
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
% Output:
%
%        vf_GARCHs               Volatility forecast by GARCH, CPGARCH,
%                                RCPGARCH
%
%    insample_fitness_GARCHs     In-sample fitness of GARCH, CPGARCH,
%                                RCPGARCH
%
%    para_GARCH                  Estimated parameters of GARCH, CPGARCH,
%                                RCPGARCH
%
%    K_GARCH                     Cluster number of CPGARCH

function [vf_GARCHs,insample_fitness_GARCHs,para_GARCH,K_GARCH,vol_persis]=VolFcst_GARCH(Index_Name,Working_Date,Read_Name,Time_Outsample,varargin)
parseObj = inputParser;
functionName='VolFcst_GARCH';
addParameter(parseObj,'Window_Size',750,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Cluster_Min_Length',50,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Innovation_Distribution','NORMAL',@(x)validateattributes(x,{'string','char'},{''},functionName));
parse(parseObj,varargin{:});
window_size=parseObj.Results.Window_Size;
innovation_distribution=parseObj.Results.Innovation_Distribution;
min_length=parseObj.Results.Cluster_Min_Length;

%Index_Name='SP500';
%Working_Date='_20220803';
%Read_Name=[Index_Name,'_0608.xlsx'];
%Start_Outsample=[2021,05,18];
%window_size = 750;
%min_length=50;
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
Excel_Name=['Volatility_forecast_',Index_Name,'_GARCHs',Working_Date,'.xlsx'];
Mat_Name=['VolFcst_',innovation_distribution,'_',Index_Name,'_GARCHs','_size',num2str(window_size),Working_Date];
results_folder=['results_',[innovation_distribution,'_',Index_Name,'_size',num2str(window_size),Working_Date]];
[~,~]=mkdir(results_folder); 
addpath(results_folder);
Timeline_outsample=datatable.Date(oos_index);
% rv=datatable.RV(oos_index);

n=sum(oos_index);
% volatility forecast
vf_GARCH=zeros(n,1);
vf_CPGARCH=zeros(n,1);
vf_CPGARCHiteration=zeros(n,1);
vol_persis=zeros(n,1);
% in-sample fitness
ismae_GARCH=zeros(n,1);
isrmse_GARCH=zeros(n,1);
ismae_CPGARCH=zeros(n,1);
isrmse_CPGARCH=zeros(n,1);
ismae_CPGARCHiteration=zeros(n,1);
isrmse_CPGARCHiteration=zeros(n,1);
% cluster number
K_GARCH=zeros(n,1);
% dynamic parameter 
para_GARCH=zeros(n,3);
% initial setting
i1=0;I=find(oos_index==1);
% GARCH Model
if strcmp(innovation_distribution,'NORMAL')
    Mdl=garch('GARCHLags',1,'ARCHLags',1,'Offset',NaN,'Distribution','Gaussian');
else
    Mdl=garch('GARCHLags',1,'ARCHLags',1,'Offset',NaN,'Distribution','t');
end

for i=I(1):I(end)

    i1=i1+1 %#ok<NOPRT> 
    index=i-window_size:i-1;
    ret=datatable.Return(index);

    
    EstMdl = estimate(Mdl,ret,"Display","off");
    v_GARCH=infer(EstMdl,ret);
    vf_GARCH(i1)=forecast(EstMdl,1,ret);
    vol_persis(i1)=EstMdl.GARCH{1}+EstMdl.ARCH{1};
    para_GARCH(i1,:)=[EstMdl.Constant,EstMdl.ARCH{1},EstMdl.GARCH{1}];
    ismae_GARCH(i1)=mean(abs(v_GARCH-ret.^2));
    isrmse_GARCH(i1)=sqrt(mean((v_GARCH-ret.^2).^2));
    %% CP-GARCH
    [LB,J,~]=Fisher_div_sqr(v_GARCH,min_length);
    K = OptimalClusterNumber(v_GARCH,LB);
    K_GARCH(i1)=K;
    [v_CPGARCH,Nodes]=Vol_ClusterPartition(v_GARCH,K,J);
    EstMdl = estimate(Mdl,ret(Nodes(end):end),"Display","off");
    vf_CPGARCH(i1)=forecast(EstMdl,1,ret(Nodes(end):end));
    ismae_CPGARCH(i1)=mean(abs(v_CPGARCH-ret.^2));
    isrmse_CPGARCH(i1)=sqrt(mean((v_CPGARCH-ret.^2).^2));
    %% CP-GARCH-Ite.
    [v_CPGARCHiteration,Nodes] = Vol_ClusterPartitionIterationGarchorGjr(Nodes,ret,v_GARCH,Mdl,min_length);
    EstMdl = estimate(Mdl,ret(Nodes(end):end),"Display","off");
    vf_CPGARCHiteration(i1)=forecast(EstMdl,1,ret(Nodes(end):end));
    ismae_CPGARCHiteration(i1)=mean(abs(v_CPGARCHiteration-ret.^2));
    isrmse_CPGARCHiteration(i1)=sqrt(mean((v_CPGARCHiteration-ret.^2).^2));

end

vf_GARCHs.vf_GARCH=vf_GARCH;
vf_GARCHs.vf_CPGARCH=vf_CPGARCH;
vf_GARCHs.vf_CPGARCHiteration=vf_CPGARCHiteration;
insample_fitness_GARCHs.ismae_GARCH=ismae_GARCH;
insample_fitness_GARCHs.isrmse_GARCH=isrmse_GARCH;
insample_fitness_GARCHs.ismae_CPGARCH=ismae_CPGARCH;
insample_fitness_GARCHs.isrmse_CPGARCH=isrmse_CPGARCH;
insample_fitness_GARCHs.ismae_CPGARCHiteration=ismae_CPGARCHiteration;
insample_fitness_GARCHs.isrmse_CPGARCHiteration=isrmse_CPGARCHiteration;

save(strcat(results_folder,'/',Mat_Name), ...
    "vf_GARCH","vf_CPGARCH","vf_CPGARCHiteration", ...
    "vol_persis", "K_GARCH", ...
    "para_GARCH", ...
    "ismae_GARCH","isrmse_GARCH","ismae_CPGARCH","isrmse_CPGARCH","ismae_CPGARCHiteration","isrmse_CPGARCHiteration");
Output_Table=table(Timeline_outsample,vf_GARCH,vf_CPGARCH,vf_CPGARCHiteration, ...
    'VariableNames',{'Date','vf_GARCH','vf_CPGARCH','vf_CPGARCHiteration'});
writetable(Output_Table,strcat(results_folder,'/',Excel_Name));
end

