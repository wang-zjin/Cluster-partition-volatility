%% ***************************************************************************************************************************************************************
% Name: Fun_Get_Data.m                                                                                                    % 程序名称
% Version: V1.0
% Author:WRT        Date: 2019/2/26
% Difference from Last Version :                                                                                        %修改后的差异
%
% Description:
%           获取数据，若未更新到最新则需要更新
% Calls:                                                                                                                 % 调用的函数清单
%
% Called By:                                                                                                             % 调用本函数的函数清单
% Table Accessed:
%
% Table Updated:                                                                                                         % 被修改的表（此项仅对于牵扯到数据库操作的程序）
% Input:
%  sStock 指数代码 
% Output:                                                                                                                % 输出参数的说明
%   dIndexTable(1.数值型日期 2-5开高低收 6.成交额 7.成交量（无）8.日期 9.时间 10.星期 11.收益率 12.收益率平方)
% Others:                               null                                                                             % 其它说明
%***************************************************************************************************************************************************************

sRoot = 'D:\99.备份\备份20200905\F盘中大文件夹备份\3.论文\代码\9.增值税改革与融资成本（整理代码）\';

Path_load = [sRoot,'\working_data'];
Path_code = [sRoot,'\codes'];
cycle = '5分钟线'; 
sStock = 'sh000300';

sStockList = xlsread([Path_load,'\StockInforYear_20211125.xlsx']);
sStockList =  unique(sStockList(:, 2));

% 20 21 24 25 26 27
BegT = '20170427T';
EndT = '20170427T +16/24';

