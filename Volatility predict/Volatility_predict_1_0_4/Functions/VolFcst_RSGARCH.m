% Forecast volatility by RSGARCH
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
%    results_RSGARCH             Volatility forecast by RSGARCH


function results_RSGARCH=VolFcst_RSGARCH(Read_Name,Time_Outsample,varargin)
parseObj = inputParser;
functionName='VolFcst_RSGARCH';
addParameter(parseObj,'Window_Size',750,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Cluster_Min_Length',50,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Innovation_Distribution','NORMAL',@(x)validateattributes(x,{'string','char'},{''},functionName));
%addParameter(parseObj,'Innovation_Distribution','NORMAL',@(x)validateattributes(x,{'char'},{''},functionName));
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
vf_RSGARCH=zeros(n,1);
% in-sample fitness
ismae_RSGARCH=zeros(n,1);
isrmse_RSGARCH=zeros(n,1);
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
        i1=i1+1;
        fprintf('RSGARCH: i=%d\n',i1)
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
        i1=i1+1;
        fprintf('RSGARCH: i=%d\n',i1)
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
        rmpath("m_Files_swgarch")
    end
end

results_RSGARCH.vf_RSGARCH=vf_RSGARCH;
results_RSGARCH.para_RSGARCH=para_RSGARCH;
results_RSGARCH.transM_RSGARCH=transM_RSGARCH;
results_RSGARCH.ismae_RSGARCH=ismae_RSGARCH;
results_RSGARCH.isrmse_RSGARCH=isrmse_RSGARCH;

end

