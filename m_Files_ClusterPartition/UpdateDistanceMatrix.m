%% Online��Fisher���ŷָ�������
% input: sigma2�ǵ�����ʱ�����У�
%        D������ľ������
%        sigma2_new�����������ʱ������
%        
%        ���ǵ�Ŀ�����������µ�����sigma2_new��ɾ��sigma2��ԭ�е���Զ�Ĺ۲�ֵ��
%        ���¾������D

% ����ļ������������е����ֵ��ƽ����

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
