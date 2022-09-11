% Cluster partition volatility K clusters
%
% Input:
%
%        sigma                   Volatility
%
%        k                       Number of clusters
%
%        J                       Matrix, of which row i column j J(i,j)
%                                means the index of the last cluster of j
%                                clusters in total i data
%
%        Time                    Time of sigma
%
%        h                       Minimum length of one cluster
%
% Output:
%
%        sigma_hat               Cluster partition volatility
%
%        Nodes                   Partition nodes K clusters
%
%        TimeTable               Time of sigma_hat

function [sigma_hat,Nodes,TimeTable] = Vol_ClusterPartition(sigma,K,J,Time)
% K:聚类数
T = numel(sigma);
Nodes = ones(K,1);
n = T;
if K>=n
    warning("Cluster number should be smaller than data size")
end
for i = K : -1 : 2
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

