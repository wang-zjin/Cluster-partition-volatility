function datasim = swgarch_sim(dim,k,parameters,M,ms_type,error_type,param_dist,fig)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Purpose: 
%   This function simulates Markov-Switching Klaassen (2002) 
%   and Haas & al (2004) with Gaussian or Student innovations. 
%   It generates 1000 observations in more for reducing any bias. 
%
% INPUTS:
%   dim             - length of the process
%   k               - the number of regime
%   parameters      - k x 3 matrix with GARCH parameters:
%                             [omega_1 alpha_11 beta_11 ;
%                                       ...             ;
%                              omega_k alpha_1k beta_1k ]
%   M               - k x k markovian matrix with colums which
%                             sum to one
%   ms_type         - [OPTIONAL] The type of regime switching process, either  
%                       'DEP' - the conditional variance regime of the current state depend on
%                       the conditional variance regime of the previous state
%                       'INDEP' - the conditional variance specific regimes
%                       are independant i.e. if a switch occurs, wo move
%                       directly and entierely in the new regime.
%   error_type      - [OPTIONAL] The error distribution:
%                       'NORMAL'    - Gaussian Innovations [DEFAULT]
%                       'STUDENTST' - T distributed errors 
%   param_dist      - [OPTIONAL] The parameter of the choosen distribution.
%                       Could be empty if 'NORMAL', a scalar if
%                       'STUDENTST'.
%   fig             - [OPTIONAL] A boolean, if fig = 1 [DEFAULT], the
%                       function returns the graphics of the simulated time series.
%
% OUTPUTS:
%   datasim    - A structure continaing five elements:
%       vH          - vector dim x 1 of the overall conditional variance 
%       mH          - matrix dim x k representing the regime specific conditional variances
%       mS          - matrix dim x k representing the true state of the nature 
%       vE          - vector dim x 1 of the residuals simulated    
%
% COMMENTS:
%   See also swgarch for estimation
%
% Copyright: Thomas Chuffart
% thomas.chuffart@univ-amu.fr
% Version: MSG_tool_Beta v4.0   Date: 30/06/2015
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Checkin' 

if nargin < 4
    error('You have forgotten some input');
end

%%%%%%%%%%%%%%%
% dim
%%%%%%%%%%%%%%%

if length(dim)>1 || dim <0
    error('dim has to be a scalar greater than 0');
end

%%%%%%%%%%%%%%%
% k
%%%%%%%%%%%%%%%

if (length(k) > 1) || any(k <  1) || isempty(k)
    error('k must be positive scalar.')
end

%%%%%%%%%%%%%%%
% parameters
%%%%%%%%%%%%%%%


if ~isempty(parameters)
    %Validate starting vals of GARCH parameters       
    if  sum((size(parameters) == [k 3])) ~= 2
        error(['parameters must be a matrix ', num2str(k),' x ', num2str(3)]);
    end      
    if any(parameters<=0)
        error('All parameters must be strictly greater than zero');
    end
end



if ~isempty(M)
    %Validate starting vals of the Markovian Matrix       
    if  sum((size(M) == [k k])) ~= 2 
        error(['M must be a matrix ', num2str(k),' x ', num2str(k)]);
    end
    if any(reshape(M,k*k,1)<=0) || any(reshape(M,k*k,1) >= 1)
        error('All single element of M must be strictly greater than zero and below than one');
    end 
end


%%%%%%%%%%%%%%%
% ms_type
%%%%%%%%%%%%%%%

if nargin<5
    ms_type='INDEP';
end

if isempty(ms_type)
    ms_type='INDEP';
end

if strcmp(ms_type,'DEP')
    ms_type = 1;
elseif strcmp(ms_type,'INDEP')
    ms_type = 2;
else
    error('ms_type must be a string and one of: ''INDEP'', ''DEP''.');
end


%%%%%%%%%%%%%%%
% error_type
%%%%%%%%%%%%%%%

if nargin<6
    error_type='NORMAL';
end

if isempty(error_type)
    error_type='NORMAL';
end

if strcmp(error_type,'NORMAL')
    error_type = 1;
elseif strcmp(error_type,'STUDENTST')
    error_type = 2;
else
    error('error_type must be a string and one of: ''NORMAL'', ''STUDENTST''.');
end

%%%%%%%%%%%%%%%
% param_dist
%%%%%%%%%%%%%%%

if nargin<7
    switch error_type
        case 1
            param_dist = [];
        case 2
            param_dist = 5;
    end
end

if error_type == 2
    if (length(param_dist) > 1) || any(param_dist <  2) || isempty(param_dist)
        error('param_dist must be greater than 2.')
    end
end


%%%%%%%%%%%%%%%
% fig
%%%%%%%%%%%%%%%

if nargin<8
    fig = 1; 
end

if fig ~= 1 && fig ~= 0
    error('fig should be equal to 0 or 1.')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% since all parameters are ok, check the stationarity 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x = [reshape(parameters,k*3,1); reshape(M,k*k,1)];
if swgarch_constr(x,k) > 0
    error('The model is not stationary with these starting values');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


maxi = 1;
T = dim+10000; 
states = zeros(T,k); 
states(1,1) = 1; 

switch error_type
    case 1
        n = randn(T,1);
    case 2      
        n = trnd(param_dist,T,1);
end

h = zeros(T,k);
h(1,:) = 1; 
H = zeros(T,1);
simulatedEpsi = zeros(T,1); 
paraGarch = parameters(1:k,1:end);

switch ms_type
    case 1
        states = markovSim(T,M);
        for t = maxi+1:T
            i = find(states(t,:));
            h(t) = paraGarch(i,:) * [1;simulatedEpsi(t-1)'.^2 ; h(t-1)];
            simulatedEpsi(t) = n(t)*sqrt(h(t));
        end
        H = h(maxi+10000:T,1);
        simulatedEpsi =  simulatedEpsi(maxi+10000:T);
        states = states(maxi+10000:T,:); 
    case 2           
        states = markovSim(T,M);        
        for t = maxi+1:T
            for i = 1:k
                h(t,i) = paraGarch(i,:) * [1;simulatedEpsi(t-1)'.^2;h(t-1,i)] ; 
            end
            i = find(states(t,:));
            simulatedEpsi(t) = n(t)*sqrt(h(t,i)); 
        end
        H =states.*h; 
        for j = 1:T
            if H(j,1) == 0
                H(j,1) = H(j,2);
            end
        end
        H = H(10000+maxi:T,1);
        simulatedEpsi =  simulatedEpsi(10000+maxi:T);
        states = states(10000+maxi:T,:); 
        h = h(10000+maxi:T,:);
end

datasim.vH = H;
datasim.vE = simulatedEpsi;
datasim.mS = states;
datasim.mH = h;

if fig == 1
    figure(1)
    subplot(3,1,1);
    plot(simulatedEpsi,'-r'); hold on
    plot(H,'-b'); hold off
    xlabel('time');
    legend('Residuals','Conditional volatility');
    subplot(3,1,2);
    plot(simulatedEpsi,'-b');
    xlabel('time');
    legend('Residuals');
    subplot(3,1,3);
    plot(H,'-b');
    xlabel('time');
    legend('Conditional volatility');
end

end

