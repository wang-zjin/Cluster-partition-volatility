function [EGARCHVaR,vForecast] = EGARCHVaRPredict(logRet,outsampleStart,outsampleEnd,EGARCHlength,forecastday,InnovationType,ConfidenceLevel)


switch nargin
    case 2
        outsampleEnd=numel(logRet);EGARCHlength=300;forecastday=1;InnovationType='Normal';
        ConfidenceLevel=0.05;
    case 3
        EGARCHlength=300;forecastday=1;InnovationType='Normal';ConfidenceLevel=0.05;
    case 4
        forecastday=1;InnovationType='Normal';ConfidenceLevel=0.05;
    case 5
        InnovationType='Normal';ConfidenceLevel=0.05;
    case 6
        ConfidenceLevel=0.05;
end
EGARCHVaR = zeros(numel(outsampleStart:outsampleEnd),numel(ConfidenceLevel));
vForecast = zeros(numel(outsampleStart:outsampleEnd),1);
for i = outsampleStart : forecastday : outsampleEnd
    Mdl=egarch('GARCH',NaN,'ARCH',NaN,'Leverage',NaN,'Offset',NaN);
    ret=logRet(i-EGARCHlength:i-1);
    EstMdl=estimate(Mdl,ret,'Display','off');
    if outsampleEnd - i >5
        vForecast(i+1-outsampleStart : i+forecastday-outsampleStart, :) = forecast(EstMdl,forecastday,'Y0',ret);
        switch InnovationType
            case 'Normal'
                EGARCHVaR(i+1-outsampleStart : i+forecastday-outsampleStart, :)...
                    = norminv(ConfidenceLevel,mean(logRet(i-EGARCHlength:i-1))...
                    ,sqrt(forecast(EstMdl,forecastday,'Y0',ret)) );
            case 'T'
                for i1=i+1-outsampleStart : i+forecastday-outsampleStart
                    EGARCHVaR(i1, :) = tinv(ConfidenceLevel,50)*sqrt(vForecast(i1,:))...
                        +mean(logRet(i-EGARCHlength:i-1));
                end
        end
    else
        vForecast(i+1-outsampleStart : end, :) = ...
            forecast(EstMdl,outsampleEnd-i+1,'Y0',ret);
        switch InnovationType
            case 'Normal'
                EGARCHVaR(i+1-outsampleStart : end, :)...
                    = norminv(ConfidenceLevel,mean(logRet(i-EGARCHlength:i-1)),sqrt(forecast(EstMdl,outsampleEnd-i+1,'Y0',ret)) );
            case 'T'
                for i1=i+1-outsampleStart : numel(vForecast)
                    EGARCHVaR(i1, :) = tinv(ConfidenceLevel,50)*sqrt(vForecast(i1,:))+mean(logRet(i-EGARCHlength:i-1));
                end
        end
    end
end

% 这是2022年1月22日之前版本
% EGARCHVaR = zeros(numel(outsampleStart:outsampleEnd),7);
% VarianceEstimate = zeros(numel(outsampleStart:outsampleEnd),1);
% switch nargin
%     case 2
%         outsampleEnd=numel(logRet);EGARCHlength=300;forecastday=1;InnovationType='Normal';
%     case 3
%         EGARCHlength=300;forecastday=1;InnovationType='Normal';
%     case 4
%         forecastday=1;InnovationType='Normal';
%     case 5
%         InnovationType='Normal';
% end
% for i = outsampleStart : forecastday : outsampleEnd
%     Mdl=egarch('GARCH',NaN,'ARCH',NaN,'Leverage',NaN,'Offset',NaN);
%     ret=logRet(i-EGARCHlength:i-1);%figure;plot(ret)
%     EstMdl=estimate(Mdl,ret,'Display','full');
%     if outsampleEnd - i >5
%         VarianceEstimate(i+1-outsampleStart : i+forecastday-outsampleStart, :) = forecast(EstMdl,forecastday,'Y0',ret);
%         switch InnovationType
%             case 'Normal'
%                 EGARCHVaR(i+1-outsampleStart : i+forecastday-outsampleStart, :) = norminv([.0025 .005 .01 .025 .05 .075 .1],mean(logRet(i-EGARCHlength:i-1)),sqrt(forecast(EstMdl,forecastday,'Y0',ret)) );
%             case 'T'
%                 for i1=i+1-outsampleStart : i+forecastday-outsampleStart
%                     EGARCHVaR(i1, :) = tinv([.0025 .005 .01 .025 .05 .075 .1],50)*sqrt(VarianceEstimate(i1,:))+mean(logRet(i-EGARCHlength:i-1));
%                 end
%         end
%     else
%         VarianceEstimate(i+1-outsampleStart : end, :) = forecast(EstMdl,outsampleEnd-i+1,'Y0',ret);
%         switch InnovationType
%             case 'Normal'
%                 EGARCHVaR(i+1-outsampleStart : end, :) = norminv([.0025 .005 .01 .025 .05 .075 .1],mean(logRet(i-EGARCHlength:i-1)),sqrt(forecast(EstMdl,outsampleEnd-i+1,'Y0',ret)) );
%             case 'T'
%                 for i1=i+1-outsampleStart : numel(VarianceEstimate)
%                     EGARCHVaR(i1, :) = tinv([.0025 .005 .01 .025 .05 .075 .1],50)*sqrt(VarianceEstimate(i1,:))+mean(logRet(i-EGARCHlength:i-1));
%                 end
%         end
% %         EGARCHVaR(i+1-outsampleStart : end, :) = norminv([.0025 .005 .01 .025 .05 .075 .1],mean(logRet(i-EGARCHlength:i-1)),sqrt(forecast(EstMdl,outsampleEnd-i+1,'Y0',ret)) );
%     end
% end

