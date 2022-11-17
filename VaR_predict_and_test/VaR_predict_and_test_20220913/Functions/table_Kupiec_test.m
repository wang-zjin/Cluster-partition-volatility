% To generate table which reports Kupiec test of VaR estimate
%
% Input:
%
%        VaRPredict              Predicted VaR
%
%        logRet                  Log return of out-of-sample
%
%    ConfidenceLevel             Confidence level, like 0.1, 0.05. Could be
%                                a vector
%
% Output:
%
%    TableOutput                 Output table containing test information
%
%    ConfidenceLevel_Label       Confidence label
%
function [TableOutput,ConfidenceLevel_Label]=table_Kupiec_test(VaRPredict,logRet,ConfidenceLevel)
format short
switch nargin
    case 2
        ConfidenceLevel = 0.05;
end
outsampleSize=numel(logRet);
% make label of table
Confidence_Length=numel(ConfidenceLevel);
ConfidenceLevel_Label=cell(1,Confidence_Length);
ConfidenceLevel=reshape(ConfidenceLevel,Confidence_Length,1);
for i=1:Confidence_Length
    ConfidenceLevel_Label{1,i}=['CL',num2str(ConfidenceLevel(i))];
end

TableOutput=zeros(3,length(ConfidenceLevel));
for i = 1:Confidence_Length
    TableOutput(1,i)=ConfidenceLevel(i);
    TableOutput(2,i)=sum(VaRPredict(:,i)>logRet);
    TableOutput(3,i)=roundn(LR_PF(TableOutput(2,i),outsampleSize,TableOutput(1,i)),-2);
    TableOutput(4,i)=chi2cdf(TableOutput(3,i),1);  
end
TableOutput=array2table(TableOutput,'RowNames',{'Confidence level','Failures','Kupiec Test','Significance'},'VariableNames',ConfidenceLevel_Label);
end