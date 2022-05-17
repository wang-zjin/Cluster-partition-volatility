clear,clc
[data, text]=xlsread('F:\Data\Chinese Stock Market\IDX_Idxtrd.xlsx'); 
Ret = data(:,6)/100;
figure;
plot(Ret)
MEAN = mean(Ret);MAX=max(Ret);MIN=min(Ret);VARIANCE=var(Ret);SKEWNESS=skewness(Ret);KURTOSIS=kurtosis(Ret);
[~,~,JBSTAT,~]=jbtest(Ret);
table(MEAN,MAX,MIN,VARIANCE,SKEWNESS,KURTOSIS,JBSTAT)% statistic analysis
[h,pValue,ADFSTAT,reg]=adftest(Ret,'model','TS','lags',0:round((numel(Ret)/100)^(1/4)*12));% Reject null hypothesis
[ACF,~,bounds] = autocorr(Ret)
[PACF,~,bounds] = parcorr(Ret)
[h,pValue,stat,cValue] = archtest(Ret-mean(Ret),'lags',1:5)% test ARCH effect
[b,~,r,~,s]=regress(Ret(7:end),[ones(size(Ret(7:end))),Ret(6:end-1),Ret(5:end-2),Ret(4:end-3),Ret(3:end-4),Ret(2:end-5),...
    Ret(1:end-6)]);
figure;
autocorr((Ret-mean(Ret)).^2)
figure;
autocorr(r.^2)
%% Estimation
[EstGarchMdl,~,~,InfoGarch]=estimate(garch(1,1),Ret,'Display','full');
VGarch=infer(EstGarchMdl,Ret);
figure;
plot(VGarch)
[EstEgarchMdl,~,~,InfoEgarch]=estimate(egarch(1,1),Ret,'Display','full');
VEgarch=infer(EstEgarchMdl,Ret);
figure;
plot(VEgarch)
rGarch=VGarch(2:end)-[ones(size(VGarch(2:end))) VGarch(1:end-1) (Ret(1:end-1)-InfoGarch.X(1)).^2]*InfoGarch.X;
[h,pValue,stat,cValue] = archtest(rGarch,'lags',1:5);% test ARCH effect of GARCH error
% Predict VaR
addpath('m_Files_GARCHfamily')
addpath('m_Files_VaR')
GarchVar=GARCHVaRPredict(Ret,700,1219,300,1,'Normal');
GarchVarT=GARCHVaRPredict(Ret,700,1219,300,1,'T');
visualizeVar(Ret,1)
addpath('m_Files_KupiecTest')
tableVaRPredict(GarchVar,Ret,700,1219,0.05)
tableVaRPredict(GarchVarT,Ret,700,1219,0.05)
2*var(Ret)/(var(Ret)-1)
tstat(50)
