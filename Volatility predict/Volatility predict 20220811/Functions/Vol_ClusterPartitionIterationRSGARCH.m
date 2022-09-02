% Estimated volatility of RCP-RSGARCH
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

function [sigma2_iterated,Nodes_iterated] = Vol_ClusterPartitionIterationRSGARCH(Nodes_initial,logRet,sigma2,Mdl,h,varargin)
if nargin<=4
    h = 30;
end
parseObj = inputParser;
functionName='Vol_ClusterPartitionIterationRSGARCH';
addParameter(parseObj,'Innovation_Distribution','NORMAL',@(x)validateattributes(x,{'string','char'},{''},functionName));
parse(parseObj,varargin{:});
1
innovation_distribution=parseObj.Results.Innovation_Distribution;

if strcmp(innovation_distribution,'NORMAL')
    sigma2_PieceRSGARCH = zeros(size(logRet));
    for i1 = 1 : numel(Nodes_initial)-1
        index=Nodes_initial(i1):Nodes_initial(i1+1)-1;
        if Nodes_initial(i1+1)-Nodes_initial(i1)>=h
            if strcmp(Mdl.startvalopt{1,1},'YES')
                estimation = swgarch(logRet(index),Mdl.k,Mdl.innovation,Mdl.model,Mdl.constraint,Mdl.startvalopt,Mdl.startvalG,Mdl.startvalM);
            else
                estimation = swgarch(logRet(index),Mdl.k,Mdl.innovation,Mdl.model,Mdl.constraint,Mdl.startvalopt);
            end
            sigma2_PieceRSGARCH(index) = estimation.H(2:end);
        else
            sigma2_PieceRSGARCH(index) = sigma2(index);
        end
    end
    N = Nodes_initial(end);
    if numel(sigma2)-Nodes_initial(end)>=h
        if strcmp(Mdl.startvalopt{1,1},'YES')
            estimation = swgarch(logRet(N:end),Mdl.k,Mdl.innovation,Mdl.model,Mdl.constraint,Mdl.startvalopt,Mdl.startvalG,Mdl.startvalM);
        else
            estimation = swgarch(logRet(N:end),Mdl.k,Mdl.innovation,Mdl.model,Mdl.constraint,Mdl.startvalopt);
        end
        sigma2_PieceRSGARCH(N:end) = estimation.H(2:end);
    else
        sigma2_PieceRSGARCH(N:end) = sigma2(N:end);
    end
    % 分段GARCH波动率聚类分割
    [LB_iterated,J_iterated,~] = Fisher_div_sqr(sigma2_PieceRSGARCH,h);
    K_iterated = OptimalClusterNumber(sigma2_PieceRSGARCH,LB_iterated);% 确定最优分类数
    [sigma2_iterated,Nodes_iterated] = Vol_ClusterPartition(sigma2_PieceRSGARCH,K_iterated,J_iterated);
    % 迭代过程
    IterationTime = 0;
    while ~isequal(Nodes_initial,Nodes_iterated) && IterationTime<100
        IterationTime = IterationTime + 1;
        Nodes_initial = Nodes_iterated;
        sigma2_PieceRSGARCH = zeros(size(logRet));
        for i1 = 1 : numel(Nodes_initial)-1
            index=Nodes_initial(i1):Nodes_initial(i1+1)-1;
            if Nodes_initial(i1+1)-Nodes_initial(i1)>=h
                if strcmp(Mdl.startvalopt{1,1},'YES')
                    estimation = swgarch(logRet(index),Mdl.k,Mdl.innovation,Mdl.model,Mdl.constraint,Mdl.startvalopt,Mdl.startvalG,Mdl.startvalM);
                else
                    estimation = swgarch(logRet(index),Mdl.k,Mdl.innovation,Mdl.model,Mdl.constraint,Mdl.startvalopt);
                end
                sigma2_PieceRSGARCH(index) = estimation.H(2:end);
            else
                sigma2_PieceRSGARCH(index) = sigma2(index);
            end
        end
        N = Nodes_initial(end);
        if numel(sigma2)-Nodes_initial(end)>=h
            if strcmp(Mdl.startvalopt{1,1},'YES')
                estimation = swgarch(logRet(N:end),Mdl.k,Mdl.innovation,Mdl.model,Mdl.constraint,Mdl.startvalopt,Mdl.startvalG,Mdl.startvalM);
            else
                estimation = swgarch(logRet(N:end),Mdl.k,Mdl.innovation,Mdl.model,Mdl.constraint,Mdl.startvalopt);
            end
            sigma2_PieceRSGARCH(N:end) = estimation.H(2:end);
        else
            sigma2_PieceRSGARCH(N:end) = sigma2(N:end);
        end
        % 分段GARCH波动率聚类分割
        [LB_iterated,J_iterated,~] = Fisher_div_sqr(sigma2_PieceRSGARCH,h);
        K_iterated = OptimalClusterNumber(sigma2_PieceRSGARCH,LB_iterated);% 确定最优分类数
        [sigma2_iterated,Nodes_iterated] = Vol_ClusterPartition(sigma2_PieceRSGARCH,K_iterated,J_iterated);
    end
