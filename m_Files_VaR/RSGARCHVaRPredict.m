function [RSGARCHVaR,vForecast] = RSGARCHVaRPredict(logRet,outsampleStart,outsampleEnd,RSGARCHlength,forecastday,InnovationType,ConfidenceLevel)

addpath('m_Files_swgarch');
switch nargin
    case 2
        outsampleEnd=numel(outsampleStart);RSGARCHlength=250;forecastday=1;InnovationType='Normal';ConfidenceLevel=0.05;
    case 3
        RSGARCHlength=250;forecastday=1;InnovationType='Normal';ConfidenceLevel=0.05;
    case 4
        forecastday=1;InnovationType='Normal';ConfidenceLevel=0.05;
    case 5
        InnovationType='Normal';ConfidenceLevel=0.05;
    case 6
        ConfidenceLevel=0.05;
end
RSGARCHVaR = zeros(numel(outsampleStart:outsampleEnd),numel(ConfidenceLevel));
vForecast = zeros(numel(outsampleStart:outsampleEnd),1);
for i = outsampleStart :forecastday: outsampleEnd
    errors=logRet(i-RSGARCHlength:i-1)-mean(logRet(i-RSGARCHlength:i-1));%error term
    estimation = swgarch(errors, 2, 'NORMAL','KLAASSEN','CONS', {'YES',[]},...
        [0.1 0.1 0.92;0.01 0.05 0.7], [0.8 0.2;0.2 0.8], [],[]);
    if i+forecastday-1<=outsampleEnd
        stimulation = swgarch_sim(forecastday,2,estimation.garch,estimation.transM, 'DEP','NORMAL',1,0);%stimulation
        switch InnovationType
            case 'Normal'
                vForecast(i+1-outsampleStart:i+forecastday-outsampleStart,:) = stimulation.vH;
                RSGARCHVaR(i+1-outsampleStart:i+forecastday-outsampleStart, :)= ...
                    norminv(ConfidenceLevel,mean(logRet(i-RSGARCHlength:i-1)),sqrt(stimulation.vH));
                
            case 'T'
                for i1=i+1-outsampleStart:i+forecastday-outsampleStart
                    i2=i1-i+outsampleStart;
                    vForecast(i1,:) = stimulation.vH(i2);
                    RSGARCHVaR(i1, :)= ...
                        tinv(ConfidenceLevel,50)*sqrt(vForecast(i1,:))+mean(logRet(i-RSGARCHlength:i-1));
                end
        end
    else
        stimulation = swgarch_sim(numel(vForecast)-i+outsampleStart,2,estimation.garch,estimation.transM, 'DEP','NORMAL',1,0);%stimulation
        switch InnovationType
            case 'Normal'
                vForecast(i+1-outsampleStart:numel(vForecast),:) = stimulation.vH;
                RSGARCHVaR(i+1-outsampleStart:numel(vForecast), :)= ...
                    norminv(ConfidenceLevel,mean(logRet(i-RSGARCHlength:i-1)),sqrt(stimulation.vH));
            case 'T'
                for i1=i+1-outsampleStart:numel(vForecast)
                    i2=i1-i+outsampleStart;
                    vForecast(i1,:) = stimulation.vH(i2);
                    RSGARCHVaR(i1, :)= ...
                        tinv(ConfidenceLevel,50)*sqrt(vForecast(i1,:))+mean(logRet(i-RSGARCHlength:i-1));
                end
        end
    end
end
rmpath('m_Files_swgarch');

% 这是2021.8.19之前版本
% addpath('m_Files_swgarch');
% RSGARCHVaR = zeros(size(logRet(outsampleStart:outsampleEnd),1),7);
% for i = outsampleStart : outsampleEnd
%     errors=logRet(i-RSGARCHlength:i-1)-mean(logRet(i-RSGARCHlength:i-1));%error term
%     estimation = swgarch(errors, 2, 'NORMAL','KLAASSEN','CONS', {'YES',[]},...
%        [0.1 0.1 0.92;0.01 0.05 0.7], [0.8 0.2;0.2 0.8], [],[]);
%     stimulation = swgarch_sim(1,2,estimation.garch,estimation.transM, 'DEP','NORMAL',1,0);%stimulation
%     RSGARCHVaR(i+1-outsampleStart, :)= norminv([.0025 .005 .01 .025 .05 .075 .1],mean(logRet(i-RSGARCHlength:i-1)),sqrt(stimulation.vH));
% end
% tableVaRPredict(RSGARCHVaR,logRet,outsampleStart,outsampleEnd,2);
% rmpath('m_Files_swgarch');