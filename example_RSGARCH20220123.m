%% Regime Switching GARCH估计波动率

clear, clc

addpath('m_Files');    % add 'm_Files' folder to the search path
addpath('data_Files'); % add 'data_Files' folder to the search path
addpath('m_Files_RegimeSwitching'); % add 'data_Files' folder to the search path

load('sampletable');

%% swgarch函数
addpath('m_Files_swgarch');
data = sample(:,4);
errors = data-mean(data);
[estimation, probabilities, diagnostics] = swgarch(errors, 2, 'NORMAL',...
     'KLAASSEN','CONS', {'YES',[]}, [0.1 0.1 0.92;0.01 0.05 0.7], [0.9 0.1;0.1 0.9],...
     [],[]); %#ok<ASGLU>
 GARCHparam=[0.000147229560116949,0.486733101953690,0.296054026778758;
     6.15273128126965e-06,0.245498929533674,0.691016182536070]
 TranM=[0.919527711921031,0.00717571578885008;
     0.0804722880789688,0.992824284211150]

[estimation, probabilities, diagnostics] = swgarch(data, 2, 'NORMAL',...
     'KLAASSEN','CONS', {'YES',[]}, [0.1 0.1 0.92;0.01 0.05 0.7], [0.9 0.1;0.1 0.9],...
     [],[]); 
[estimation, probabilities, diagnostics] = swgarch(logRet, 2, 'NORMAL',...
     'KLAASSEN','CONS', {'YES',[]}, [0.1 0.1 0.92;0.01 0.05 0.7], [0.9 0.1;0.1 0.9],...
     [],[]); 
 figure;plot(estimation.H);diagnostics.LL=-2.494001356624992e+04
