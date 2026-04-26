%% 求解电制氢与风光主体之间进行传统合作时的成本
p_h2t = sdpvar(1,24); %t时刻储氢罐内部气压
ph20 = 28; %定义储氢罐内部0时刻气压
p_h2t(1) = ph20;
p_hgt =  sdpvar(1,24); %t时刻电制氢主体向电网买的购电量
pbat_ct =  sdpvar(1,24); %t时刻充电功率
pbat_dt =  sdpvar(1,24); %t时刻放电功率
u_batt = binvar(1,24,'full'); %二进制变量，用来表示t时刻是充电还是放电，放电时为0
ebat0 = 1000; %t0时刻储能量
e_batt = sdpvar(1,24); %t时刻储能量
e_batt(1) = ebat0;
for i = 2:24
    p_h2t(i) = p_h2t(i-1) + rh2*th2*(mtcom - Lh2t(i)/10000)/(vh2 * molh2); %计算t时刻储氢罐内部气压
end
for i = 2:24
   e_batt(i) = e_batt(i-1) + (pbat_ct(i) * ebatc - pbat_dt(i)/ebatd) ; %计算储能充放电功率
end
for i = 1:24
    pel0t(i) = p_h2t(i)/nh2; %计算t时刻电解槽耗电功率
end
%% 求解氢能个体与电网的成本，不参与合作
%%%% 定义约束条件集合
C3 = []; 
for i = 1:24 
    C3 = [C3,  pel0t(i) >= 0]; 
    C3 = [C3,  pel0t(i) <= pelmax]; 
    C3 = [C3,  p_h2t(i) >= ph2min];
    C3 = [C3,  p_h2t(i) <= ph2max];
    if i <= 23
    C3 = [C3,  pel0t(i+1) - pel0t(i) <= pelrp]; 
    C3 = [C3,  pel0t(i) - pel0t(i+1) <= pelrp]; 
    end
    C3 = [C3,  ptcom(i) >= 0]; 
    C3 = [C3,  pbat_ct(i) <= u_batt(i) * pbatcmax];
    C3 = [C3,  pbat_ct(i) >= 0];
    C3 = [C3,  pbat_dt(i) >= 0];
    C3 = [C3,  pbat_dt(i) <= (1 - u_batt(i)) * pbatdmax];
    C3 = [C3,  e_batt(i) >= ebatmin];
    C3 = [C3,  e_batt(i) <= ebatmax];
    C3 = [C3,  p_hgt(i)+ pbat_dt(i)+ pwt2ht(i)+ ppv2ht(i)== pel0t(i)+pbat_ct(i)+ptcom(i)];
end 
  
%%%% 定义目标函数f 
chg = p_hgt * b1; %电制氢主体从电网购电的成本
chm = kel * sum(pel0t) + kbat * (sum(pbat_ct)+sum(pbat_dt)^2); %电制氢运维成本
U_h0 =  chg + chm + Upv2h + Uwt2h; %电制氢的全部成本
  
%%%% 求解问题 
options = sdpsettings('solver','cplex'); % 使用求解器cplex求解 
p1 = optimize(C3, U_h0, options); % 服从C，最小化f 
  
%%%% 输出信息 
fprintf('Example problem: %s. \n', p1.info); 
  
%%%% 获取最优解和最优值 
f_02 = value(U_h0); %获取光电利润