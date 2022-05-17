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
% S&P 500 index yield
figure;
h=plot(TimeLine, logRet);
xlim([TimeLine(1),TimeLine(end)]);
dateaxis('x' , 10, TimeLine(1))
h=set(gcf,'Position',[500 500 900 300]);
h=set(gcf,'color','none')
h=set(gca,'color','none')
h=set(gcf,'InvertHardCopy','off');
saveas(gcf,'a','png','transparency', backgroundColor);
imwrite(bitmapData, 'a.png', 'png', 'transparency', backgroundColor)