%% Fisher最优分割法
% 直径D是其中所有点与均值的平方和

function [LB,J,D] = Fisher_div_sqr(sigma2,h,D)

T = numel(sigma2);
if T<100000
    if nargin < 3
        D = zeros(T,T);  %计算直径
        for i = 1 : T
            strcat('D:',num2str(i))
            for j = i : T
                D(i,j) = sum(    (    sigma2(i:j) - mean(sigma2(i:j)) ).^2            );
                %                 D(i,j) = (std(sigma2(i:j))*(j-i+1)).^2;
            end
        end
        for i = 1 : T
            for j = 1 : i
                D(i,j) = D(j,i);
            end
        end
    end
    % LB = zeros(T,T); % 最优损失函数
    % J = ones(T,T);   % 对LP(n,k)分割，最后一个分割点
    LB = nan(T,min(T,floor(T/h))-1); % 最优损失函数
    J = nan(T,min(T,floor(T/h))-1);   % 对LP(n,k)分割，最后一个分割点
    for k = 2 : min(T,floor(T/h))-1 % 分类数k，从二分类开始，最多到floor(T/h)-1分类
        for n = h*k : T % 样本数量n至少为h*k个，最多是T个
            minLP = 10^300;
            strcat('k:',num2str(k),' n:',num2str(n))
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
            strcat('k:',num2str(k),' n:',num2str(n))
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