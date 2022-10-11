% Fitted volatility of RCP-HAR
%
% Input:
%
%        Nodes_initial           Initial partition nodes
%
%        vt                      Log return of raw data
%
%        rv_est                  Pre-estimated conditional variance of
%                                RCP-HAR
%
%        X                       Model of RCP-HAR
%
%        h                       Minimum length of one cluster
%
% Output:
%
%        rv_iterated             Fitted realised volatility of RCPHAR
%
%        Nodes_iterated          Partition nodes of RCPHAR

function [rv_iterated,Nodes_iterated] = Vol_ClusterPartitionIterationHAR(Nodes_initial,vt,rv_est,X,h)
if nargin<=4
    h = 20;
end
rv_PieceHAR = zeros(size(vt));
for i1 = 1 : numel(Nodes_initial)-1
    index=Nodes_initial(i1):Nodes_initial(i1+1)-1;
    if Nodes_initial(i1+1)-Nodes_initial(i1)>=h
        rv_PieceHAR(index) = Vol_HAR(vt(index),X(index,:));
    else
        rv_PieceHAR(index) = rv_est(index);
    end
end
N = Nodes_initial(end);
if numel(vt)-N>=h
    rv_PieceHAR(N:end) = Vol_HAR(vt(N:end),X(N:end,:));
else
    rv_PieceHAR(N:end) = rv_est(N:end);
end
% 分段GARCH波动率聚类分割
[LB_iterated,J_iterated,~] = Fisher_div_sqr(rv_PieceHAR,h);
K_iterated = OptimalClusterNumber(rv_PieceHAR,LB_iterated);% 确定最优分类数
[rv_iterated,Nodes_iterated] = Vol_ClusterPartition(rv_PieceHAR,K_iterated,J_iterated);
% 迭代过程
IterationTime = 0;
while ~isequal(Nodes_initial,Nodes_iterated) && IterationTime<100
    IterationTime = IterationTime + 1;
    Nodes_initial = Nodes_iterated;
    rv_PieceHAR = zeros(size(vt));
    for i1 = 1 : numel(Nodes_initial)-1
        index=Nodes_initial(i1):Nodes_initial(i1+1)-1;
        if Nodes_initial(i1+1)-Nodes_initial(i1)>=10
            rv_PieceHAR(index) = Vol_HAR(vt(index),X(index,:));
        else
            rv_PieceHAR(index) = rv_est(index);
        end
    end
    N = Nodes_initial(end);
    if numel(vt)-Nodes_initial(end)>=h
        rv_PieceHAR(N:end) = Vol_HAR(vt(N:end),X(N:end,:));
    else
        rv_PieceHAR(N:end) = rv_est(N:end);
    end
    [LB_iterated,J_iterated,~] = Fisher_div_sqr(rv_PieceHAR,h);
    K_iterated = OptimalClusterNumber(rv_PieceHAR,LB_iterated);% 确定最优分类数
    [rv_iterated,Nodes_iterated] = Vol_ClusterPartition(rv_PieceHAR,K_iterated,J_iterated);
end
end


