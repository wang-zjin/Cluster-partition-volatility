%% Fisher���ŷָ
% ֱ��D���������е����ֵ��ƽ����

function [LB,J,D] = Fisher_div_sqr(sigma2,h,D)

T = numel(sigma2);
if T<100000
    if nargin < 3
        D = zeros(T,T);  %����ֱ��
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
    % LB = zeros(T,T); % ������ʧ����
    % J = ones(T,T);   % ��LP(n,k)�ָ���һ���ָ��
    LB = nan(T,min(T,floor(T/h))-1); % ������ʧ����
    J = nan(T,min(T,floor(T/h))-1);   % ��LP(n,k)�ָ���һ���ָ��
    for k = 2 : min(T,floor(T/h))-1 % ������k���Ӷ����࿪ʼ����ൽfloor(T/h)-1����
        for n = h*k : T % ��������n����Ϊh*k���������T��
            minLP = 10^300;
            strcat('k:',num2str(k),' n:',num2str(n))
            if k == 2
                for j = h*(k-1)+1 : n-h+1 % �ָ��j����h*(k-1)+1��ʼ�ң�����n-h+1
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
    LB = nan(T,min(T,floor(T/h))-1); % ������ʧ����
    J = nan(T,min(T,floor(T/h))-1);   % ��LP(n,k)�ָ���һ���ָ��
    for k = 2 : min(T,floor(T/h))-1 % ������k���Ӷ����࿪ʼ����ൽfloor(T/h)-1����
        for n = h*k : T % ��������n����Ϊh*k���������T��
            minLP = 10^300;
            strcat('k:',num2str(k),' n:',num2str(n))
            if k == 2
                for j = h*(k-1)+1 : n-h+1 % �ָ��j����h*(k-1)+1��ʼ�ң�����n-h+1
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