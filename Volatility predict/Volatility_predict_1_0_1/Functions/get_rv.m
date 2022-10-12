% Realised volatility
%
% Input:
%
%        Read_Name               Input excel name of raw index, like 'DAX_0608.xlsx'
%
%        Time_Outsample          Time for out-of-sample, like
%                                [2021,05,18;2022,05,18], the first row is
%                                the starting date, the second row is the
%                                end date. If only one row, like
%                                [2021,05,18], then the default end date is
%                                the last date of input data.
% Output:
%
%    rv                          Realised volatility

function rv=get_rv(Read_Name,Time_Outsample)

datatable=readtable(Read_Name);
if size(Time_Outsample,1)>1
    Start_Outsample=Time_Outsample(1,:);
    End_Outsample=Time_Outsample(2,:);
    oos_index=and(datatable.Date>=datetime(Start_Outsample(1),Start_Outsample(2),Start_Outsample(3)),...
                  datatable.Date<=datetime(End_Outsample(1),End_Outsample(2),End_Outsample(3)));
else
    Start_Outsample=Time_Outsample(1,:);
    oos_index=datatable.Date>=datetime(Start_Outsample(1),Start_Outsample(2),Start_Outsample(3));
end

rv=datatable.RV(oos_index);

end

