function tableOptionPredict(MAE_CP,MAE_GARCH,MAE_EGARCH,MAE_RSGARCH,MSE_CP,MSE_GARCH,MSE_EGARCH,MSE_RSGARCH)
 
format long
Model={'GARCH';[];'EGARCH';[];'RSGARCH';[];'Cluster Partition';[]};
MAE_Call=[roundn(mean(MAE_GARCH(:,1)),-2);roundn(std(MAE_GARCH(:,1)),-2);roundn(mean(MAE_EGARCH(:,1)),-2);roundn(std(MAE_EGARCH(:,1)),-2);...
    roundn(mean(MAE_RSGARCH(:,1)),-2);roundn(std(MAE_RSGARCH(:,1)),-2);roundn(mean(MAE_CP(:,1)),-2);roundn(std(MAE_CP(:,1)),-3)];
MAE_Put=[roundn(mean(MAE_GARCH(:,2)),-2);roundn(std(MAE_GARCH(:,2)),-2);roundn(mean(MAE_EGARCH(:,2)),-2);roundn(std(MAE_EGARCH(:,2)),-2);...
    roundn(mean(MAE_RSGARCH(:,2)),-2);roundn(std(MAE_RSGARCH(:,2)),-2);roundn(mean(MAE_CP(:,2)),-2);roundn(std(MAE_CP(:,2)),-2)];
MSE_Call=[roundn(mean(MSE_GARCH(:,1)),-2);roundn(std(MSE_GARCH(:,1)),-2);roundn(mean(MSE_EGARCH(:,1)),-2);roundn(std(MSE_EGARCH(:,1)),-2);...
    roundn(mean(MSE_RSGARCH(:,1)),-2);roundn(std(MSE_RSGARCH(:,1)),-2);roundn(mean(MSE_CP(:,1)),-2);roundn(std(MSE_CP(:,1)),-2)];
MSE_Put=[roundn(mean(MSE_GARCH(:,2)),-2);roundn(std(MSE_GARCH(:,2)),-2);roundn(mean(MSE_EGARCH(:,2)),-2);roundn(std(MSE_EGARCH(:,2)),-2);...
    roundn(mean(MSE_RSGARCH(:,2)),-2);roundn(std(MSE_RSGARCH(:,2)),-2);roundn(mean(MSE_CP(:,2)),-2);roundn(std(MSE_CP(:,2)),-2)];
table(Model,MAE_Call,MAE_Put,MSE_Call,MSE_Put)


% fprintf('��Cluster Partitionģ�͹��Ƴ����Ŀ�����Ȩ�۸�MAEΪ%2g��\n',mean(MAE_CP(:,1))  );%2.40363
% fprintf('��Cluster Partitionģ�͹��Ƴ����Ŀ�����Ȩ�۸�MAE��׼��Ϊ%2g��\n',std(MAE_CP(:,1))  );%1.29983
% fprintf('��Cluster Partitionģ�͹��Ƴ����Ŀ�����Ȩ�۸�MAEΪ%2g��\n',mean(MAE_CP(:,2))  );%35.8409
% fprintf('��Cluster Partitionģ�͹��Ƴ����Ŀ�����Ȩ�۸�MAE��׼��Ϊ%2g��\n',std(MAE_CP(:,2))  );%34.7614
% fprintf('��Cluster Partitionģ�͹��Ƴ����Ŀ�����Ȩ�۸�MSEΪ%2g��\n',mean(MSE_CP(:,1))  );%174.005
% fprintf('��Cluster Partitionģ�͹��Ƴ����Ŀ�����Ȩ�۸�MSE��׼��Ϊ%2g��\n',std(MSE_CP(:,1))  );%103.655
% fprintf('��Cluster Partitionģ�͹��Ƴ����Ŀ�����Ȩ�۸�MSEΪ%2g��\n',mean(MSE_CP(:,2))  );%2603.08
% fprintf('��Cluster Partitionģ�͹��Ƴ����Ŀ�����Ȩ�۸�MSE��׼��Ϊ%2g��\n',std(MSE_CP(:,2))  );%4249.13
% fprintf('��GARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MAEΪ%2g��\n',mean(MAE_GARCH(:,1))  );%28.7299
% fprintf('��GARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MAE��׼��Ϊ%2g��\n',std(MAE_GARCH(:,1))  );%31.1237
% fprintf('��GARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MAEΪ%2g��\n',mean(MAE_GARCH(:,2))  );%61.3002
% fprintf('��GARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MAE��׼��Ϊ%2g��\n',std(MAE_GARCH(:,2))  );%62.3814
% fprintf('��GARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MSEΪ%2g��\n',mean(MSE_GARCH(:,1))  );%2057.37
% fprintf('��GARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MSE��׼��Ϊ%2g��\n',std(MSE_GARCH(:,1))  );%4166.09
% fprintf('��GARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MSEΪ%2g��\n',mean(MSE_GARCH(:,2))  );%7692.15
% fprintf('��GARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MSE��׼��Ϊ%2g��\n',std(MSE_GARCH(:,2))  );%14289.8
% fprintf('��EGARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MAEΪ%2g��\n',mean(MAE_EGARCH(:,1))  );%28.644
% fprintf('��EGARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MAE��׼��Ϊ%2g��\n',std(MAE_EGARCH(:,1))  );%30.9312
% fprintf('��EGARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MAEΪ%2g��\n',mean(MAE_EGARCH(:,2))  );%61.2143
% fprintf('��EGARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MAE��׼��Ϊ%2g��\n',std(MAE_EGARCH(:,2))  );%62.2313
% fprintf('��EGARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MSEΪ%2g��\n',mean(MSE_EGARCH(:,1))  );%2038.33
% fprintf('��EGARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MSE��׼��Ϊ%2g��\n',std(MSE_EGARCH(:,1))  );%4107.11
% fprintf('��EGARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MSEΪ%2g��\n',mean(MSE_EGARCH(:,2))  );%7662.52
% fprintf('��EGARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MSE��׼��Ϊ%2g��\n',std(MSE_EGARCH(:,2))  );%14207.8
% fprintf('��RSGARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MAEΪ%2g��\n',mean(MAE_RSGARCH(:,1))  );%16.4321
% fprintf('��RSGARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MAE��׼��Ϊ%2g��\n',std(MAE_RSGARCH(:,1))  );%21.5605
% fprintf('��RSGARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MAEΪ%2g��\n',mean(MAE_RSGARCH(:,2))  );%45.9537
% fprintf('��RSGARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MAE��׼��Ϊ%2g��\n',std(MAE_RSGARCH(:,2))  );%51.4403
% fprintf('��RSGARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MSEΪ%2g��\n',mean(MSE_RSGARCH(:,1))  );%6017.71
% fprintf('��RSGARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MSE��׼��Ϊ%2g��\n',std(MSE_RSGARCH(:,1))  );%10341.6
% fprintf('��RSGARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MSEΪ%2g��\n',mean(MSE_RSGARCH(:,2))  );%9785.36
% fprintf('��RSGARCHģ�͹��Ƴ����Ŀ�����Ȩ�۸�MSE��׼��Ϊ%2g��\n',std(MSE_RSGARCH(:,2))  );%16148.1