%% 风电场主体模型
wind1 = P_wind_pre(1,1:24); %提取第一种场景下风力发电每小时发电量
wind2 = P_wind_pre(2,1:24); %提取第二种场景下风力发电每小时发电量
wind3 = P_wind_pre(3,1:24); %提取第三种场景下风力发电每小时发电量
wind4 = P_wind_pre(4,1:24); %提取第四种场景下风力发电每小时发电量
wind5 = P_wind_pre(5,1:24); %提取第五种场景下风力发电每小时发电量
windf = []; %用于计算平均每小时风力发电量
for i = 1:24
    windf(i) = wind1(i) * pi(1) + wind2(i) * pi(2) + wind3(i) * pi(3) + wind4(i) * pi(4) + wind5(i) * pi(5); %计算出每小时风场的平均发电量
end
%% 定义1*24（1行24列）连续变量a1和c1 
a1 = sdpvar(1,24);  %t时刻风电场向电网出售的电量
b1 = [0.3376; 0.3376; 0.3376; 0.3376; 0.3376; 0.3376; 0.3376; 0.3376; 0.5980; 0.5980; 0.5980; 0.5980;
    0.8654; 0.8654; 0.8654; 0.5980; 0.5980; 0.5980; 0.5980; 0.8654; 0.8654; 0.8654; 0.8654; 0.3376;];  %每小时电网工业电价
pwt2ht = sdpvar(1,24);  %t时刻风电主体向电制氢主体的售电量
d1 = 0.34; %风电上网电价
e1 = 0.008; %风电场单位发电量维护成本系数
f1 = 0.00003; %过网费折算系数1
g1 = 0.01; %过网费折算系数2
%% 定义约束条件集合确保售电量等于发电量,同时计算各部分收益和成本
C1 = []; 
for i = 1:24 
    C1 = [C1,  a1(i) >= 0]; 
    C1 = [C1,  a1(i) <= windf(i)]; 
    C1 = [C1,  pwt2ht(i) >= 0]; 
    C1 = [C1,  pwt2ht(i) <= windf(i)]; 
    C1 = [C1, a1(i) + pwt2ht(i) == windf(i)];
end 
%% 定义目标函数f 
a11 = sum(a1) * d1; %风电出售给电网的收益
Uwt2h = pwt2ht * b1; %风电出售给电制氢的收益
a13 = sum(windf) * e1 ; %风电场发电所需成本
a14 = f1 * sum(pwt2ht)^2 + g1 * sum(pwt2ht);%风电场售电给电制氢的成本
Fwind =  - (a11 + Uwt2h - a13 - a14); %利润减成本，由于是最小化求解，前面加负号
%% 求解问题 
options = sdpsettings('solver','cplex'); % 使用求解器cplex求解 
p1 = optimize(C1, Fwind, options); % 服从C，最小化f 
%% 输出信息 
fprintf('Example problem: %s. \n', p1.info); 
%% 获取最优解和最优值 
a01 = value(a1); %获取t时刻风电场向电网出售的电量  
c01 = value(pwt2ht); %获取t时刻风电主体向电制氢主体的售电量
f01 = value(Fwind); %获取风电利润
shijif = sum(windf) * d1;
sf = shijif - a13;
%% 绘图
hours = 1:24;
y1label1 = a01;      % 左轴数据（向电网售电量）
y2label1 = c01; % 右轴数据（向电制氢售电量）
% 创建图形窗口
figure;
% 绘制左侧Y轴柱状图
bb1 = bar(hours, y1label1, 0.3, 'FaceColor', [0.2 0.6 1]); % 0.3控制柱宽
hold on;
bb2 = bar(hours+0.25, y2label1, 0.3, 'FaceColor', [1 0.5 0.2]); 
ylabel('售电量 (kw)');
ylim([0 1000]);  % 设置左轴范围
ax.YRightAxis.Visible = 'off';
% 设置公共参数
xlabel('小时');
title('风电主体每小时售电量');
set(gca, 'XTick', hours);  % 显示所有月份刻度
grid on;
% 添加图例（需要指定两个条形对象）
legend([bb1, bb2], {'向电网售电量', '向电制氢售电量'}, 'Location', 'northwest');
% 可选：设置自定义小时标签
hourNames = {'1','2','3','4','5','6','7','8','9','10','11','12',...
              '13','14','15','16','17','18','19','20','21','22','23','24'};
set(gca, 'XTickLabel', hourNames);
% 生成示例数据（时间序列，假设为24小时监控）
time = 1:24;          % 时间轴（小时）
% 两条横线（需扩展为与time等长的向量）
d1 = 0.34 * ones(size(time)); % 风电上网电价
d2 = 0.40 * ones(size(time)); % 光伏上网电价
figure;
hold on;
% 绘制折线（工业电价）
plot(time, b1, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'b');
% 绘制横线（更规范的写法）
plot(time, d1, 'r--', 'LineWidth', 2); % 红色虚线
plot(time, d2, 'g:', 'LineWidth', 2);  % 绿色点划线（更正线型）
% 图表美化
title('工业电价与风电价格和光电价格比较图 (24小时)', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('时间 (小时)', 'FontSize', 10);
ylabel('价格 (元)', 'FontSize', 10); % 修正字号
xlim([1 24]);
ylim([0 1]);         % 调整y轴范围以适配随机数据
% 添加图例（确保顺序与绘图一致）
legend('工业电价', '风电上网电价', '光伏上网电价', 'Location', 'northwest');
hold off;