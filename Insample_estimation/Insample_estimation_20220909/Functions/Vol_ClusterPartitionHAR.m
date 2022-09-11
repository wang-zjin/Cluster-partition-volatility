% Fitted volatility of piece CPHAR
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
%        X                       Inputs of HAR
%
%        h                       Minimum length of one cluster
%
% Output:
%
%        rv_PieceHAR             Fitted realised volatility of piece HAR
%

function rv_PieceHAR = Vol_ClusterPartitionHAR(Nodes_initial,vt,rv_est,X,h)
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

end


