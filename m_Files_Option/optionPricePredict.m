function [MAD_CP,MAD_GARCH,MAD_EGARCH,MAD_RSGARCH,MSE_CP,MSE_GARCH,MSE_EGARCH,MSE_RSGARCH] =...
    optionPricePredict(OptionSetExerciseAtCell)
t1=cputime;
MAD_CP = zeros(numel(OptionSetExerciseAtCell),2);
MAD_GARCH = zeros(numel(OptionSetExerciseAtCell),2);
MAD_EGARCH = zeros(numel(OptionSetExerciseAtCell),2);
MAD_RSGARCH = zeros(numel(OptionSetExerciseAtCell),2);
MSE_CP = zeros(numel(OptionSetExerciseAtCell),2);
MSE_GARCH = zeros(numel(OptionSetExerciseAtCell),2);
MSE_EGARCH = zeros(numel(OptionSetExerciseAtCell),2);
MSE_RSGARCH = zeros(numel(OptionSetExerciseAtCell),2);
for i=1:numel(OptionSetExerciseAtCell)
    t2=cputime;
    fprintf('The option price prediction process is %2.2f%% and will finish in %6.2f minutes.\n',...
        i/numel(OptionSetExerciseAtCell)*100,... 
        (t2-t1)*(numel(OptionSetExerciseAtCell)/i-1)/60);
    % extract option
    underlydingOption=OptionSetExerciseAtCell{i,1};
    
    CPCall = zeros(numel(70 : 101),1);     % Cluster partition model
    CPPut = zeros(numel(70 : 101),1);
    GARCHCall = zeros(numel(70 : 101),1);  % GARCH 定价
    GARCHPut = zeros(numel(70 : 101),1);
    EGARCHCall = zeros(numel(70 : 101),1); % EGARCH 定价
    EGARCHPut = zeros(numel(70 : 101),1);
    RSGARCHCall = zeros(numel(70 : 101),1); % RSGARCH 定价
    RSGARCHPut = zeros(numel(70 : 101),1);
    
    for T = 70 : 101
        
        ret=price2ret(underlydingOption(1:T,1));
        
        % Cluster partition model
%         addpath('F:\structural change model\programming\programming\20210326\m_Files_ClusterPartition');
        addpath('m_Files_ClusterPartition');
        sigma_IV = underlydingOption(1:T,11);
%         [LB,J,~] = Fisher_div_sqr(T,sigma_IV,5);
        [LB,J,~] = Fisher_div_sqr(sigma_IV,T,5);
        K = OptimalClusterNumber(sigma_IV,LB);
        sigma_CP = Vol_ClusterPartition(sigma_IV,K,J);
%         rmpath('F:\structural change model\programming\programming\20210326\m_Files_ClusterPartition');
        rmpath('m_Files_ClusterPartition');
        
        % GARCH
        Mdl=garch(1,1);EstMdl=estimate(Mdl,ret,'Display','full');
        sigma2_GARCH = std(ret).^2*ones(numel(ret),1);
        for ii = 2:numel(sigma2_GARCH)
            sigma2_GARCH(ii)=EstMdl.Constant+EstMdl.ARCH{1}*ret(ii-1).^2+EstMdl.GARCH{1}*sigma2_GARCH(ii-1);
        end
        sigma_GARCH = sqrt(EstMdl.Constant+EstMdl.ARCH{1}*ret(ii).^2+EstMdl.GARCH{1}*sigma2_GARCH(ii));
        
        % EGARCH
        Mdl=egarch(1,1);EstMdl=estimate(Mdl,ret,'Display','full');
        sigma2_EGARCH = std(ret).^2*ones(numel(ret),1);logsigma2 = log(sigma2_EGARCH);
        for ii = 2:numel(sigma2_EGARCH)
            logsigma2(ii) = EstMdl.Constant...
                + EstMdl.ARCH{1} * ( abs(ret(ii-1)-mean(ret))/sqrt(sigma2_EGARCH(ii-1)) - sqrt(2/pi) )...
                + EstMdl.GARCH{1} * logsigma2(ii-1)...
                + EstMdl.Leverage{1} * (ret(ii-1)-mean(ret)) / sqrt(sigma2_EGARCH(ii-1));
            sigma2_EGARCH(ii) = exp(logsigma2(ii));
        end
        sigma_EGARCH = sqrt(exp(EstMdl.Constant...
            + EstMdl.ARCH{1} * ( abs(ret(ii)-mean(ret))/sqrt(sigma2_EGARCH(ii)) - sqrt(2/pi) )...
            + EstMdl.GARCH{1} * logsigma2(ii)...
            + EstMdl.Leverage{1} * (ret(ii)-mean(ret)) / sqrt(sigma2_EGARCH(ii))));
        
        % RSGARCH
