clear;
clc;
close all;

rng(20); % 设置随机数种子，确保结果可复现

run('draw_scene.m');

run('common_params.m');

run('WT_model.m');
run('PV_model.m');
run('H_model.m');

run('coop_question1.m');
run('coop_question2.m');

run('result_summary.m');

% disp('非合作阶段成果');
% disp(['风电非合作最大利润 = ', num2str(ideal_profit_WT_noncoop)]);
% disp(['光伏非合作最大利润 = ', num2str(ideal_profit_PV_noncoop)]);
% disp(['电制氢非合作最小成本 = ', num2str(ideal_cost_H_noncoop_Total)]);

% disp('合作阶段1电制氢购电成果');
% disp(['风电合作购电量 = ', num2str(sol_P_WT2H_coop)]);
% disp(['光伏合作购电量 = ', num2str(sol_P_PV2H_coop)]);
% disp(['电网合作购电量 = ', num2str(sol_P_H_from_G_coop)]);