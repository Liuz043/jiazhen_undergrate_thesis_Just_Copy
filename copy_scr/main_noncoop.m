clear;
clc;
close all;

rng(202); % 设置随机数种子，确保结果可复现

run('draw_scene.m');
run('Wind_Turbine.m');
run('PV_model.m');
run('H_model.m');

disp('非合作阶段成果');
disp(['风电非合作最大利润 = ', num2str(WT_noncoop_ideal_profit)]);
disp(['光伏非合作最大利润 = ', num2str(PV_noncoop_ideal_profit)]);
disp(['电制氢非合作最小成本 = ', num2str(H_noncoop_ideal_cost)]);

disp(sol_P_ba_dis);
disp(max(sol_P_ba_dis));
disp(sum(sol_P_ba_dis));
disp(sol_E_ba);