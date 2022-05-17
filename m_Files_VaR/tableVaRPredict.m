%% To generate table which reports Kupiec test of VaR estimate
function TableOutput=tableVaRPredict(VaRPredict,logRet,outsampleStart,outsampleEnd,ConfidenceLevel)

format long
switch nargin
    case 4
        ConfidenceLevel = 0.05;
end
Ret=logRet(outsampleStart : outsampleEnd);
outsampleSize=numel(outsampleStart:outsampleEnd);
% make label of table
confidenceSize=numel(ConfidenceLevel);
ConfidenceLevelLabel=cell(1,confidenceSize);
for i=1:confidenceSize
    ConfidenceLevelLabel{1,i}=['CL',num2str(i)];
end
TableMatrix=nan(3,confidenceSize+1);
TableMatrix(1,1:end-1)=1-ConfidenceLevel;
for i = 1:confidenceSize
    TableMatrix(2,i)=sum(VaRPredict(:,i)>Ret);
    TableMatrix(3,i)=roundn(LR_PF(sum(VaRPredict(:,i)>Ret),outsampleSize,ConfidenceLevel(i)),-2);
end
TableMatrix(2,end)=roundn((1-sum(sum(VaRPredict>Ret))/numel(ConfidenceLevel)/outsampleSize)*100,-2);
TableOutput=array2table(TableMatrix,'VariableNames',[ConfidenceLevelLabel,'Accuracy'],'RowNames',{'Confidence Level','Failures(%)', 'Kupiec Statistics'});

end