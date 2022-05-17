% find optimal split points
function Nodes = OptimalSplitPoint(sigma2,J,N)

T = numel(sigma2);
Nodes=ones(N,1);
for n = N : -1 : 2
    Nodes(n)=J(T,n);
    T=Nodes(n)-1;
end