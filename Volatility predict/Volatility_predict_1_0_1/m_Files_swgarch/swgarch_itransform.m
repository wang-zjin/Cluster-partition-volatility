function trans_parameters = swgarch_itransform(parameters,k,error_type)

% swgarch(k) inverse parameter transformation.  Used to map parameters from
% the real line to a set of parameters appropriate for a swgarch model.
% Used in the estimation of swgarch.
%
% USAGE:
%   trans_parameters = swgarch_itransform(parameters,k,error_type)
%
% INPUTS:
%   PARAMETERS       - Column parameter vector
%   k             - The number of regimes
%
% OUTPUTS:
%   trans_parameters - A 3 x k + k x k column vector of parameters with
%                      [omega_1, ...,omega_k ,alpha_1, ... , alpha_k, beta_1, ... ,beta_k]'
%
% COMMENTS:
%   Output parameters satisfy:
%    (1) omega > 0
%    (2) alpha_j >= 0 for j = 1,2,...,k
%    (3) beta_j  >= 0 for i = 1,2,...,k
%
% See also swgarch

% Copyright: Thomas Chuffart
% thomas.chuffart@univ-amu.fr
% Version: MSG_tool_Beta v2.0   Date: 30/01/2015

%Upper constraint to make sure that there is no overflow
parameters(parameters>100)=100;

%Parse the parameters
omega=parameters(1:k);
alpha=parameters(k+1:k*2);
beta=parameters(k*2+1:k*3);
P = parameters(3*k+1:3*k+(k*k));

if error_type==2,
    %Square here
    tnu=parameters(3*k+(k*k)+1);
    tnu=2.01+tnu^2;
else
    tnu = [];
end
%Simple transform of the GARCH transformed parameters
%Upper bound of transform
UB = ones(k,1).*1.3338;
UBp = ones(k,1).*0.999999;
%Simple transform of omega
tomega=exp(omega);

%Initialize the transformed parameters
talpha=alpha;
tbeta=beta;

%Set the scale
scale=UB;
%Alpha is between 0 and scale
talpha=0.000001 + (exp(talpha)/(1+exp(talpha)))*(scale-0.000001);
%Update the scale
scale=scale-talpha;
%Beta is between 0 and scale
tbeta=0.000001 + (exp(tbeta)/(1+exp(tbeta)))*(scale-0.000001);


% Transform of the transformed transition matrix parameters
P =  reshape(P,k,k);
tP = P;
for i = 1:k,
    scale = UBp;
    for j = 1:k,
        if j == i,
            tP(j,i) = (1/(1+(sum(exp(P(:,j)))-exp(P(i,j))))) * scale(j)-0.000001;
        else
            tP(i,j) = (exp(P(i,j))/(1+(sum(exp(P(:,j)))-exp(P(j,j))))) * scale(j)-0.000001;
        end
        scale(j) = scale(j) - tP(i,k); 
    end
end

tP = reshape(tP,k*k,1);

%Merge the transformed parameters.
trans_parameters=[tomega;talpha;tbeta;tP;tnu];

end

