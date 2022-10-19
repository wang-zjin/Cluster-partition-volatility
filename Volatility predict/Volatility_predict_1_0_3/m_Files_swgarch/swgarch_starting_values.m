function [garch_startval,M,dist_startval,LLf]=swgarch_starting_values(startval,data,k,T,error_type,ms_type,startvalopt)

% If starting values are user supplied (and thus nonempty), reformats
% as vectors. 
% If not, ask the user a number of starting values he wants
% to try. Then, the function drawn randomnly these vectors of starting
% values and returns the most decent one. 
%
% USAGE:
%   [garch_startval,M,LLf] = swgarch_starting_values(startval,data,k,T,error_type,ms_type)
%
% INPUTS:
%   startval         - A vector of starting values or empty if the user wants them to be random   
%   data             - Vector of mean zero residuals
%   k                - The number of regimes
%   T                - Length of data
%   error_type       - The type of error being assumed, valid types are:
%                        1 if 'NORMAL'
%                        2 if 'STUDENTST' [NOT IMPLEMENTED YET]
%
%   ms_type          - 1 for 'GRAY'     [NOT IMPLEMENTED YET]
%                    - 2 for 'KLAASSEN'
%                    - 3 for 'HAAS'
%  startvalopt       - A vector of two integer The first element has to be equal to 0 or 1, 
%		       the second is a positive interger 
%
% OUTPUTS:
%   garch_startval    - A vector 3 x k by 1 of starting values for the GARCH parameters 
%   M                 - A vecto of k x k starting values for the transition
%                       matrix probabilities
%   LLf               - A vector of log likelihoods 
%
% COMMENTS:
%   See also swgarch
%
% Copyright: Thomas Chuffart
% thomas.chuffart@univ-amu.fr
% Version: MSG_tool_Beta v2.0   Date: 30/01/2015


%No starting values provided
if startvalopt(1),
    count = 0;
    m = startvalopt(2);
    switch error_type
        case 1
            startvaltemp = zeros(3*k + k*k,m);
        case 2
            startvaltemp = zeros(3*k + k*k +1,m);
    end    
    LL = zeros(m,1);
    while count ~= m,
% Random simulation of bounding parameters 
% - Omega belong to the interval 0.0001 and 0.2
% - Alpha belong to the interval 0.01 and 0.3
% - Beta belong to the interval 0.4 and 0.9
        omega = 0.15*rand(k,1);
        alpha = 0.1+0.2*rand(k,1);
        beta = 0.4 + 0.5*rand(k,1);
        M = rand(k,k);
        colSums = sum(M,1);
        normalizingM = repmat(colSums,k,1);
        M = M./normalizingM;
        if error_type == 2,
            dist_startval = 2+10*rand(1,1);
        else
            dist_startval = [];
        end
% Stationnarity check 
        x = [omega ; reshape(alpha,k,1) ; reshape(beta,k,1) ; reshape(M,k*k,1)];
        if swgarch_constr(x,k) < 0
        % If stationary, implement count, if not, do nothing
            count = count+1;
            startvaltemp(:,count) = [omega ; alpha ; beta ; reshape(M,k*k,1);dist_startval];             
            LL(count) = swgarch_likelihood(startvaltemp(:,count), data, k, error_type, ms_type, T,0);
        end       
    end 
    [~, index] = min(LL);
    startval = startvaltemp(:,index);  
    LLf = min(LL);
end
%Parse starting values
garch_startval=startval(1:3*k);
M = startval(3*k+1:3*k+k*k);
if error_type == 2,
   dist_startval = startval((3*k)+(k*k)+1);
else
   dist_startval = [];
end

end

