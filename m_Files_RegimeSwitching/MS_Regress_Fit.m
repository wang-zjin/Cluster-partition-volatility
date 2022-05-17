% Function for estimation of a general Markov Switching regression
%
%   Input:  dep     - Dependent Variable (vector (univariate model) or matrix (multivariate) )
%           indep   - Independent variables (explanatory variables), should
%                     be cell array in the case of multivariate model (see examples).
%           k       - Number of states (integer higher or equal to 2)
%           S       - This variable controls for where to include a Markov Switching effect.
%                     See pdf file for details.
%           advOpt  - A structure with advanced options for algorithm.
%                     See pdf file for details.
%
%   Output: Spec_Output - A structure with all information regarding the
%                         model estimated from the data (see pdf for details).
%
%   Author: Marcelo Perlin (UFRGS/BR)
%   Contact:  marceloperlin@gmail.com

function [Spec_Output]=MS_Regress_Fit(dep,indep,k,S,advOpt)

% build nargin withing script (Mathworks you suck!)
my_nargin = nargin();

% Error checking lines
checkInputs(); % checking if inputs variables are OK

% Error checking lines

if nargin<4
    error('The function needs at least 4 arguments');
end

if nargin==4    % Default values when advOpt is not an input
    advOpt.distrib='Normal';
    advOpt.std_method=1;
    advOpt.useMex=0;
    advOpt.diagCovMat=1;
    advOpt.printOut=1;
    advOpt.printIter=1;
    advOpt.doPlots=1;
    advOpt.optimizer='fminsearch';

else    % checking inputs of advOpt
    
    if isfield(advOpt,'distrib')==0
        advOpt.distrib='Normal';
    end

    if isfield(advOpt,'printOut')==0
        advOpt.printOut=1;
    end

    if isfield(advOpt,'printIter')==0
        advOpt.printIter=1;
    end

    if isfield(advOpt,'doPlots')==0
        advOpt.doPlots=1;
    end

    if isfield(advOpt,'std_method')==0
        advOpt.std_method=1;
    end
       
    if isfield(advOpt,'diagCovMat')==0
        advOpt.diagCovMat=1;
    end

    if isfield(advOpt,'useMex')==0
        advOpt.useMex=0;
    end
    
    if isfield(advOpt,'optimizer')==0
        advOpt.optimizer='fminsearch';
    end
    
end

% copying some values for easier handling

distrib=advOpt.distrib;
std_method=advOpt.std_method;
useMex=advOpt.useMex;

if useMex~=1&&useMex~=0
    error('The input advOpt.useMex only take values 1 or 0');
end

% options 3 and 4 excluded (until equations are verified)

% if ~any(std_method==[1 2 3 4])
%     error('The input advOpt.std_method should be 1, 2, 3 or 4, only.');
% end

if ~any(std_method==[1 2])
    error('The input advOpt.std_method should be 1, 2, only.');
end

if strcmp(distrib,'Normal')==0&&strcmp(distrib,'t')==0&&strcmp(distrib,'GED')==0
    error('The distrib input should be ''Normal'', ''t'' or ''GED''');
end

if ~any(strcmp(advOpt.optimizer,{'fmincon','fminsearch','fminunc'}))
    error('The input advOpt can either be ''fminsearch'', ''fmincon'' or ''fminunc''.');
end

nEq=size(dep,2);

if iscell(dep)
    dep=cell2mat(dep);
end

if ~iscell(indep)
    temp=indep;
    clear indep;
    for iEq=1:nEq
        indep{iEq}=temp;
    end
end

if ~iscell(S)
    temp=S;
    clear S;
    for iEq=1:nEq
        S{iEq}=temp;
    end
end

if size(dep,2)>1    % flag for multivariate switching model
    mvFlag=1;
else
    mvFlag=0;
end

if mvFlag
    if ~strcmp('Normal',distrib)
        error('So far, in the multivariate version (size(dep,2)>1), the package only handles the multivariate normal distribution. Please set advOpt.distrib=''Normal''.')
    end

    if numel(indep)~=nEq
        error('For a multivariate model, the size of cell indep should match the number of columns in dep.')
    end

    if numel(S)~=nEq
        error('For a multivariate model, the size of cell S should match the number of columns in dep.')
    end
