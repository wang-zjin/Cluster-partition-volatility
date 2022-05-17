function [sigma2,EstMdl]=estimateGARCH(logRet,Mdl)

% EstMdl = estimate(Mdl,logRet,'Display','full');
EstMdl = estimate(Mdl,logRet,'Display','off');
% 计算波动率
sigma2=infer(EstMdl,logRet);

% 这是2022年2月3日之前版本
% 计算波动率
% errors=logRet-mean(logRet);
% T=numel(logRet);
% sigma2 = std(errors)^2*ones(T,1); 
% for i = 2:T
%     sigma2(i) = EstMdl.Constant + EstMdl.ARCH{1} * errors(i-1).^2 + EstMdl.GARCH{1} * sigma2(i-1); 
% end