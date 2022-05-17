% 通过迭代稳定的方法计算cluster GARCH波动率
% logRet       输入的收益率序列
% v0           输入的波动率序列
% h            输入的cluster最小间隔
% forecastday  输入的预测时间，defaulte为1
function [V,OUTPUT]=ClusterGarchIteration(logRet,v0,h,forecastday)

if nargin < 4
    forecastday=1;
end
addpath('m_Files_ClusterPartition');
[LB0,J0] = Fisher_div_sqr(v0,h);
N0 = OptimalClusterNumber(v0,LB0);
% 知道每个分段点
I0 = OptimalSplitPoint(v0,J0,N0);
% 对每个cluster进行garch
v1=zeros(size(v0));
for i = 1:numel(I0)-1
    ret=logRet(I0(i):I0(i+1)-1);
    v1(I0(i):I0(i+1)-1)=estimateGARCH(ret,garch('GARCHLags',1,'ARCHLags',1,'Offset',NaN));
end
ret=logRet(I0(end):end);
v1(I0(end):end)=estimateGARCH(ret,garch('GARCHLags',1,'ARCHLags',1,'Offset',NaN));
[LB1,J1] = Fisher_div_sqr(v1,h); % (TIME : 20min)
N1 = OptimalClusterNumber(v1,LB1);
I1 = OptimalSplitPoint(v1,J1,N1);

Time=0;
while sum(N0~=N1)>0 || sum(v0~=v1)>0 || and(sum(N0==N1)>0,sum(I0~=I1)>0)
    Time=Time+1;
    
    v0=v1;I0=I1;N0=N1;
    
    v1=zeros(size(v0));
    for i = 1:numel(I0)-1
        ret=logRet(I0(i):I0(i+1)-1);
        v1(I0(i):I0(i+1)-1)=estimateGARCH(ret,garch('GARCHLags',1,'ARCHLags',1,'Offset',NaN));
    end
    ret=logRet(I0(end):end);
    [v1(I0(end):end),EstMdl]=estimateGARCH(ret,garch('GARCHLags',1,'ARCHLags',1,'Offset',NaN));
    [LB1,J1] = Fisher_div_sqr(v1,h); % (TIME : 20min)
    N1 = OptimalClusterNumber(v1,LB1);
    I1 = OptimalSplitPoint(v1,J1,N1);
    
end
% Forecast 
vForecast=forecast(EstMdl,forecastday,'Y0',logRet(I0(end):end));
yForecast=EstMdl.Offset*ones(forecastday,1);
% Output
V=v1;
OUTPUT.Times = Time;
OUTPUT.SplitPoints = I1;
OUTPUT.ClusterNumber = N1;
OUTPUT.LossFunctionValue = LB1;
OUTPUT.SplitPointMatrix = J1;
OUTPUT.vForecast = vForecast;
OUTPUT.yForecast = yForecast;