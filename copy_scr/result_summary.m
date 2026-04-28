%% result_summary.m
% 汇总表 4.1 到表 4.4 的结果
% 运行前需要已经运行：
% WT_model.m, PV_model.m, H_model.m, coop_quesion1.m, coop_question2.m

fprintf('\n================ 表 4.1 风电场参与合作前后收益比较 ================\n');

WT_ideal_grid_revenue = value(revenue_WT2G);
WT_ideal_H_revenue    = value(revenue_WT2H);
WT_om_cost            = value(cost_WT_om);
WT_ideal_grid_fee     = value(cost_WT2H);

WT_ideal_profit = WT_ideal_grid_revenue ...
                + WT_ideal_H_revenue ...
                - WT_om_cost ...
                - WT_ideal_grid_fee;

WT_actual_grid_revenue_before = sum(WT_avg) * price_WT2G;
WT_actual_H_revenue_before    = 0;
WT_actual_grid_fee_before     = 0;

WT_actual_profit_before = WT_actual_grid_revenue_before ...
                        - WT_om_cost;

WT_grid_revenue_after = value(revenue_WT_coop);
WT_H_revenue_after    = value(payment_WT2H_coop);
WT_grid_fee_after     = value(cost_WT2H_coop);

WT_actual_profit_after = WT_grid_revenue_after ...
                       + WT_H_revenue_after ...
                       - WT_om_cost ...
                       - WT_grid_fee_after;

fprintf('风电合作前理想：电网 %.2f, 电制氢 %.2f, 运维 %.2f, 过网费 %.2f, 总收益 %.2f\n', ...
    WT_ideal_grid_revenue, WT_ideal_H_revenue, WT_om_cost, WT_ideal_grid_fee, WT_ideal_profit);

fprintf('风电合作前实际：电网 %.2f, 电制氢 %.2f, 运维 %.2f, 过网费 %.2f, 总收益 %.2f\n', ...
    WT_actual_grid_revenue_before, WT_actual_H_revenue_before, WT_om_cost, WT_actual_grid_fee_before, WT_actual_profit_before);

fprintf('风电合作后实际：电网 %.2f, 电制氢 %.2f, 运维 %.2f, 过网费 %.2f, 总收益 %.2f\n', ...
    WT_grid_revenue_after, WT_H_revenue_after, WT_om_cost, WT_grid_fee_after, WT_actual_profit_after);


fprintf('\n================ 表 4.2 光伏电场参与合作前后收益比较 ================\n');

PV_ideal_grid_revenue = value(revenue_PV2G);
PV_ideal_H_revenue    = value(revenue_PV2H);
PV_om_cost            = value(cost_PV_om);
PV_ideal_grid_fee     = value(cost_PV2H);

PV_ideal_profit = PV_ideal_grid_revenue ...
                + PV_ideal_H_revenue ...
                - PV_om_cost ...
                - PV_ideal_grid_fee;

PV_actual_grid_revenue_before = sum(PV_avg) * price_PV2G;
PV_actual_H_revenue_before    = 0;
PV_actual_grid_fee_before     = 0;

PV_actual_profit_before = PV_actual_grid_revenue_before ...
                        - PV_om_cost;

PV_grid_revenue_after = value(revenue_PV_coop);
PV_H_revenue_after    = value(payment_PV2H_coop);
PV_grid_fee_after     = value(cost_PV2H_coop);

PV_actual_profit_after = PV_grid_revenue_after ...
                       + PV_H_revenue_after ...
                       - PV_om_cost ...
                       - PV_grid_fee_after;

fprintf('光伏合作前理想：电网 %.2f, 电制氢 %.2f, 运维 %.2f, 过网费 %.2f, 总收益 %.2f\n', ...
    PV_ideal_grid_revenue, PV_ideal_H_revenue, PV_om_cost, PV_ideal_grid_fee, PV_ideal_profit);

fprintf('光伏合作前实际：电网 %.2f, 电制氢 %.2f, 运维 %.2f, 过网费 %.2f, 总收益 %.2f\n', ...
    PV_actual_grid_revenue_before, PV_actual_H_revenue_before, PV_om_cost, PV_actual_grid_fee_before, PV_actual_profit_before);

fprintf('光伏合作后实际：电网 %.2f, 电制氢 %.2f, 运维 %.2f, 过网费 %.2f, 总收益 %.2f\n', ...
    PV_grid_revenue_after, PV_H_revenue_after, PV_om_cost, PV_grid_fee_after, PV_actual_profit_after);


fprintf('\n================ 表 4.3 电制氢系统参与合作前后成本比较 ================\n');

H_grid_cost_before = value(cost_H_from_G);
H_WT_cost_before   = 0;
H_PV_cost_before   = 0;
H_om_cost_before   = value(cost_H_om);

H_total_cost_before = H_grid_cost_before ...
                    + H_WT_cost_before ...
                    + H_PV_cost_before ...
                    + H_om_cost_before;

H_grid_cost_after = value(cost_H_from_G_coop);
H_WT_cost_after   = value(payment_WT2H_coop);
H_PV_cost_after   = value(payment_PV2H_coop);
H_om_cost_after   = value(cost_H_om_coop);

H_total_cost_after = H_grid_cost_after ...
                   + H_WT_cost_after ...
                   + H_PV_cost_after ...
                   + H_om_cost_after;

fprintf('电制氢合作前：电网 %.2f, 风电 %.2f, 光伏 %.2f, 运维 %.2f, 总成本 %.2f\n', ...
    H_grid_cost_before, H_WT_cost_before, H_PV_cost_before, H_om_cost_before, H_total_cost_before);

fprintf('电制氢合作后：电网 %.2f, 风电 %.2f, 光伏 %.2f, 运维 %.2f, 总成本 %.2f\n', ...
    H_grid_cost_after, H_WT_cost_after, H_PV_cost_after, H_om_cost_after, H_total_cost_after);


fprintf('\n================ 表 4.4 风光氢系统整体收益比较 ================\n');

system_net_before = WT_actual_profit_before ...
                  + PV_actual_profit_before ...
                  - H_total_cost_before;

system_net_after_consistent = WT_actual_profit_after ...
                            + PV_actual_profit_after ...
                            - H_total_cost_after;

system_net_after_paper_style = WT_ideal_profit ...
                             + PV_ideal_profit ...
                             - H_total_cost_after;

fprintf('合作前整体收益：%.2f\n', system_net_before);
fprintf('合作后一致口径整体收益：%.2f\n', system_net_after_consistent);
fprintf('合作后论文表4.4口径整体收益：%.2f\n', system_net_after_paper_style);

cost_reduction_consistent = system_net_after_consistent - system_net_before;
cost_reduction_rate_consistent = cost_reduction_consistent / abs(system_net_before);

fprintf('一致口径下整体改善：%.2f\n', cost_reduction_consistent);
fprintf('一致口径下整体改善率：%.2f%%\n', cost_reduction_rate_consistent * 100);