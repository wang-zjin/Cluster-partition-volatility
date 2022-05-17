function [sigma2,EstMdl]=estimateGARCH(logRet,Mdl)

% EstMdl = estimate(Mdl,logRet,'Display','full');
EstMdl = estimate(Mdl,logRet,'Display','off');
% ���㲨����
sigma2=infer(EstMdl,logRet);

% ����2022��2��3��֮ǰ�汾
% ���㲨����
% errors=logRet-mean(logRet);
% T=numel(logRet);
% sigma2 = std(errors)^2*ones(T,1); 
% for i = 2:T
%     sigma2(i) = EstMdl.Constant + EstMdl.ARCH{1} * errors(i-1).^2 + EstMdl.GARCH{1} * sigma2(i-1); 
% end