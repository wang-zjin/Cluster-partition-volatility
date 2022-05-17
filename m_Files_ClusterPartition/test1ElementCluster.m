function test1ElementCluster(J,T,ClusterNumber)

K=ClusterNumber;
Nodes = ones(K , 1);
n1 = T;
for k = K : -1 : 2
    Nodes(k) = J(n1 ,k); % Nodes就是将T个样本分成k类，每个子集的第一个元素
    n1 = Nodes(k) - 1;
end
NodesOnes=zeros(size(Nodes));
for i=2:numel(NodesOnes)
    if Nodes(i)-Nodes(i-1)==1
        NodesOnes(i)=1;
    end
end
if sum(NodesOnes)>0
    fprintf('当K=%4d时存在一个点为一类的情况。\n',K);
else
    fprintf('当K=%4d时不存在一个点为一类的情况。\n',K);
end