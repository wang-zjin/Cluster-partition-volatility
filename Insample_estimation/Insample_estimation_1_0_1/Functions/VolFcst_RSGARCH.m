% Forecast volatility by RSGARCH, CPRSGARCH, RCPRSGARCH
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
%        vf_RSGARCHs             Volatility forecast by RSGARCH, CPRSGARCH,
%                                RCPRSGARCH
%
%    insample_fitness_RSGARCHs   In-sample fitness of RSGARCH, CPRSGARCH,
%                                RCPRSGARCH
%
%    para_RSGARCH                Estimated parameters of RSGARCH, CPRSGARCH,
%                                RCPRSGARCH
%
%    transM_RSGARCH              Estimated transition matrix of RSGARCH
%
%    K_RSGARCH                   Cluster number of CPRSGARCH

function [vf_RSGARCHs,insample_fitness_RSGARCHs,para_RSGARCH,K_RSGARCH,transM_RSGARCH]=VolFcst_RSGARCH(Index_Name,Working_Date,Read_Name,Time_Outsample,varargin)
parseObj = inputParser;
functionName='VolFcst_RSGARCH';
addParameter(parseObj,'Window_Size',750,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Cluster_Min_Length',50,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Innovation_Distribution','NORMAL',@(x)validateattributes(x,{'string','char'},{''},functionName));
%addParameter(parseObj,'Innovation_Distribution','NORMAL',@(x)validateattributes(x,{'char'},{''},functionName));
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
Excel_Name=['Volatility_forecast_',Index_Name,'_RSGARCHs',Working_Date,'.xlsx'];
Mat_Name=['VolFcst_',innovation_distribution,'_',Index_Name,'_RSGARCHs','_size',num2str(window_size),Working_Date];
results_folder=['results_',[innovation_distribution,'_',Index_Name,'_size',num2str(window_size),Working_Date]];
[~,~]=mkdir(results_folder); 
addpath(results_folder);
Timeline_outsample=datatable.Date(oos_index);
% rv=datatable.RV(oos_index);

n=sum(oos_index);
% volatility forecast
vf_RSGARCH=zeros(n,1);
vf_CPRSGARCH=zeros(n,1);
vf_CPRSGARCHiteration=zeros(n,1);
% in-sample fitness
ismae_RSGARCH=zeros(n,1);
isrmse_RSGARCH=zeros(n,1);
ismae_CPRSGARCH=zeros(n,1);
isrmse_CPRSGARCH=zeros(n,1);
ismae_CPRSGARCHiteration=zeros(n,1);
isrmse_CPRSGARCHiteration=zeros(n,1);
% cluster number
K_RSGARCH=zeros(n,1);
% dynamic parameter 
para_RSGARCH=zeros(2,3,n);
transM_RSGARCH=zeros(2,2,n);
% initial setting
i1=0;I=find(oos_index==1);



% itinial value of RSGARCH
Mdl=garch('GARCHLags',1,'ARCHLags',1,'Offset',NaN,'Distribution','Gaussian');
EstMdl=estimate(Mdl,datatable.Return(I(1)-window_size:I(1)-1),'Display','off');
addpath("m_Files_swgarch")
Mdl_RSGARCH.k=2;
Mdl_RSGARCH.model='HAAS';
Mdl_RSGARCH.constraint='CONS';
%Mdl_RSGARCH.startvalopt={'NO',10};
Mdl_RSGARCH.startvalopt={'YES',[]};
%Mdl_RSGARCH.startvalG=[0.1 0.1 0.82;0.01 0.01 0.5];
Mdl_RSGARCH.startvalG=[EstMdl.Constant,EstMdl.ARCH{1},EstMdl.GARCH{1};EstMdl.Constant,EstMdl.ARCH{1},EstMdl.GARCH{1}];
Mdl_RSGARCH.startvalM=[0.8 0.2;0.2 0.8];
Mdl_RSGARCH.fig=0;
Mdl_RSGARCH.dep_type='INDEP';
if strcmp(innovation_distribution,'NORMAL')
    Mdl_RSGARCH.innovation='NORMAL';
    Mdl_RSGARCH.param_dist=[];
    [estimation,~] = swgarch(datatable.Return(I(1)-window_size:I(1)-1),Mdl_RSGARCH.k, ...
        Mdl_RSGARCH.innovation,Mdl_RSGARCH.model,Mdl_RSGARCH.constraint, ...
        Mdl_RSGARCH.startvalopt,Mdl_RSGARCH.startvalG,Mdl_RSGARCH.startvalM);
