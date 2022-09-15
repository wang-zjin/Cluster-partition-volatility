function [vol, predict_prob, filtered_prob, loglik] = swgarch_coreNG(data,parameters,k,T)

% Conditional variance computation for a  swgarch(k) following Gray (1996)
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
predict_prob = zeros(T+1,k);
loglik = zeros(T,1);

P = parameters(3*k+1:3*k+(k*k));
P = reshape(P,k,k);

% v = zeros(T,k); % delected by Wang Zijin
A = [eye(k)-P;ones(1,k)];
I3 = eye(k+1); 
c3 = I3(:,k+1); 
pinf = (A'*A)\A'*c3; 
omega = parameters(1:k)'; 
alpha = parameters(k+1:k*2)'; 
beta = parameters(k*2+1:k*3); 
filtered_prob(1:2,:) = repmat(pinf',2,1); 
v = zeros(T,1);
v(1) = var(data);
H(1,:) = var(data);

for t=2:T
	H(t,:) = omega + alpha*data(t-1)^2 + v(t-1).*beta';
	LL(1,1:k) = filtered_prob(t,1:k).*normpdf(data(t),0,sqrt(H(t,1:k)));	    
 	predict_prob(t,:) =  LL/sum(LL);	
	filtered_prob(t+1,:) = P*predict_prob(t,:)';
    v(t) = predict_prob(t,:)*H(t,:)';
	loglik(t,1) = log(LL*ones(k,1));
end
vol = v;
end
