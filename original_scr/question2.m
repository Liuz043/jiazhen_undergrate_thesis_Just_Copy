Wh2 = value(Wh); %子问题1求得的氢能成本最优解
Wwt2 = value(Wwt); %子问题1求得的风能最优解
Wpv2 = value(Wpv); %子问题1求得的光能最优解
Uh02 = -value(Uh0); %获取最低电制氢个体成本
Uwt02 = -f01; %获取最低风能个体利益
Upv02 = -f02; %获取最低光能个体利益
Pwj = sdpvar(24,1);%风电场每小时电价
Pgj = sdpvar(24,1);%光伏场每小时电价
U_wt2h = s2 * Pwj ; %参与合作时风与氢之间的交易收益
U_pv2h = s3 * Pgj ; %参与合作时光与氢之间的交易收益
%% 定义约束条件集合确保风光氢个体效益大于最低效益
C5 = [];
for i = 1:24 
if s2(i) > 0
C5 = [C5, Pwj(i)>=0.34];
end
if s3(i) > 0
C5 = [C5, Pgj(i)>=0.40];
end
C5 = [C5, Pwj(i)>=0];
C5 = [C5, Pwj(i)<=0.9];
C5 = [C5, Pgj(i)>=0];
C5 = [C5, Pgj(i)<=0.9];
end
C5 = [C5,  Wh2 - U_wt2h - U_pv2h >= Uh02]; %电制氢的最低个体利益
C5 = [C5,  Wwt2 + U_wt2h >= Uwt02]; %风能主体的最低个体利益
C5 = [C5,  Wpv2 + U_pv2h >= Upv02]; %光伏主体的最低个体利益
%% 定义目标函数f 
Fz2 = -(log(Wh2- U_wt2h- U_pv2h- Uh02)+ log(Wwt2+ U_wt2h- Uwt02)+ log(Wpv2+ U_pv2h- Upv02)); %合作2的整体收益
% setenv('PATH', [getenv('PATH') ';D:\Matlab 2019a\toolbox\mosek\11.0\tools\platform\win64x86\bin']); %mosek求解器问题，需要设置路径识别
%% 求解问题 
options = sdpsettings('solver','mosek'); % 使用求解器mosek求解 指数问题
p1 = optimize(C5, Fz2, options); % 服从C，最小化f   
%% 输出信息 
fprintf('Example problem: %s. \n', p1.info);   
%% 获取最优解和最优值 
hezuof = Wwt2 + U_wt2h;%获取合作后风能收益
hezuog = Wpv2 + U_pv2h;%获取合作后光能收益
maxFz2 = value(Fz2); %获取电能支付谈判子问题最低利益
U_wt = value(Pwj); %获取t时刻风电价格
U_pv = value(Pgj); %获取t时刻光电价格
%% 绘图
% 生成示例数据（时间序列，假设为24小时监控）
time = 1:24;          % 时间轴（小时）
figure;
hold on;
% 绘制折线（工业电价）
plot(time, b1, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'b');
% 绘制横线（更规范的写法）
plot(time, U_wt, 'r--', 'LineWidth', 2); % 红色虚线
plot(time, U_pv, 'g:', 'LineWidth', 2);  % 绿色点划线（更正线型）
% 图表美化
title('工业电价与风电价格和光电价格比较图 (24小时)', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('时间 (小时)', 'FontSize', 10);
ylabel('价格 (元)', 'FontSize', 10); % 修正字号
xlim([1 24]);
ylim([0 1]);         % 调整y轴范围以适配随机数据
% 添加图例（确保顺序与绘图一致）
legend('工业电价', '风电电价', '光伏电价', 'Location', 'northwest');
hold off;