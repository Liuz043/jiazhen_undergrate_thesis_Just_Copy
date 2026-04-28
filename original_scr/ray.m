%% 光伏主体模型
ray1 = P_wind_pre(1,25:48); %提取第一种场景下光伏发电每小时发电量
ray2 = P_wind_pre(2,25:48); %提取第二种场景下光伏发电每小时发电量
ray3 = P_wind_pre(3,25:48); %提取第三种场景下光伏发电每小时发电量
ray4 = P_wind_pre(4,25:48); %提取第四种场景下光伏发电每小时发电量
ray5 = P_wind_pre(5,25:48); %提取第五种场景下光伏发电每小时发电量
rayf = []; %用于计算平均每小时光伏发电量
for i = 1:24
    rayf(i) = ray1(i) * pi(1) + ray2(i) * pi(2) + ray3(i) * pi(3) + ray4(i) * pi(4) + ray5(i) * pi(5); %计算出每小时光伏的平均发电量
end
%%%% 定义1*24（1行24列）连续变量a1和c1 
a2 = sdpvar(1,24);  %t时刻光伏主体向电网出售的电量
ppv2ht = sdpvar(1,24);  %t时刻光伏主体向电制氢主体的售电量
d2 = 0.40; %光伏上网电价
e2 = 0.0085; %光伏单位发电量维护成本系数
f2 = 0.00003; %过网费折算系数1
g2 = 0.01; %过网费折算系数2  
%%%% 定义约束条件集合确保售电量等于发电量,同时计算各部分收益和成本
C2 = []; 
for i = 1:24 
    C2 = [C2,  a2(i) >= 0]; 
    C2 = [C2,  a2(i) <= rayf(i)]; 
    C2 = [C2,  ppv2ht(i) >= 0]; 
    C2 = [C2,  ppv2ht(i) <= rayf(i)]; 
    C2 = [C2, a2(i) + ppv2ht(i) == rayf(i)];
end 
%%%% 定义目标函数f 
a21 = sum(a2) * d2; %光电出售给电网的收益
Upv2h = ppv2ht * b1; %光电出售给电制氢的收益
a23 = sum(rayf) * e2 ; %光伏电场发电所需成本
a24 = f2 * sum(ppv2ht)^2 + g2 * sum(ppv2ht);%光伏电场售电给电制氢的成本
Fray =  - (a21 + Upv2h - a23 - a24); %利润减成本，由于是最小化求解，前面加负号  
%%%% 求解问题 
options = sdpsettings('solver','gurobi'); % 使用求解器cplex求解 
p1 = optimize(C2, Fray, options); % 服从C，最小化f   
%%%% 输出信息 
fprintf('Example problem: %s. \n', p1.info); 
%%%% 获取最优解和最优值 
a02 = value(a2); %获取t时刻光电场向电网出售的电量  
c02 = value(ppv2ht); %获取t时刻光伏主体向电制氢主体的售电量
f02 = value(Fray); %获取光电利润
shijig = sum(rayf) * d2;
sg = shijig - a13;
%% 绘图
hours = 1:24;
y1label2 = a02;      % 左轴数据（向电网售电量）
y2label2 = c02; % 右轴数据（向电制氢售电量）
% 创建图形窗口
figure;
% 绘制左侧Y轴柱状图
bb1 = bar(hours, y1label2, 0.3, 'FaceColor', [0.2 0.6 1]); % 0.3控制柱宽
hold on;
bb2 = bar(hours+0.25, y2label2, 0.3, 'FaceColor', [1 0.5 0.2]); 
ylabel('售电量 (kw)');
ylim([0 1000]);  % 设置左轴范围
% 设置公共参数
xlabel('小时');
title('光伏主体每小时售电量');
set(gca, 'XTick', hours);  % 显示所有月份刻度
grid on;
% 添加图例（需要指定两个条形对象）
legend([bb1, bb2], {'向电网售电量', '向电制氢售电量'}, 'Location', 'northwest');
% 可选：设置自定义小时标签
hourNames = {'1','2','3','4','5','6','7','8','9','10','11','12',...
              '13','14','15','16','17','18','19','20','21','22','23','24'};
set(gca, 'XTickLabel', hourNames);