rmpath("m_Files_swgarch")
    for i=I(1):I(end)
        i1=i1+1 %#ok<NOPRT> 
        index=i-window_size:i-1;
        ret=datatable.Return(index);
        addpath("m_Files_swgarch")
        Mdl_RSGARCH.startvalG=estimation.garch;
        Mdl_RSGARCH.startvalM=estimation.transM;
        [estimation,probabilities] = swgarch(ret,Mdl_RSGARCH.k, ...
            Mdl_RSGARCH.innovation,Mdl_RSGARCH.model,Mdl_RSGARCH.constraint, ...
            Mdl_RSGARCH.startvalopt,Mdl_RSGARCH.startvalG,Mdl_RSGARCH.startvalM);
        datafcst = swgarch_forecast(1,Mdl_RSGARCH.k,estimation.garch,...
            estimation.transM,Mdl_RSGARCH.dep_type,Mdl_RSGARCH.innovation,Mdl_RSGARCH.param_dist, ...
            Mdl_RSGARCH.fig,ret,estimation.H,probabilities);
        para_RSGARCH(:,:,i1)=estimation.garch;
        transM_RSGARCH(:,:,i1)=estimation.transM;
        v_RSGARCH=estimation.H(2:end);
        vf_RSGARCH(i1)=datafcst.vH;
        ismae_RSGARCH(i1)=mean(abs(v_RSGARCH-ret.^2));
        isrmse_RSGARCH(i1)=sqrt(mean((v_RSGARCH-ret.^2).^2));
        %% CP-RSGARCH
        [LB,J,~]=Fisher_div_sqr(v_RSGARCH,min_length);
        K = OptimalClusterNumber(v_RSGARCH,LB);
        K_RSGARCH(i1)=K;
        [v_CPRSGARCH,Nodes]=Vol_ClusterPartition(v_RSGARCH,K,J);
        [estimation_last,probabilities] = swgarch(ret(Nodes(end):end),Mdl_RSGARCH.k, ...
            Mdl_RSGARCH.innovation,Mdl_RSGARCH.model,Mdl_RSGARCH.constraint, ...
            Mdl_RSGARCH.startvalopt,estimation.garch,estimation.transM);
        datafcst = swgarch_forecast(1,Mdl_RSGARCH.k,estimation_last.garch,...
            estimation_last.transM,Mdl_RSGARCH.dep_type,Mdl_RSGARCH.innovation,Mdl_RSGARCH.param_dist, ...
            Mdl_RSGARCH.fig,ret(Nodes(end):end),estimation_last.H,probabilities);
        vf_CPRSGARCH(i1)=datafcst.vH;
        ismae_CPRSGARCH(i1)=mean(abs(v_CPRSGARCH-ret.^2));
        isrmse_CPRSGARCH(i1)=sqrt(mean((v_CPRSGARCH-ret.^2).^2));
        %% CP-RSGARCH-Ite.
        [v_CPRSGARCHiteration,Nodes] = Vol_ClusterPartitionIterationRSGARCH(Nodes,ret,v_RSGARCH,Mdl_RSGARCH,min_length,'Innovation_Distribution',innovation_distribution);
