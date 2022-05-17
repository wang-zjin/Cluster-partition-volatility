clc,clear
%% 导入数据
addpath('data_Files'); % add 'data_Files' folder to the search path
load('sample')
logRet = sample(:,4);% 收益率
start_long = 5044;
start_short = 7058;
endTime = 7559; 
TimeLine = datenum(sample(:,1:3));
T = length(logRet); 
%% 画SP500收益率图像
figure;
plot(TimeLine, logRet)
xlim([TimeLine(1),TimeLine(end)])
dateaxis('x' , 10, TimeLine(1))
set(gcf,'Position',[500 500 900 300]);
set(gcf,'color','none');
set(gca,'color','none');
set(gcf,'InvertHardCopy','off');
saveas(gcf,'results_Files\keynote20220116_fig1','png');
%% 画白噪声图像被分割为两段的图像
x1 = randn(1,200);x2 = randn(1,200)*3;x=[x1 x2];
figure;
plot(x,'LineWidth',1.5);hold on 
plot(200*ones(size(-10:0.1:10)),-10:0.1:10,'k--','LineWidth',1);
set(gca,'yticklabel',[],'ytick',[],'xticklabel',[],'xtick',[]);
set(gcf,'Position',[500 500 900 300]);
set(gcf,'color','none');
set(gca,'color','none');
set(gca,'Visible','off');
% set(gcf,'InvertHardCopy','off');
saveas(gcf,'results_Files\keynote20220116_fig2','png');
%% 画白噪声图像被分割为多段的图像
x1 = randn(1,300);x2 = randn(1,100)*5;x3 = randn(1,200)*1.5;x4 = randn(1,100)*6;
x5 = randn(1,200)*4;x6 = randn(1,50)*7;x7 = randn(1,200)*2;x8 = randn(1,100)*6;x9 = randn(1,50)*1.5;
x=[x1 x2 x3 x4 x5 x6 x7 x8 x9];
figure;DashLine=-15:0.1:15;
plot(x,'LineWidth',1.5);hold on 
plot(300*ones(size(DashLine)),DashLine,'k--','LineWidth',1);
plot(400*ones(size(DashLine)),DashLine,'k--','LineWidth',1);
plot(600*ones(size(DashLine)),DashLine,'k--','LineWidth',1);
plot(700*ones(size(DashLine)),DashLine,'k--','LineWidth',1);
plot(900*ones(size(DashLine)),DashLine,'k--','LineWidth',1);
plot(950*ones(size(DashLine)),DashLine,'k--','LineWidth',1);
plot(1150*ones(size(DashLine)),DashLine,'k--','LineWidth',1);
plot(1250*ones(size(DashLine)),DashLine,'k--','LineWidth',1);
set(gca,'yticklabel',[],'ytick',[],'xticklabel',[],'xtick',[]);
set(gcf,'Position',[200 500 1200 300]);
set(gcf,'color','none');
set(gca,'color','none','Visible','off');
saveas(gcf,'results_Files\keynote20220116_fig2-1','png');
%% 画聚类分割后的波动率图像
%% 最优分割法
addpath('m_Files_ClusterPartition');
addpath('results_Files');
% [LB,J,D] = Fisher_div_sqr(T,sigma2,5);  
load('GARCHCP2018');% D：直径    LB：最优损失函数   J：最后一个区间的分割点
% 图像确定聚类数 figure 3
K=500;y = zeros(K - 1 ,1);for i = 1 : K - 1
    y(i) = LB(T,i+1);end
k = 2 : K;figure;plot(k,y,'k.')
xlim([-5,K+10])
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig3','png');
% Slope确定聚类数 figure 4
K=800;y = zeros(K-1 , 1);for k = 2 : K
    y(k - 1) = LB(T , k) / LB(T , k+1 );end
figure;plot(2:K, y, 'k')
hold on 
plot(2:K, ones(size(y)), 'k--');hold on 
if sum(y<1)>0
    plot(find(y<0,1)+1, y(find(y<0,1)), 'k.');text(find(y<0,1)+1, y(find(y<0,1)),strcat('(',num2str(find(y<0,1)+1),',',num2str(y(find(y<0,1))),')'));end