%% 获取指数行情数据
% 输出：dIndexTable(1.数值型日期 2-5开高低收 6.成交额 7.成交量（无）8.日期 9.时间 10.星期 11.收益率 12.收益率平方)
ts = actxserver('TSExpert.CoExec');
ts.SetSysParam('Cycle',cycle)
for iStock = 1 : length(sStockList)
    sStock = num2str(sStockList(iStock));
    nZeros = 6 - length(sStock);
    sStock = [repmat('0',1,nZeros),sStock];
    Type_ID = sStock(1:3);
    if strcmp(Type_ID, '000') || strcmp(Type_ID, '002') || strcmp(Type_ID, '300') 
        str_id = ['SZ', sStock];
    elseif strcmp(Type_ID,'600')
        str_id = ['SH', sStock];
    else
    end
    
    Data = ts.RemoteExecute(['return select ["date"],["open"],["high"],["low"],["close"],["vol"],["amount"] ',...
        'from markettable datekey ',BegT,' to ',EndT,'  of "', str_id,'" end;']) ;
    if ~isempty(Data)
        
        % 处理日期
        dOutput = zeros(size(Data, 1) - 1, 7);
        dOutput(:, 2 : 7) = cell2mat(Data(2 : end, 2 : 7));
        dTemp =  cell2mat(Data(2 : end, 1)) + 693960;
        % dTemp_t=datevec(dTemp);
        % dTemp_t = dTemp_t(:, 1) * 10000000000 + dTemp_t(:, 2) * 100000000 + dTemp_t(:, 3) * 1000000 + dTemp_t(:, 4) * 10000 + dTemp_t(:, 5) * 100 + dTemp_t(:, 6);
        dOutput(:, 1) = dTemp;
        
        % 效率比较低，建议改成datev
        dOutput(:, 8) = arrayfun(@(x) str2double(datestr(x,'yyyymmdd')),  dOutput(:, 1));
        dOutput(:, 9)= arrayfun(@(x) str2double(datestr(x,'HHMM')),  dOutput(:, 1));
        [dWeek, ~] = weekday(dOutput(:, 1));
        dOutput(:, 10) = dWeek - 1;
        %     save(sStock,'dOutput')
        % csvwrite([Path_code, '\Trade 20220118 5min\',sStock,'.csv'],dOutput)
        csvwrite([Path_code, '\Trade 20170427 5min\',sStock,'.csv'],dOutput)
        disp(['finish ', sStock])
    else
    end
end

sRoot_trade = [Path_code, '\Trade 20170421 5min'];
sStockInfor = dir(sRoot_trade);
sStockInfor = {sStockInfor.name};
sStockInfor = sStockInfor(3:length(sStockInfor));
cd(sRoot_trade)
dRV = zeros(length(sStockInfor), 2);
for iStock = 1 : length(sStockInfor)
    sStock = sStockInfor{iStock};
    nStock = str2double(sStock(1:length(sStock)-4));
    dData = csvread(sStock);
    dData(:, end + 1) = (log(dData(:, 5)) - log(dData(:, 2))).^2;
    dRV(iStock, :) = [nStock,sum(dData(:, end))];
end

xlswrite([Path_code, '\RealizedVolatility.xlsx'], dRV);    
csvwrite([Path_code, '\RealizedVolatility.csv'],dRV)

dDays = [20170420, 20170421,20170424,20170425,20170426,20170427];
dRV = [];
for iDay = 1 : length(dDays)
    sDay = num2str(dDays(iDay));
    sRoot_trade = [Path_code, '\Trade ',sDay,' 5min'];
    sStockInfor = dir(sRoot_trade);
    sStockInfor = {sStockInfor.name};
    sStockInfor = sStockInfor(3:length(sStockInfor));
    cd(sRoot_trade)
    dRV_T = zeros(length(sStockInfor), 2);
    for iStock = 1 : length(sStockInfor)
        sStock = sStockInfor{iStock};
        nStock = str2double(sStock(1:length(sStock)-4));
        dData = csvread(sStock);
        dData(:, end + 1) = (log(dData(:, 5)) - log(dData(:, 2))).^2;
        dRV_T(iStock, :) = [nStock,sum(dData(:, end))];
    end
    dRV_T(:, end + 1) = dDays(iDay);
    dRV = [dRV; dRV_T];
end

dRV_C = unique(dRV(:, 1));
dRV_C(:, 2 : length(dDays)+1) = nan;
for i = 1 : length(dRV_C)
    nCode = dRV_C(i, 1);
    dTemp = dRV(dRV(:,1) == nCode, :);
    dTemp = sortrows(dTemp, 3);
%     dTemp_T = nan(5, 3);
    dTemp_T = nan(length(dDays), 3);
    dTemp_T(:, 3) = dDays;
    dTemp_T(ismember(dTemp_T(:, 3), dTemp(:, 3)), 1 : 2) = dTemp(:, 1:2);
%     dRV_C(i, 2:end) = [dTemp_T(1,2), mean(dTemp_T(1:2,2)), ...
%         mean(dTemp_T(1:3,2)), mean(dTemp_T(1:4,2)), mean(dTemp_T(1:5,2)), mean(dTemp_T(1:6,2))];
    dRV_C(i, 2:end) = dTemp_T(:, 2)';
%     for iDay = 1 : length(dDays)
%         dTemp_1 = dTemp_T(1,2);
%         if ~isnan(dTemp_1)
%             dRV_C(i, 2) = dTemp_1;
%         else
%         end
%         
%         dTemp_2 = dTemp_T(1:2,2);
%         dTemp_2(isnan(dTemp_2)) = [];
%         if ~isempty(dTemp_2)
%             dRV_C(i, 3) = mean(dTemp_2);
%         else
%         end
%         
%         dTemp_3 = dTemp_T(1:3,2);
%         dTemp_3(isnan(dTemp_3)) = [];
%         if ~isempty(dTemp_3)
%             dRV_C(i, 4) = mean(dTemp_3);
%         else
%         end
%         
%         dTemp_4 = dTemp_T(1:4,2);
%         dTemp_4(isnan(dTemp_4)) = [];
%         if ~isempty(dTemp_4)
%             dRV_C(i, 5) = mean(dTemp_4);
%         else
%         end
%         
%         dTemp_5 = dTemp_T(1:5,2);
%         dTemp_5(isnan(dTemp_5)) = [];
%         if ~isempty(dTemp_5)
%             dRV_C(i, 6) = mean(dTemp_5);
%         else
%         end
%         
%         dTemp_6 = dTemp_T(1:6,2);
%         dTemp_6(isnan(dTemp_6)) = [];
%         if ~isempty(dTemp_6)
%             dRV_C(i, 7) = mean(dTemp_6);
%         else
%         end
%         
%     end
end
dRV_C = [zeros(1, size(dRV_C, 2));dRV_C];
xlswrite([Path_code, '\RealizedVolatility_20220130.xlsx'], dRV_C);    




