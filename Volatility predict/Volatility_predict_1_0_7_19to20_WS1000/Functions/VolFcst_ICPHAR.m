% Forecast volatility by ICPHAR
%
% Input:
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
%    results_ICPHAR_a            Volatility forecast by ICPHAR
%

function results_ICPHAR = VolFcst_ICPHAR(Read_Name,Time_Outsample,varargin)
parseObj = inputParser;
functionName='VolFcst_ICPHAR';
addParameter(parseObj,'Window_Size',750,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Cluster_Min_Length',50,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Innovation_Distribution','NORMAL',@(x)validateattributes(x,{'string','char'},{''},functionName));
parse(parseObj,varargin{:});
window_size=parseObj.Results.Window_Size;
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

n=sum(oos_index);
% volatility forecast
vf_ICPHAR=zeros(n,1);
% in-sample fitness
ismae_ICPHAR=zeros(n,1);
isrmse_ICPHAR=zeros(n,1);
% initial setting
i1=0;I=find(oos_index==1);

for i=I(1):I(end)

    i1=i1+1;
    fprintf('ICPHAR: i=%d\n',i1)
    index=i-window_size:i-1;
    ret=datatable.Return(index);

    logrv=log(datatable.RV);
    vt=logrv(index);
    vt_1=logrv(index-1);
    vt_5=movmean(logrv,5,'Endpoints','discard');
    vt_5=vt_5(index-5);
    vt_22=movmean(logrv,5,'Endpoints','discard');
    vt_22=vt_22(index-22);
    v_HAR=Vol_HAR(vt,[vt_1,vt_5,vt_22]);
    %% CP-HAR
    [LB,J,~]=Fisher_div_sqr(v_HAR,min_length);
    K = OptimalClusterNumber(v_HAR,LB);
    [~,Nodes]=Vol_ClusterPartition(v_HAR,K,J);
    %% ICP-HAR
    [v_CPHARiteration,Nodes] = Vol_ClusterPartitionIterationHAR(Nodes,vt,v_HAR, ...
        [vt_1,vt_5,vt_22],min_length);
    [~,paras]=Vol_HAR(vt(Nodes(end):end),[vt_1(Nodes(end):end),vt_5(Nodes(end):end),vt_22(Nodes(end):end)]);
    vf_ICPHAR(i1)=exp([1,vt_1(end),vt_5(end),vt_22(end)]*paras);
    ismae_ICPHAR(i1)=mean(abs(v_CPHARiteration-ret.^2));
    isrmse_ICPHAR(i1)=sqrt(mean((v_CPHARiteration-ret.^2).^2));
end

results_ICPHAR.vf_ICPHAR=vf_ICPHAR;
results_ICPHAR.ismae_ICPHAR=ismae_ICPHAR;
results_ICPHAR.isrmse_ICPHAR=isrmse_ICPHAR;

end

