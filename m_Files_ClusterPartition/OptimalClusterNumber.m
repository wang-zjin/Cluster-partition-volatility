%% 确定最优分割数
function N = OptimalClusterNumber(sigma,LB)

N=size(LB,2);y=zeros(N,1);
for k = 2:N
    y(k)=log(numel(sigma))*k/numel(sigma) + log(LB(numel(sigma),k)/numel(sigma));
end
N=find(y==min(y(2:end)))+1;

end