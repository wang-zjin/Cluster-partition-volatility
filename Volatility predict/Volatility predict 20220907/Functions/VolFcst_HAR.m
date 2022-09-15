% Forecast volatility by HAR
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
%    results_HAR                 Volatility forecast by HAR

function results_HAR = VolFcst_HAR(Read_Name,Time_Outsample,varargin)
parseObj = inputParser;
functionName='VolFcst_HAR';
addParameter(parseObj,'Window_Size',750,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Cluster_Min_Length',50,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Innovation_Distribution','NORMAL',@(x)validateattributes(x,{'string','char'},{''},functionName));
parse(parseObj,varargin{:});
window_size=parseObj.Results.Window_Size;

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
vf_HAR=zeros(n,1);
% in-sample fitness
ismae_HAR=zeros(n,1);
isrmse_HAR=zeros(n,1);
% dynamic parameter 
para_HAR=zeros(n,4);
% initial setting
i1=0;I=find(oos_index==1);

for i=I(1):I(end)

    i1=i1+1;
    fprintf('HAR: i=%d\n',i1)
    index=i-window_size:i-1;
    ret=datatable.Return(index);

    logrv=log(datatable.RV);
    vt=logrv(index);
    vt_1=logrv(index-1);
    vt_5=movmean(logrv,5,'Endpoints','discard');
    vt_5=vt_5(index-5);
    vt_22=movmean(logrv,5,'Endpoints','discard');
    vt_22=vt_22(index-22);
    [v_HAR,paras]=Vol_HAR(vt,[vt_1,vt_5,vt_22]);
    vf_HAR(i1)=exp([1,vt_1(end),vt_5(end),vt_22(end)]*paras);
    para_HAR(i1,:)=paras;
    ismae_HAR(i1)=mean(abs(v_HAR-ret.^2));
    isrmse_HAR(i1)=sqrt(mean((v_HAR-ret.^2).^2));
end

results_HAR.vf_HAR=vf_HAR;
results_HAR.para_HAR=para_HAR;
results_HAR.ismae_HAR=ismae_HAR;
results_HAR.isrmse_HAR=isrmse_HAR;

end

