% Fisher division method
%
% Input:
%
%        sigma2                  Data to be partitioned
%
%        h                       Minimum length of one cluster
%
%        D                       Pre-determined distance matrix, T-by-T, of
%                                which D(i,j) means distance of data from i
%                                to j
%
% Output:
%
%        LB                      Matrix of best loss function value,
%                                element of row i column j means loss
%                                function value of i data into j clusters
%
%
%        J                       Matrix, of which row i column j J(i,j)
%                                means the index of the last cluster of j
%                                clusters in total i data
%
%        D                       Calculated distance matrix, T-by-T, of
%                                which D(i,j) means distance of data from i
%                                to j

function [LB,J,D] = Fisher_div_sqr(sigma2,h,D)
T = numel(sigma2);
if T<100000
    if nargin < 3
        D = zeros(T,T);  %计算直径
        %i = 1 : T;
        %j = 1 : T;
        parfor i = 1 : T
        %strcat('D:',num2str(i));
            for j = 1 : T
                D(i,j) = sum(    (    sigma2(i:j) - mean(sigma2(i:j)) ).^2            );
            end
        end
    else
        if length(sigma2)==length(D)
            D(1:end-1,1:end-1)=D(2:end,2:end);
            %i = 1 : T;
            parfor i = 1 : T
                D(i,end)=sum((sigma2(i:end)-mean(sigma2(i:end)).^2));
            end
            D(end,:)=D(:,end)';
        else
            warning('Size of Distance matrix and length of sigma2 do not match.')
        end
    end
    % LB = zeros(T,T); % 最优损失函数
    % J = ones(T,T);   % 对LP(n,k)分割，最后一个分割点
    LB = nan(T,min(T,floor(T/h))-1); % 最优损失函数
    J = nan(T,min(T,floor(T/h))-1);   % 对LP(n,k)分割，最后一个分割点
    for k = 2 : min(T,floor(T/h))-1 % 分类数k，从二分类开始，最多到floor(T/h)-1分类
        for n = h*k : T % 样本数量n至少为h*k个，最多是T个
            minLP = 10^300;
            minJ=[];
            %strcat('k:',num2str(k),' n:',num2str(n));
            if k == 2
                for j = h*(k-1)+1 : n-h+1 % 分割点j，从h*(k-1)+1开始找，找至n-h+1
                    d = D(1,j-1)+D(j,n);
                    if d < minLP
                        minLP = d;
                        minJ = j;
                    end
                end
            else
                for j = h*(k-1)+1 : n-h+1
                    d = LB(j-1,k-1) + D(j,n);
                    if d < minLP
                        minLP = d;
                        minJ = j;
                    end
                end
            end
            LB(n,k) = minLP;
            J(n,k) = minJ;
        end
    end   
else
    LB = nan(T,min(T,floor(T/h))-1); % 最优损失函数
    J = nan(T,min(T,floor(T/h))-1);   % 对LP(n,k)分割，最后一个分割点
    for k = 2 : min(T,floor(T/h))-1 % 分类数k，从二分类开始，最多到floor(T/h)-1分类
        for n = h*k : T % 样本数量n至少为h*k个，最多是T个
            minLP = 10^300;
            strcat('k:',num2str(k),' n:',num2str(n));
            if k == 2
                for j = h*(k-1)+1 : n-h+1 % 分割点j，从h*(k-1)+1开始找，找至n-h+1
                    %                     d = std(sigma2(1:j-1))*(j-1)+std(sigma2(j:n))*(n-j+1);
                    d = sum( ( sigma2(1:j-1) - mean(sigma2(1:j-1)) ).^2 )...
                        +sum( ( sigma2(j:n) - mean(sigma2(j:n)) ).^2 );
                    if d < minLP
                        minLP = d;
                        minJ = j;
                    end
                end
            else
                for j = h*(k-1)+1 : n-h+1
                    d = LB(j-1,k-1) + sum( ( sigma2(j:n) - mean(sigma2(j:n)) ).^2 );
                    %                     d = LB(j-1,k-1) + std(sigma2(j:n))*(n-j+1);
                    if d < minLP
                        minLP = d;
                        minJ = j;
                    end
                end
            end
            LB(n,k) = minLP;
            J(n,k) = minJ;
        end
    end
end
J(:,1) = 1;
end

