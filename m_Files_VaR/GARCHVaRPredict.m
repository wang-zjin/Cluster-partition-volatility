function GARCHVaR = GARCHVaRPredict(logRet,outsampleStart,outsampleEnd,GARCHlength,forecastday,InnovationType,ConfidenceLevel)

switch nargin
    case 2
        outsampleEnd=numel(logRet);GARCHlength=300;forecastday=1;InnovationType='Normal';ConfidenceLevel=0.05;
    case 3
        GARCHlength=300;forecastday=1;InnovationType='Normal';ConfidenceLevel=0.05;
    case 4
        forecastday=1;InnovationType='Normal';ConfidenceLevel=0.05;
    case 5
        InnovationType='Normal';ConfidenceLevel=0.05;
    case 6
        ConfidenceLevel=0.05;%[.0025 .005 .01 .025 .05 .075 .1]
end
GARCHVaR = zeros(numel(outsampleStart:outsampleEnd),numel(ConfidenceLevel));
vForecast = zeros(numel(outsampleStart:outsampleEnd),1);
for i = outsampleStart :forecastday: outsampleEnd
    Mdl=garch(1,1);
    ret=logRet(i-GARCHlength:i-1);
    [~,EstMdl]=estimateGARCH(ret,Mdl);
    if i+forecastday-1 <= outsampleEnd
        vForecast(i+1-outsampleStart:i+forecastday-outsampleStart, :)=forecast(EstMdl,forecastday,'Y0',ret);
        switch InnovationType
            case 'Normal'
                GARCHVaR(i+1-outsampleStart:i+forecastday-outsampleStart, :) = ...
                    norminv(ConfidenceLevel,mean(ret),sqrt(vForecast(i+1-outsampleStart:i+forecastday-outsampleStart,:)));
            case 'T'
                for i1=i+1-outsampleStart:i+forecastday-outsampleStart
                    GARCHVaR(i1, :) = tinv(ConfidenceLevel,50).*sqrt(vForecast(i1,:))+mean(ret);
                end
        end
    else
        vForecast(i+1-outsampleStart:end, :)=forecast(EstMdl,outsampleEnd-i+1,'Y0',ret);
        switch InnovationType
            case 'Normal'
                GARCHVaR(i+1-outsampleStart:end, :) = norminv(ConfidenceLevel,mean(ret),sqrt(vForecast(i+1-outsampleStart:end,:)));
            case 'T'
                for i1=i+1-outsampleStart:numel(vForecast)
                    GARCHVaR(i1, :) = tinv(ConfidenceLevel,50).*sqrt(vForecast(i1,:))+mean(ret);
                end
        end
    end
end


% 这是2021.8.19之前版本
% function GARCHVaR = GARCHVaRPredict(logRet,outsampleStart,outsampleEnd,GARCHlength)
%
% GARCHVaR = zeros(size(logRet(outsampleStart:outsampleEnd),1),7);
% for i = outsampleStart : outsampleEnd
%     Mdl=garch(1,1);
%     ret=logRet(i-GARCHlength:i-1);
%     EstMdl=estimate(Mdl,ret,'Display','full');
%     sigma2 = std(ret).^2*ones(numel(ret),1);
%     for ii = 2:numel(sigma2)
%         sigma2(ii)=EstMdl.Constant+EstMdl.ARCH{1}*ret(ii-1).^2+EstMdl.GARCH{1}*sigma2(ii-1);
%     end
%     GARCHVaR(i+1-outsampleStart, :) = norminv([.0025 .005 .01 .025 .05 .075 .1],mean(logRet(i-251:i-1)),sqrt(sigma2(end)));
% end

