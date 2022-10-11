function [Ht, predict_prob, filtered_prob, loglik] =swgarch_coreNH(data,parameters,k,T)

% Conditional variance computation for a swgarch(k) following Haas & al (2004)
%
% USAGE:
%   [Ht, predict_prob, filtered_prob, loglik] =swgarch_coreH(data,parameters,p,q,k,m,T,ms_type)
%
% INPUTS:
%   data          - A column of mean zero data transformed according to F (see COMMENTS)
%   parameters    - (1+p+q) x k + (k x k) by 1 vector of parameters
%   k             - The number of regimes
%   T             - Length of data
%
% OUTPUTS:
%   Ht            - Vector of conditonal varainces, T by 1
%   predict_prob  - Time series of the predicted probabilities (size T x k)
%   filtered_prob - Time series of the filtered probabilities (size T x k)
%   loglik        - Time series of log likelihoods 
%
%
%
%  See also swgarch
%

% Copyright: Thomas Chuffart
% thomas.chuffart@univ-amu.fr
% Version: MSG_tool_Beta v2.0   Date: 30/01/2015

H = zeros(T,k);
filtered_prob = zeros(T+1,k);
predict_prob = zeros(T,k);
loglik = zeros(T,1);

P = parameters(3*k+1:3*k+(k*k));
P = reshape(P,k,k);    

A = [eye(k)-P;ones(1,k)];
I3 = eye(k+1);
c3 = I3(:,k+1);
pinf = ((A'*A)\A'*c3);
omega=parameters(1:k)';
alpha=parameters(k+1:k*2)';
beta=diag(parameters(k*2+1:k*3));
filtered_prob(1:2,:) = repmat(pinf',2,1);
Ht = zeros(T,1);


for t = 2:T
    H(t,:) = omega + alpha*data(t-1)^2 + H(t-1,:)*beta;
    LL(1,1:k) = filtered_prob(t,1:k).*normpdf(data(t),0,sqrt(H(t,1:k)));
    predict_prob(t,:) = LL/sum(LL);
    filtered_prob(t+1,:) = P*predict_prob(t,:)';
    loglik(t,1) = log(LL*ones(k,1));
    Ht(t) = predict_prob(t,:)*H(t,:)';
end

end