end

for iEq=1:nEq
    switch distrib
        case 'Normal'
            n_dist_param=1; % Number of distributional parameters
            S_Var{iEq}=S{iEq}(end);     % if model switches in variance
            S_df{iEq}=0;                % flag for S_df (NOT USED, keep for simplicity of algorithm)
            S_K{iEq}=0;                 % flag for S_K (NOT USED, keep for simplicity of algorithm)
        case 't'
            S_Var{iEq}=S{iEq}(end-1);   % if model switches in variance
            S_df{iEq}=S{iEq}(end);      % if model is switching in degrees of freedom
            S_K{iEq}=0;
            n_dist_param=2; % Number of distributional parameters
        case 'GED'
            S_Var{iEq}=S{iEq}(end-1);
            S_K{iEq}=S{iEq}(end);     % if model is switching in K parameter (K as the GED parameter)
            S_df{iEq}=0;
            n_dist_param=2; % Number of distributional parameters
    end
end

if ~any([numel(indep)==nEq numel(S)==nEq])
    error('The number of elements in cell arrays indep and S should equal to the number of columns in dep.')
end

if k<2
    error('k should be an integer higher than 1. If you trying to do a linear regression, check Matlab statistical toolbox.') ;
end

for i=1:nEq
    
    if any(isnan(dep))
        [idx1 idx2]=find(isnan(dep));
        error(sprintf('NaN values found for row #%i, column #%i of dep matrix.\n',idx1(1),idx2(1)));
    end
    
    if any(isinf(dep))
        [idx1 idx2]=find(isinf(dep));
        error(sprintf('Inf values found for row #%i, column #%i of dep matrix.',idx1(1),idx2(1)));
    end
       
    if any(isnan(indep{i}))
        [idx1 idx2]=find(isnan(indep{i}));
        error(sprintf('NaN values found for row #%i, column #%i of indep matrix %i.',idx1(1),idx2(1),i));
    end
    
    if any(isinf(indep{i}))
        [idx1 idx2]=find(isinf(indep{i}));
        error(sprintf('Inf values found for row #%i, column #%i of indep matrix %i.',idx1(1),idx2(1),i));
    end
    
    if size(indep{i},1)~=size(dep,1)
        error('The number of rows in any cell in indep should be equal to the number of rows in dep.')
    end

    if (size(S{i},2))~=(size(indep{i},2)+n_dist_param)
        error('The number of elements in any cell in S should be equal to the number of elements in S, plus one (the variance flag). Check pdf manual for details.')
    end

    if sum((S{i}==0)+(S{i}==1))~=size(S{i},2)
        error('The S input should have only 1 and 0 values (those tell the function where to place markov switching effects)') ;
    end

    if sum(S{i})==0
        error('The S input should have at least one value 1 in each equation (something must switch states).') ;
    end
end

% building constCoeff for the cases when it is not specified

build_constCoeff();

% checking if all fields are specified and make sense

check_constCoeff();

% checking sizes of fields in constCoeff

checkSize_constCoeff();

% Pre calculations before calling the optimizer

preCalc_MSModel();

% Initialization of optimization algorithm

warning('off');

options=optimset('fmincon');
options=optimset(options,'display','off');

dispOut=advOpt.printIter;

% Defining linear contraints in model

A=[];   % inequality constrain (not used)
b=[];   % inequality constrain (not used)

% equality constraint (each collum of Coeff.p must sum to 1)

beq=ones(k,1);  
Aeq=zeros(k,numel(param0));

for i=1:k
    idx=Coeff_Tag.p(:,i);
    
    for j=1:numel(idx)
        if idx(j)==0
            continue;
        else
            Aeq(i,idx(j))=1;
        end
    end
    
end

for i=1:k
    if all(Aeq(i,:)==0)
        Aeq(i,:)=0;    % fixing equality restrictions for when using contrained estimation in Coeff.p
        beq(i,:)=0;
    end