else
    sigma2_PieceRSGARCH = zeros(size(logRet));
    for i1 = 1 : numel(Nodes_initial)-1
        index=Nodes_initial(i1):Nodes_initial(i1+1)-1;
        if Nodes_initial(i1+1)-Nodes_initial(i1)>=h
            if strcmp(Mdl.startvalopt{1,1},'YES')
                estimation = swgarch(logRet(index),Mdl.k,Mdl.innovation,Mdl.model,Mdl.constraint,Mdl.startvalopt,Mdl.startvalG,Mdl.startvalM,Mdl.param_dist);
            else
                estimation = swgarch(logRet(index),Mdl.k,Mdl.innovation,Mdl.model,Mdl.constraint,Mdl.startvalopt);
            end
            sigma2_PieceRSGARCH(index) = estimation.H(2:end);
        else
            sigma2_PieceRSGARCH(index) = sigma2(index);
        end
    end
    N = Nodes_initial(end);
    if numel(sigma2)-Nodes_initial(end)>=h
        if strcmp(Mdl.startvalopt{1,1},'YES')
            estimation = swgarch(logRet(N:end),Mdl.k,Mdl.innovation,Mdl.model,Mdl.constraint,Mdl.startvalopt,Mdl.startvalG,Mdl.startvalM,Mdl.param_dist);
        else
            estimation = swgarch(logRet(N:end),Mdl.k,Mdl.innovation,Mdl.model,Mdl.constraint,Mdl.startvalopt);
        end
        sigma2_PieceRSGARCH(N:end) = estimation.H(2:end);
    else
        sigma2_PieceRSGARCH(N:end) = sigma2(N:end);
    end
    % 分段GARCH波动率聚类分割
    [LB_iterated,J_iterated,~] = Fisher_div_sqr(sigma2_PieceRSGARCH,h);
    K_iterated = OptimalClusterNumber(sigma2_PieceRSGARCH,LB_iterated);% 确定最优分类数
    [sigma2_iterated,Nodes_iterated] = Vol_ClusterPartition(sigma2_PieceRSGARCH,K_iterated,J_iterated);
    % 迭代过程
    IterationTime = 0;
    while ~isequal(Nodes_initial,Nodes_iterated) && IterationTime<100
        IterationTime = IterationTime + 1;
        Nodes_initial = Nodes_iterated;
        sigma2_PieceRSGARCH = zeros(size(logRet));
        for i1 = 1 : numel(Nodes_initial)-1
            index=Nodes_initial(i1):Nodes_initial(i1+1)-1;
            if Nodes_initial(i1+1)-Nodes_initial(i1)>=h
                if strcmp(Mdl.startvalopt{1,1},'YES')
                    estimation = swgarch(logRet(index),Mdl.k,Mdl.innovation,Mdl.model,Mdl.constraint,Mdl.startvalopt,Mdl.startvalG,Mdl.startvalM,Mdl.param_dist);
                else
                    estimation = swgarch(logRet(index),Mdl.k,Mdl.innovation,Mdl.model,Mdl.constraint,Mdl.startvalopt);
                end
                sigma2_PieceRSGARCH(index) = estimation.H(2:end);
            else
                sigma2_PieceRSGARCH(index) = sigma2(index);
            end
        end
        N = Nodes_initial(end);
        if numel(sigma2)-Nodes_initial(end)>=h
            if strcmp(Mdl.startvalopt{1,1},'YES')
                estimation = swgarch(logRet(N:end),Mdl.k,Mdl.innovation,Mdl.model,Mdl.constraint,Mdl.startvalopt,Mdl.startvalG,Mdl.startvalM,Mdl.param_dist);
            else
                estimation = swgarch(logRet(N:end),Mdl.k,Mdl.innovation,Mdl.model,Mdl.constraint,Mdl.startvalopt);
            end
            sigma2_PieceRSGARCH(N:end) = estimation.H(2:end);
        else
            sigma2_PieceRSGARCH(N:end) = sigma2(N:end);
        end
        % 分段GARCH波动率聚类分割
        [LB_iterated,J_iterated,~] = Fisher_div_sqr(sigma2_PieceRSGARCH,h);
        K_iterated = OptimalClusterNumber(sigma2_PieceRSGARCH,LB_iterated);% 确定最优分类数
        [sigma2_iterated,Nodes_iterated] = Vol_ClusterPartition(sigma2_PieceRSGARCH,K_iterated,J_iterated);
    end
end
end