%         [v_CPRSGARCHiteration,Nodes] = Vol_ClusterPartitionIterationRSGARCH(Nodes,ret,v_RSGARCH,Mdl_RSGARCH,min_length);
        [estimation_last,probabilities] = swgarch(ret(Nodes(end):end),Mdl_RSGARCH.k, ...
            Mdl_RSGARCH.innovation,Mdl_RSGARCH.model,Mdl_RSGARCH.constraint, ...
            Mdl_RSGARCH.startvalopt,Mdl_RSGARCH.startvalG,Mdl_RSGARCH.startvalM);
        datafcst = swgarch_forecast(1,Mdl_RSGARCH.k,estimation_last.garch,...
            estimation_last.transM,Mdl_RSGARCH.dep_type,Mdl_RSGARCH.innovation,Mdl_RSGARCH.param_dist, ...
            Mdl_RSGARCH.fig,ret(Nodes(end):end),estimation_last.H,probabilities);
        vf_CPRSGARCHiteration(i1)=datafcst.vH;
        ismae_CPRSGARCHiteration(i1)=mean(abs(v_CPRSGARCHiteration-ret.^2));
        isrmse_CPRSGARCHiteration(i1)=sqrt(mean((v_CPRSGARCHiteration-ret.^2).^2));
        rmpath("m_Files_swgarch")    
    end
else
    fit_data=fitdist(datatable.Return(I(1)-window_size:I(1)-1),"tLocationScale");
    Mdl_RSGARCH.innovation='STUDENTST';
    Mdl_RSGARCH.param_dist=[fit_data.nu];
    [estimation,~] = swgarch(datatable.Return(I(1)-window_size:I(1)-1),Mdl_RSGARCH.k, ...
        Mdl_RSGARCH.innovation,Mdl_RSGARCH.model,Mdl_RSGARCH.constraint, ...
        Mdl_RSGARCH.startvalopt,Mdl_RSGARCH.startvalG,Mdl_RSGARCH.startvalM,Mdl_RSGARCH.param_dist);
rmpath("m_Files_swgarch")
    for i=I(1):I(end)
        i1=i1+1 %#ok<NOPRT> 
        index=i-window_size:i-1;
        ret=datatable.Return(index);
        addpath("m_Files_swgarch")
        Mdl_RSGARCH.startvalG=estimation.garch;
        Mdl_RSGARCH.startvalM=estimation.transM;
        Mdl_RSGARCH.param_dist=[fit_data.nu];
        [estimation,probabilities] = swgarch(ret,Mdl_RSGARCH.k, ...
            Mdl_RSGARCH.innovation,Mdl_RSGARCH.model,Mdl_RSGARCH.constraint, ...
            Mdl_RSGARCH.startvalopt,Mdl_RSGARCH.startvalG,Mdl_RSGARCH.startvalM,Mdl_RSGARCH.param_dist);
        datafcst = swgarch_forecast(1,Mdl_RSGARCH.k,estimation.garch,...
            estimation.transM,Mdl_RSGARCH.dep_type,Mdl_RSGARCH.innovation,Mdl_RSGARCH.param_dist, ...
            Mdl_RSGARCH.fig,ret,estimation.H,probabilities);
        para_RSGARCH(:,:,i1)=estimation.garch;
        transM_RSGARCH(:,:,i1)=estimation.transM;
        v_RSGARCH=estimation.H(2:end);
        vf_RSGARCH(i1)=datafcst.vH;
        ismae_RSGARCH(i1)=mean(abs(v_RSGARCH-ret.^2));
        isrmse_RSGARCH(i1)=sqrt(mean((v_RSGARCH-ret.^2).^2));
        %% CP-RSGARCH
        [LB,J,~]=Fisher_div_sqr(v_RSGARCH,min_length);
        K = OptimalClusterNumber(v_RSGARCH,LB);
        K_RSGARCH(i1)=K;
        [v_CPRSGARCH,Nodes]=Vol_ClusterPartition(v_RSGARCH,K,J);
        [estimation_last,probabilities] = swgarch(ret(Nodes(end):end),Mdl_RSGARCH.k, ...
            Mdl_RSGARCH.innovation,Mdl_RSGARCH.model,Mdl_RSGARCH.constraint, ...
            Mdl_RSGARCH.startvalopt,estimation.garch,estimation.transM,Mdl_RSGARCH.param_dist);
        datafcst = swgarch_forecast(1,Mdl_RSGARCH.k,estimation_last.garch,...
            estimation_last.transM,Mdl_RSGARCH.dep_type,Mdl_RSGARCH.innovation,Mdl_RSGARCH.param_dist, ...
            Mdl_RSGARCH.fig,ret(Nodes(end):end),estimation_last.H,probabilities);
        vf_CPRSGARCH(i1)=datafcst.vH;
        ismae_CPRSGARCH(i1)=mean(abs(v_CPRSGARCH-ret.^2));
        isrmse_CPRSGARCH(i1)=sqrt(mean((v_CPRSGARCH-ret.^2).^2));
        %% CP-RSGARCH-Ite.
        [v_CPRSGARCHiteration,Nodes] = Vol_ClusterPartitionIterationRSGARCH(Nodes,ret,v_RSGARCH,Mdl_RSGARCH,min_length,'Innovation_Distribution',innovation_distribution);
        [estimation_last,probabilities] = swgarch(ret(Nodes(end):end),Mdl_RSGARCH.k, ...
            Mdl_RSGARCH.innovation,Mdl_RSGARCH.model,Mdl_RSGARCH.constraint, ...
            Mdl_RSGARCH.startvalopt,Mdl_RSGARCH.startvalG,Mdl_RSGARCH.startvalM,Mdl_RSGARCH.param_dist);
        datafcst = swgarch_forecast(1,Mdl_RSGARCH.k,estimation_last.garch,...
            estimation_last.transM,Mdl_RSGARCH.dep_type,Mdl_RSGARCH.innovation,Mdl_RSGARCH.param_dist, ...
            Mdl_RSGARCH.fig,ret(Nodes(end):end),estimation_last.H,probabilities);
        vf_CPRSGARCHiteration(i1)=datafcst.vH;
        ismae_CPRSGARCHiteration(i1)=mean(abs(v_CPRSGARCHiteration-ret.^2));
        isrmse_CPRSGARCHiteration(i1)=sqrt(mean((v_CPRSGARCHiteration-ret.^2).^2));
        rmpath("m_Files_swgarch")
    end
