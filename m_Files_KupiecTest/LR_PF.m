function LR  = LR_PF(x,n,p_star )
% LR statistic�������ɶ�Ϊ1�Ŀ����ֲ�
% x:ʧ��������
% n����������
% p_star:null pypothesis failure rate��

% LR = 2 * log( ( (1-x./n).^(n-x).*(x/n).^x) )...
%     -2 * log( ( (1-p_star).^(n-x).*(p_star).^x) );

LR = 2 * log( ( ((1-x./n)/(1-p_star)).^(n-x) .* (x/n/p_star).^x) );


end