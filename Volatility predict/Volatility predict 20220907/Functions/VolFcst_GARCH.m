% Forecast volatility by GARCH
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
%    results_GARCH               Results of GARCH model
%

function results_GARCH=VolFcst_GARCH(Read_Name,Time_Outsample,varargin)
parseObj = inputParser;
functionName='VolFcst_GARCH';
addParameter(parseObj,'Innovation_Distribution','NORMAL',@(x)validateattributes(x,{'string','char'},{''},functionName));
addParameter(parseObj,'Window_Size',750,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
parse(parseObj,varargin{:});
innovation_distribution=parseObj.Results.Innovation_Distribution;
window_size=parseObj.Results.Window_Size;

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
vf_GARCH=zeros(n,1);
% in-sample fitness
ismae_GARCH=zeros(n,1);
isrmse_GARCH=zeros(n,1);
% dynamic parameter 
para_GARCH=zeros(n,3);
% volatility persistence
persis=zeros(n,1);
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
%     fprintf('GARCH: i=%d\n',i1)
    index=i-window_size:i-1;
    ret=datatable.Return(index);

    
    EstMdl = estimate(Mdl,ret,"Display","off");
    v_GARCH=infer(EstMdl,ret);
    vf_GARCH(i1)=forecast(EstMdl,1,ret);
    persis(i1)=EstMdl.GARCH{1}+EstMdl.ARCH{1};
    para_GARCH(i1,:)=[EstMdl.Constant,EstMdl.ARCH{1},EstMdl.GARCH{1}];
    ismae_GARCH(i1)=mean(abs(v_GARCH-ret.^2));
    isrmse_GARCH(i1)=sqrt(mean((v_GARCH-ret.^2).^2));
end

results_GARCH.vf_GARCH=vf_GARCH;
results_GARCH.persis=persis;
results_GARCH.para=para_GARCH;
results_GARCH.ismae_GARCH=ismae_GARCH;
results_GARCH.isrmse_GARCH=isrmse_GARCH;

end

