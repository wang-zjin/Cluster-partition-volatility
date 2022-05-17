%% Cluster partitionģ�ͽ�sigma��ΪK��
% J����Fisher�ָ��㷨������ķָ�ڵ㣬��һ��T*K����(T���������ȣ�K�Ƿ�����)
% Time��һ��T*3���󣬱�ʾÿ�����ݵ�ʱ�䣺��-��-��
function [sigma_hat,TimeTable,Nodes] = Vol_ClusterPartition(sigma,K,J,Time)

% K:������
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
    %     TimeTable = zeros(K,3); % ÿ������ڵ��ʱ��
    %     for i = 1 : K
    %         TimeTable(i,:) = Time(Nodes(i),:);
    %     end
    TimeTable = cell(K,1); % ÿ������ڵ��ʱ��
    for i = 1 : K
        TimeTable{i,1} = datestr(Time(Nodes(i),:));
    end
else
    TimeTable=[];
end

end