%  用error和residual的效果不一样
 [estimation, probabilities, diagnostics] = swgarch(logRet, 2, 'NORMAL',...
     'HAAS','CONS', {'YES',[]}, [0.1 0.1 0.92;0.01 0.05 0.7], [0.9 0.1;0.1 0.9],...
     [],[]); 
 figure;plot(estimation.H);diagnostics.LL=-2.496744172981380e+04;
 [7.827613294830544e-06,0.114397089553337,0.851901049109312;
     8.480981481308070e-06,0.060470849774976,0.694111218252418]
 [0.990911757406945,0.011686840202597;
     0.009088242593055,0.988313159797404]
 
 [estimation, probabilities, diagnostics] = swgarch(logRet, 2, 'NORMAL',...
     'HAAS','CONS', {'YES',[]}, [0.1 0.1 0.92;0.01 0.01 0.7], [0.9 0.1;0.1 0.9],...
     [],[]); 
 figure;plot(estimation.H);diagnostics.LL=-2.4939e+04
 estimation.garch=[1.135683793767303e-05,0.116566698817899,0.883958467213031;3.418406228982027e-06,0.133567931221771,0.791466679116361]
 estimation.transM=0.8756    0.0318
    0.1244    0.9682
 probabilities.predict(end,:)*estimation.garch*[1 logRet(end).^2 estimation.H(end)]'

  [estimation, probabilities, diagnostics] = swgarch(logRet, 2, 'NORMAL',...
     'GRAY','CONS', {'YES',[]}, [0.1 0.1 0.92;0.01 0.01 0.7], [0.9 0.1;0.1 0.9],...
     [],[]); 
 figure;plot(estimation.H);diagnostics.LL=-2.4636e+04
 estimation.garch=0.0003    0.5602    0.0000
    0.0000    0.0097    0.5957
 estimation.transM=0.3673    0.0898
    0.6327    0.9102
 probabilities.smooth(end,:)*estimation.garch*[1 logRet(end).^2 estimation.H(end)]'

 [estimation, probabilities, diagnostics] = swgarch(logRet, 2, 'NORMAL',...
     'GRAY','CONS', {'YES',[]}, [0.1 0.1 0.92;0.01 0.05 0.7], [0.9 0.1;0.1 0.9],...
     [],[]);
 figure;plot(estimation.H);diagnostics.LL=-2.4659e+04
 probabilities.smooth(end,:)*estimation.garch*[1 logRet(end).^2 estimation.H(end)]'
 =1.9380e-04
 
 [estimation, probabilities, diagnostics] = swgarch(logRet, 2, 'NORMAL',...
     'GRAY','CONS', {'YES',[]}, [0.1 0.1 0.92;0.01 0.05 0.7], [0.8 0.2;0.2 0.8],...
     [],[]);
 figure;plot(estimation.H);diagnostics.LL=-2.4897e+04
 probabilities.smooth(end,:)*estimation.garch*[1 logRet(end).^2 estimation.H(end)]'
 =3.3947e-04
 markovSim(10,estimation.transM)
 
 % 换成t分布
 [estimation, probabilities, diagnostics] = swgarch(logRet, 2, 'STUDENTST',...
     'KLAASSEN','CONS', {'YES',[]}, [0.1 0.1 0.92;0.01 0.05 0.7], [0.8 0.2;0.2 0.8],...
     5,[]);
 figure;plot(estimation.H);diagnostics.LL%=-2.4970e+04 图像有误
 probabilities.smooth(end,:)*estimation.garch*[1 logRet(end).^2 estimation.H(end)]'
 %=1.4550e-05
 [estimation, probabilities, diagnostics] = swgarch(logRet, 2, 'STUDENTST',...
     'KLAASSEN','CONS', {'YES',[]}, [0.1 0.1 0.92;0.01 0.05 0.7], [0.8 0.2;0.2 0.8],...
     3,[]);
 figure;plot(estimation.H);diagnostics.LL%=-2.4998e+04 图像有误
 probabilities.smooth(end,:)*estimation.garch*[1 logRet(end).^2 estimation.H(end)]'
 %=9.3516e-06
 [estimation, probabilities, diagnostics] = swgarch(logRet, 2, 'STUDENTST',...
     'HAAS','CONS', {'YES',[]}, [0.1 0.1 0.92;0.01 0.05 0.7], [0.8 0.2;0.2 0.8],...
     50,[]);
 figure;plot(estimation.H);diagnostics.LL%=-2.4992e+04 图像有误
 probabilities.smooth(end,:)*estimation.garch*[1 logRet(end).^2 estimation.H(end)]'
 %=8.3271e-04 
 [estimation, probabilities, diagnostics] = swgarch(logRet, 2, 'STUDENTST',...
     'HAAS','CONS', {'YES',[]}, [0.1 0.1 0.92;0.01 0.05 0.7], [0.8 0.2;0.2 0.8],...
     5,[]);
 figure;plot(estimation.H);diagnostics.LL%=-2.4992e+04 图像有误
 probabilities.smooth(end,:)*estimation.garch*[1 logRet(end).^2 estimation.H(end)]'
 %=8.3271e-04 
 [estimation, probabilities, diagnostics] = swgarch(logRet, 2, 'STUDENTST',...
     'HAAS','CONS', {'YES',[]}, [0.1 0.1 0.92;0.01 0.05 0.7], [0.8 0.2;0.2 0.8],...
     3,[]);
 figure;plot(estimation.H);diagnostics.LL%=-2.4689e+04 图像不错
 probabilities.smooth(end,:)*estimation.garch*[1 logRet(end).^2 estimation.H(end)]'
 %=2.3031e-04
 [estimation, probabilities, diagnostics] = swgarch(logRet, 2, 'STUDENTST',...
     'GRAY','CONS', {'YES',[]}, [0.1 0.1 0.92;0.01 0.05 0.7], [0.8 0.2;0.2 0.8],...
     5,[]);
 figure;plot(estimation.H);diagnostics.LL%=-2.4905e+04 图像不行
 probabilities.smooth(end,:)*estimation.garch*[1 logRet(end).^2 estimation.H(end)]'
 %=2.0531e-04
 [estimation, probabilities, diagnostics] = swgarch(logRet, 2, 'STUDENTST',...
     'GRAY','CONS', {'YES',[]}, [0.1 0.1 0.92;0.01 0.05 0.7], [0.8 0.2;0.2 0.8],...
     3,[]);
 figure;plot(estimation.H);diagnostics.LL%=-2.4828e+04 图像不行
 probabilities.smooth(end,:)*estimation.garch*[1 logRet(end).^2 estimation.H(end)]'
 %=3.4461e-04
 
rmpath('m_Files');    % remove 'm_Files' folder to the search path
rmpath('data_Files'); % remove 'data_Files' folder to the search path
rmpath('m_Files_RegimeSwitching'); % remove 'data_Files' folder to the search path