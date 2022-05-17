function test1ElementCluster(J,T,ClusterNumber)

K=ClusterNumber;
Nodes = ones(K , 1);
n1 = T;
for k = K : -1 : 2
    Nodes(k) = J(n1 ,k); % Nodes���ǽ�T�������ֳ�k�࣬ÿ���Ӽ��ĵ�һ��Ԫ��
    n1 = Nodes(k) - 1;
end
NodesOnes=zeros(size(Nodes));
for i=2:numel(NodesOnes)
    if Nodes(i)-Nodes(i-1)==1
        NodesOnes(i)=1;
    end
end
if sum(NodesOnes)>0
    fprintf('��K=%4dʱ����һ����Ϊһ��������\n',K);
else
    fprintf('��K=%4dʱ������һ����Ϊһ��������\n',K);
end