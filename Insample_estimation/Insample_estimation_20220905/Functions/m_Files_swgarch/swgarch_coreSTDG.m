function [Ht, predict_prob, filtered_prob, loglik] = swgarch_coreSTDG(data,parameters,k,T,c)

% Conditional variance computation for a swgarch(k) following Gray (1996)
%
% USAGE: 
%   [Ht, predict_prob, filtered_prob, loglik] = swgarch_coreH(data,parameters,k,m,T,ms_type)
%
% INPUTS:
%   data 	   - A vector of mean zero residuals
%   parameters     - A vector of parameters (see swgarch_itransform) 
%   k		   - The number of regimes
%   T		   - Lenght of data
%
% OUTPUTS:
%   Ht 		   - Vector of conditional variance, T by 1
%   predict_prob   - Time series of the prediected probabilities (T x k)
%   filtered_prob  - Time series of the filetered probabilities (T x k)
%   loglik         - Individual log-likelihoods vector
%
%
%
%  See also swgarch
%

% Copyright: Thomas Chuffart
% thomas.chuffart@univ-amu.fr
% Version: MSG_tool_Beta v3.0 Date: 17/09/2015

H = zeros(T,k);
filtered_prob = zeros(T+1,k);
predict_prob = zeros(T,k); % added by Wang Zijin
loglik = zeros(T,1);

P = parameters(3*k+1:3*k+(k*k));
P = reshape(P,k,k);
v = zeros(T,k);
A = [eye(k)-P;ones(1,k)];
I3 = eye(k+1); 
c3 = I3(:,k+1); 
pinf = ((A'*A)\A'*c3); 
omega = parameters(1:k)'; 
alpha = parameters(k+1:k*2)'; 
beta = diag(parameters(k*2+1:k*3)); 
nu = parameters(3*k+(k*k)+1);
filtered_prob(1:2,:) = repmat(pinf',2,1); 
Ht = zeros(T,1); 
v(1,:) = var(data);
for t=2:T
	H(t,:) = omega + alpha*data(t-1)^2 + v(t-1,:)*beta;
% 	Hit1 = H(t,:) * filtered_prob(t,:)';   deleted by Wang Zijin
	Ht(t) = H(t,:) * filtered_prob(t,:)'; 
    LL(1,1:k) = filtered_prob(t,1:k).*(c*(H(t,:).^(-.5).*(1+(data(t)^(2))./(H(t,:)*(nu-2))).^(-.5*(nu+1))));	
	predict_prob(t,:) =  LL/sum(LL);	
	filtered_prob(t+1,:) = P*predict_prob(t,:)';
	loglik(t,1) = log(LL*ones(k,1));
end
end
