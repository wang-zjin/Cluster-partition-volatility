%% Online的Fisher最优分割法计算距离
% input: sigma2是单变量时间序列；
%        D是输入的距离矩阵
%        sigma2_new是输入的最新时间序列
%        
%        我们的目的是输入最新的数据sigma2_new，删除sigma2中原有的最远的观测值，
%        更新距离矩阵D

% 距离的计算是其中所有点与均值的平方和

function D = UpdateDistanceMatrix(sigma2,D,sigma2_new)

T = numel(sigma2);
D(:,1) = [];
D(1,:) = [];
D = [D;zeros(1,T-1)];
D_NewColumn = zeros(T,1);
for i = 1 : T-1
    NewSeries=[sigma2(i+1:end);sigma2_new];
    D_NewColumn(i,1) = sum( ( NewSeries - mean(NewSeries) ).^2 );
end
D = [D D_NewColumn];
D(end,:)=D_NewColumn';
