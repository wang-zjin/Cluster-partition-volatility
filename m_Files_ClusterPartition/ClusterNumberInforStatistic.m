%% 基于信息统计量,figure5
function ClusterNumberInforStatistic(LB,T,K)

y = zeros(K , 1);
for k = 2 : K
    y(k) =  log(T)*k/T +    log(  LB(T , k)/T );
end
figure;
plot(2:length(y), y(2:end) , 'k' )
hold on
plot(find(y==min(y(2:end)))+1, min(y(2:end)),'k.')
text(find(y==min(y(2:end)))+1, min(y(2:end))*0.98,strcat('(',num2str(find(y==min(y(2:end)))+1),',',sprintf('%2.2f',min(y(2:end))),')') )
xlim([-5,K+10])
xlabel('Cluster k')
legend('Information based statistic')
set(gcf,'Position',[500 500 900 300]); 