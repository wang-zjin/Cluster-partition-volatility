%% Cluster partition模型将sigma分为K类
% J是用Fisher分割算法算出来的分割节点，是一个T*K矩阵(T是样本长度，K是分类数)
% Time是一个T*3矩阵，表示每个数据的时间：月-日-年
function [sigma_hat,TimeTable,Nodes] = Vol_ClusterPartition(sigma,K,J,Time)

% K:聚类数
T = numel(sigma);
Nodes = ones(K,1);
n = T;
for i = K : -1 : 1
    Nodes(i) = J(n,i);
    n = Nodes(i) - 1;
end

sigma_hat = sigma;
for i = 1 : K-1
    sigma_hat(Nodes(i):Nodes(i+1)-1)=mean( sigma(Nodes(i):Nodes(i+1)-1) );
end
sigma_hat(Nodes(K):end)=mean( sigma(Nodes(K):end) );

if nargin>3
    %     TimeTable = zeros(K,3); % 每个聚类节点的时间
    %     for i = 1 : K
    %         TimeTable(i,:) = Time(Nodes(i),:);
    %     end
    TimeTable = cell(K,1); % 每个聚类节点的时间
    for i = 1 : K
        TimeTable{i,1} = datestr(Time(Nodes(i),:));
    end
else
    TimeTable=[];
end

end