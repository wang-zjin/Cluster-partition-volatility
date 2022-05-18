function [estimation, probabilities, diagnostics] = swgarch(data, k, error_type ,ms_type, estim_cons,startvalopt, startvalG, startvalM, startvalDist ,options)

% swgarch(k) estimation of Markov Switching GARCH models with different error distributions:
% Estimation of GARCH models if k = 1 (not implemented yet, could introduce
% some bugs. 
%
% USAGE:
%   parameters = swgarch(data,k);
%   [parameters, probabilities, diagnostics] 
%               = swgarch(data,k, error_type, ms_type, estim_cons , startvalG,startvalM, options)
%
% %%%%%%%%%%%%%%%%%%%%
%
% INPUTS
%
% %%%%%%%%%%%%%%%%%%%%
%
%   data         - a vector of zeros mean data
%   k            - Postive scalar integer representing the number of
%                  regimes
%   error_type   - [OPTIONAL] The error distribution:
%                    'NORMAL'    - Gaussian Innovations [DEFAULT]
%                    'STUDENTST' - T distributed errors 
%   ms_type      - [OPTIONAL] The type of regime switching process, either
%                    'GRAY'    - Following GRAY (JoFE 1996)  
%                    'KLAASSEN' - Following Klaassen (EE 2002)
%                    'Haas' - Following Haas & al (JoFE 2004) [DEFAULT]
%   estim_cons   - [OPTIONAL] The type of QML estimation
%                    'CONS' - fmincon will be used, constraints are
%                             computed in the function swgarch_constr
%                    'UNCONS'  - fmincun will be used, the parameters are
%                               reparametrized in order to obtain valid parameters [DEFAULT]
%   startvalopt  - [OPTIONAL] A stucture of two elements and one field. The first 
%			      element is a string taking value 'YES' if the user 
%			      provides starting values and 'NO' otherwise. The seconde 
%			      element is an empty field if 'YES' or a postitive 
%			      integer if 'NO' and represent the number of 
%			      starting values to try before starting the estimation.
%                             {'NO'; 10} by [DEFAULT].
%   startvalG    - [OPTIONAL] A k x 3 matrix with GARCH parameters:
%                             [omega_1 alpha_11 beta_11 ;
%                                       ...             ;
%                              omega_k alpha_1k beta_1k ]
%   startvalM    - [OPTIONAL] A k x k markovian matrix with colums which sum to one
%   startvalDist - [OPTIONAL] A vector of parameters depending on the
%                               distribution
%                             
%   OPTIONS      - [OPTIONAL] A user provided options structure. Default options are below.
%
% %%%%%%%%%%%%%%%%%%%%
%
% OUTPUTS
%
% %%%%%%%%%%%%%%%%%%%%
%
%   estimation      - A structure with 3 elements: 
%                       - garch: the garch parameters estimation
%                       - M: the transition probability matrix estimation
%                       - VCV: the variance covariance matrix
%                       - H: the condictional predicted variance 
%
%   probabilities   - A structure with 3 elements:
%                       - predict_proba: the predicted probabilities 
%                       - smoothed_proba: the smoothed probabilitie
%                         following Kim and Nelson's algorithm (1994)
%                       - uncond_proba: the unconditional probabilities
%
%   diagnostics     - A structure with 9 elements:
%                       - EXITFLAG
%                       - ITERATIONS
%                       - funcCount
%                       - message
%                       - scores
%                       - hess 
%                       - gross_scores
%                       - LL 
%                       - LLS
%
% 
% %%%%%%%%%%%%%%%%%%%%
%
% COMMENTS:

% %%%%%%%%%%%%%%%%%%%%
%
% The following (generally wrong) constraints are used when you use the
% UNCONS option (fmincun function)
%   (1) omega_k > 0
%   (2) alpha_j >= 0 for j = 1,...,k 
%   (3) beta_j  >= 0 for j = 1,...,k
%   (4) The Markovian matrix's columns sum to one
%   (5) Sum of alpha and beta is less than 1.38
%
% The following (generally wrong) constraints are used when you use the
% CONS option (fmincon function)
%
%   (1) The maximum eigenvalues of the matrix Mc = [M_11 M_21 ...  M_k1]
%                                                  [M_12 ...  ...  ... ]                                
%                                                  [...  ...  ...  ... ]
%                                                  [M_1k ...  ...  M_kk]
%       with M_ij = p_ij(beta + alpha x e_j') where e_j is the k x 1 unique
%       vector
%   (2) The Markovian matrix's columns sum to one
%
% %%%%%%%%%%%%%%%%%%%%
%
% The conditional variances, h(t), of a swarch(p,q,k) process is modeled as follows:
%   (1) ms_type = 1: GRAY (1996) specification 
%                       h(t) = Sum_i^k(p_i x h_i(t-1)) with
%                       h_it = omega_i + alpha_i x eps(t-1)^2 + beta_i x h_(t-1)
%                       h_it is the conditional variance of regime i at time t
%                       p_i is the probability to be in regime i at time t
%                       conditional to be information up to t-2
%   (2) ms_type = 2: Klaassen (2002) specification 
%                       h(t) = Sum_i^k(p_i x h_it) with
%                       h_it = omega_i + alpha_i x eps(t-1)^2 + beta_i x h_(t-1)
%                       h_it is the conditional variance of regime i
%                       p_i is the probability to be in regime i at time t
%                       conditional to be information up to t-1
%   (3) ms_type = 3: Haas & al (2004) specifictation 
%                       h(t) = Sum_i^k(p_i x h_it) 
%                       h(it) = [omega_1,...,omega_k]' + [alpha_1,...,
%                       alpha_k]' x eps(t-1)^2 + diag(beta_1,...,beta_k) x h(i,t-1)
%                      
% %%%%%%%%%%%%%%%%%%%%
%
%   If startvalopt is set as 'NO', the program simulate
%   the starting values as
%       Omega is random between 0.0001 and 0.2
%       Alpha is random between 0.01 and 0.3
%       Beta  is random betwenn 0.4 and 0.9 
%   If the random starting values lead to a non-stationary process, 
%   the program draw another set of starting values. 
%
% %%%%%%%%%%%%%%%%%%%%
%
%   if UNCONS option:
%       Default Options
%           options  =  optimset('fminunc');
%           options  =  optimset(options , 'TolFun'      , 1e-005);
%           options  =  optimset(options , 'TolX'        , 1e-005);
%           options  =  optimset(options , 'Display'     , 'iter');
%           options  =  optimset(options , 'Diagnostics' , 'on');
%           options  =  optimset(options , 'LargeScale'  , 'off');
%           options  =  optimset(options , 'MaxFunEvals' , '400*numberOfVariables');
%
%   if CONS options: 
%       options  =  optimset('fmincon');
%       options  =  optimset(options , 'Algorithm ','interior-point');
%       options  =  optimset(options, 'Hessian','bfgs');
%       options  =  optimset(options , 'TolFun'      , 1e-006);
%       options  =  optimset(options , 'TolX'        , 1e-006);
%       options  =  optimset(options , 'TolCon'      , 1e-006);
%       options  =  optimset(options , 'Display'     , 'iter');
%       options  =  optimset(options , 'Diagnostics' , 'on');
%       options  =  optimset(options , 'LargeScale'  , 'off');
%       options  =  optimset(options , 'MaxIter'     , 1500);
%       options  =  optimset(options , 'Jacobian'     ,'off');
%       options  =  optimset(options , 'MeritFunction'     ,'multiobj');
%       options  =  optimset(options , 'MaxFunEvals' , 3000);
%
%  See also swarch_likelihood, swarch_core, swarch_parameter_check, swarch_starting_values,
%  swarch_transform, swarch_itransform, swgarch_constr
%
% %%%%%%%%%%%%%%%%%%%%
%
% Copyright: Thomas Chuffart
% Inspired by the work of Kevin Sheppard and the MFET toolbox
% thomas.chuffart@univ-amu.fr
% Version: MSG_tool_Beta v3.0   Date: 30/01/2015
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input Checking
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch nargin 
    case 2
        [k,error_type,ms_type,estim_cons,startvalopt,startval,options]=swgarch_parameters_check(data,k);
    case 3
        [k,error_type,ms_type,estim_cons,startvalopt,startval,options]=swgarch_parameters_check(data,k, error_type);
    case 4
        [k,error_type,ms_type,estim_cons,startvalopt,startval,options]=swgarch_parameters_check(data,k,error_type,ms_type);
    case 5
        [k,error_type,ms_type,estim_cons,startvalopt,startval,options]=swgarch_parameters_check(data,k,error_type,ms_type,estim_cons);
    case 6
        [k,error_type,ms_type,estim_cons,startvalopt,startval,options]=swgarch_parameters_check(data,k,error_type,ms_type,estim_cons,startvalopt);
    case 7
        [k,error_type,ms_type,estim_cons,startvalopt,startval,options]=swgarch_parameters_check(data,k,error_type,ms_type,estim_cons,startvalopt,startvalG);
    case 8 
        [k,error_type,ms_type,estim_cons,startvalopt,startval,options]=swgarch_parameters_check(data,k,error_type,ms_type,estim_cons,startvalopt, startvalG,startvalM);
    case 9 
        [k,error_type,ms_type,estim_cons,startvalopt,startval,options]=swgarch_parameters_check(data,k,error_type,ms_type, estim_cons, startvalopt, startvalG,startvalM,startvalDist);
    case 10 
        [k,error_type,ms_type,estim_cons,startvalopt,startval,options]=swgarch_parameters_check(data,k,error_type,ms_type, estim_cons, startvalopt,startvalG,startvalM, startvalDist, options);
    otherwise
        error('Number of inputs must be between 2 and 10');
end
      options.Display="off";
      options.Diagnostics="off";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Size 

data_augmented=[zeros(1,1) ; data];
T = size(data_augmented,1);

%Starting values

if isempty(startval)
    startingflag=0;
else
    startingflag=1;
end

%Initialization of starting values

[garch_startval,M,dist_startval]=swgarch_starting_values(startval,data_augmented,k,T,error_type,ms_type,startvalopt);
startval = [garch_startval; M; dist_startval];

%Transform the starting values
%LL0 is used to make sure the log likelihood improves

if estim_cons == 1
    tParameters = swgarch_trans(startval,k,error_type,ms_type);
    LL0=swgarch_likelihood(tParameters,data_augmented,k,error_type,ms_type,T,1);  
    [parameters,LL,exitflag,output]=fminunc('swgarch_likelihood',tParameters,options,data_augmented,k,error_type,ms_type,T,1);
    
else
    LL0=swgarch_likelihood(startval,data_augmented,k,error_type,ms_type,T,0); 
    LB = [zeros(1,length(garch_startval)+length(M)) 2*ones(length(dist_startval))];
    UB = [];
    A = [];
    bt = []; 
    Aeq = [];
    beq = [];
    [parameters,LL,exitflag,output] = fmincon(@(x) swgarch_likelihood(x, data_augmented, k, error_type, ms_type, T, 0),startval,A,bt,Aeq,beq,LB,UB,@(x) swgarch_constr(x,k),options);     
end    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Estimation Robustness
%   This portion of the code is to make sure that the optimization converged
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if LL < LL0 && exitflag<=0
    %Try more iterations, only do more iterations if the final likelihood is
    %actually better than the initial
    %Increase the max iterations and max fun evals
    if ischar(options.MaxFunEvals)
        options.MaxIter=2*100*length(parameters);
    else
        options.MaxIter=2*options.MaxIter;
    end
    if ischar(options.MaxFunEvals)
        options.MaxFunEvals=4*100*length(parameters);
    else
        options.MaxFunEvals=2*options.MaxFunEvals;
    end   
    options.HessUpdate='steepdesc';
    if estim_cons == 1
        [parameters,LL,exitflag,output]=fminunc('swgarch_likelihood',parameters,options,data_augmented,k,error_type,ms_type,T,1);  
    else
        [parameters,LL,exitflag,output] = fmincon(@(x) swgarch_likelihood(x, data_augmented, k, error_type, ms_type, T, 0),startval,A,bt,Aeq,beq,LB,UB,@(x) swgarch_constr(x,k),options);             
    end
end

if startingflag==0 && exitflag<=0
    m = input('The estimation has not converge yet, do you want to try other starting values? If yes, how much? Enter a positive scalar. 0 if you do not want. ');
    if (length(m) > 1) || any(m <  0) || isempty(m)
        error('Your input must be a positive scalar or you should provide good starting values.')
    elseif m == 0
        error('Program will stop here');    
    end      
    %Keep track of the final estimates, if nothing converges
    robust_parameters(1,:)=parameters';
    robust_LL = zeros(2,1);
    robust_LL(1) = LL;
    index=2;
    while exitflag<=0 && m > 0
        %This condition checks that we haven't converged
        %OR that the best objective is worse than best grid search
        %Sort the original grid search log likelihoods and parameters
        startval = [];
        [garch_startval,M,dist_startval] = swgarch_starting_values(startval,data,k,T,error_type,ms_type,startvalopt);
        startval = [garch_startval; M; dist_startval];        
        trans_parameters = swgarch_trans(startval,k,error_type, ms_type);       
        LL0=swgarch_likelihood(trans_parameters,data_augmented,k,error_type,ms_type,T,1);
        options.HessUpdate='bfgs';
        if estim_cons == 1
            [parameters,LL,exitflag,output]=fminunc('swgarch_likelihood',trans_parameters,options,data_augmented,k,error_type,ms_type,T,1);
        else
            [parameters,LL,exitflag,output] = fmincon(@(x) swgarch_likelihood(x, data_augmented, k, error_type, ms_type, T, 0),startval,A,bt,Aeq,beq,LB,UB,@(x) swgarch_constr(x,k),options);             
        end
        if  exitflag<=0 && LL<LL0
            %Again, if the LL improved, try more iterations
            %Increase the max iterations and max fun evals
            options.MaxIter=2*options.MaxIter;
            options.MaxFunEvals=2*options.MaxFunEvals;
            options.HessUpdate='steepdesc';
            if estim_cons == 1
                [parameters,LL,exitflag,output]=fminunc('swgarch_likelihood',trans_parameters,options,data_augmented,k,error_type,ms_type,T,1);
            else
                [parameters,LL,exitflag,output] = fmincon(@(x) swgarch_likelihood(x, data_augmented, k, error_type, ms_type, T, 0),startval,A,bt,Aeq,beq,LB,UB,@(x) swgarch_constr(x,k),options);             
            end
        end
        robust_parameters(index,:)=parameters';
        robust_LL(index)=LL;
        index=index+1;       
        if index> m
            warning('Convergence not achieved. Use results with caution');
            [~,index]=min(robust_LL);
            parameters=robust_parameters(index,:)';
            break
        end
    end
end

if estim_cons == 1
    parameters = swgarch_itransform(parameters,k,error_type);
end

paramG = reshape(parameters(1:3*k),k,3);
M = reshape(parameters(3*k+1:3*k+(k*k)),k,k);
[LL, LLS, H,predict_proba, filtered_proba] = swgarch_likelihood(parameters,data_augmented,k,error_type,ms_type,T,0);
smoothed_proba(T,:) = predict_proba(T,:);

for t = 1:(T-1)
smoothed_proba(T-t,:) = predict_proba(T-t,:).*((smoothed_proba(T-t+1,:)./filtered_proba(T-t+1,:))*M);
end

probabilities.smooth = smoothed_proba;
probabilities.predict = predict_proba;

[VCVr,A,B,scores,hess]=robustvcv('swgarch_likelihood',parameters,0,data_augmented,k, error_type, ms_type, T, 0);
VCV=hess^(-1)/(T-1);
estimation.garch = paramG;
estimation.transM = M;
estimation.VCV = VCV;
estimation.VCVr = VCVr;
estimation.H = H;
diagnostics.EXITFLAG=exitflag;
diagnostics.ITERATIONS=output.iterations;
diagnostics.FUNCCOUNT=output.funcCount;
diagnostics.MESSAGE=output.message;
diagnostics.scores = scores;
diagnostics.hess = hess;
diagnostics.LL = LL;
diagnostics.LLS = LLS;
diagnostics.VCV = VCV;
if error_type ~= 1
    estimation.other = parameters(end);
end