ylim([0.8,max(y)*1.1]);xlim([-5,K+10]);
set(gca,'yticklabel',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
text(250, 0.9, 'y=1');
saveas(gcf,'results_Files\keynote20220116_fig4','png');
% 基于信息统计量 figure 5
K=800;y = zeros(K , 1);for k = 2 : K
    y(k) =  log(T)*k/T +    log(  LB(T , k)/T );end
figure;plot(2:length(y), y(2:end) , 'k' );hold on
plot(find(y==min(y(2:end)))+1, min(y(2:end)),'k.')
set(gca,'yticklabel',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig5','png');
%% CP波动率 figure 6-9
addpath('m_Files_VaR');
addpath('m_Files_GARCHfamily')
% sigma2=estimateGARCH(logRet,garch(1,1));
% GARCH波动率 figure 6
figure;plot(TimeLine, sigma2, 'k')
dateaxis('x' , 10, TimeLine(1))
set(gca,'yticklabel',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig6','png');
% N=1000 CP波动率 figure 7
sigma2_CP = Vol_ClusterPartition(sigma2,1000,J);
figure;plot(TimeLine(1:length(sigma2_CP)), sigma2_CP, 'k');
dateaxis('x' , 10)
set(gca,'yticklabel',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig7','png');
% N=500 CP波动率 figure 8
sigma2_CP = Vol_ClusterPartition(sigma2,500,J);
figure;plot(TimeLine(1:length(sigma2_CP)), sigma2_CP, 'k');
dateaxis('x' , 10)
set(gca,'yticklabel',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig8','png');
% N=100 CP波动率 figure 9
sigma2_CP = Vol_ClusterPartition(sigma2,100,J);
figure;plot(TimeLine(1:length(sigma2_CP)), sigma2_CP, 'k');
dateaxis('x' , 10)
set(gca,'yticklabel',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig9','png');
%% 各模型VaR与实际收益率的对比
addpath('results_Files');
% Historical simulation method in short term
load('ShortHSVaR');VaR=hVaR(:,[3,5,7]);ret=logRet(start_short:end);Time=TimeLine(start_short:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig10','png');
% Variance-covariance method in short term
load('ShortVaCovVaR');VaR=pVaR(:,[3,5,7]);ret=logRet(start_short:end);Time=TimeLine(start_short:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig11','png');
VaR=pVaRT(:,[3,5,7]);ret=logRet(start_short:end);Time=TimeLine(start_short:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig11-1','png');
% GARCH in short term
load('ShortGARCHVaR');VaR=GARCHVaR(:,[3,5,7]);ret=logRet(start_short:end);Time=TimeLine(start_short:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig12','png');
% EGARCH in short term
load('ShortEGARCHVaR');VaR=EGARCHVaR(:,[3,5,7]);ret=logRet(start_short:end);Time=TimeLine(start_short:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig13','png');
% RSGARCH in short term
load('ShortRSGARCHVaR');VaR=RSGARCHVaR(:,[3,5,7]);ret=logRet(start_short:end);Time=TimeLine(start_short:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig14','png');
% GARCH cluster in short term
load('ShortGARCHclusterVaR');VaR=GARCHclusterVaR1(:,[3,5,7]);ret=logRet(start_short:end);Time=TimeLine(start_short:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig15','png');
VaR=GARCHclusterVaR2(:,[3,5,7]);ret=logRet(start_short:end);Time=TimeLine(start_short:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig15-1','png');
% EGARCH cluster in short term
load('ShortEGARCHclusterVaR');
VaR=EGARCHclusterVaR1(:,[3,5,7]);ret=logRet(start_short:end);Time=TimeLine(start_short:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig16','png');
VaR=EGARCHclusterVaR2(:,[3,5,7]);ret=logRet(start_short:end);Time=TimeLine(start_short:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig16-1','png');
%%%%%%%%%%%%%%%%%%%%%%%%%% Long Term %%%%%%%%%%%%%%%%%%%%%%%%%%
% Historical simulation method in long term
load('LongHSVaR');VaR=hVaR(:,[3,5,7]);ret=logRet(start_long:end);Time=TimeLine(start_long:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig17','png');
% Variance-covariance method in long term
load('LongVaCovVaR');VaR=pVaR(:,[3,5,7]);ret=logRet(start_long:end);Time=TimeLine(start_long:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig18','png');
% GARCH in long term
load('LongGARCHVaR');VaR=GARCHVaR(:,[3,5,7]);ret=logRet(start_long:end);Time=TimeLine(start_long:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig19','png');
% EGARCH in long term
load('LongEGARCHVaR');VaR=EGARCHVaR(:,[3,5,7]);ret=logRet(start_long:end);Time=TimeLine(start_long:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig20','png');
% RSGARCH in long term
load('LongRSGARCHVaR');VaR=RSGARCHVaR(:,[3,5,7]);ret=logRet(start_long:end);Time=TimeLine(start_long:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig21','png');
% GARCH cluster in long term
load('LongGARCHclusterVaR');VaR=GARCHclusterVaR1(:,[3,5,7]);ret=logRet(start_long:end);Time=TimeLine(start_long:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig22','png');
VaR=GARCHclusterVaR2(:,[3,5,7]);ret=logRet(start_long:end);Time=TimeLine(start_long:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig22-1','png');
% EGARCH cluster in long term
load('LongEGARCHclusterVaR');VaR=EGARCHclusterVaR1(:,[3,5,7]);ret=logRet(start_long:end);Time=TimeLine(start_long:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig23','png');
VaR=EGARCHclusterVaR2(:,[3,5,7]);ret=logRet(start_long:end);Time=TimeLine(start_long:end);
figure;plot(Time, ret, 'k' );hold on 
plot(Time, VaR(:,1), 'b');hold on 
plot(Time, VaR(:,2),'g');hold on 
plot(Time, VaR(:,3),'r');dateaxis('x' , 12);
set(gca,'yticklabel',[],'ytick',[],'color','none');
set(gcf,'Position',[500 500 500 300],'color','none');
saveas(gcf,'results_Files\keynote20220116_fig23-1','png');