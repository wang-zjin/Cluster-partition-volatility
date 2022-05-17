clear,clc
% 导入数据
addpath('F:\structural change model\programming\programming\20210326\data_Files'); % add 'data_Files' folder to the search path
addpath('F:\structural change model\programming\programming\20210326\m_Files_GARCHfamily')
addpath('F:\structural change model\programming\programming\20210326\m_Files_ClusterPartition');
load('sample')
logRet = sample(:,4);% 收益率
TimeLine = datenum(sample(:,1:3));
% 参数设置
T = length(logRet); 
clusterMinNumel = 150;
% GARCH波动率
sigma2_GARCH=estimateGARCH(logRet,garch(1,1));
% 波动率聚类分割
[LB_initial,J_initial,D_initial] = Fisher_div_sqr(T,sigma2_GARCH,clusterMinNumel);  
K_initial = OptimalClusterNumber(sigma2_GARCH,LB_initial);% 确定最优分类数
[sigma2_CP_initial,NodesTime_initial,Nodes_initial] = Vol_ClusterPartition(sigma2_GARCH,K_initial,J_initial,TimeLine);% 输出GARCH-CP波动率和分割点
% 分段GARCH波动率
sigma2_PieceGARCH = zeros(size(logRet));
for i1 = 1 : numel(Nodes_initial)-1
    sigma2_PieceGARCH(Nodes_initial(i1):Nodes_initial(i1+1)-1) = estimateGARCH(logRet(Nodes_initial(i1):Nodes_initial(i1+1)-1),garch(1,1));
end
sigma2_PieceGARCH(Nodes_initial(end):end) = estimateGARCH(logRet(Nodes_initial(end):end),garch(1,1));
% 分段GARCH波动率聚类分割
[LB_iterated,J_iterated,~] = Fisher_div_sqr(T,sigma2_PieceGARCH,clusterMinNumel);
K_iterated = OptimalClusterNumber(sigma2_PieceGARCH,LB_iterated);% 确定最优分类数
[sigma2_iterated,NodesTime_iterated,Nodes_iterated] = Vol_ClusterPartition(sigma2_PieceGARCH,K_iterated,J_iterated,TimeLine);
% 迭代过程
IterationTime = 0;
while (numel(Nodes_initial)~=numel(Nodes_iterated) || sum(Nodes_initial~=Nodes_iterated)>0) && IterationTime<100
    
    IterationTime = IterationTime + 1;
    
    Nodes_initial = Nodes_iterated;
    sigma2_PieceGARCH = zeros(size(logRet));
    for i1 = 1 : numel(Nodes_initial)-1
        sigma2_PieceGARCH(Nodes_initial(i1):Nodes_initial(i1+1)-1) = estimateGARCH(logRet(Nodes_initial(i1):Nodes_initial(i1+1)-1),garch(1,1));
    end
    sigma2_PieceGARCH(Nodes_initial(end):end) = estimateGARCH(logRet(Nodes_initial(end):end),garch(1,1));
    [LB_iterated,J_iterated,~] = Fisher_div_sqr(T,sigma2_PieceGARCH,clusterMinNumel);
    K_iterated = OptimalClusterNumber(sigma2_PieceGARCH,LB_iterated);% 确定最优分类数
    [sigma2_iterated,NodesTime_iterated,Nodes_iterated] = Vol_ClusterPartition(sigma2_PieceGARCH,K_iterated,J_iterated,TimeLine);
end
figure;
plot(v)

rmpath('F:\structural change model\programming\programming\20210326\data_Files'); % remove 'data_Files' folder to the search path
rmpath('F:\structural change model\programming\programming\20210326\m_Files_GARCHfamily')
rmpath('F:\structural change model\programming\programming\20210326\m_Files_ClusterPartition');