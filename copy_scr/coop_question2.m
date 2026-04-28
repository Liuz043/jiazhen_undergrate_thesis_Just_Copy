price_WT_coop = sdpvar(24,1); % 风电每小时售电价格
price_PV_coop = sdpvar(24,1); % 光伏每小时售电价格

% 定义交易支付额
payment_WT2H_coop = sol_P_WT2H_coop(:)' * price_WT_coop;
payment_PV2H_coop = sol_P_PV2H_coop(:)' * price_PV_coop;

% 风电最终利润 = 合作问题1基础利润 + 风氢交易收入
profit_WT_coop_final = ideal_profit_WT_coop_Total + payment_WT2H_coop;

% 光伏最终利润 = 合作问题1基础利润 + 光氢交易收入
profit_PV_coop_final = ideal_profit_PV_coop_Total + payment_PV2H_coop;

% 电制氢最终成本 = 合作问题1基础成本 + 支付给风电和光伏的交易费用
cost_H_coop_final = ideal_cost_H_coop_Total + payment_WT2H_coop + payment_PV2H_coop;

gain_WT = profit_WT_coop_final - ideal_profit_WT_noncoop;
gain_PV = profit_PV_coop_final - ideal_profit_PV_noncoop;
gain_H = ideal_cost_H_noncoop_Total - cost_H_coop_final;

%% 定义约束条件
C5 = [];

for i = 1:24
    if sol_P_WT2H_coop(i) > 0
        C5 = [C5, price_WT_coop(i) >= price_WT2G]; % 风电售电价格不低于上网电价
    end

    if sol_P_PV2H_coop(i) > 0
        C5 = [C5, price_PV_coop(i) >= price_PV2G]; % 光伏售电价格不低于上网电价
    end

    C5 = [C5, price_WT_coop(i) >= 0];
    C5 = [C5, price_WT_coop(i) <= 0.9]; % 设置一个合理的上限，避免价格过高

    C5 = [C5, price_PV_coop(i) >= 0];
    C5 = [C5, price_PV_coop(i) <= 0.9]; % 设置一个合理的上限，避免价格过高
end

C5 = [C5, gain_WT >= 0];
C5 = [C5, gain_PV >= 0];
C5 = [C5, gain_H >= 0];

%% 定义目标函数，最大化风光氢联盟的总利润
obj_neg_nash_log = - (log(gain_WT) + log(gain_PV) + log(gain_H));

%% 求解问题
options = sdpsettings('solver','gurobi'); % 使用求解器mosek求解 指数问题
p3 = optimize(C5, obj_neg_nash_log, options);

fprintf('Cooperation question 2: %s.\n', p3.info);

sol_price_WT_coop = value(price_WT_coop);
sol_price_PV_coop = value(price_PV_coop);

sol_payment_WT2H_coop = value(payment_WT2H_coop);
sol_payment_PV2H_coop = value(payment_PV2H_coop);

sol_profit_WT_coop_final = value(profit_WT_coop_final);
sol_profit_PV_coop_final = value(profit_PV_coop_final);
sol_cost_H_coop_final = value(cost_H_coop_final);

sol_obj_neg_nash_log = value(obj_neg_nash_log);

%% 绘图
time = 1:24;          % 时间轴（小时）

figure;

hold on;
% 绘制折线（工业电价）
plot(time, price_G, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'b');
% 绘制横线（更规范的写法）
plot(time, sol_price_WT_coop, 'r--', 'LineWidth', 2); % 红色虚线
plot(time, sol_price_PV_coop, 'g:', 'LineWidth', 2);  % 绿色点划线（更正线型）
% 图表美化

xlabel('时间 (小时)', 'FontSize', 10);
ylabel('价格 (元)', 'FontSize', 10); % 修正字号
title('工业电价与风电价格和光电价格比较图 (24小时)', 'FontSize', 12, 'FontWeight', 'bold');
xlim([1 24]);
ylim([0 1]);         % 调整y轴范围以适配随机数据
legend('工业电价', '风电电价', '光伏电价', 'Location', 'northwest');
hold off;