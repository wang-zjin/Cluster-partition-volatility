function Vhat = sample_VaR(data,alpha)
% function [VEhat,vcv] = sample_VE(data,alpha)
%
% Function to compute the sample VaR and ES from a data set
%
%  INPUTS:  data, a TxN matrix, data on N time series
%           alpha, a px1 vector, the values of alpha to consider
%
%  OUTPUTS: VEhat, a Nx2xp matrix, the sample VaR and ES for each series
%           vcv, a 2x2xp matrix, the covariance matrix of the estimated VaR and ES
%
%  Andrew Patton
%
%  7 November 2015
%
% This code was used in: 
% Patton, A.J., J.F. Ziegel, and R. Chen, 2018, Dynamic Semiparametric
% Models for Expected Shortfall (and Value-at-Risk), Journal of Econometrics, forthcoming. 

[~,N] = size(data);
p = length(alpha);
Vhat = nan(N,p);
for ii=1:N
    for aa=1:p
        Vhat(ii,aa) = quantile(data,alpha(aa));
    end
end
Vhat = squeeze(Vhat);  % just removing any redundant dimensions