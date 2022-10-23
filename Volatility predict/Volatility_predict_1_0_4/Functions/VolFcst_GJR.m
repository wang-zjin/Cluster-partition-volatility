% Forecast volatility by GJR
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
%    results_GJR                 Volatility forecast by GJR


function results_GJR = VolFcst_GJR(Read_Name,Time_Outsample,varargin)
parseObj = inputParser;
functionName='VolFcst_GJR';
addParameter(parseObj,'Window_Size',750,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Cluster_Min_Length',50,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Innovation_Distribution','NORMAL',@(x)validateattributes(x,{'string','char'},{''},functionName));
parse(parseObj,varargin{:});
window_size=parseObj.Results.Window_Size;
innovation_distribution=parseObj.Results.Innovation_Distribution;

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
vf_GJR=zeros(n,1);
% in-sample fitness
ismae_GJR=zeros(n,1);
isrmse_GJR=zeros(n,1);
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

    i1=i1+1;
    fprintf('GJR: i=%d\n',i1)
    index=i-window_size:i-1;
    ret=datatable.Return(index);
    
    EstMdl = estimate(Mdl,ret,"Display","off");
    v_GJR = infer(EstMdl,ret);
    vf_GJR(i1)=forecast(EstMdl,1,ret);
    para_GJR(i1,:)=[EstMdl.Constant,EstMdl.ARCH{1},EstMdl.GARCH{1},EstMdl.Leverage{1}];
    ismae_GJR(i1)=mean(abs(v_GJR-ret.^2));
    isrmse_GJR(i1)=sqrt(mean((v_GJR-ret.^2).^2));

end

results_GJR.vf_GJR=vf_GJR;
results_GJR.para_GJR=para_GJR;
results_GJR.ismae_GJR=ismae_GJR;
results_GJR.isrmse_GJR=isrmse_GJR;

end

