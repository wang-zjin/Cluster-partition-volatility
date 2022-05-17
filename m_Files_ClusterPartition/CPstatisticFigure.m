%% Cluster统计量 按最近一年,figure2
function CPstatisticFigure(sigma2,TimeLine,h,start_1Year,endTime)

m0 = mean(sqrt(sigma2( start_1Year : endTime )));
ro = zeros(endTime-start_1Year+1, 1);
for i = start_1Year+h : endTime-h+1
    m1 = mean(sqrt(sigma2( start_1Year : i-1)));
    m2 = mean(sqrt(sigma2( i : endTime )));
    ro(i+1-start_1Year) = sum(  (sqrt(sigma2(  start_1Year : endTime  )) - m0).^2  )...
                  - sum(  (sqrt(sigma2(  start_1Year : i-1   )) - m1).^2  )...
                  - sum(  (sqrt(sigma2(  i    : endTime  )) - m2).^2  );
end
figure;
plot(TimeLine(start_1Year:end), ro, 'k')
xlim([TimeLine(start_1Year),TimeLine(end)])
xlabel('Year')
ylabel('Cluster statistic value')
dateaxis('x' , 12, TimeLine(start_1Year))
hold on
plot([TimeLine(start_1Year+find(ro==max(ro))-1),TimeLine(start_1Year+find(ro==max(ro))-1)],[0,max(ro)],'k--')
text(TimeLine(start_1Year+find(ro==max(ro))-1),max(ro)*1.05,sprintf('%2.2f',max(ro)*1000 ))
plot([TimeLine(start_1Year+23-1),TimeLine(start_1Year+23-1)],[0,ro(23)],'k--')
text(TimeLine(start_1Year+23-1),ro(23)*1.1,sprintf('%2.2f',ro(23)*1000)  )
plot([TimeLine(start_1Year+83-1),TimeLine(start_1Year+83-1)],[0,ro(83)],'k--')
text(TimeLine(start_1Year+83-1),ro(83)*1.15,sprintf('%2.2f',ro(83)*1000)  )
set(gcf,'Position',[500 500 900 300]);
figure;
plot(TimeLine(start_1Year:end), sigma2(start_1Year:end), 'k')
xlim([TimeLine(start_1Year),TimeLine(end)])
xlabel('Year')
ylabel('Volatility')
dateaxis('x' , 12, TimeLine(start_1Year))
hold on
plot([TimeLine(start_1Year+find(ro==max(ro))-1),TimeLine(start_1Year+find(ro==max(ro))-1)],[0,max(sigma2(start_1Year:endTime))],'k--')
text(TimeLine(start_1Year+find(ro==max(ro))-1),sigma2(start_1Year+find(ro==max(ro))-1)*1.8,'2018/10/12')
plot([TimeLine(start_1Year+23-1),TimeLine(start_1Year+23-1)],[0,max(sigma2(start_1Year:endTime))],'k--')
text(TimeLine(start_1Year+23-1),sigma2(start_1Year+23-1)*1.8,'2018/2/5')
plot([TimeLine(start_1Year+83-1),TimeLine(start_1Year+83-1)],[0,max(sigma2(start_1Year:endTime))],'k--')
text(TimeLine(start_1Year),sigma2(start_1Year+83-1)*1.8,'2018/4/26')
set(gcf,'Position',[500 500 900 300]);