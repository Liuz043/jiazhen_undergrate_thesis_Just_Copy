PV1 = P_data(1,25:48); 
PV2 = P_data(2,25:48);
PV3 = P_data(3,25:48);
PV4 = P_data(4,25:48);
PV5 = P_data(5,25:48);

PV_avg = [];%用于计算平均每小时光伏发电量
for i = 1:24
    PV_avg(i) = PV1(i) * pi(1) + PV2(i) * pi(2) + PV3(i) * pi(3) + PV4(i) * pi(4) + PV5(i) * pi(5);
end

%% 定义决策变量
P_PV2G = sdpvar(1,24);  % 向电网出售的电量
P_PV2H = sdpvar(1,24);  % 向电制氢主体的售电量

%% 定义约束条件
C2 = [];
for i = 1:24
    C2 = [C2, P_PV2G(i) >= 0];
    C2 = [C2, P_PV2G(i) <= PV_avg(i)];

    C2 = [C2, P_PV2H(i) >= 0];
    C2 = [C2, P_PV2H(i) <= PV_avg(i)];

    C2 = [C2, P_PV2G(i) + P_PV2H(i) == PV_avg(i)];
end

%% 定义目标函数
revenue_PV2G = sum(P_PV2G) * price_PV2G; % 向电网出售的收益
revenue_PV2H = P_PV2H * price_G; % 向电制氢出售的收益

cost_PV_om = sum(PV_avg) * cost_PV_om_coeff; % 发电成本
cost_PV2H = cost_PV2H_quad_coeff * sum(P_PV2H)^2 + cost_PV2H_linear_coeff * sum(P_PV2H); % 售电给电制氢的成本

obj_PV_neg_profit = - (revenue_PV2G + revenue_PV2H - cost_PV_om - cost_PV2H); % 利润减成本

%% 求解问题
options = sdpsettings('solver','gurobi'); % 使用求解器gurobi求解
p1 = optimize(C2, obj_PV_neg_profit, options); % 服从C，最小化Fpv

fprintf('Example problem: %s. \n', p1.info);

sol_P_PV2G = value(P_PV2G); % 获取向电网出售的电量
sol_P_PV2H = value(P_PV2H); % 获取向电制氢出售的电量

ideal_profit_PV_noncoop = - value(obj_PV_neg_profit); % 获取光伏利润

ideal_revenue_PV_G_only = sum(PV_avg) * price_PV2G; % 理想最大收入
ideal_profit_PV_G_only = ideal_revenue_PV_G_only - cost_PV_om; % 理想最大利润（指全部卖给电网）

%% 绘图
hours = 1:24;
y1label2 = sol_P_PV2G;% 左轴数据（向电网售电量）
y2label2 = sol_P_PV2H;% 右轴数据（向电制氢售电量）

figure;
bb1 = bar(hours, y1label2, 0.3, 'FaceColor', [0.2 0.6 1]); % 0.3控制柱宽
hold on;
bb2 = bar(hours+0.25, y2label2, 0.3, 'FaceColor', [1 0.5 0.2]); 

xlabel('小时');
ylabel('售电量 (kw)');
title('光伏主体每小时售电量');
ylim([0 1000]);  % 设置左轴范围
set(gca, 'XTick', hours);  % 显示所有月份刻度
grid on;
legend([bb1, bb2], {'向电网售电量', '向电制氢售电量'}, 'Location', 'northwest');