function [CPEGARCHVaR1,CPEGARCHVaR2] = EGARCHclusterVaRPredict(logRet,outsampleStart,outsampleEnd,CPlength,forecastday,InnovationType,ConfidenceLevel)

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
CPEGARCHVaR1 = zeros(size(logRet(outsampleStart:outsampleEnd),1),numel(ConfidenceLevel));
CPEGARCHVaR2 = zeros(size(logRet(outsampleStart:outsampleEnd),1),numel(ConfidenceLevel));

% Mdl=egarch('GARCHLags',1,'ARCHLags',1,'LeverageLags',1,'Offset',NaN);
% ret=logRet(i-CPlength:i-1);
% sigma2=estimateGARCH(ret,Mdl);
% [LB,J,D]=Fisher_div_sqr(sigma2,5);
% K = OptimalClusterNumber(sigma2,LB);
% sigma2_hat = Vol_ClusterPartition(sigma2,K,J);
% ret_hat1 = Vol_ClusterPartition(ret,K,J);ret_hat1=ret_hat1(end);
% ret_hat2 = mean(ret);
% vForecast(1:forecastday, :)=sigma2_hat(end);
% switch InnovationType
%     case 'Normal'
%         CPEGARCHVaR1(1:forecastday, :) = ...
%             norminv(ConfidenceLevel,ret_hat1,sqrt(vForecast(1:forecastday,:)));
%         CPEGARCHVaR2(1:forecastday, :) = ...
%             norminv(ConfidenceLevel,ret_hat2,sqrt(vForecast(1:forecastday,:)));
%     case 'T'
%         for i1=1:forecastday
%             CPEGARCHVaR1(i1, :) = tinv(ConfidenceLevel,50).*sqrt(vForecast(i1,:))+ret_hat1;
%             CPEGARCHVaR2(i1, :) = tinv(ConfidenceLevel,50).*sqrt(vForecast(i1,:))+ret_hat2;
%         end
% end
for i = outsampleStart :forecastday: outsampleEnd
    Mdl=egarch('GARCHLags',1,'ARCHLags',1,'LeverageLags',1,'Offset',NaN);
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
                CPEGARCHVaR1(i+1-outsampleStart:i+forecastday-outsampleStart, :) = ...
                    norminv(ConfidenceLevel,ret_hat1,sqrt(vForecast(i+1-outsampleStart:i+forecastday-outsampleStart,:)));
                CPEGARCHVaR2(i+1-outsampleStart:i+forecastday-outsampleStart, :) = ...
                    norminv(ConfidenceLevel,ret_hat2,sqrt(vForecast(i+1-outsampleStart:i+forecastday-outsampleStart,:)));
            case 'T'
                for i1=i+1-outsampleStart:i+forecastday-outsampleStart
                    CPEGARCHVaR1(i1, :) = tinv(ConfidenceLevel,50).*sqrt(vForecast(i1,:))+ret_hat1;
                    CPEGARCHVaR2(i1, :) = tinv(ConfidenceLevel,50).*sqrt(vForecast(i1,:))+ret_hat2;
                end
        end
    else
        vForecast(i+1-outsampleStart:end, :)=sigma2_hat(end);
        switch InnovationType
            case 'Normal'
                CPEGARCHVaR1(i+1-outsampleStart:end, :) = norminv(ConfidenceLevel,ret_hat1,sqrt(vForecast(i+1-outsampleStart:end,:)));
                CPEGARCHVaR2(i+1-outsampleStart:end, :) = norminv(ConfidenceLevel,ret_hat2,sqrt(vForecast(i+1-outsampleStart:end,:)));
            case 'T'
                for i1=i+1-outsampleStart:numel(vForecast)
                    CPEGARCHVaR1(i1, :) = tinv(ConfidenceLevel,50).*sqrt(vForecast(i1,:))+ret_hat1;
                    CPEGARCHVaR2(i1, :) = tinv(ConfidenceLevel,50).*sqrt(vForecast(i1,:))+ret_hat2;
                end
        end
    end
end

% 2022年2月2日之前程序
% CPEGARCHVaR1 = zeros(size(logRet(outsampleStart:outsampleEnd),1),7);
% CPEGARCHVaR2 = zeros(size(logRet(outsampleStart:outsampleEnd),1),7);
% for i = outsampleStart : outsampleEnd
%     Mdl=egarch(1,1);
%     ret=logRet(i-CPlength:i-1);
%     EstMdl=estimate(Mdl,ret,'Display','full');
%     sigma2=infer(EstMdl,ret);
%     
%     [LB,J,~]=Fisher_div_sqr(numel(sigma2),sigma2,5);
%     K=size(LB,2);y=zeros(K,1);
%     for k = 2:K
%         y(k)=log(numel(ret))*k/numel(ret) + log(LB(numel(ret),k)/numel(ret));
%     end
%     K=find(y==min(y(2:end)))+1;
%     sigma_hat = Vol_ClusterPartition(sigma2,K,J);
%     ret_hat1 = Vol_ClusterPartition(ret,K,J);
%     ret_hat2 = mean(logRet(i-251:i-1));
%     CPEGARCHVaR1(i+1-outsampleStart, :)= norminv([.0025 .005 .01 .025 .05 .075 .1],ret_hat1(end),sqrt(sigma_hat(end)));
%     CPEGARCHVaR2(i+1-outsampleStart, :)= norminv([.0025 .005 .01 .025 .05 .075 .1],ret_hat2,sqrt(sigma_hat(end)));
% end