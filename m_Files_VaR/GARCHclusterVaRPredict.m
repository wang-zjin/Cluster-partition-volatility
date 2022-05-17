function [CPGARCHVaR1,CPGARCHVaR2] = GARCHclusterVaRPredict(logRet,outsampleStart,outsampleEnd,CPlength,forecastday,InnovationType,ConfidenceLevel)

switch nargin
    case 2
        outsampleEnd=numel(logRet);CPlength=300;forecastday=1;InnovationType='Normal';
        ConfidenceLevel=0.05;
    case 3
        CPlength=300;forecastday=1;InnovationType='Normal';ConfidenceLevel=0.05;
    case 4
        forecastday=1;InnovationType='Normal';ConfidenceLevel=0.05;
    case 5
        InnovationType='Normal';ConfidenceLevel=0.05;
    case 6
        ConfidenceLevel=0.05;
end
CPGARCHVaR1 = zeros(size(logRet(outsampleStart:outsampleEnd),1),numel(ConfidenceLevel));
CPGARCHVaR2 = zeros(size(logRet(outsampleStart:outsampleEnd),1),numel(ConfidenceLevel));
for i = outsampleStart :forecastday: outsampleEnd
    Mdl=garch('GARCHLags',1,'ARCHLags',1,'Offset',NaN);
    ret=logRet(i-CPlength:i-1);
    sigma2=estimateGARCH(ret,Mdl);
    [LB,J,~]=Fisher_div_sqr(sigma2,5);
    K = OptimalClusterNumber(sigma2,LB);
    sigma2_hat = Vol_ClusterPartition(sigma2,K,J);
    ret_hat1 = Vol_ClusterPartition(ret,K,J);ret_hat1=ret_hat1(end);
    ret_hat2 = mean(ret);
    if i+forecastday-1 <= outsampleEnd
        vForecast(i+1-outsampleStart:i+forecastday-outsampleStart, :)=sigma2_hat(end);
        switch InnovationType
            case 'Normal'
                CPGARCHVaR1(i+1-outsampleStart:i+forecastday-outsampleStart, :) = ...
                    norminv(ConfidenceLevel,ret_hat1,sqrt(vForecast(i+1-outsampleStart:i+forecastday-outsampleStart,:)));
                CPGARCHVaR2(i+1-outsampleStart:i+forecastday-outsampleStart, :) = ...
                    norminv(ConfidenceLevel,ret_hat2,sqrt(vForecast(i+1-outsampleStart:i+forecastday-outsampleStart,:)));
            case 'T'
                for i1=i+1-outsampleStart:i+forecastday-outsampleStart
                    CPGARCHVaR1(i1, :) = tinv(ConfidenceLevel,50).*sqrt(vForecast(i1,:))+ret_hat1;
                    CPGARCHVaR2(i1, :) = tinv(ConfidenceLevel,50).*sqrt(vForecast(i1,:))+ret_hat2;
                end
        end
    else
        vForecast(i+1-outsampleStart:end, :)=sigma2_hat(end);
        switch InnovationType
            case 'Normal'
                CPGARCHVaR1(i+1-outsampleStart:end, :) = norminv(ConfidenceLevel,ret_hat1,sqrt(vForecast(i+1-outsampleStart:end,:)));
                CPGARCHVaR2(i+1-outsampleStart:end, :) = norminv(ConfidenceLevel,ret_hat2,sqrt(vForecast(i+1-outsampleStart:end,:)));
            case 'T'
                for i1=i+1-outsampleStart:numel(vForecast)
                    CPGARCHVaR1(i1, :) = tinv(ConfidenceLevel,50).*sqrt(vForecast(i1,:))+ret_hat1;
                    CPGARCHVaR2(i1, :) = tinv(ConfidenceLevel,50).*sqrt(vForecast(i1,:))+ret_hat2;
                end
        end
    end
end

% 这是2022年2月3日之前版本
% function [CPVaR1,CPVaR2] = GARCHclusterVaRPredict(logRet,outsampleStart,outsampleEnd,CPlength)
% CPVaR1 = zeros(size(logRet(outsampleStart:outsampleEnd),1),7);
% CPVaR2 = zeros(size(logRet(outsampleStart:outsampleEnd),1),7);
% for i = outsampleStart : outsampleEnd
%     Mdl=garch(1,1);
%     ret=logRet(i-CPlength:i-1);
%     EstMdl=estimate(Mdl,ret,'Display','full');
%     sigma2 = std(ret).^2*ones(numel(ret),1);
%     for ii = 2:numel(sigma2)
%         sigma2(ii)=EstMdl.Constant+EstMdl.ARCH{1}*ret(ii-1).^2+EstMdl.GARCH{1}*sigma2(ii-1);
%     end
%     [LB,J,~]=Fisher_div_sqr(numel(sigma2),sigma2,5);
%     K=size(LB,2);y=zeros(K,1);
%     for k = 2:K
%         y(k)=log(numel(ret))*k/numel(ret) + log(LB(numel(ret),k)/numel(ret));
%     end
%     K=find(y==min(y(2:end)))+1;
%     sigma_hat = Vol_ClusterPartition(sigma2,K,J);
%     ret_hat1 = Vol_ClusterPartition(ret,K,J);
%     ret_hat2 = mean(logRet(i-251:i-1));
%     CPVaR1(i+1-outsampleStart, :)= norminv([.0025 .005 .01 .025 .05 .075 .1],ret_hat1(end),sqrt(sigma_hat(end)));
%     CPVaR2(i+1-outsampleStart, :)= norminv([.0025 .005 .01 .025 .05 .075 .1],ret_hat2,sqrt(sigma_hat(end)));
% end