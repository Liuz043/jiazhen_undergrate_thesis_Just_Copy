P_ba_c_coop =  sdpvar(1,24); %t时刻充电功率
P_ba_dis_coop =  sdpvar(1,24); %t时刻放电功率
P_H_from_G_coop =  sdpvar(1,24); %t时刻电制氢主体向电网买的购电量
P_el_coop = sdpvar(1,24); %合作1时每小时输入电功率
H_tank_press_coop = sdpvar(1,24); %t时刻储氢罐内部气压

P_WT2G_coop = sdpvar(1,24); %t时刻风电主体向电网出售的电量
P_WT2H_coop = sdpvar(1,24); %t时刻风电主体向电制氢主体的售电量

P_PV2G_coop = sdpvar(1,24); %t时刻光伏主体向电网出售的电量
P_PV2H_coop = sdpvar(1,24); %t时刻光伏主体向电制氢主体的售电量

P_com_coop = sdpvar(1,24); %合作时压缩机耗电功率

E_ba_coop = sdpvar(1,24); %t时刻储能量
ubatt_coop = binvar(1,24,'full'); %二进制变量，用来表示t时刻是充电还是放电，放电时为0

%% 定义约束条件集合确保风光氢联盟效益最大化
C4 = [];

% 初始化状态约束
C4 = [C4, H_tank_press_coop(1) == H_tank_t0];
C4 = [C4, E_ba_coop(1) == E_ba_t0];

% 动态约束
for i = 2:24
    C4 = [C4, H_tank_press_coop(i) == H_tank_press_coop(i-1) ...
        + H_spec2Heat * Temp_tank_H ...
        * (Flow_com_H - H_avg(i)/10000) ...
        / (volume_tank_H * H_mol)];

    C4 = [C4, E_ba_coop(i) == E_ba_coop(i-1) ...
        + P_ba_c_coop(i) * E_ba_c ...
        - P_ba_dis_coop(i) / E_ba_dis];
end

% 运行约束
for i = 1:24 
    C4 = [C4, P_el_coop(i) == H_tank_press_coop(i) / H_yield_coeff];

    % 风电约束
    C4 = [C4, P_WT2G_coop(i) >= 0];
    C4 = [C4, P_WT2G_coop(i) <= WT_avg(i)];

    C4 = [C4, P_WT2H_coop(i) >= 0];
    C4 = [C4, P_WT2H_coop(i) <= WT_avg(i)];

    C4 = [C4, P_WT2G_coop(i) + P_WT2H_coop(i) == WT_avg(i)];

    % 光伏约束
    C4 = [C4, P_PV2G_coop(i) >= 0];
    C4 = [C4, P_PV2G_coop(i) <= PV_avg(i)];

    C4 = [C4, P_PV2H_coop(i) >= 0];
    C4 = [C4, P_PV2H_coop(i) <= PV_avg(i)];

    C4 = [C4, P_PV2G_coop(i) + P_PV2H_coop(i) == PV_avg(i)];

    % 电解槽约束
    C4 = [C4,  P_el_coop(i) >= 0];
    C4 = [C4,  P_el_coop(i) <= P_el_max];
    C4 = [C4,  H_tank_press_coop(i) >= H_tank_press_min];
    C4 = [C4,  H_tank_press_coop(i) <= H_tank_press_max];

    if i <= 23
        C4 = [C4,  P_el_coop(i+1) - P_el_coop(i) <= P_el_rp_max];
        C4 = [C4,  P_el_coop(i) - P_el_coop(i+1) <= P_el_rp_max];
    end

    % 压缩机约束
    C4 = [C4,  P_com_coop(i) >= H_avg(i)*2.85];
    
    % 电池约束
    C4 = [C4,  P_ba_c_coop(i) <= ubatt_coop(i) * P_ba_c_max];
    C4 = [C4,  P_ba_c_coop(i) >= 0];

    C4 = [C4,  P_ba_dis_coop(i) >= 0];
    C4 = [C4,  P_ba_dis_coop(i) <= (1 - ubatt_coop(i)) * P_ba_dis_max];

    C4 = [C4,  E_ba_coop(i) >= E_ba_min];
    C4 = [C4,  E_ba_coop(i) <= E_ba_max];

    % 联盟约束
    C4 = [C4,  P_H_from_G_coop(i) >= 0];
    C4 = [C4,  P_H_from_G_coop(i) + P_ba_dis_coop(i) ...
        + P_WT2H_coop(i) + P_PV2H_coop(i) ...
        == P_el_coop(i) + P_ba_c_coop(i) + P_com_coop(i)];

