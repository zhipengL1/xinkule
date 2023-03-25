clc 
clear all 
close all
%% 加载数据
load assetData_mpsm.mat;
%% 资产价格转化为资产收益率
% 投资收益率
assetRet = price2ret(assetData_mpsm);
% 平均投资收益率
MeanassetRet = mean(assetRet);
% 风险资产列表
assetList = {'AAPL', 'AEP', 'AIG', 'AMGN', 'AXP', 'BAC', 'BA', 'CAT', 'CMCSA', 'CVX', 'DUK', 'FDX', 'F', 'GE', 'HD', 'HON', 'INTC', 'JNJ', 'JPM', 'KO', 'MCD', 'MDT', 'MSFT', 'NKE', 'PG', 'SLB', 'T', 'UNH', 'WMT', 'XOM'};
%% 创建Portfolio对象
pmv = Portfolio('AssetList',assetList);
%% 设置风险资产的期望收益率和协方差矩阵
pmv = pmv.estimateAssetMoments(assetRet);
assetMean = pmv.AssetMean;
assetCovar = pmv.AssetCovar;
assetRisk = sqrt(diag(assetCovar));
pmv = pmv.setAssetMoments(assetMean,assetRisk);
%% lower-level 
% quadprog
H = assetCovar*2;
A = -MeanassetRet;
b = -0.05/252; % 论文中设定
Aeq = ones(1,30);
f = zeros(30,1);
beq = 1;
lb = zeros(30,1);
y = quadprog(H,f,A,b,Aeq,beq,lb);
%% upper-level
% sdpt3
%定义问题数据
k = y'*assetCovar*y; % lower-level最优解
C = chol(assetCovar); % Cholesky分解矩阵
p = 0.004; % tolerance parameter
r = assetRet';
m = 0.95;
L = 0.05;
% 定义优化变量
x = sdpvar(length(MeanassetRet),1);
v = sdpvar(1);

% 定义目标函数
obj = -(MeanassetRet*x); 

% 定义约束条件
F0 = [sum(x)==1]; % 等式约束
F1 = [norm(C*x)<=sqrt(k+p),x>=0]; % 不等式约束

z  = x'*r;
%zt = sdpvar(1,length(assetRet));
zt = z-v;
F2 = [];
F2 = [F2; zt>=-z-v];
F2 = [F2; zt>=0];

s_zt = sum(zt);
F3 = [s_zt/((1-m)*length(assetRet))<=L-v];

constraints = [F0,F1,F2,F3];

% 定义优化设置
options = sdpsettings('verbose',2,'solver','sdpt3'); 

%求解优化问题
result = optimize(constraints,obj,options);

%显示结果
disp(double(x'));
%disp(double(v));
disp(double(obj));