% 2021.8.17日之前版本

% function [EGARCHVaR,VarianceEstimate] = EGARCHVaRPredict(logRet,outsampleStart,outsampleEnd,EGARCHlength)
%
% EGARCHVaR = zeros(size(logRet(outsampleStart:outsampleEnd),1),7);
% VarianceEstimate = zeros(size(logRet(outsampleStart:outsampleEnd),1),1);
% for i = outsampleStart : outsampleEnd
%     Mdl=egarch('GARCH',NaN,'ARCH',NaN,'Leverage',NaN,'Offset',NaN);
% %     Mdl=egarch(3,2);
%     ret=logRet(i-EGARCHlength:i-1);%figure;plot(ret)
%     EstMdl=estimate(Mdl,ret,'Display','full');
%     VarianceEstimate(i+1-outsampleStart, :) = forecast(EstMdl,1,'Y0',ret);
%     EGARCHVaR(i+1-outsampleStart, :) = norminv([.0025 .005 .01 .025 .05 .075 .1],mean(logRet(i-EGARCHlength:i-1)),sqrt(VarianceEstimate(i+1-outsampleStart, :)));
%
% %     sigma2 = std(ret).^2*ones(numel(ret),1);
% %     logsigma2 = log(sigma2);
% %     for ii = 2:numel(sigma2)
% %         coefficient = [EstMdl.Constant EstMdl.GARCH{1} EstMdl.GARCH{2} EstMdl.GARCH{3} ...
% %             EstMdl.ARCH{1} EstMdl.ARCH{2} EstMdl.Leverage{1} EstMdl.Leverage{2}];
% %         data = [1 logsigma2(ii-1) logsigma2(ii-2) logsigma2(ii-3)...
% %             abs(ret(ii-1)-EstMdl.Offset)/sqrt(sigma2(ii-1))  - sqrt(2/pi) ...
% %             abs(ret(ii-2)-EstMdl.Offset)/sqrt(sigma2(ii-2))  - sqrt(2/pi) ...
% %             (ret(ii-1)-EstMdl.Offset) / sqrt(sigma2(ii-1)) (ret(ii-2)-EstMdl.Offset) / sqrt(sigma2(ii-2))]';
% %         logsigma2(ii) = coefficient*data;
% %         logsigma2(ii) = EstMdl.Constant...
% %             + EstMdl.ARCH{1} * ( abs(ret(ii-1)-mean(ret))/sqrt(sigma2(ii-1)) - sqrt(2/pi) )...
% %             + EstMdl.GARCH{1} * logsigma2(ii-1)...
% %             + EstMdl.Leverage{1} * (ret(ii-1)-mean(ret)) / sqrt(sigma2(ii-1));
% %         sigma2(ii) = exp(logsigma2(ii));
% %     end
% %     EGARCHVaR(i+1-outsampleStart, :) = norminv([.0025 .005 .01 .025 .05 .075 .1],mean(logRet(i-EGARCHlength:i-1)),sqrt(sigma2(end)));
% %     VarianceEstimate(i+1-outsampleStart, :) = sigma2(end);
% end