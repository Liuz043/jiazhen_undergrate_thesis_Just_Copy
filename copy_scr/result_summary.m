%% result_summary.m
% 结果汇总代码
% 需要在以下文件之后运行：
% WT_model.m
% PV_model.m
% H_model.m
% coop_question1.m
% coop_question2.m

fprintf('\n==============================\n');
fprintf('风光氢纳什谈判复现结果汇总\n');
fprintf('==============================\n\n');

%% 0. 求解状态检查

fprintf('【求解状态检查】\n');

if exist('p1','var')
    fprintf('最近一次 p1.info = %s\n', p1.info);
end

if exist('p2','var')
    fprintf('合作问题1 p2.info = %s\n', p2.info);
    fprintf('合作问题1 p2.problem = %d\n', p2.problem);
end

if exist('p3','var')
    fprintf('合作问题2 p3.info = %s\n', p3.info);
    fprintf('合作问题2 p3.problem = %d\n', p3.problem);
end

fprintf('\n');

%% 1. 风电场收益对比，对应论文表 4.1

WT_ideal_grid_trade = numval(revenue_WT2G);
WT_ideal_H_trade = numval(revenue_WT2H);
WT_ideal_om_cost = numval(cost_WT_om);
WT_ideal_wheeling_cost = numval(cost_WT2H);
WT_ideal_profit = numval(ideal_profit_WT_noncoop);

WT_actual_grid_trade_before = numval(ideal_revenue_WT_G_only);
WT_actual_H_trade_before = 0;
WT_actual_om_cost_before = numval(cost_WT_om);
WT_actual_wheeling_cost_before = 0;
WT_actual_profit_before = numval(ideal_profit_WT_G_only);

WT_actual_grid_trade_after = numval(revenue_WT_coop);
WT_actual_H_trade_after = numval(sol_payment_WT2H_coop);
WT_actual_om_cost_after = numval(cost_WT_om_coop);
WT_actual_wheeling_cost_after = numval(cost_WT2H_coop);
WT_actual_profit_after = numval(sol_profit_WT_coop_final);

WT_table = table( ...
    ["合作前理想收益"; "合作前实际收益"; "合作后实际收益"], ...
    [WT_ideal_grid_trade; WT_actual_grid_trade_before; WT_actual_grid_trade_after], ...
    [WT_ideal_H_trade; WT_actual_H_trade_before; WT_actual_H_trade_after], ...
    [WT_ideal_om_cost; WT_actual_om_cost_before; WT_actual_om_cost_after], ...
    [WT_ideal_wheeling_cost; WT_actual_wheeling_cost_before; WT_actual_wheeling_cost_after], ...
    [WT_ideal_profit; WT_actual_profit_before; WT_actual_profit_after], ...
    'VariableNames', {'类型','电网交易额','电制氢交易额','运行维护费用','过网费','总收益'} ...
);

fprintf('【表 4.1 风电场参与合作前后收益比较】\n');
disp(WT_table);

%% 2. 光伏电场收益对比，对应论文表 4.2

PV_ideal_grid_trade = numval(revenue_PV2G);
PV_ideal_H_trade = numval(revenue_PV2H);
PV_ideal_om_cost = numval(cost_PV_om);
PV_ideal_wheeling_cost = numval(cost_PV2H);
PV_ideal_profit = numval(ideal_profit_PV_noncoop);

PV_actual_grid_trade_before = numval(ideal_revenue_PV_G_only);
PV_actual_H_trade_before = 0;
PV_actual_om_cost_before = numval(cost_PV_om);
PV_actual_wheeling_cost_before = 0;
PV_actual_profit_before = numval(ideal_profit_PV_G_only);

PV_actual_grid_trade_after = numval(revenue_PV_coop);
PV_actual_H_trade_after = numval(sol_payment_PV2H_coop);
PV_actual_om_cost_after = numval(cost_PV_om_coop);
PV_actual_wheeling_cost_after = numval(cost_PV2H_coop);
PV_actual_profit_after = numval(sol_profit_PV_coop_final);

PV_table = table( ...
    ["合作前理想收益"; "合作前实际收益"; "合作后实际收益"], ...
    [PV_ideal_grid_trade; PV_actual_grid_trade_before; PV_actual_grid_trade_after], ...
    [PV_ideal_H_trade; PV_actual_H_trade_before; PV_actual_H_trade_after], ...
    [PV_ideal_om_cost; PV_actual_om_cost_before; PV_actual_om_cost_after], ...
    [PV_ideal_wheeling_cost; PV_actual_wheeling_cost_before; PV_actual_wheeling_cost_after], ...
    [PV_ideal_profit; PV_actual_profit_before; PV_actual_profit_after], ...
    'VariableNames', {'类型','电网交易额','电制氢交易额','运行维护费用','过网费','总收益'} ...
);

fprintf('【表 4.2 光伏电场参与合作前后收益比较】\n');
disp(PV_table);

%% 3. 电制氢系统成本对比，对应论文表 4.3

H_grid_cost_before = numval(cost_H_from_G);
H_WT_cost_before = 0;
H_PV_cost_before = 0;
H_om_cost_before = numval(cost_H_om);
H_total_cost_before = numval(ideal_cost_H_noncoop_Total);

H_grid_cost_after = numval(cost_H_from_G_coop);
H_WT_cost_after = numval(sol_payment_WT2H_coop);
H_PV_cost_after = numval(sol_payment_PV2H_coop);
H_om_cost_after = numval(cost_H_om_coop);
H_total_cost_after = numval(sol_cost_H_coop_final);

