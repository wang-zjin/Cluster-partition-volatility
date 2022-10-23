% Forecast volatility by ICPGARCH
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
%    results_ICPGARCH            Volatility forecast by ICPGARCH
%

function results_ICPGARCH=VolFcst_ICPGARCH(Read_Name,Time_Outsample,varargin)
parseObj = inputParser;
functionName='VolFcst_GARCH';
addParameter(parseObj,'Window_Size',750,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Cluster_Min_Length',50,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Innovation_Distribution','NORMAL',@(x)validateattributes(x,{'string','char'},{''},functionName));
parse(parseObj,varargin{:});
window_size=parseObj.Results.Window_Size;
innovation_distribution=parseObj.Results.Innovation_Distribution;
min_length=parseObj.Results.Cluster_Min_Length;

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

% rv=datatable.RV(oos_index);

n=sum(oos_index);
% volatility forecast
vf_ICPGARCH=zeros(n,1);
% in-sample fitness
ismae_ICPGARCH=zeros(n,1);
isrmse_ICPGARCH=zeros(n,1);
% initial setting
i1=0;I=find(oos_index==1);
% GARCH Model
if strcmp(innovation_distribution,'NORMAL')
    Mdl=garch('GARCHLags',1,'ARCHLags',1,'Offset',NaN,'Distribution','Gaussian');
else
    Mdl=garch('GARCHLags',1,'ARCHLags',1,'Offset',NaN,'Distribution','t');
end

for i=I(1):I(end)

    i1=i1+1;
    fprintf('ICPGARCH: i=%d\n',i1)
    index=i-window_size:i-1;
    ret=datatable.Return(index);

    
    EstMdl = estimate(Mdl,ret,"Display","off");
    v_GARCH=infer(EstMdl,ret);
    %% CP-GARCH
    [LB,J,~]=Fisher_div_sqr(v_GARCH,min_length);
    K = OptimalClusterNumber(v_GARCH,LB);
    [~,Nodes]=Vol_ClusterPartition(v_GARCH,K,J);
    %% ICP-GARCH
    [v_ICPGARCH,Nodes] = Vol_ClusterPartitionIterationGarchorGjr(Nodes,ret,v_GARCH,Mdl,min_length);
    EstMdl = estimate(Mdl,ret(Nodes(end):end),"Display","off");
    vf_ICPGARCH(i1)=forecast(EstMdl,1,ret(Nodes(end):end));
    ismae_ICPGARCH(i1)=mean(abs(v_ICPGARCH-ret.^2));
    isrmse_ICPGARCH(i1)=sqrt(mean((v_ICPGARCH-ret.^2).^2));

end

results_ICPGARCH.vf_ICPGARCH=vf_ICPGARCH;
results_ICPGARCH.ismae_ICPGARCH=ismae_ICPGARCH;
results_ICPGARCH.isrmse_ICPGARCH=isrmse_ICPGARCH;

end

