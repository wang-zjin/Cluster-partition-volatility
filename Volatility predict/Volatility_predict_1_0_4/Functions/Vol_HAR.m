% Estimated volatility and parameters of HAR
%
% Input:
%
%        y                       Log realised volatility
%
%        X                       Right hand side of HAR model
%
% Output:
%
%        v_HAR                   Fitted volatility by HAR
%
%        paras                   Estimated parameters of HAR

function [v_HAR,paras] = Vol_HAR(y,X)
x0=ones(size(y));
lm=fitlm(X,y);
paras=lm.Coefficients.Estimate;
v_HAR=exp([x0 X]*paras);
end

