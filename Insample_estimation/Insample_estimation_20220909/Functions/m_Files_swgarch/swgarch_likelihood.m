function [LL, LLS, Ht, predict_prob, filtered_prob] = swgarch_likelihood(parameters, data, k, error_type, ms_type, T, estim_flag)

% Log likelihood for swgarch(k) estimation
%
% USAGE:
%   [LL, LLS, Ht, predict_prob, filtered_prob] = swgarch_likelihood(parameters, data, k, error_type, ms_type, T, estim_flag)
%
% INPUTS:
%   parameters    - A vector of parameters (see swgarch_itransform)
%   data          - Vector of mean zero residuals
%   k             - The number of regimes
%   error_type    - The type of error being assumed, valid types are:
%                     1 if 'NORMAL'
%                     2 if 'STUDENTST' [NOT IMPLEMENTED]
%   ms_type       - 1 for 'GRAY'     [NOT IMPLEMENTED YET]
%                 - 2 for 'KLAASSEN'
%                 - 3 for 'HAAS'
%   T             - Length of data
%   ESTIM_FLAG    - [OPTIONAL] Flag (0 or 1) to indicate if the function
%                   is being used in estimation.  If it is 1, then the parameters are
%                   transformed from unconstrained values to constrained by standard
%                   garch model constraints. If it's 0, the parameters are
%                   nod transformed as usual with fmincon.
%
% OUTPUTS:
%   LL             - Minus 1 times the log likelihood
%   LLS            - Time series of log likelihoods (Also multiplied by -1)
%   HT             - Time series of conditional variances
%   predict_prob   - Time series of the predicted probabilities
%                    computed for the estimation
%   filtered_prob  - Time series of the filtered probabilities
%
% COMMENTS:
%   See also swgarch

% Copyright: Thomas Chuffart
% Mail: thomas.chuffart@univ-amu.fr
% Version: MSG_tool_Beta v2.0   Date: 30/01/2015


LL = [];

%If for estimation, transform the parameters otherwise they must be parsed
if nargin==7 && estim_flag
    parameters = swgarch_itransform(parameters,k,error_type);
end

%Compute the conditional variances and the time series of log likelihoods

switch ms_type
    case 1 
	switch error_type
	    case 1
		[Ht, predict_prob,filtered_prob,loglik] = swgarch_coreNG(data, parameters,k,T);
		LL = -ones(1,T-1)*loglik(2:T);
		LLS = -loglik;
	    case 2
		nu = parameters(3*k+(k*k)+1);
		c = (gamma((nu+1)*0.5)/gamma(nu*0.5))*pi^(-.5)*((nu-2)^(-.5));
		[Ht, predict_prob, filtered_prob, loglik] = swgarch_coreSTDG(data,parameters,k,T,c);
		LL = -ones(1,T-1)*loglik(2:T);
		LLS = -loglik;
	end
    case 2
        switch error_type
            case 1
                [Ht, predict_prob, filtered_prob, loglik]= swgarch_coreNK(data,parameters,k,T);
                LL = -ones(1,T-1)*loglik(2:T);
                LLS = -loglik;   
            case 2
                nu = parameters(3*k+(k*k) +1);                
                c =  (gamma((nu+1)*0.5)/gamma(nu*0.5))*pi^(-.5)*((nu-2)^(-.5)); 
                [Ht, predict_prob, filtered_prob, loglik]= swgarch_coreSTDK(data,parameters,k,T,c);
                LL = -ones(1,T-1)*loglik(2:T);
                LLS = -loglik;                             
        end
    case 3
        switch error_type
            case 1
                [Ht, predict_prob, filtered_prob, loglik]= swgarch_coreNH(data,parameters,k,T);
                LL = -ones(1,T-1)*loglik(2:T);
                LLS = -loglik;
            case 2     
                nu = parameters(3*k+(k*k) +1);
                c =  (gamma((nu+1)*0.5)/gamma(nu*0.5))*pi^(-.5)*((nu-2)^(-.5)); 
                [Ht, predict_prob, filtered_prob, loglik]= swgarch_coreSTDH(data,parameters,k,T,c);
                LL = -ones(1,T-1)*loglik(2:T);
                LLS = -loglik;
        end
end

end

