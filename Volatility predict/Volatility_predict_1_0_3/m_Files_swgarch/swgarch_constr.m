function [c, ceq] = swgarch_constr(x,k)

% swgarch(k) constraints.
%    function to compute the stationarity constraint of a MS-GARCH
%    model and the constraints on the Markovian matrix
%
% USAGE:
%   [c, ceq] = swgarch_constr(x,k)
%
% INPUTS:      - x the vector of parameters 
%              - k the number of regimes
%              - nbcgtot: the number of GARCH parameters 
%
% OUTPUTS: - c inequality constraints
%
% See also swgarch
%
% Author: Thomas Chuffart
% Mail: thomas.chuffart@univ-amu.fr
% Version: MSG_tool_Beta v2.0 Date: 30/01/2015

alpha = x(k+1:k*2);
beta = x(k*2+1:k*3);
dbeta = diag(beta);
M = reshape(x(k*3+1:k*3+k*k),k,k);

for i = 1:k,
    for j = 1:k,
        e = zeros(1,k);
        e(i) = 1;
        Mtemp  = M(i,j)*(dbeta+alpha*e);
        Mc((i*k)-(k-1):(i*k),(j*k)-(k-1):(j*k)) = Mtemp;
    end    
end
c = max(abs(eig(Mc)))-1;

ceq = sum(M,1)'-1;   

end
    