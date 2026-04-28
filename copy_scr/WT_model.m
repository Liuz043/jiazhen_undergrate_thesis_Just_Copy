%% 风电模型
wind1 = P_data(1,1:24);
wind2 = P_data(2,1:24);
wind3 = P_data(3,1:24);
wind4 = P_data(4,1:24);
wind5 = P_data(5,1:24);

WT_avg = [];%用于计算平均每小时风力发电量
for i = 1:24
    WT_avg(i) = wind1(i) * pi(1) + wind2(i) * pi(2) + wind3(i) * pi(3) + wind4(i) * pi(4) + wind5(i) * pi(5);
end

%% 定义决策变量
P_WT2G = sdpvar(1,24);  % 向电网出售的电量
P_WT2H = sdpvar(1,24);  % 向电制氢主体的售电量

%% 定义约束条件
C1 = [];

for i = 1:24
    C1 = [C1, P_WT2G(i) >= 0];
    C1 = [C1, P_WT2G(i) <= WT_avg(i)];
    
    C1 = [C1, P_WT2H(i) >= 0];
    C1 = [C1, P_WT2H(i) <= WT_avg(i)];
    
    C1 = [C1, P_WT2G(i) + P_WT2H(i) == WT_avg(i)];
end

%% 定义目标函数
revenue_WT2G = sum(P_WT2G) * price_WT2G; % 向电网出售的收益
revenue_WT2H = P_WT2H * price_G; % 向电制氢出售的收益

cost_WT_om = sum(WT_avg) * cost_WT_om_coeff; % 发电成本
cost_WT2H = cost_WT2H_quad_coeff * sum(P_WT2H)^2 + cost_WT2H_linear_coeff * sum(P_WT2H); % 售电给电制氢的成本

obj_WT_profit = - (revenue_WT2G + revenue_WT2H - cost_WT_om - cost_WT2H); % 利润减成本

%% 求解问题
options = sdpsettings('solver','gurobi'); % 使用求解器gurobi求解
p1 = optimize(C1, obj_WT_profit, options); % 服从C，最小化obj_WT_profit

fprintf('Example problem: %s. \n', p1.info); 

sol_P_WT2G = value(P_WT2G); % 获取向电网出售的电量
sol_P_WT2H = value(P_WT2H); % 获取向电制氢出售的电量

ideal_profit_WT_noncoop = - value(obj_WT_profit); % 获取风电利润

ideal_revenue_WT_G_only = sum(WT_avg) * price_WT2G; % 理想最大收入
ideal_profit_WT_G_only = ideal_revenue_WT_G_only - cost_WT_om; % 理想最大利润（指全部卖给电网）

%% 绘图
% 绘制风电主体每小时售电量
hours = 1:24;

y1label1 = sol_P_WT2G;% 左轴数据（向电网售电量）
y2label1 = sol_P_WT2H; % 右轴数据（向电制氢售电量）

figure;
% 绘制左侧Y轴柱状图
bb1 = bar(hours, y1label1, 0.3, 'FaceColor', [0.2 0.6 1]); % 0.3控制柱宽
hold on;
bb2 = bar(hours+0.25, y2label1, 0.3, 'FaceColor', [1 0.5 0.2]); 

xlabel('小时');
ylabel('售电量 (kw)');
title('风电主体每小时售电量');
ylim([0 1000]);  % 设置左轴范围
set(gca, 'XTick', hours);  % 显示所有月份刻度
grid on;

legend([bb1, bb2], {'向电网售电量', '向电制氢售电量'}, 'Location', 'northwest');
hold off;

% 绘制工业电价与风电价格和光电价格比较图
time = 1:24;

price_WT2G_line = 0.34 * ones(size(time)); % 风电上网电价
price_PV2G_line = 0.40 * ones(size(time)); % 光伏上网电价

figure;
hold on;

% 绘制折线（工业电价）
plot(time, price_G, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'b');
% 绘制横线（更规范的写法）
plot(time, price_WT2G_line, 'r--', 'LineWidth', 2); % 红色虚线
plot(time, price_PV2G_line, 'g:', 'LineWidth', 2);  % 绿色点划线（更正线型）
% 图表美化
title('工业电价与风电价格和光电价格比较图 (24小时)', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('时间 (小时)', 'FontSize', 10);
ylabel('价格 (元)', 'FontSize', 10); % 修正字号
xlim([1 24]);
ylim([0 1]);         % 调整y轴范围以适配随机数据
grid on;
% 添加图例（确保顺序与绘图一致）
legend('工业电价', '风电上网电价', '光伏上网电价', 'Location', 'northwest');
hold off;