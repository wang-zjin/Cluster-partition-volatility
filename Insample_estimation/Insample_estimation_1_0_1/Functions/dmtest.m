% DM test
%
% Input:
%
%        e1                      Volatility
%
%        e2                      Number of clusters
%
%        h                       Forecast date
%
% Output:
%
%        DM                      DM test 

function DM = dmtest(e1, e2, h)
if nargin < 2
    error('dmtest:TooFewInputs','At least two arguments are required');
end
if nargin < 3
    h = 1;
end
if size(e1,1) ~= size(e2,1) || size(e1,2) ~= size(e2,2)
    error('dmtest:InvalidInput','Vectors should be of equal length');
end
if size(e1,2) > 1 || size(e2,2) > 1
    error('dmtest:InvalidInput','Input should have T rows and 1 column');
end
% Initialization
T = size(e1,1);
% Define the loss differential
d = e1.^2 - e2.^2;
dMean = mean(d);
gamma0 = var(d);
if h > 1
    gamma = zeros(h-1,1);
    for i = 1:h-1
        gamma(i) = ( d(1+i:T)' * d(1:T-i) ) ./ T; % bugfix
    end
    varD = gamma0 + 2*sum(gamma);
else
    varD = gamma0;
end
DM = dMean / sqrt ( (1/T)*varD );
end

