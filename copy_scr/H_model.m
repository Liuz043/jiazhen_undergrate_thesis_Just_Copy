H1 = P_data(1,49:72);
H2 = P_data(2,49:72);
H3 = P_data(3,49:72);
H4 = P_data(4,49:72);
H5 = P_data(5,49:72);

H_avg = [];%用于计算平均每小时氢气需求量
for i = 1:24
    H_avg(i) = H1(i) * pi(1) + H2(i) * pi(2) + H3(i) * pi(3) + H4(i) * pi(4) + H5(i) * pi(5);
end

%% 定义决策变量
H_yield_coeff = 0.019224; %单位产氢量

P_el_max = 5000; %最大约束功率
P_el_rp_max = 1000; %功率爬坡约束

H_spec2Heat = 14.304; %氢气比热容常数
T_in = 40; %压缩机输入氢气的温度
n_com = 0.7; %压缩机工作效率
K = 1.4; %氢气等熵指数
k1 = (K-1)/K;% 氢气压缩机模型公式的指数次方

volume_tank_H = 500; %氢气容量
Temp_tank_H = 60; %储氢罐内部温度
H_mol = 0.002; %氢气摩尔质量
Flow_com_H = 0.004; %t时刻压缩氢气流量
H_tank_press_min = 20; %储氢罐最小气压
H_tank_press_max = 40; %储氢罐最大气压

E_ba_min = 200; %储能系统最小储能量
E_ba_max = 1800; %储能系统最大储能量
E_ba_c = 0.95; %充电效率
E_ba_dis = 0.96; %放电效率
P_ba_c_max = 500; %最大充电功率
P_ba_dis_max = 600; %最大放电功率

el_om_coeff = 0.022; %电解槽运维成本系数
ba_om_coeff = 0.00018; %储能运维成本系数

P_el = sdpvar(1,24); %每小时输入电功率
P_com =  sdpvar(1,24); %压缩机耗电功率
H_tank_press = sdpvar(1,24); %t时刻储氢罐内部气压
H_tank_t0 = 28; %定义储氢罐内部0时刻气压

P_H_from_G =  sdpvar(1,24); %t时刻电制氢主体向电网买的购电量
P_ba_c =  sdpvar(1,24); %t时刻充电功率
P_ba_dis =  sdpvar(1,24); %t时刻放电功率
ubatt = binvar(1,24,'full'); %二进制变量，用来表示t时刻是充电还是放电，放电时为0
E_ba_t0 = 1000; %t0时刻储能量
E_ba = sdpvar(1,24); %t时刻储能量

%% 求解氢能个体与电网的成本，不参与合作
C3 = []; 

% 初始化状态约束
C3 = [C3, H_tank_press(1) == H_tank_t0];
C3 = [C3, E_ba(1) == E_ba_t0];

% 动态约束
for i = 2:24
    C3 = [C3, H_tank_press(i) == H_tank_press(i-1) ...
        + H_spec2Heat * Temp_tank_H ...
        * (Flow_com_H - H_avg(i)/10000) ...
        / (volume_tank_H * H_mol)];


    C3 = [C3, E_ba(i) == E_ba(i-1) ...
        + P_ba_c(i) * E_ba_c ...
        - P_ba_dis(i) / E_ba_dis];
end

% 运行约束
for i = 1:24 
    C3 = [C3, P_el(i) == H_tank_press(i) / H_yield_coeff];

    C3 = [C3,  P_el(i) >= 0]; 
    C3 = [C3,  P_el(i) <= P_el_max]; 

    C3 = [C3,  H_tank_press(i) >= H_tank_press_min];
    C3 = [C3,  H_tank_press(i) <= H_tank_press_max];

    if i <= 23
    C3 = [C3,  P_el(i+1) - P_el(i) <= P_el_rp_max]; 
    C3 = [C3,  P_el(i) - P_el(i+1) <= P_el_rp_max]; 
    end

    C3 = [C3,  P_com(i) >= H_avg(i)*2.85]; 

    C3 = [C3,  P_ba_c(i) <= ubatt(i) * P_ba_c_max];
    C3 = [C3,  P_ba_c(i) >= 0];

    C3 = [C3,  P_ba_dis(i) >= 0];
    C3 = [C3,  P_ba_dis(i) <= (1 - ubatt(i)) * P_ba_dis_max];

    C3 = [C3,  E_ba(i) >= E_ba_min];
    C3 = [C3,  E_ba(i) <= E_ba_max];

    C3 = [C3,  P_H_from_G(i)+ P_ba_dis(i) == P_el(i)+P_ba_c(i)+P_com(i)];
end 

%% 定义目标函数
cost_H_from_G = P_H_from_G * price_G; %电制氢主体从电网购电的成本
cost_H_om = el_om_coeff * sum(P_el) + ba_om_coeff * (sum(P_ba_c)+sum(P_ba_dis))^2; %电制氢运维成本
obj_H_Total_cost =  cost_H_from_G + cost_H_om; %电制氢的全部成本  

%% 求解问题 
options = sdpsettings('solver','gurobi'); % 使用求解器gurobi求解 
p1 = optimize(C3, obj_H_Total_cost, options); % 服从C，最小化f   

fprintf('Example problem: %s. \n', p1.info);   

sol_P_H_from_g = value(P_H_from_G); %获取电制氢电网购电量
sol_P_ba_dis = value(P_ba_dis); %获取电制氢每小时放电功率
sol_P_el = value(P_el); %获取电解槽设备功率
sol_P_ba_c = value(P_ba_c); %获取充电功率
sol_P_com = value(P_com); %获取压缩机设备功率

H_noncoop_ideal_cost = value(obj_H_Total_cost); %获取电制氢成本

%% 绘图
hours = 1:24;
y1label3 = sol_P_H_from_g; % 左轴数据（电制氢电网购电量）
y2label3 = sol_P_ba_dis; % 右轴数据（电制氢放电功率）

figure;
bb1 = bar(hours, y1label3, 0.3, 'FaceColor', [0.2 0.6 1]); % 0.3控制柱宽
hold on;
bb2 = bar(hours+0.25, y2label3, 0.3, 'FaceColor', [1 0.5 0.2]);

xlabel('小时');
title('电制氢系统每小时电能输入量');
ylabel('电能输入量 (kw)');
ylim([0 3000]);  % 设置左轴范围
set(gca, 'XTick', hours);  % 显示所有小时刻度
grid on;
legend([bb1, bb2], {'向电网购电量', '电制氢放电功率'}, 'Location', 'northwest');

y1label5 = sol_P_el;      % 左轴数据（电解槽功率）
y2label5 = sol_P_ba_c; % 右轴数据（充电功率）
y3label5 = sol_P_com; % 右轴数据（压缩机功率）
% 创建图形窗口
figure;
% 绘制左侧Y轴柱状图
bb1 = bar(hours-0.25, y1label5, 0.3, 'FaceColor', [0.2 0.6 1]); % 0.3控制柱宽
hold on;
bb2 = bar(hours+0.25, y2label5, 0.3, 'FaceColor', [1 0.5 0.2]); 
bb3 = bar(hours+0.5, y3label5, 0.3, 'FaceColor', [0.5 0.5 0.3]);
hold off;

xlabel('小时');
title('电制氢系统每小时电能输出量');
ylabel('电制氢系统设备功率 (kw)');
ylim([0 3000]);  % 设置左轴范围
set(gca, 'XTick', hours);  % 显示所有小时刻度
grid on;
legend([bb1, bb2, bb3], {'电解槽功率', '充电功率','压缩机功率'}, 'Location', 'northwest');