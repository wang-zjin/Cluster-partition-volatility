function Vhat = skewt_VaR(theta,alpha)
% function VEhat = skewt_VE(theta,alpha)
%
% Function to compute the theoretical VaR for Hansen's skew t distribution
%
%  INPUTS:  theta, a Nx2 matrix containing [nu,lambda], the two parameters of Hansen's skew t distribution
%              (Note that setting lam=0 leads to the standardized (i.e., unit variance) Student's t distribution)
%           alpha, a px1 vector, the values of alpha to consider
%
%  OUTPUTS: Vhat, a Nxp matrix, the sample VaR for each series
%
%  Andrew Patton
%
%  11 October 2018
%
% The formula below appeared in:
%
% Patton, A.J., J.F. Ziegel, and R. Chen, 2018, Dynamic Semiparametric
% Models for Expected Shortfall (and Value-at-Risk), Journal of Econometrics, forthcoming. 
%
% and is based on the following paper, which presented results for the Student's t distribution (among other results):
%
% Dobrev, D., T.D. Nesmith, D.H. Oh, 2017, Accurate Evaluation of Expected Shortfall for Linear Portfolios with 
% Elliptically Distributed Risk Factors, Journal of Risk and Financial Management, 10(5), 1-14.

if numel(size(theta))==2 && size(theta,1)==2 % ie, just a single value of (nu,lam) is entered but it is a column vector
    theta = theta';
end

    
N = size(theta,1);
p = length(alpha);
Vhat = nan(N,p);
for ii=1:N
    nu = theta(ii,1);
    lam = theta(ii,2);
    
    c = exp(gammaln((nu+1)/2)-gammaln(nu/2))/sqrt(pi*(nu-2));      % parameters used in Hansen's skew t PDF
    a = 4*lam*c*(nu-2)/(nu-1);
    b = sqrt(1+3*lam^2-a^2);

    if max(skewtdis_inv(alpha,nu,lam))>(-a/b)  % then at least one of the alpha values requires "special" treatment, so use a loop
        for aa=1:length(alpha)
            alpha1 = alpha(aa);
            VVZ = skewtdis_inv(alpha1,nu,lam);
            Vhat(ii,aa) = VVZ;  % theoretical VaR for the skew t
        end
    else  % no alpha value requires special treatment, and so I can vectorize
        VVZ = skewtdis_inv(alpha,nu,lam);
        Vhat(ii,:) = VVZ;  % theoretical VaR for the skew t
    end
end
Vhat = squeeze(Vhat);  % removing any redundant dimensions
