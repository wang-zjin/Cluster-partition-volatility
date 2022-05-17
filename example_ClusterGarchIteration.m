clear, clc

addpath('data_Files'); % add 'data_Files' folder to the search path
addpath('m_Files_GARCHfamily'); % add 'm_Files_GARCHfamily' folder to the search path
load('sample')
logRet = sample(:,4);
TimeLine = datenum(sample(:,1:3));
rmpath('data_Files')
v0=estimateGARCH(logRet,garch('GARCHLags',1,'ARCHLags',1,'Offset',NaN));

addpath('m_Files_ClusterPartition');
tic
[V,OUTPUT]=ClusterGarchIteration(logRet,v0,250); % (TIME : 23.65min)
toc
tic
[V,OUTPUT]=ClusterGarchIteration(logRet,v0,200); % (TIME : 23.59min)
toc

figure;
plot(TimeLine,V)
hold on
plot(TimeLine,v0)
hold on
plot([TimeLine(OUTPUT.SplitPoints(2:end)),TimeLine(OUTPUT.SplitPoints(2:end))],[0,max(V)],'k--')
plot([TimeLine(I1(2:end)),TimeLine(I1(2:end))],[0,max(v1)],'k--')


empath('m_Files_ClusterPartition');
rmpath('m_Files_GARCHfamily'); % remove 'm_Files_GARCHfamily' folder out of the search path

[data]=textread('F:\Data\SP500¸ßÆµ\finaldata.txt'); 
max(data(:,1))
min(data(:,1))
find(data(:,1)==max(data(:,1)))
find(data(:,1)==min(data(:,1)))
date=datestr(data(:,1));

n=10000;
logRet=price2ret(data(1:n,2));
TimeLine = data(2:n,1);
v0=estimateGARCH(logRet,garch('GARCHLags',1,'ARCHLags',1,'Offset',NaN));
tic
[V,OUTPUT]=ClusterGarchIteration(logRet,v0,250); % (TIME : 79min)
toc
figure;
plot(TimeLine,V)
hold on
plot(TimeLine,v0)
hold on
plot([TimeLine(OUTPUT.SplitPoints(2:end)),TimeLine(OUTPUT.SplitPoints(2:end))],[0,max(V)],'k--')