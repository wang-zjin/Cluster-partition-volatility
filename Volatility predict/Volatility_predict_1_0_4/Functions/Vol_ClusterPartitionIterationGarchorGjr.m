% Estimated volatility of GARCH or GJR
%
% Input:
%
%        Nodes_initial           Initial partition nodes
%
%        logRet                  Log return of raw data
%
%        sigma2                  Pre-estimated conditional variance of
%                                RSGARCH
%
%        Mdl                     Model of RSGARCH
%
%        h                       Minimum length of one cluster
%
% Output:
%
%        sigma2_iterated         Estimated volatility of RCPHAR
%
%        Nodes_iterated          Partition nodes of RCPHAR

function [sigma2_iterated,Nodes_iterated] = Vol_ClusterPartitionIterationGarchorGjr(Nodes_initial,logRet,sigma2,Mdl,h)
if nargin<=4
    h = 10;
end
% 参数设置
% T = length(logRet);
% 分段GARCH波动率
sigma2_PieceGARCH = zeros(size(logRet));
for i1 = 1 : numel(Nodes_initial)-1
    if Nodes_initial(i1+1)-Nodes_initial(i1)>=h
        EstMdl = estimate(Mdl,logRet(Nodes_initial(i1):Nodes_initial(i1+1)-1),"Display","off");
        sigma2_PieceGARCH(Nodes_initial(i1):Nodes_initial(i1+1)-1) = ...
            infer(EstMdl,logRet(Nodes_initial(i1):Nodes_initial(i1+1)-1));
    else
        sigma2_PieceGARCH(Nodes_initial(i1):Nodes_initial(i1+1)-1) = sigma2(Nodes_initial(i1):Nodes_initial(i1+1)-1);
    end
end
if numel(sigma2)-Nodes_initial(end)>=h
    EstMdl = estimate(Mdl,logRet(Nodes_initial(end):end),"Display","off");
    sigma2_PieceGARCH(Nodes_initial(end):end) = ...
        infer(EstMdl,logRet(Nodes_initial(end):end));
else
    sigma2_PieceGARCH(Nodes_initial(end):end) = sigma2(Nodes_initial(end):end);
end
% 分段GARCH波动率聚类分割
[LB_iterated,J_iterated,~] = Fisher_div_sqr(sigma2_PieceGARCH,h);
K_iterated = OptimalClusterNumber(sigma2_PieceGARCH,LB_iterated);% 确定最优分类数
if K_iterated==numel(sigma2_PieceGARCH)
    K_iterated=K_iterated-1;
end
[sigma2_iterated,Nodes_iterated] = Vol_ClusterPartition(sigma2_PieceGARCH,K_iterated,J_iterated);
% 迭代过程
IterationTime = 0;
while ~isequal(Nodes_initial,Nodes_iterated) && IterationTime<100

    IterationTime = IterationTime + 1;

    Nodes_initial = Nodes_iterated;
    sigma2_PieceGARCH = zeros(size(logRet));
    for i1 = 1 : numel(Nodes_initial)-1
        if Nodes_initial(i1+1)-Nodes_initial(i1)>=h
            EstMdl = estimate(Mdl,logRet(Nodes_initial(i1):Nodes_initial(i1+1)-1),"Display","off");
            sigma2_PieceGARCH(Nodes_initial(i1):Nodes_initial(i1+1)-1) = ...
                infer(EstMdl,logRet(Nodes_initial(i1):Nodes_initial(i1+1)-1));
        else
            sigma2_PieceGARCH(Nodes_initial(i1):Nodes_initial(i1+1)-1) = sigma2(Nodes_initial(i1):Nodes_initial(i1+1)-1);
        end
    end
    if numel(sigma2)-Nodes_initial(end)>=h
        EstMdl = estimate(Mdl,logRet(Nodes_initial(end):end),"Display","off");
        sigma2_PieceGARCH(Nodes_initial(end):end) = ...
            infer(EstMdl,logRet(Nodes_initial(end):end));
    else
        sigma2_PieceGARCH(Nodes_initial(end):end) = sigma2(Nodes_initial(end):end);
    end
    [LB_iterated,J_iterated,~] = Fisher_div_sqr(sigma2_PieceGARCH,h);
    K_iterated = OptimalClusterNumber(sigma2_PieceGARCH,LB_iterated);% 确定最优分类数
    if K_iterated==numel(sigma2_PieceGARCH)
        K_iterated=K_iterated-1;
    end
    [sigma2_iterated,Nodes_iterated] = Vol_ClusterPartition(sigma2_PieceGARCH,K_iterated,J_iterated);
end
end

