function [CPGARCHIterationVaR,vF] = GARCHclusterIterationVaRPredict(logRet,outsampleStart,outsampleEnd,ClusterMinSize,forecastday,InnovationType)

CPGARCHIterationVaR = zeros(numel(outsampleStart:outsampleEnd),7); % 设置VaR值
vF = zeros(numel(outsampleStart:outsampleEnd),1);                  % 波动率预测
yF = zeros(numel(outsampleStart:outsampleEnd),1);                  % 收益率预测
switch nargin
    case 2
        outsampleEnd=numel(logRet);ClusterMinSize=300;forecastday=1;InnovationType='Normal';
    case 3
        ClusterMinSize=300;forecastday=1;InnovationType='Normal';
    case 4
        forecastday=1;InnovationType='Normal';
    case 5
        InnovationType='Normal';
end
for i = outsampleStart : forecastday : outsampleEnd
    %     Mdl=egarch(1,1);
    %     strcat('Out-of-Sample:',num2str(i))
    ret=logRet(1:i-1);
    %     EstMdl=estimate(Mdl,ret,'Display','full');
    %     v=infer(EstMdl,ret);
    v0=estimateGARCH(ret,garch('GARCHLags',1,'ARCHLags',1,'Offset',NaN));
    addpath('m_Files_ClusterPartition');
    if i+forecastday-1 <= outsampleEnd
        [V,OUTPUT]=ClusterGarchIteration(ret,v0,ClusterMinSize,forecastday); 
        vF(i+1-outsampleStart:i+forecastday-outsampleStart)=OUTPUT.vForecast;
        yF(i+1-outsampleStart:i+forecastday-outsampleStart)=OUTPUT.yForecast;
        switch InnovationType
            case 'Normal'
                CPGARCHIterationVaR(i+1-outsampleStart:i+forecastday-outsampleStart, :)= norminv([.0025 .005 .01 .025 .05 .075 .1],OUTPUT.yForecast,sqrt(OUTPUT.vForecast));
            case 'T'
                for i1=i+1-outsampleStart : i+forecastday-outsampleStart
                    CPGARCHIterationVaR(i1, :) = tinv([.0025 .005 .01 .025 .05 .075 .1],50)*sqrt(vF(i1,:))+yF(i1,:);
                end
        end
    else
        [V,OUTPUT]=ClusterGarchIteration(ret,v0,ClusterMinSize,outsampleEnd+1-i);
        vF(i+1-outsampleStart:end)=OUTPUT.vForecast;     
        yF(i+1-outsampleStart:end)=OUTPUT.yForecast;     
        switch InnovationType
            case 'Normal'
                CPGARCHIterationVaR(i+1-outsampleStart:end, :)= norminv([.0025 .005 .01 .025 .05 .075 .1],OUTPUT.yForecast,sqrt(OUTPUT.vForecast));
            case 'T'
                for i1=i+1-outsampleStart : numel(vF)
                    CPGARCHIterationVaR(i1, :) = tinv([.0025 .005 .01 .025 .05 .075 .1],50)*sqrt(vF(i1,:))+yF(i1,:);
                end
        end
    end
end

