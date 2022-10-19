% Choose optimal number of clusters
%
% Input:
%
%        sigma                   Volatility
%
%        LB                      Matrix of best loss function value,
%                                element of row i column j means loss
%                                function value of i data into j clusters
%
% Output:
%
%        N                       Number of clusters

function N = OptimalClusterNumber(sigma,LB)
N=size(LB,2);y=nan(N,1);
for k = 2:N
    y(k)=log(numel(sigma))*k/numel(sigma) + log(LB(numel(sigma),k)/numel(sigma));
end
N=find(y==min(y),1);
end

