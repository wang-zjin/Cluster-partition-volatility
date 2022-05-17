clear, clc

addpath('data_Files'); % add 'data_Files' folder to the search path
load('sample')
logRet = sample(:,4);

Mdl = egarch(1,1);
[EstMdl] = estimate(Mdl,logRet,'Display','full');
% [SmltMdl] = simulate(Mdl,logRet,100);
%% ¼ÆËã²¨¶¯ÂÊ
a0 = EstMdl.Constant;
a1 = EstMdl.ARCH{1};
b1 = EstMdl.GARCH{1};
xi = EstMdl.Leverage{1};
sigma2 = std(logRet)^2*ones(numel(logRet),1); 
logsigma2 = log(sigma2); 
for i = 2:numel(logRet)
%     logsigma2(i) = a0 +   a1 * ( abs(logRet(i-1)-mean(logRet))/sqrt(sigma2(i-1)) - sqrt(2/pi) )   + b1 * logsigma2(i-1);
    logsigma2(i) = a0 + a1 * ( abs(logRet(i-1)-mean(logRet))/sqrt(sigma2(i-1)) - sqrt(2/pi) ) + b1 * logsigma2(i-1)...
        + xi * (logRet(i-1)-mean(logRet)) / sqrt(sigma2(i-1));
    sigma2(i)=exp(logsigma2(i));
end
figure;
plot(sigma2)
rmpath('data_Files');