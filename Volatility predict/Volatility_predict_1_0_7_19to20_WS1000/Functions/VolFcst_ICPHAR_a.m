% Forecast volatility by ICPHAR-a
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

function results_ICPHAR_a = VolFcst_ICPHAR_a(Read_Name,Time_Outsample,varargin)
parseObj = inputParser;
functionName='VolFcst_ICPHAR-a';
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
vf_ICPHAR_a=zeros(n,1);
% in-sample fitness
ismae_ICPHAR_a=zeros(n,1);
isrmse_ICPHAR_a=zeros(n,1);
% initial setting
i1=0;I=find(oos_index==1);

for i=I(1):I(end)

    i1=i1+1;
    fprintf('ICPHAR-a: i=%d\n',i1)
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
    v_HAR_a=Vol_HAR(vt,[vt_1,vt_5,vt_22]);
    %% CP-HAR-a
    [LB,J,~]=Fisher_div_sqr(v_HAR_a,min_length);
    K = OptimalClusterNumber(v_HAR_a,LB);
    [~,Nodes]=Vol_ClusterPartition(v_HAR_a,K,J);
    %% ICP-HAR-a
    [v_CPHARiteration,Nodes] = Vol_ClusterPartitionIterationHAR(Nodes,vt,v_HAR_a, ...
        [vt_1,vt_5,vt_22,Jump,a1,a2],min_length);
    [~,paras]=Vol_HAR(vt(Nodes(end):end),[vt_1(Nodes(end):end),vt_5(Nodes(end):end),vt_22(Nodes(end):end),Jump(Nodes(end):end),a1(Nodes(end):end),a2(Nodes(end):end)]);
    vf_ICPHAR_a(i1)=exp([1,vt_1(end),vt_5(end),vt_22(end),Jump(end),a1(end),a2(end)]*paras);
    ismae_ICPHAR_a(i1)=mean(abs(v_CPHARiteration-ret.^2));
    isrmse_ICPHAR_a(i1)=sqrt(mean((v_CPHARiteration-ret.^2).^2));
end

results_ICPHAR_a.vf_ICPHAR_a=vf_ICPHAR_a;
results_ICPHAR_a.ismae_ICPHAR_a=ismae_ICPHAR_a;
results_ICPHAR_a.isrmse_ICPHAR_a=isrmse_ICPHAR_a;

end