end

vf_RSGARCHs.vf_RSGARCH=vf_RSGARCH;
vf_RSGARCHs.vf_CPRSGARCH=vf_CPRSGARCH;
vf_RSGARCHs.vf_CPRSGARCHiteration=vf_CPRSGARCHiteration;
insample_fitness_RSGARCHs.ismae_RSGARCH=ismae_RSGARCH;
insample_fitness_RSGARCHs.isrmse_RSGARCH=isrmse_RSGARCH;
insample_fitness_RSGARCHs.ismae_CPRSGARCH=ismae_CPRSGARCH;
insample_fitness_RSGARCHs.isrmse_CPRSGARCH=isrmse_CPRSGARCH;
insample_fitness_RSGARCHs.ismae_CPRSGARCHiteration=ismae_CPRSGARCHiteration;
insample_fitness_RSGARCHs.isrmse_CPRSGARCHiteration=isrmse_CPRSGARCHiteration;

save(strcat(results_folder,'/',Mat_Name), ...
    "vf_RSGARCH","vf_RSGARCH","vf_CPRSGARCHiteration", ...
    "K_RSGARCH", ...
    "para_RSGARCH", ...
    "ismae_RSGARCH","isrmse_RSGARCH","ismae_CPRSGARCH","isrmse_CPRSGARCH","ismae_CPRSGARCHiteration","isrmse_CPRSGARCHiteration");
Output_Table=table(Timeline_outsample,vf_RSGARCH,vf_CPRSGARCH,vf_CPRSGARCHiteration, ...
    'VariableNames',{'Date','vf_RSGARCH','vf_CPRSGARCH','vf_CPRSGARCHiteration'});
writetable(Output_Table,strcat(results_folder,'/',Excel_Name));
end

