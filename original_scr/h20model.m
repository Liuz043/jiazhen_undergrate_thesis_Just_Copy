%% 电制氢独立主体模型
H21 = P_wind_pre(1,49:72); %提取第一种场景下每小时氢气需求量
H22 = P_wind_pre(2,49:72); %提取第二种场景下每小时氢气需求量
H23 = P_wind_pre(3,49:72); %提取第三种场景下每小时氢气需求量
H24 = P_wind_pre(4,49:72); %提取第四种场景下每小时氢气需求量
H25 = P_wind_pre(5,49:72); %提取第五种场景下每小时氢气需求量
Lh2t = []; %用于计算平均每小时风力发电量
for i = 1:24
    Lh2t(i) = H21(i) * pi(1) + H22(i) * pi(2) + H23(i) * pi(3) + H24(i) * pi(4) + H25(i) * pi(5); %计算出平均每小时氢气需求量
end
nh2 = 0.019224; %单位产氢量
pelmax = 5000; %最大约束功率
pelrp = 1000; %功率爬坡约束
rh2 = 14.304; %氢气比热容常数
tin = 40; %压缩机输入氢气的温度
ncom = 0.7; %压缩机工作效率
K = 1.4; %氢气等熵指数
k1 = (K-1)/K;% 氢气压缩机模型公式的指数次方
vh2 = 500; %氢气容量
th2 = 60; %储氢罐内部温度
molh2 = 0.002; %氢气摩尔质量
mtcom = 0.004; %t时刻压缩氢气流量
ph2min = 20; %储氢罐最小气压
ph2max = 40; %储氢罐最大气压
ebatmin = 200; %储能系统最小储能量
ebatmax = 1800; %储能系统最大储能量
ebatc = 0.95; %充电效率
ebatd = 0.96; %放电效率
pbatcmax = 500; %最大充电功率
pbatdmax = 600; %最大放电功率
kel = 0.022; %电解槽运维成本系数
kbat = 0.00018; %储能运维成本系数
pel0t = sdpvar(1,24); %每小时输入电功率
ptcom =  sdpvar(1,24); %压缩机耗电功率
ph20t = sdpvar(1,24); %t时刻储氢罐内部气压
ph20 = 28; %定义储氢罐内部0时刻气压
ph20t(1) = ph20;
phg0t =  sdpvar(1,24); %t时刻电制氢主体向电网买的购电量
pbat0ct =  sdpvar(1,24); %t时刻充电功率
pbat0dt =  sdpvar(1,24); %t时刻放电功率
ubatt = binvar(1,24,'full'); %二进制变量，用来表示t时刻是充电还是放电，放电时为0
ebat0 = 1000; %t0时刻储能量
ebatt0 = sdpvar(1,24); %t时刻储能量
ebatt0(1) = ebat0;
for i = 2:24
    ph20t(i) = ph20t(i-1) + rh2*th2*(mtcom - Lh2t(i)/10000)/(vh2 * molh2); %计算t时刻储氢罐内部气压
end
for i = 2:24
   ebatt0(i) = ebatt0(i-1) + (pbat0ct(i) * ebatc - pbat0dt(i)/ebatd) ; %计算储能充放电功率
end
for i = 1:24
    pel0t(i) = ph20t(i)/nh2; %计算t时刻电解槽耗电功率
end
%% 求解氢能个体与电网的成本，不参与合作
%%%% 定义约束条件集合
C3 = []; 
for i = 1:24 
    C3 = [C3,  pel0t(i) >= 0]; 
    C3 = [C3,  pel0t(i) <= pelmax]; 
    C3 = [C3,  ph20t(i) >= ph2min];
    C3 = [C3,  ph20t(i) <= ph2max];
    if i <= 23
    C3 = [C3,  pel0t(i+1) - pel0t(i) <= pelrp]; 
    C3 = [C3,  pel0t(i) - pel0t(i+1) <= pelrp]; 
    end
    C3 = [C3,  ptcom(i) >= Lh2t(i)*2.85;]; 
    C3 = [C3,  pbat0ct(i) <= ubatt(i) * pbatcmax];
    C3 = [C3,  pbat0ct(i) >= 0];
    C3 = [C3,  pbat0dt(i) >= 0];
    C3 = [C3,  pbat0dt(i) <= (1 - ubatt(i)) * pbatdmax];
    C3 = [C3,  ebatt0(i) >= ebatmin];
    C3 = [C3,  ebatt0(i) <= ebatmax];
    C3 = [C3,  phg0t(i)+ pbat0dt(i) == pel0t(i)+pbat0ct(i)+ptcom(i)];
