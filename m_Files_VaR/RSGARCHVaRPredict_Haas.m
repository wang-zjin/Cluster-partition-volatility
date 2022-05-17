function RSGARCHVaR = RSGARCHVaRPredict_Haas(logRet,outsampleStart,outsampleEnd,RSGARCHlength,forecastday,InnovationType,ConfidenceLevel)

% 2022年1月24日改进版本
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
RSGARCHVaR = zeros(size(logRet(outsampleStart:outsampleEnd),1),numel(ConfidenceLevel));
vForecast = zeros(numel(outsampleStart:outsampleEnd),1);
for i = outsampleStart :forecastday: outsampleEnd
    errors=logRet(i-RSGARCHlength:i-1)-mean(logRet(i-RSGARCHlength:i-1));%error term
    %     estimation = swgarch(errors, 2, 'NORMAL','HAAS','CONS', {'YES',[]},...
    %         [0.1 0.1 0.92;0.01 0.05 0.7], [0.8 0.2;0.2 0.8], [],[]);
    switch InnovationType
        case 'Normal'
            [estimation, probabilities, ~] = swgarch(errors, 2, 'NORMAL',...
                'HAAS','CONS', {'YES',[]}, [0.1 0.1 0.82;0.05 0.05 0.7], [0.8 0.2;0.2 0.8],...
                [],[]);
        case 'T'
            [estimation, probabilities, ~] = swgarch(errors, 2, 'STUDENTST',...
                'HAAS','CONS', {'YES',[]}, [0.1 0.1 0.82;0.01 0.05 0.7], [0.9 0.1;0.1 0.9],...
                50,[]);
    end
    if i+forecastday-1<=outsampleEnd
        switch InnovationType
            case 'Normal'
                datafcst = swgarch_forecast(forecastday,2,estimation.garch,estimation.transM,'INDEP','NORMAL',[],0,errors,estimation.H,probabilities);
                vForecast(i+1-outsampleStart:i+forecastday-outsampleStart,:) = datafcst.vH;
                RSGARCHVaR(i+1-outsampleStart:i+forecastday-outsampleStart, :)= ...
                    norminv(ConfidenceLevel,mean(logRet(i-RSGARCHlength:i-1)),sqrt(datafcst.vH));
                
            case 'T'
                datafcst = swgarch_forecast(forecastday,2,estimation.garch,estimation.transM,'INDEP','STUDENTST',estimation.other,0,errors,estimation.H,probabilities);
                for i1=i+1-outsampleStart:i+forecastday-outsampleStart
                    i2=i1-i+outsampleStart;
                    vForecast(i1,:) = datafcst.vH(i2);
                    RSGARCHVaR(i1, :)= tinv(ConfidenceLevel,estimation.other)*sqrt(vForecast(i1,:))+mean(logRet(i-RSGARCHlength:i-1));
                end
        end
    else
        switch InnovationType
            case 'Normal'
                datafcst = swgarch_forecast(forecastday,2,estimation.garch,estimation.transM,'INDEP','NORMAL',[],0,errors,estimation.H,probabilities);
                vForecast(i+1-outsampleStart:numel(vForecast),:) = datafcst.vH;
                RSGARCHVaR(i+1-outsampleStart:numel(vForecast), :)= ...
                    norminv(ConfidenceLevel,mean(logRet(i-RSGARCHlength:i-1)),sqrt(datafcst.vH));
            case 'T'
                datafcst = swgarch_forecast(forecastday,2,estimation.garch,estimation.transM,'INDEP','STUDENTST',estimation.other,0,errors,estimation.H,probabilities);
                for i1=i+1-outsampleStart:numel(vForecast)
                    i2=i1-i+outsampleStart;
                    vForecast(i1,:) = datafcst.vH(i2);
                    RSGARCHVaR(i1, :)= tinv(ConfidenceLevel,estimation.other)*sqrt(vForecast(i1,:))+mean(logRet(i-RSGARCHlength:i-1));
                end
        end
    end
end

