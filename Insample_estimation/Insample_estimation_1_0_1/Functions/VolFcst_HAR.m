% Forecast volatility by HAR, CPHAR, RCPHAR
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
%        vf_HARs                 Volatility forecast by HAR, CPHAR,
%                                RCPHAR
%
%    insample_fitness_HARs       In-sample fitness of HAR, CPHAR,
%                                RCPHAR
%
%    para_HAR                    Estimated parameters of HAR, CPHAR,
%                                RCPHAR
%
%    K_HAR                       Cluster number of CPHAR

function [vf_HARs,insample_fitness_HARs,para_HAR,K_HAR]=VolFcst_HAR(Index_Name,Working_Date,Read_Name,Time_Outsample,varargin)
parseObj = inputParser;
functionName='VolFcst_HAR';
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
Excel_Name=['Volatility_forecast_',Index_Name,'_HARs',Working_Date,'.xlsx'];
Mat_Name=['VolFcst_',innovation_distribution,'_',Index_Name,'_HARs','_size',num2str(window_size),Working_Date];
results_folder=['results_',[innovation_distribution,'_',Index_Name,'_size',num2str(window_size),Working_Date]];
[~,~]=mkdir(results_folder); 
addpath(results_folder);
Timeline_outsample=datatable.Date(oos_index);
% rv=datatable.RV(oos_index);

n=sum(oos_index);
% volatility forecast
vf_HAR=zeros(n,1);
vf_CPHAR=zeros(n,1);
vf_CPHARiteration=zeros(n,1);
% in-sample fitness
ismae_HAR=zeros(n,1);
isrmse_HAR=zeros(n,1);
ismae_CPHAR=zeros(n,1);
isrmse_CPHAR=zeros(n,1);
ismae_CPHARiteration=zeros(n,1);
isrmse_CPHARiteration=zeros(n,1);
% cluster number
K_HAR=zeros(n,1);
% dynamic parameter 
para_HAR=zeros(n,7);
% initial setting
i1=0;I=find(oos_index==1);

for i=I(1):I(end)

    i1=i1+1 %#ok<NOPRT> 
    index=i-window_size:i-1;
    ret=datatable.Return(index);

    Jump=zeros(size(datatable.RV(index)));
    index_Jump=(datatable.RV(index)-datatable.RBP(index))>0;
    Jump(index_Jump) = log(datatable.RV(index_Jump)-datatable.RBP(index_Jump)+1);
    logrv=log(datatable.RV);
    vt=logrv(index);
    vt_1=logrv(index-1);
    vt_5=movmean(logrv,5,'Endpoints','discard');
    vt_5=vt_5(index-5);
    vt_22=movmean(logrv,5,'Endpoints','discard');
    vt_22=vt_22(index-22);
    rt_1=datatable.Return(index-1);
    rvt_1=datatable.RV(index-1);
    a1=abs(rt_1)./sqrt(rvt_1);
    a2=a1;a2(rt_1>0)=0;
    %x0=ones(size(vt));
    [v_HAR,paras]=Vol_HAR(vt,[vt_1,vt_5,vt_22,Jump,a1,a2]);
    vf_HAR(i1)=exp([1,vt_1(end),vt_5(end),vt_22(end),Jump(end),a1(end),a2(end)]*paras);
    para_HAR(i1,:)=paras;
    ismae_HAR(i1)=mean(abs(v_HAR-ret.^2));
    isrmse_HAR(i1)=sqrt(mean((v_HAR-ret.^2).^2));
    %% CP-HAR
    [LB,J,~]=Fisher_div_sqr(datatable.RV,min_length);
    K = OptimalClusterNumber(datatable.RV,LB);
    K_HAR(i1)=K;
    [v_CPHAR,Nodes]=Vol_ClusterPartition(datatable.RV,K,J);
    [~,paras]=Vol_HAR(vt(Nodes(end):end),[vt_1(Nodes(end):end),vt_5(Nodes(end):end),vt_22(Nodes(end):end),Jump(Nodes(end):end),a1(Nodes(end):end),a2(Nodes(end):end)]);
    vf_CPHAR(i1)=exp([1,vt_1(end),vt_5(end),vt_22(end),Jump(end),a1(end),a2(end)]*paras);
    ismae_CPHAR(i1)=mean(abs(v_CPHAR-ret.^2));
    isrmse_CPHAR(i1)=sqrt(mean((v_CPHAR-ret.^2).^2));
    %% CP-HAR-Ite.
    [v_CPHARiteration,Nodes] = Vol_ClusterPartitionIterationHAR(Nodes,vt,v_HAR, ...
        [vt_1,vt_5,vt_22,Jump,a1,a2],min_length);
    [~,paras]=Vol_HAR(vt(Nodes(end):end),[vt_1(Nodes(end):end),vt_5(Nodes(end):end),vt_22(Nodes(end):end),Jump(Nodes(end):end),a1(Nodes(end):end),a2(Nodes(end):end)]);
    vf_CPHARiteration(i1)=exp([1,vt_1(end),vt_5(end),vt_22(end),Jump(end),a1(end),a2(end)]*paras);
    ismae_CPHARiteration(i1)=mean(abs(v_CPHARiteration-ret.^2));
    isrmse_CPHARiteration(i1)=sqrt(mean((v_CPHARiteration-ret.^2).^2));
end

vf_HARs.vf_HAR=vf_HAR;
vf_HARs.vf_CPHAR=vf_CPHAR;
vf_HARs.vf_CPHARiteration=vf_CPHARiteration;
insample_fitness_HARs.ismae_HAR=ismae_HAR;
insample_fitness_HARs.isrmse_HAR=isrmse_HAR;
insample_fitness_HARs.ismae_CPHAR=ismae_CPHAR;
insample_fitness_HARs.isrmse_CPHAR=isrmse_CPHAR;
insample_fitness_HARs.ismae_CPHARiteration=ismae_CPHARiteration;
insample_fitness_HARs.isrmse_CPHARiteration=isrmse_CPHARiteration;

save(strcat(results_folder,'/',Mat_Name), ...
    "vf_HAR","vf_HAR","vf_CPHARiteration", ...
    "K_HAR", ...
    "para_HAR", ...
    "ismae_HAR","isrmse_HAR","ismae_CPHAR","isrmse_CPHAR","ismae_CPHARiteration","isrmse_CPHARiteration");
Output_Table=table(Timeline_outsample,vf_HAR,vf_CPHAR,vf_CPHARiteration, ...
    'VariableNames',{'Date','vf_HAR','vf_CPHAR','vf_CPHARiteration'});
writetable(Output_Table,strcat(results_folder,'/',Excel_Name));
end