end

%% 定义目标函数，最大化风光氢联盟的总利润
revenue_WT_coop = sum(P_WT2G_coop) * price_WT2G; % 向电网出售的风电收益
cost_WT_om_coop = sum(WT_avg) * cost_WT_om_coeff; % 风电运维成本
cost_WT2H_coop = cost_WT2H_quad_coeff * sum(P_WT2H_coop)^2 ...
    + cost_WT2H_linear_coeff * sum(P_WT2H_coop);% 售电给电制氢的成本
revenue_WT_coop_total = revenue_WT_coop - cost_WT_om_coop - cost_WT2H_coop; % 风电主体总利润

revenue_PV_coop = sum(P_PV2G_coop) * price_PV2G; % 向电网出售的光伏收益
cost_PV_om_coop = sum(PV_avg) * cost_PV_om_coeff; % 光伏运维成本
cost_PV2H_coop = cost_PV2H_quad_coeff * sum(P_PV2H_coop)^2 ...
    + cost_PV2H_linear_coeff * sum(P_PV2H_coop); % 售电给电制氢的成本
revenue_PV_coop_total = revenue_PV_coop - cost_PV_om_coop - cost_PV2H_coop; % 光伏主体总利润

cost_H_from_G_coop = P_H_from_G_coop * price_G; % 电制氢主体从电网购电的成本
cost_H_om_coop = el_om_coeff * sum(P_el_coop) ...
    + ba_om_coeff * (sum(P_ba_c_coop)+sum(P_ba_dis_coop))^2; % 电制氢运维成本
cost_H_coop_total = cost_H_from_G_coop + cost_H_om_coop; % 电制氢主体总成本

obj_neg_revenue_coop = - (revenue_WT_coop_total + revenue_PV_coop_total - cost_H_coop_total); % 联盟总利润

%% 求解问题
options = sdpsettings('solver','gurobi'); % 使用求解器gurobi求解
p2 = optimize(C4, obj_neg_revenue_coop, options); % 服从C4，最小化obj_neg_revenue_coop

fprintf('Cooperation problem: %s. \n', p2.info);

Total_coop_revenue = - value(obj_neg_revenue_coop); % 联盟总利润

sol_P_WT2H_coop = value(P_WT2H_coop); % 获取风电向电制氢出售的电量
sol_P_PV2H_coop = value(P_PV2H_coop); % 获取光伏向电制氢出售的电量
sol_P_H_from_G_coop = value(P_H_from_G_coop); % 获取电制氢电网购电量

%% 绘图
hours = 1:24;
y1label1 = sol_P_PV2H_coop; % 右轴数据（光伏向电制氢售电量）
y2label1 = sol_P_WT2H_coop; % 左轴数据（风电向电制氢售电量）
y3label1 = sol_P_H_from_G_coop; % 右轴数据（电制氢电网购电量）

figure;

bb1 = bar(hours, y1label1 + y2label1 + y3label1, 0.6, 'FaceColor', [0.2 0.6 1]); % 0.6控制柱宽
hold on;
bb2 = bar(hours, y1label1 + y2label1, 0.6, 'FaceColor', [1 0.5 0.2]); % 0.4控制柱宽
hold on;
bb3 = bar(hours, y1label1, 0.6, 'FaceColor', [0.5 0.5 0.3]); % 0.2控制柱宽
hold off;

xlabel('小时');
ylabel('电制氢系统购电量 (kw)');
title('电制氢系统每小时购电量');
ylim([0 3000]);  % 设置左轴范围
set(gca, 'XTick', hours);  % 显示所有小时刻度
grid on;
legend([bb1, bb2, bb3], {'电网购电量', '风电购电量','光伏购电量'}, 'Location', 'northwest');