%         addpath('F:\structural change model\programming\programming\20210326\m_Files_swgarch');
        addpath('m_Files_swgarch');
        errors=ret-mean(ret);%error term
        estimation = swgarch(errors, 2, 'NORMAL','KLAASSEN','CONS', {'YES',[]},...
            [0.1 0.1 0.92;0.01 0.05 0.7], [0.8 0.2;0.2 0.8], [],[]);
        stimulation = swgarch_sim(1,2,estimation.garch,estimation.transM, 'DEP','NORMAL',1,0);
        sigma_RSGARCH = sqrt(stimulation.vH);
%         rmpath('F:\structural change model\programming\programming\20210326\m_Files_swgarch');
        rmpath('m_Files_swgarch');
        
        % option parameter
        rfRate = underlydingOption(T,12); % risk-free rate
        Price = underlydingOption(T,1)*exp(rfRate/250); % stock price
        Strike = underlydingOption(T,10); % strike price
        Time = underlydingOption(T+1,13); % time to maturuty date
        
        [CPCall(T-69),CPPut(T-69)] = blsprice(Price,Strike,rfRate,Time,sigma_CP(T));
        [GARCHCall(T-69),GARCHPut(T-69)] = blsprice(Price,Strike,rfRate,Time,sigma_GARCH);
        [EGARCHCall(T-69),EGARCHPut(T-69)] = blsprice(Price,Strike,rfRate,Time,sigma_EGARCH);
        [RSGARCHCall(T-69),RSGARCHPut(T-69)] = blsprice(Price,Strike,rfRate,Time,sigma_RSGARCH);
    end
    
    ActCall = underlydingOption(71:end,14);
    ActPut = underlydingOption(71:end,15);
    
    MAD_CP(i,1) = abs(mean(ActCall-CPCall));
    MAD_GARCH(i,1) = abs(mean(ActCall-GARCHCall));
    MAD_EGARCH(i,1) = abs(mean(ActCall-EGARCHCall));
    MAD_RSGARCH(i,1) = abs(mean(ActCall-RSGARCHCall));
    MAD_CP(i,2) = abs(mean(ActPut-CPPut));
    MAD_GARCH(i,2) = abs(mean(ActPut-GARCHPut));
    MAD_EGARCH(i,2) = abs(mean(ActPut-EGARCHPut));
    MAD_RSGARCH(i,2) = abs(mean(ActPut-RSGARCHPut));
    MSE_CP(i,1) = abs(mean((ActCall-CPCall).^2));
    MSE_GARCH(i,1) = abs(mean((ActCall-GARCHCall).^2));
    MSE_EGARCH(i,1) = abs(mean((ActCall-EGARCHCall).^2));
    MSE_RSGARCH(i,1) = abs(mean((ActCall-RSGARCHCall).^2));
    MSE_CP(i,2) = abs(mean((ActPut-CPPut).^2));
    MSE_GARCH(i,2) = abs(mean((ActPut-GARCHPut).^2));
    MSE_EGARCH(i,2) = abs(mean((ActPut-EGARCHPut).^2));
    MSE_RSGARCH(i,2) = abs(mean((ActPut-RSGARCHPut).^2));
    
end