pbatct =  sdpvar(1,24); %合作1时t时刻充电功率
pbatdt =  sdpvar(1,24); %合作1时t时刻放电功率
phgt =  sdpvar(1,24); %合作1时t时刻电制氢主体向电网买的购电量
pelt = sdpvar(1,24); %合作1时每小时输入电功率
ph2t = sdpvar(1,24); %t时刻储氢罐内部气压
ph2t(1) = ph20;
a_1 = sdpvar(1,24);  %t时刻风电场向电网出售的电量
p_wt2ht = sdpvar(1,24);  %t时刻风电主体向电制氢主体的售电量
a_2 = sdpvar(1,24);  %t时刻光伏主体向电网出售的电量
p_pv2ht = sdpvar(1,24);  %t时刻光伏主体向电制氢主体的售电量
ptcom2 = sdpvar(1,24); %合作时压缩机耗电功率
ebat0 = 1000; %t0时刻储能量
ebatt = sdpvar(1,24); %t时刻储能量
ebatt(1) = ebat0;
ubatt1 = binvar(1,24,'full'); %二进制变量，用来表示t时刻是充电还是放电，放电时为0
d1 = 0.34; %风电电价
d2 = 0.40; %光伏上网电价
for i = 2:24
    ph2t(i) = ph2t(i-1) + rh2*th2*(mtcom - Lh2t(i)/10000)/(vh2 * molh2); %计算t时刻储氢罐内部气压
end
for i = 2:24
   ebatt(i) = ebatt(i-1) + (pbat0ct(i) * ebatc - pbat0dt(i)/ebatd) ; %计算储能充放电功率
end
for i = 1:24
    pelt(i) = ph2t(i)/nh2; %计算t时刻电解槽耗电功率
end
%% 定义约束条件集合确保风光氢联盟效益最大化
C4 = []; 
for i = 1:24 
    C4 = [C4,  a_1(i) >= 0]; 
    C4 = [C4,  a_1(i) <= windf(i)]; 

    C4 = [C4,  p_wt2ht(i) >= 0]; 
    C4 = [C4,  p_wt2ht(i) <= windf(i)]; 

    C4 = [C4, a_1(i) + p_wt2ht(i) == windf(i)]; %风电主体约束
    
    C4 = [C4,  a_2(i) >= 0]; 
    C4 = [C4,  a_2(i) <= rayf(i)]; 
    C4 = [C4,  p_pv2ht(i) >= 0]; 
    C4 = [C4,  p_pv2ht(i) <= rayf(i)]; 
    C4 = [C4, a_2(i) + p_pv2ht(i) == rayf(i)]; %光电主体约束
    
    C4 = [C4,  pelt(i) >= 0]; 
    C4 = [C4,  pelt(i) <= pelmax]; 
    C4 = [C4,  ph2t(i) >= ph2min];
    C4 = [C4,  ph2t(i) <= ph2max];
    
    if i <= 23
    C4 = [C4,  pelt(i+1) - pelt(i) <= pelrp]; 
    C4 = [C4,  pelt(i) - pelt(i+1) <= pelrp]; 
    end

    C4 = [C4,  ptcom2(i) >= Lh2t(i)*2.85;]; 
    
    C4 = [C4,  pbatct(i) <= ubatt1(i) * pbatcmax];
    C4 = [C4,  pbatct(i) >= 0];
    
    C4 = [C4,  pbatdt(i) >= 0];
    C4 = [C4,  pbatdt(i) <= (1 - ubatt1(i)) * pbatdmax];
   
    C4 = [C4,  ebatt(i) >= ebatmin];
    C4 = [C4,  ebatt(i) <= ebatmax];
    
    C4 = [C4,  phgt(i)>=0];
    C4 = [C4,  phgt(i)+ pbatdt(i)+ p_wt2ht(i)+ p_pv2ht(i) == pelt(i)+pbatct(i)+ptcom2(i)]; %电制氢主体约束
end   
%% 定义目标函数f 
a_11 = sum(a_1) * d1; %风电出售给电网的收益
a_13 = sum(windf) * e1 ; %风电场发电所需成本
a_14 = f1 * sum(p_wt2ht)^2 + g1 * sum(p_wt2ht);%风电场售电给电制氢的成本
Wwt = a_11 - a_13 - a_14; %风电场合作的整体收益

a_21 = sum(a_2) * d2; %光电出售给电网的收益
a_23 = sum(rayf) * e2 ; %光伏电场发电所需成本
a_24 = f2 * sum(p_pv2ht)^2 + g2 * sum(p_pv2ht);%光伏电场售电给电制氢的成本
Wpv = a_21 - a_23 - a_24; %光伏场合作的整体收益

chg = phgt * b1 ; %电制氢主体从电网购电的成本
chm = kel * sum(pelt) + kbat * (sum(pbatct)+sum(pbatdt)^2); %电制氢运维成本
Wh =  -(chg + chm); %电制氢的全部成本
Fz1 = -(Wwt + Wpv + Wh); %合作1的整体收益

%%%% 求解问题 
options = sdpsettings('solver','cplex'); % 使用求解器cplex求解 
p1 = optimize(C4, Fz1, options); % 服从C，最小化f   
%%%% 输出信息 
fprintf('Example problem: %s. \n', p1.info);   
%%%% 获取最优解和最优值 
maxFz1 = -value(Fz1); %获取最高集体利润
s1 = value(phgt); %获取t时刻电制氢向电网的买电量
s2 = value(p_wt2ht); %获取t时刻电制氢向风电的购电量
s3 = value(p_pv2ht); %获取t时刻电制氢向光电的购电量
%% 绘图
hours = 1:24;
y1label4 = s1;      % 左轴数据（电网购电量）
y2label4 = s2; % 右轴数据（电制氢向风电的购电量）
y3label4 = s3; % 右轴数据（电制氢向光电的购电量）
% 创建图形窗口
figure;
% 绘制左侧Y轴柱状图
bb1 = bar(hours, y3label4+y2label4+y1label4, 0.6, 'FaceColor', [0.2 0.6 1]); % 0.6控制柱宽
hold on;
bb2 = bar(hours, y3label4+y2label4, 0.6, 'FaceColor', [1 0.5 0.2]); 
bb3 = bar(hours, y3label4, 0.6, 'FaceColor', [0.5 0.5 0.3]);
hold off;
ylabel('电制氢系统购电量 (kw)');
ylim([0 3000]);  % 设置左轴范围
% 设置公共参数
xlabel('小时');
title('电制氢系统每小时购电量');
set(gca, 'XTick', hours);  % 显示所有小时刻度
grid on;
% 添加图例（需要指定两个条形对象）
legend([bb1, bb2, bb3], {'电网购电量', '风电购电量','光电购电量'}, 'Location', 'northwest');
% 可选：设置自定义小时标签
hourNames = {'1','2','3','4','5','6','7','8','9','10','11','12',...
              '13','14','15','16','17','18','19','20','21','22','23','24'};
set(gca, 'XTickLabel', hourNames);