end 
%%%% 定义目标函数f 
chg = phg0t * b1; %电制氢主体从电网购电的成本
chm = kel * sum(pel0t) + kbat * (sum(pbat0ct)+sum(pbat0dt))^2; %电制氢运维成本
Uh0 =  chg + chm; %电制氢的全部成本  
%%%% 求解问题 
options = sdpsettings('solver','gurobi'); % 使用求解器cplex求解 
p1 = optimize(C3, Uh0, options); % 服从C，最小化f   
%%%% 输出信息 
fprintf('Example problem: %s. \n', p1.info);   
%%%% 获取最优解和最优值 
f03 = value(Uh0); %获取电制氢最小成本
a03 = value(phg0t); %获取电制氢电网购电量
c03 = value(pbat0dt); %获取电制氢每小时放电功率
d03 = value(pel0t); %获取电解槽设备功率
e03 = value(pbat0ct); %获取充电功率
g03 = value(ptcom); %获取压缩机设备功率
%% 绘图
hours = 1:24;
y1label3 = a03;      % 左轴数据（电网购电量）
y2label3 = c03; % 右轴数据（电制氢每小时放电功率）
% 创建图形窗口
figure;
% 绘制左侧Y轴柱状图
bb1 = bar(hours, y1label3, 0.3, 'FaceColor', [0.2 0.6 1]); % 0.3控制柱宽
hold on;
bb2 = bar(hours+0.25, y2label3, 0.3, 'FaceColor', [1 0.5 0.2]); 
ylabel('电能输入量 (kw)');
ylim([0 3000]);  % 设置左轴范围
% 设置公共参数
xlabel('小时');
title('电制氢系统每小时电能输入量');
set(gca, 'XTick', hours);  % 显示所有小时刻度
grid on;
% 添加图例（需要指定两个条形对象）
legend([bb1, bb2], {'向电网购电量', '电制氢放电功率'}, 'Location', 'northwest');
% 可选：设置自定义小时标签
hourNames = {'1','2','3','4','5','6','7','8','9','10','11','12',...
              '13','14','15','16','17','18','19','20','21','22','23','24'};
set(gca, 'XTickLabel', hourNames);
y1label5 = d03;      % 左轴数据（电解槽功率）
y2label5 = e03; % 右轴数据（充电功率）
y3label5 = g03; % 右轴数据（压缩机功率）
% 创建图形窗口
figure;
% 绘制左侧Y轴柱状图
bb1 = bar(hours-0.25, y1label5, 0.3, 'FaceColor', [0.2 0.6 1]); % 0.3控制柱宽
hold on;
bb2 = bar(hours+0.25, y2label5, 0.3, 'FaceColor', [1 0.5 0.2]); 
bb3 = bar(hours+0.5, y3label5, 0.3, 'FaceColor', [0.5 0.5 0.3]);
hold off;
ylabel('电制氢系统设备功率 (kw)');
ylim([0 3000]);  % 设置左轴范围
% 设置公共参数
xlabel('小时');
title('电制氢系统每小时电能输出量');
set(gca, 'XTick', hours);  % 显示所有小时刻度
grid on;
% 添加图例（需要指定两个条形对象）
legend([bb1, bb2, bb3], {'电解槽功率', '充电功率','压缩机功率'}, 'Location', 'northwest');
% 可选：设置自定义小时标签
hourNames = {'1','2','3','4','5','6','7','8','9','10','11','12',...
              '13','14','15','16','17','18','19','20','21','22','23','24'};
set(gca, 'XTickLabel', hourNames);