H_table = table( ...
    ["合作前"; "合作后"], ...
    [H_grid_cost_before; H_grid_cost_after], ...
    [H_WT_cost_before; H_WT_cost_after], ...
    [H_PV_cost_before; H_PV_cost_after], ...
    [H_om_cost_before; H_om_cost_after], ...
    [H_total_cost_before; H_total_cost_after], ...
    'VariableNames', {'类型','电网交易额','风电交易额','光伏交易额','运行维护费用','总成本'} ...
);

fprintf('【表 4.3 电制氢系统参与合作前后成本比较】\n');
disp(H_table);

%% 4. 系统整体收益对比，对应论文表 4.4

system_net_before_actual = WT_actual_profit_before ...
                         + PV_actual_profit_before ...
                         - H_total_cost_before;

system_net_after_actual = WT_actual_profit_after ...
                        + PV_actual_profit_after ...
                        - H_total_cost_after;

system_cost_before_actual = -system_net_before_actual;
system_cost_after_actual = -system_net_after_actual;

system_improvement = system_net_after_actual - system_net_before_actual;
system_cost_reduction = system_cost_before_actual - system_cost_after_actual;
system_cost_reduction_rate = system_cost_reduction / system_cost_before_actual;

system_table = table( ...
    ["合作前实际"; "合作后实际"], ...
    [WT_actual_profit_before; WT_actual_profit_after], ...
    [PV_actual_profit_before; PV_actual_profit_after], ...
    [H_total_cost_before; H_total_cost_after], ...
    [system_net_before_actual; system_net_after_actual], ...
    [system_cost_before_actual; system_cost_after_actual], ...
    'VariableNames', {'类型','风电总收益','光伏总收益','电制氢总成本','系统净收益','系统等效成本'} ...
);

fprintf('【表 4.4 风光氢系统整体收益比较，一致口径】\n');
disp(system_table);

fprintf('系统净收益改善 = %.4f\n', system_improvement);
fprintf('系统等效成本降低 = %.4f\n', system_cost_reduction);
fprintf('系统等效成本降低率 = %.2f%%\n\n', system_cost_reduction_rate * 100);

%% 5. 合作问题 1 和合作问题 2 一致性检查

system_net_after_from_q1 = numval(ideal_profit_WT_coop_Total) ...
                         + numval(ideal_profit_PV_coop_Total) ...
                         - numval(ideal_cost_H_coop_Total);

system_net_after_from_q2 = numval(sol_profit_WT_coop_final) ...
                         + numval(sol_profit_PV_coop_final) ...
                         - numval(sol_cost_H_coop_final);

fprintf('【合作问题 1 与合作问题 2 一致性检查】\n');
fprintf('question1 合作后系统净收益 = %.8f\n', system_net_after_from_q1);
fprintf('question2 合作后系统净收益 = %.8f\n', system_net_after_from_q2);
fprintf('二者差值 = %.8e\n\n', system_net_after_from_q2 - system_net_after_from_q1);

%% 6. 纳什谈判收益增量检查

gain_WT_value = numval(gain_WT);
gain_PV_value = numval(gain_PV);
gain_H_value = numval(gain_H);

nash_table = table( ...
    ["风电"; "光伏"; "电制氢"], ...
    [gain_WT_value; gain_PV_value; gain_H_value], ...
    'VariableNames', {'主体','收益增量'} ...
);

fprintf('【纳什谈判收益增量检查】\n');
disp(nash_table);

fprintf('三方收益增量合计 = %.8f\n\n', gain_WT_value + gain_PV_value + gain_H_value);

%% 7. 交易量与交易价格汇总

WT2H_energy_total = sum(sol_P_WT2H_coop);
PV2H_energy_total = sum(sol_P_PV2H_coop);
G2H_energy_total = sum(sol_P_H_from_G_coop);

avg_price_WT2H = sol_payment_WT2H_coop / WT2H_energy_total;
avg_price_PV2H = sol_payment_PV2H_coop / PV2H_energy_total;

trade_table = table( ...
    ["风电到电制氢"; "光伏到电制氢"; "电网到电制氢"], ...
    [WT2H_energy_total; PV2H_energy_total; G2H_energy_total], ...
    [sol_payment_WT2H_coop; sol_payment_PV2H_coop; H_grid_cost_after], ...
    [avg_price_WT2H; avg_price_PV2H; H_grid_cost_after / G2H_energy_total], ...
    'VariableNames', {'交易类型','总电量','总交易额','平均价格'} ...
);

fprintf('【合作后电制氢购电结构汇总】\n');
disp(trade_table);

% %% 8. 保存结果，可选

% save('summary_results.mat', ...
%     'WT_table', 'PV_table', 'H_table', 'system_table', 'nash_table', 'trade_table', ...
%     'system_net_before_actual', 'system_net_after_actual', ...
%     'system_cost_before_actual', 'system_cost_after_actual', ...
%     'system_cost_reduction', 'system_cost_reduction_rate');

% fprintf('结果已保存到 summary_results.mat\n');

%% 本脚本使用的局部函数

function y = numval(x)
    try
        y = value(x);
    catch
        y = x;
    end
    y = double(y);
end


surplus_actual = ...
    (ideal_profit_WT_coop_Total - ideal_profit_WT_G_only) ...
  + (ideal_profit_PV_coop_Total -ideal_profit_PV_G_only) ...
  + (ideal_cost_H_noncoop_Total - ideal_cost_H_coop_Total);

disp('以实际合作前收益为破裂点时的可分配剩余：');
disp(surplus_actual);

surplus_ideal = ...
    (ideal_profit_WT_coop_Total - ideal_profit_WT_noncoop) ...
  + (ideal_profit_PV_coop_Total - ideal_profit_PV_noncoop) ...
  + (ideal_cost_H_noncoop_Total - ideal_cost_H_coop_Total);

  disp('以理想合作前收益为破裂点时的可分配剩余：');
disp(surplus_ideal);