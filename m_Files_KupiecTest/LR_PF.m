function LR  = LR_PF(x,n,p_star )
% LR statistic符合自由度为1的卡方分布
% x:失败天数；
% n：总天数；
% p_star:null pypothesis failure rate；

% LR = 2 * log( ( (1-x./n).^(n-x).*(x/n).^x) )...
%     -2 * log( ( (1-p_star).^(n-x).*(p_star).^x) );

LR = 2 * log( ( ((1-x./n)/(1-p_star)).^(n-x) .* (x/n/p_star).^x) );


end