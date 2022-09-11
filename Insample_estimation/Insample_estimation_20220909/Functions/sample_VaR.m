function VaRhat = sample_VaR(data,alpha)
% function VEhat = sample_VaR(data,alpha)
%
% Function to compute the sample VaR from a data set
%
%  INPUTS:  data, a TxN matrix, data on N time series
%           alpha, a px1 vector, the values of alpha to consider
%
%  OUTPUTS: VEhat, a Nxp matrix, the sample VaR for each series
%
%  Andrew Patton
%
%  10 Spetemberr 2022
%
% This code was used in: 
% Print summary statistics of SP500, DAX and FTSE

[~,N] = size(data);
p = length(alpha);
VaRhat = nan(N,2,p);
for ii=1:N
    for aa=1:p
        VaRhat(ii,aa) = quantile(data,alpha(aa));
    end
    
end
VaRhat = squeeze(VaRhat);  % just removing any redundant dimensions