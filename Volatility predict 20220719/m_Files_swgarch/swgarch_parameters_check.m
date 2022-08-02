function [k,error_type,ms_type,estim_cons,startvalopt,startval,options] = swgarch_parameters_check(data,k,error_type,ms_type,estim_cons,startvalopt,startvalG,startvalM,startvalDist,options)

% swarch(k) input validation.  Ensures that the input parameters are
% conformable to what is expected.
%
% USAGE:
%   [k,error_type,ms_type,estim_cons,startvalopt,startval,options] =
%           swgarch_parameters_check(data,k,error_type,ms_type,estim_cons,startvalopt,startvalG,startvalM,options)
%
% INPUTS:
%   See swgarch.
%
% OUTPUTS:
%   See swgarch.
%
% COMMENTS:
%   See also swgarch

% Copyright: Thomas Chuffart
% Mail: thomas.chuffart@univ-amu.fr
% Version: MSG_tool_Beta v2.0   Date: 30/01/2015

%%%%%%%%%%%%%%%
% data
%%%%%%%%%%%%%%%

if size(data,2) > 1 || length(data)==1
    error('data series must be a column vector.')
elseif isempty(data)
    error('data is empty.')
end

%%%%%%%%%%%%%%%
% k
%%%%%%%%%%%%%%%

if (length(k) > 1) || any(k <  1) || isempty(k)
    error('k must be positive scalar.')
end

%%%%%%%%%%%%%%%
% error_type
%%%%%%%%%%%%%%%

if nargin<3
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
% ms_type
%%%%%%%%%%%%%%%

if nargin<4
    ms_type='HAAS';
end

if isempty(ms_type)
    ms_type='HAAS';
end

if strcmp(ms_type, 'GRAY')
    ms_type = 1;
elseif strcmp(ms_type,'KLAASSEN')
    ms_type = 2;
elseif strcmp(ms_type,'HAAS')
    ms_type = 3;
else
    error('ms_type must be a string and one of: ''HAAS'', ''KLAASSEN''.');
end

%%%%%%%%%%%%%%%
% estim_cons
%%%%%%%%%%%%%%%

if nargin<5
    estim_cons='UNCONS';
end
if isempty(estim_cons)
    estim_cons='UNCONS';
end

if strcmp(estim_cons,'UNCONS')
    estim_cons = 1;
elseif strcmp(estim_cons,'CONS')
    estim_cons = 2;
else
    error('estim_cons must be a string and one of: ''UNCONS'', ''CONS''.');
end


%%%%%%%%%%%%%%%%%
% starting values
%%%%%%%%%%%%%%%%%
if nargin<6
    startvalopt = {'NO',10};
end
if isempty(startvalopt)
    startvalopt = {'NO',10};
end

if strcmp(startvalopt{1},'YES')
    startvalopt = [0,0];
else
    startvalopt = [1,startvalopt{2}];
end

% Starting values GARCH parameters

if nargin>6
    if ~isempty(startvalG)
        %Validate starting vals of GARCH parameters
        if  sum((size(startvalG) == [k 3])) ~= 2
            error(['startvalG must be a matrix ', num2str(k),' x ', num2str(3)]);
        end
        startval = reshape(startvalG,3*k,1);
        if any(startval<=0)
            error('All startingvals for omega, alpha and beta must be strictly greater than zero');
        end
    else
        startval=[];
    end
else
    startval=[];
end

% Starting values transition matrix

if nargin>7
    if ~isempty(startvalM)
        %Validate starting vals of transition probabilities
        if  sum((size(startvalM) == [k k])) ~= 2
            error(['startvalM must be a matrix ', num2str(k),' x ', num2str(k)]);
        end
        startvalMv = reshape(startvalM,k*k,1);
        if any(startvalMv<=0) || any(startvalMv >= 1)
            error('All single element of M must be strictly greater than zero and below than one');
        end
        startval = [startval ; startvalMv];
    else
        startval=[];
    end
else
    startval=[];
end

if nargin>8
    if ~isempty(startvalDist) && error_type == 2
        %Validate starting vals of Student parameters
        if (length(startvalDist) > 1) || any(startvalDist <  1)
            error('startvalDist = Nu, the student parameters must be positive scalar.')
        end
        startval = [startval ; startvalDist];
        else
        startval=[];
    end
end

if isempty(startval) && (startvalopt(1) == 0)
    startvalopt = [1,10];
    fprintf('The starting values option and the starting values are not coherent. The estimation continues with random starting values.');
end

% Starting values Check stationarity

if ~isempty(startval)
    omega = startval(1:k);
    alpha = startval(k+1:k*2);
    beta = startval(k*2+1:k*3);
    x = [omega ; alpha ; beta ; startvalMv];
    if swgarch_constr(x,k) > 0
        error('The model is not stationary with these starting values');
    end
end

if nargin>9 &&	~isempty(options)
    try
        optimset(options);
    catch
        error('options is not a valid minimization option structure');
    end
elseif estim_cons == 1
    options  =  optimset('fminunc');
    options  =  optimset(options , 'TolFun'      , 1e-005);
    options  =  optimset(options , 'TolX'        , 1e-005);
    options  =  optimset(options , 'Display'     , 'iter');
    options  =  optimset(options , 'Diagnostics' , 'on');
    options  =  optimset(options , 'LargeScale'  , 'off');
    options  =  optimset(options , 'MaxFunEvals' , 3000);
else
    options  =  optimset('fmincon');
    options  =  optimset(options , 'Algorithm ','interior-point');
    options  =  optimset(options, 'Hessian','lbfgs');
    options  =  optimset(options , 'TolFun'      , 1e-008);
    options  =  optimset(options , 'TolX'        , 1e-008);
    options  =  optimset(options , 'TolCon'      , 1e-008);
    options  =  optimset(options , 'Display'     , 'iter');
    options  =  optimset(options , 'Diagnostics' , 'on');
    options  =  optimset(options , 'LargeScale'  , 'off');
    options  =  optimset(options , 'MaxIter'     , 1000);
    options  =  optimset(options , 'Jacobian'     ,'off');
    options  =  optimset(options , 'MeritFunction'     ,'multiobj');
    options  =  optimset(options , 'MaxFunEvals' , 3000);
end




