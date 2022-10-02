% Forecast volatility by GJR, CPGJR, RCPGJR
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
%        vf_GJRs                 Volatility forecast by GJR, CPGJR,
%                                RCPGJR
%
%    insample_fitness_GJRs       In-sample fitness of GJR, CPGJR,
%                                RCPGJR
%
%    para_GJR                    Estimated parameters of GJR, CPGJR,
%                                RCPGJR
%
%    K_GJR                       Cluster number of CPGJR

function [vf_GJRs,insample_fitness_GJRs,para_GJR,K_GJR]=VolFcst_GJR(Index_Name,Working_Date,Read_Name,Time_Outsample,varargin)
parseObj = inputParser;
functionName='VolFcst_GJR';
addParameter(parseObj,'Window_Size',750,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Cluster_Min_Length',50,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Innovation_Distribution','NORMAL',@(x)validateattributes(x,{'string','char'},{''},functionName));
parse(parseObj,varargin{:});
window_size=parseObj.Results.Window_Size;
innovation_distribution=parseObj.Results.Innovation_Distribution;
min_length=parseObj.Results.Cluster_Min_Length;

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
Excel_Name=['Volatility_forecast_',Index_Name,'_GJRs',Working_Date,'.xlsx'];
Mat_Name=['VolFcst_',innovation_distribution,'_',Index_Name,'_GJRs','_size',num2str(window_size),Working_Date];
results_folder=['results_',[innovation_distribution,'_',Index_Name,'_size',num2str(window_size),Working_Date]];
[~,~]=mkdir(results_folder); 
addpath(results_folder);
Timeline_outsample=datatable.Date(oos_index);
% rv=datatable.RV(oos_index);

n=sum(oos_index);
% volatility forecast
vf_GJR=zeros(n,1);
vf_CPGJR=zeros(n,1);
vf_CPGJRiteration=zeros(n,1);
% in-sample fitness
ismae_GJR=zeros(n,1);
isrmse_GJR=zeros(n,1);
ismae_CPGJR=zeros(n,1);
isrmse_CPGJR=zeros(n,1);
ismae_CPGJRiteration=zeros(n,1);
isrmse_CPGJRiteration=zeros(n,1);
% cluster number
K_GJR=zeros(n,1);
% dynamic parameter 
para_GJR=zeros(n,4);
% initial setting
i1=0;I=find(oos_index==1);
% GJR-GARCH Model
if strcmp(innovation_distribution,'NORMAL')
    Mdl=gjr('GARCHLags',1,'ARCHLags',1,'LeverageLags',1,'Offset',NaN,'Distribution','Gaussian');
else
    Mdl=gjr('GARCHLags',1,'ARCHLags',1,'LeverageLags',1,'Offset',NaN,'Distribution','t');
end

for i=I(1):I(end)

    i1=i1+1 %#ok<NOPRT> 
    index=i-window_size:i-1;
    ret=datatable.Return(index);

    
    EstMdl = estimate(Mdl,ret,"Display","off");
    v_GJR = infer(EstMdl,ret);
    vf_GJR(i1)=forecast(EstMdl,1,ret);
    para_GJR(i1,:)=[EstMdl.Constant,EstMdl.ARCH{1},EstMdl.GARCH{1},EstMdl.Leverage{1}];
    ismae_GJR(i1)=mean(abs(v_GJR-ret.^2));
    isrmse_GJR(i1)=sqrt(mean((v_GJR-ret.^2).^2));
    %% CP-GJR
    [LB,J,~]=Fisher_div_sqr(v_GJR,min_length);
    K = OptimalClusterNumber(v_GJR,LB);
    K_GJR(i1)=K;
    [v_CPGJR,Nodes]=Vol_ClusterPartition(v_GJR,K,J);
    EstMdl = estimate(Mdl,ret(Nodes(end):end),"Display","off");
    vf_CPGJR(i1)=forecast(EstMdl,1,ret(Nodes(end):end));
    ismae_CPGJR(i1)=mean(abs(v_CPGJR-ret.^2));
    isrmse_CPGJR(i1)=sqrt(mean((v_CPGJR-ret.^2).^2));
    %% CP-GJR-Ite.
    [v_CPGJRiteration,Nodes] = Vol_ClusterPartitionIterationGarchorGjr(Nodes,ret,v_GJR,Mdl,min_length);
    EstMdl = estimate(Mdl,ret(Nodes(end):end),"Display","off");
    vf_CPGJRiteration(i1)=forecast(EstMdl,1,ret(Nodes(end):end));
    ismae_CPGJRiteration(i1)=mean(abs(v_CPGJRiteration-ret.^2));
    isrmse_CPGJRiteration(i1)=sqrt(mean((v_CPGJRiteration-ret.^2).^2));

end

vf_GJRs.vf_GJR=vf_GJR;
vf_GJRs.vf_CPGJR=vf_CPGJR;
vf_GJRs.vf_CPGJRiteration=vf_CPGJRiteration;
insample_fitness_GJRs.ismae_GJR=ismae_GJR;
insample_fitness_GJRs.isrmse_GJR=isrmse_GJR;
insample_fitness_GJRs.ismae_CPGJR=ismae_CPGJR;
insample_fitness_GJRs.isrmse_CPGJR=isrmse_CPGJR;
insample_fitness_GJRs.ismae_CPGJRiteration=ismae_CPGJRiteration;
insample_fitness_GJRs.isrmse_CPGJRiteration=isrmse_CPGJRiteration;

save(strcat(results_folder,'/',Mat_Name), ...
    "vf_GJR","vf_CPGJR","vf_CPGJRiteration", ...
    "K_GJR", ...
    "para_GJR", ...
    "ismae_GJR","isrmse_GJR","ismae_CPGJR","isrmse_CPGJR","ismae_CPGJRiteration","isrmse_CPGJRiteration");
Output_Table=table(Timeline_outsample,vf_GJR,vf_CPGJR,vf_CPGJRiteration, ...
    'VariableNames',{'Date','vf_GJR','vf_CPGJR','vf_CPGJRiteration'});
writetable(Output_Table,strcat(results_folder,'/',Excel_Name));
end

