%% Regime Switching GARCH估计波动率

clear, clc

addpath('m_Files');    % add 'm_Files' folder to the search path
addpath('data_Files'); % add 'data_Files' folder to the search path

load('sample')
%% 两阶段法
logRet=sample(:,4);
time=datenum(sample(:,1:3));
Mdl = arima(1, 0, 0);               %ARIMA(p,i,q)
EstMdl = estimate(Mdl,logRet);
[res,CondVariance,logL] = infer(EstMdl,logRet);
sigma2 = res.^2;
% figure;
% plot(sigma2)
epsilon = logRet-mean(logRet);
epsilon2 = epsilon.^2;
% sigma^2_t = alpha0_st + alpha1_st * epsilon^2_{t-1} + beta_st * sigma^2_{t-1}
dep = sigma2(2:end); 
constVec=ones(length(dep),1);                            % Defining a constant vector in mean equation
indep=[constVec epsilon2(1:end-1) sigma2(1:end-1)];      % Defining constant explanatory variables
k=2;                                                     % Number of States
S=[1 1 1 0];                                             % Defining which parts of the equation will switch states
advOpt.distrib='Normal';                                 % The Distribution assumption ('Normal', 't' or 'GED')
Spec_Out = MS_Regress_Fit(dep,indep,k,S,advOpt);         % Estimating the model


%% swgarchest函数 
% 这个程序不好使
data = sample(:,4);
%[thetahat,results,struct]= swgarchest(data,flag,ORDERS,reg,startval,startM,hreal)
[thetahat,results,struct]= swgarchest(data,1,[1,1,1],2);
% swgarchlik(thetahat,data,1,[1,1,1],1)
M = genMarkovMatrix(thetahat(8:9));
para = reshape(thetahat(2:9),2,4);
[simulatedEpsi,H,states,Y,s] = msGarchSim(1,para,[1,1,1],M,2,1,123);

%% swgarch函数
addpath('m_Files_swgarch');
data = sample(:,4);
errors = data-mean(data);
[estimation, probabilities, diagnostics] = swgarch(errors, 2, 'NORMAL',...
     'KLAASSEN','CONS', {'YES',[]}, [0.1 0.1 0.92;0.01 0.05 0.7], [0.9 0.1;0.1 0.9],...
     [],[]); %#ok<ASGLU>
 estimation.garch; % parameters of GARCH
 estimation.transM; % parameters of transition matrix
 [estimation, probabilities, diagnostics] = swgarch(data, 2, 'NORMAL',...
     'KLAASSEN','CONS', {'YES',[]}, [0.1 0.1 0.92;0.01 0.05 0.7], [0.9 0.1;0.1 0.9],...
     [],[]);
 % show the figure of conditional variance
 figure;
 plot(estimation.H(2:end));
 % stimulate the volatility by estimated parameters
 data_simu = swgarch_sim(1000,2,estimation.garch,estimation.transM, 'DEP','NORMAL',1,1);
 % show the figure of stimulated conditional variance
 figure;
 plot(data_simu.vH);
 % show the figure of stimulated errors
 figure;
 plot(data_simu.vE);
 