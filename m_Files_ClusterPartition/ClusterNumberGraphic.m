%% 图像确定聚类数 K,figure3
function ClusterNumberGraphic(LB,T,K)

y = zeros(K - 1 ,1);
for i = 1 : K - 1
    y(i) = LB(T,i+1);  %损失函数值
end
k = 2 : K;
figure;
plot(k,y,'k.')
xlim([-5,K+10])
ylim([0,max(y)*1.1])
xlabel('Cluster k')
ylabel('Loss Function Value')
set(gcf,'Position',[500 500 900 300]);