clear;
% 3个发电机 
Nunits = 3;     
Horizon = 48;   % 48个时段 
Pmax = [100;50;25];   % 发电功率最大值 
Pmin = [20;40;1];     
% 发电功率最小值 
Q = diag([.04 .01 .02]);   % 矩阵Q，对角线元素为0.04, 0.01, 0.02 
C = [10 20 20];             
% 横向量C 
Pforecast = sdpvar(48,1);
Pforecast = 100 + 50*sin((1:Horizon)*2*pi/24);  % 横向量 
onoff = binvar(Nunits,Horizon,'full');  % 二元变量矩阵，大小为3x48 
P = sdpvar(Nunits,Horizon,'full');   % 连续变量矩阵，大小为3x48 
Constraints = []; 
for k = 1:Horizon 
Constraints = [Constraints, ... 
onoff(:,k).*Pmin <= P(:,k) <= onoff(:,k).*Pmax]; 
end 
for k = 1:Horizon 
Constraints = [Constraints, sum(P(:,k)) >= Pforecast(k)]; 
end 
Objective = 0; 
for k = 1:Horizon 
Objective = Objective + P(:,k)'*Q*P(:,k) + C*P(:,k); 
end 
ops = sdpsettings('solver','cplex'); % 使用求解器cplex求解 
p1 = optimize(Constraints, Objective, ops); % 服从C，最小化f 
% ops = sdpsettings('verbose',1,'debug',1);   % 设置选项 
% optimize(Constraints,Objective,ops)          
stairs(value(P)');                     
% 求解问题 
% 画图 
legend('Unit 1','Unit 2','Unit 3');  % 设置图例 
minup   = [6;30;1];  % 发电机开启后，必须持续运行的最小连续时段数量 
mindown = [3;6;3];   % 发电机关闭后，必须保持关闭的最小连续时段数量 
for k = 2:Horizon 
for unit = 1:Nunits 
% indicator = 1 当且仅当发电机被启动 
indicator = onoff(unit,k)-onoff(unit,k-1); 
range = k:min(Horizon,k+minup(unit)-1); 
% 以下约束条件只在indicator = 1时才起作用 
Constraints = [Constraints, onoff(unit,range) >= indicator]; 
end 
end 
for k = 2:Horizon 
for unit = 1:Nunits 
% indicator = 1 当且仅当发电机被关闭 
indicator = onoff(unit,k-1)-onoff(unit,k); 
range = k:min(Horizon,k+mindown(unit)-1); 
% 以下约束条件只在indicator = 1时才起作用 
Constraints = [Constraints, onoff(unit,range) <= 1-indicator]; 
end 
end 
ops = sdpsettings('solver','cplex'); % 使用求解器cplex求解 
p1 = optimize(Constraints, Objective, ops); % 服从C，最小化f 
stairs(value(P)'); 
legend('Unit 1','Unit 2','Unit 3'); 