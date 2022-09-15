function [trans_parameters, trans_garch, tP, trans_dist]=swgarch_trans(parameters, k, error_type,ms_type)

% swgarch(k) parameter transformation.  Used to map parameters from a
% swgarch process to the positive unit simplex. Used in the unconstrained estimation of
% swgarch.
%
% USAGE:
%   [trans_parameters, trans_garch, tP]=swgarch_trans(parameters, k, ~,ms_type)
%
% INPUTS:
%   parameters       - Column parameter vector
%   k                - Positive scalar integer representing the number of
%                      regimes
%   error_type       - The type of error being assumed, valid types are:
%                        1 if 'NORMAL'
%                        2 if 'STUDENTST' [NOT IMPLEMENTED YET]  
%   
%   ms_type          - 1 for 'GRAY'     [NOT IMPLEMENTED YET]
%                    - 2 for 'KLAASSEN'
%                    - 3 for 'HAAS'
%
% OUTPUTS:
%   trans_parameters - A 3 x k + (k x k) column vector of transformed parameters corresponding to
%                      [omega_1, ...,omega_k ,alpha_1, ... , alpha_k, beta_1, ... ,beta_k]'
%   trans_garch      - A 3 x k column vector of transformed GARCH parameters
%   tP               - A k x k column vector of transformed transition probabiliies 
%                      parameters
%   
%
% COMMENTS:
%   Input parameters must satisfy:
%    (1) omega_j > 0
%    (2) alpha_j >= 0 for j = 1,...,k
%    (3) beta_j  >= 0 for j = 1,...,k
%    (4) A stationary process (more constraints on all the parameters)
%    (5) The p_ij sum in colum to one 
%
% See also swgarch
%
% Copyright: Thomas Chuffart
% Mail: thomas.chuffart@univ-amu.fr
% Version: MSG_tool_Beta v2.0   Date: 30/01/2015


% Parse the parameters and if equal to 0, just add 1e-8

omega=parameters(1:k);
alpha=parameters(k+1:k*2)';
beta=parameters(k*2+1:k*3);
beta(beta==0) = 1e-8;
alpha(alpha==0) = 1e-8;
omega(omega==0) = 1e-8;

% construct the Markovian matrix

P = parameters(3*k+1:3*k+(k*k));
Pstat = reshape(P,k,k)';


if error_type == 2,
    nu = parameters(3*k+(k*k)+1);
    trans_dist=sqrt(nu-2.01);
else
    trans_dist = [];
end

% Check that the parameters satisfy the necessary constraints
if  any(alpha<0) || any(beta<0);
    error('These do not conform to the necessary set of restrictions to be transformed.')
end

    beta = diag(beta);
    for i = 1:k,
        for j = 1:k,
            e = zeros(1,k);
            e(i) = 1;
            Mtemp  = Pstat(i,j)*(beta+alpha'*e);
            Mc((i*k)-(k-1):(i*k),(j*k)-(k-1):(j*k)) = Mtemp;
        end    
    end
    if max(abs(eig(Mc))) > 1,
        error('These do not conform to the necessary set of restrictions to be transformed.')
    end


%Arbitrary uper bound, enough large to be too much restrictive
UB = ones(k,1).*1.3338;
scale = UB;
%Initialze the transformed GARCH parameters

tomega=log(omega);
alpha = alpha';
%Scale the alpha
talpha =alpha./scale;
%Use an inverse logistic
talpha=log(talpha./(1-talpha));
%Update the scale
scale=scale-alpha;
%Initialize the beta
beta = diag(beta);
%Scale the beta
tbeta=beta./scale;
%Use an inverse logistic
tbeta=log(tbeta./(1-tbeta));

%Initialze the transformed transition probability matrix
Pstat = reshape(Pstat,k,k);
tP = Pstat;

for i = 1:k,
    for j = 1:k,
        tP(j,i) = log(Pstat(i,j)/Pstat(j,j));
    end
end

% Parse the parameters

trans_garch = [tomega;talpha;tbeta];
tP = reshape(tP,k*k,1);

% Merge the parameters
trans_parameters=[tomega;talpha;tbeta;tP;trans_dist];

end