% % 这是2022年1月24日之前版本
% addpath('m_Files_swgarch');
% switch nargin
%     case 2
%         outsampleEnd=numel(outsampleStart);RSGARCHlength=250;forecastday=1;InnovationType='Normal';ConfidenceLevel=0.05;
%     case 3
%         RSGARCHlength=250;forecastday=1;InnovationType='Normal';ConfidenceLevel=0.05;
%     case 4
%         forecastday=1;InnovationType='Normal';ConfidenceLevel=0.05;
%     case 5
%         InnovationType='Normal';ConfidenceLevel=0.05;
%     case 6
%         ConfidenceLevel=0.05;
% end
% RSGARCHVaR = zeros(size(logRet(outsampleStart:outsampleEnd),1),numel(ConfidenceLevel));
% vForecast = zeros(numel(outsampleStart:outsampleEnd),1);
% for i = outsampleStart :forecastday: outsampleEnd
%     errors=logRet(i-RSGARCHlength:i-1)-mean(logRet(i-RSGARCHlength:i-1));%error term
%     estimation = swgarch(errors, 2, 'NORMAL','HAAS','CONS', {'YES',[]},...
%         [0.1 0.1 0.92;0.01 0.05 0.7], [0.8 0.2;0.2 0.8], [],[]);
%     if i+forecastday-1<=outsampleEnd
%         stimulation = swgarch_sim(forecastday,2,estimation.garch,estimation.transM, 'DEP','NORMAL',1,0);%stimulation
%         switch InnovationType
%             case 'Normal'
%                 vForecast(i+1-outsampleStart:i+forecastday-outsampleStart,:) = stimulation.vH;
%                 RSGARCHVaR(i+1-outsampleStart:i+forecastday-outsampleStart, :)= ...
%                     norminv(ConfidenceLevel,mean(logRet(i-RSGARCHlength:i-1)),sqrt(stimulation.vH));
%
%             case 'T'
%                 for i1=i+1-outsampleStart:i+forecastday-outsampleStart
%                     i2=i1-i+outsampleStart;
%                     vForecast(i1,:) = stimulation.vH(i2);
%                     RSGARCHVaR(i1, :)= ...
%                         tinv(ConfidenceLevel,50)*sqrt(vForecast(i1,:))+mean(logRet(i-RSGARCHlength:i-1));
%                 end
%         end
%     else
%         stimulation = swgarch_sim(numel(vForecast)-i+outsampleStart,2,estimation.garch,estimation.transM, 'DEP','NORMAL',1,0);%stimulation
%         switch InnovationType
%             case 'Normal'
%                 vForecast(i+1-outsampleStart:numel(vForecast),:) = stimulation.vH;
%                 RSGARCHVaR(i+1-outsampleStart:numel(vForecast), :)= ...
%                     norminv(ConfidenceLevel,mean(logRet(i-RSGARCHlength:i-1)),sqrt(stimulation.vH));
%             case 'T'
%                 for i1=i+1-outsampleStart:numel(vForecast)
%                     i2=i1-i+outsampleStart;
%                     vForecast(i1,:) = stimulation.vH(i2);
%                     RSGARCHVaR(i1, :)= ...
%                         tinv(ConfidenceLevel,50)*sqrt(vForecast(i1,:))+mean(logRet(i-RSGARCHlength:i-1));
%                 end
%         end
%     end
% end

% 这是2022年1月22日之前版本
% RSGARCHVaR = zeros(size(logRet(outsampleStart:outsampleEnd),1),7);
% for i = outsampleStart : outsampleEnd
%     errors=logRet(i-RSGARCHlength:i-1)-mean(logRet(i-RSGARCHlength:i-1));%error term
%     estimation = swgarch(errors, 2, 'NORMAL','HAAS','CONS', {'YES',[]},...
%        [0.1 0.1 0.92;0.01 0.05 0.7], [0.8 0.2;0.2 0.8], [],[]);
%     stimulation = swgarch_sim(1,2,estimation.garch,estimation.transM, 'DEP','NORMAL',1,0);%stimulation
%     RSGARCHVaR(i+1-outsampleStart, :)= norminv([.0025 .005 .01 .025 .05 .075 .1],mean(logRet(i-RSGARCHlength:i-1)),sqrt(stimulation.vH));
% end
% tableVaRPredict(RSGARCHVaR,logRet,outsampleStart,outsampleEnd,2);
rmpath('m_Files_swgarch');