end

param0=param0'; % changing notation for param0

% Call to optimization function

switch advOpt.optimizer
    case 'fminsearch'
        options=optimset('fminsearch');
        options=optimset(options,'display','off');
        options=optimset(options,'MaxIter',500*numel(param0));
        options=optimset(options,'MaxFunEvals',500*numel(param0));
        
        [param]=fminsearch(@(param)MS_Regress_Lik(dep,indep_nS,indep_S,param,k,S,advOpt,dispOut),param0,options);
        
    case 'fminunc'
        options=optimset('fminunc');
        options=optimset(options,'display','off');
        [param]=fminunc(@(param)MS_Regress_Lik(dep,indep_nS,indep_S,param,k,S,advOpt,dispOut),param0,options);
       
    case 'fmincon'
        options=optimset('fmincon');
        options=optimset(options,'display','off');
        [param]=fmincon(@(param)MS_Regress_Lik(dep,indep_nS,indep_S,param,k,S,advOpt,dispOut),param0, ...
            A,b,Aeq,beq,lB,uB,[],options);
        
        
end

% Calculation of Covariance Matrix

[V]=getvarMatrix_MS_Regress(dep,indep_nS,indep_S,param,k,S,std_method,advOpt);
param_std=sqrt(diag((V)));

% Controls for covariance matrix. If found imaginary number for variance, replace with
% Inf. This will then be showed at output

param_std(isinf(param_std))=0;
param_pvalues=2*(1-tcdf(abs(param./param_std),nr-numel(param)));

if ~isreal(param_std)
    for i=1:numel(param)
        if ~isreal(param_std(i))
            param_std(i)=Inf;
        end
    end
end

typeCall='se_calculation';

[Coeff_SE]=param2spec(param_std,Coeff_Tag,constCoeff,typeCall);
[Coeff_pValues]=param2spec(param_pvalues,Coeff_Tag,constCoeff,typeCall);

% After finding param, filter it to the data to get estimated output

[sumlik,Spec_Output]=MS_Regress_Lik(dep,indep_nS,indep_S,param,k,S,advOpt,0);

% calculating smoothed probabilities

Prob_t_1=zeros(nr,k);
Prob_t_1(1,1:k)=1/k; % This is the matrix with probability of s(t)=j conditional on the information in t-1

for i=2:nr
    Prob_t_1(i,1:k)=(Spec_Output.Coeff.p*Spec_Output.filtProb(i-1,1:k)')';
end

filtProb=Spec_Output.filtProb;

P=abs(Spec_Output.Coeff.p);

smoothProb=zeros(nr,k);
smoothProb(nr,1:k)=Spec_Output.filtProb(nr,:);  % last observation for starting filter

for i=nr-1:-1:1     % work backwards in time for smoothed probs
    for j1=1:k
        for j2=1:k
            smooth_value(1,j2)=smoothProb(i+1,j2)*filtProb(i,j1)*P(j2,j1)/Prob_t_1(i+1,j2);
        end
        smoothProb(i,j1)=sum(smooth_value);
    end
end

% Calculating Expected Duration of regimes

stateDur=1./(1-diag(Spec_Output.Coeff.p));
Spec_Output.stateDur=stateDur;

% passing values to output structure

Spec_Output.smoothProb=smoothProb;
Spec_Output.nObs=size(Spec_Output.filtProb,1);
Spec_Output.nEq=nEq;
Spec_Output.Number_Parameters=numel(param);
Spec_Output.advOpt.distrib=distrib;
Spec_Output.advOpt.std_method=std_method;
Spec_Output.Coeff_SE=Coeff_SE;
Spec_Output.Coeff_pValues=Coeff_pValues;
Spec_Output.AIC=2*numel(param)-2*Spec_Output.LL;
Spec_Output.BIC=-2*Spec_Output.LL+numel(param)*log(Spec_Output.nObs*nEq);

% ploting probabilities

if advOpt.doPlots
    doPlots();
end

% Sending output to matlab's screen

disp(' ');
if advOpt.printOut
    doOutScreen()
end
