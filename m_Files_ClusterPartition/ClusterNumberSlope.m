%% 函数确定聚类数,figure4
function ClusterNumberSlope(LB,T,K)

y = zeros(K-1 , 1);
for k = 2 : K
    y(k - 1) = LB(T , k) / LB(T , k+1 );
end
figure;
plot(2:K, y, 'k')
hold on 
plot(2:K, ones(size(y)), 'k--')
hold on 
if sum(y<1)>0
    plot(find(y<0,1)+1, y(find(y<0,1)), 'k.')
    text(find(y<0,1)+1, y(find(y<0,1)),strcat('(',num2str(find(y<0,1)+1),',',num2str(y(find(y<0,1))),')'))
else
end
legend('Slope statistic', 'y=1')
xlim([-5,K+10])
ylim([0.8,max(y)*1.1])
xlabel('Cluster k')
set(gcf,'Position',[500 500 900 300]);