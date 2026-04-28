(START OF CONTEXT)

# 研究复现项目记忆胶囊

## 1. 项目背景与核心目标

项目类型：研究生入门阶段论文复现训练。

复现对象：师兄本科毕业设计，主题为“风电场、光伏电场、电制氢系统多主体合作优化与纳什谈判收益分配”。

核心目标：

1. 用 MATLAB 复现师兄论文和源代码。
2. 理解从“随机场景生成、场景削减、非合作优化、合作交易量优化、纳什谈判价格分配、结果表格汇总”的完整流程。
3. 训练 YALMIP 建模、Gurobi 求解、随机场景处理、合作博弈收益分配。
4. 最终得到论文中的表 4.1、表 4.2、表 4.3、表 4.4 类似结果，并理解每个结果的物理意义。

系统主体：

1. 风电场。
2. 光伏电场。
3. 电制氢系统，包括电解槽、压缩机、储氢罐、储能电池。

论文主线：

1. 蒙特卡洛生成 1000 个风光氢随机场景。
2. 场景削减到 5 个典型场景。
3. 分别求风电、光伏、电制氢非合作模式结果。
4. 合作问题 1：求合作模式下风电、光伏、电网向电制氢供电的最优交易量。
5. 合作问题 2：在交易量固定后，用纳什谈判求风氢、光氢交易价格。
6. 汇总合作前理想收益、合作前实际收益、合作后实际收益、系统整体收益。

---

## 2. 当前最新进度与版本号

当前版本：`v0.5_refactor_reproduce`

当前进度：

1. `generate_scene.m` 已基本对齐师兄 `julei.m` 的场景生成逻辑。
2. `scene_reduction.m` 已复现场景削减逻辑。
3. `draw_scene.m` 用于绘制场景生成和削减后的图。
4. `common_params.m` 已抽出公共参数。
5. `WT_model.m` 已完成风电非合作模型。
6. `PV_model.m` 已完成光伏非合作模型。
7. `H_model.m` 已完成电制氢非合作模型。
8. `coop_question1.m` 已完成合作问题 1，求合作交易量。
9. `coop_question2.m` 已完成合作问题 2，求纳什谈判交易价格。
10. `result_summary.m` 已写出，能输出类似论文表 4.1 到表 4.4 的汇总结果。
11. 目前最大未决问题：纳什谈判破裂点口径。用“实际合作前收益”做破裂点时结果稳定且三方均分收益改善；用“理想合作前收益”做破裂点时，我的重构代码出现贴边解，而师兄源代码仍有约 181 的可分配剩余。准备组会问师兄。

当前确认结果之一，采用“实际合作前收益”为破裂点时，汇总输出：

```matlab
风电合作前实际收益 = 2612.4
风电合作后实际收益 = 3196.6
光伏合作前实际收益 = 1808.6
光伏合作后实际收益 = 2392.8
电制氢合作前成本 = 24359
电制氢合作后成本 = 23775
系统合作前净收益 = -19938
系统合作后净收益 = -18185
系统净收益改善 = 1752.52
三方收益增量约等分 = 584.17
```

采用“理想合作前收益”为破裂点时，我的当前重构代码结果：

```matlab
surplus_ideal ≈ 2.3647e-11
gain_WT ≈ 0
gain_PV ≈ 0
gain_H ≈ 0
```

师兄源代码在相同随机种子测试中输出：

```matlab
surplus_actual = 2173.5
surplus_ideal = 181.0651
```

说明师兄源代码以理想收益为破裂点时仍存在正可分配剩余。我自己的重构代码仍需对照排查。

---

## 3. 核心技术栈、库、版本、环境

软件环境：

1. MATLAB，用户本机有 MATLAB R2024。
2. YALMIP，用于 `sdpvar`、`binvar`、`optimize`、`sdpsettings`、`value`。
3. Gurobi，用于线性、二次、混合整数、非线性部分求解。当前日志显示：

   ```text
   Gurobi Optimizer version 13.0.1
   ```
4. MOSEK 原论文代码中用于 `log` 纳什谈判目标，但用户当前用 `gurobi` 或 `GUROBI-NONLINEAR` 也能求出 question2。
5. MATLAB Statistics and Machine Learning Toolbox，用于：

   ```matlab
   betarnd
   wblrnd
   ```

无硬件选型。该项目是 MATLAB 仿真复现，不涉及嵌入式硬件、引脚、通信协议。

核心文件结构：

```text
main_noncoop.m
common_params.m

generate_scene.m
scene_reduction.m
draw_scene.m

WT_model.m
PV_model.m
H_model.m

coop_question1.m
coop_question2.m

result_summary.m
parameters.txt
julei.m
```

主程序建议运行顺序：

```matlab
clear;
clc;
close all;

rng(20);

run('generate_scene.m');
run('scene_reduction.m');
run('draw_scene.m');

run('common_params.m');

run('WT_model.m');
run('PV_model.m');
run('H_model.m');

run('coop_question1.m');
run('coop_question2.m');

run('result_summary.m');
```

---

## 4. 数据结构与全局命名规范

### 4.1 参数文件

`parameters.txt` 是 24 行 6 列纯数字矩阵。

列含义：

```matlab
WT_c = parameter(:,1);  % 风电 Weibull 尺度参数
WT_k = parameter(:,2);  % 风电 Weibull 形状参数
PV_a = parameter(:,3);  % 光伏 Beta 参数 alpha
PV_b = parameter(:,4);  % 光伏 Beta 参数 beta
H_a  = parameter(:,5);  % 氢负荷 Beta 参数 alpha
H_b  = parameter(:,6);  % 氢负荷 Beta 参数 beta
```

### 4.2 场景数据

```matlab
times = 1000;

WT_data  % 24 x 1000，每小时 1000 个风电样本
PV_data  % 24 x 1000，每小时 1000 个光伏样本
H_data   % 24 x 1000，每小时 1000 个氢负荷样本
```

削减前拼接：

```matlab
P_data = [WT_data' PV_data' H_data'];
```

维度：

```matlab
P_data = 1000 x 72
```

含义：

```matlab
P_data(:, 1:24)   % 风电 24 小时曲线
P_data(:, 25:48)  % 光伏 24 小时曲线
P_data(:, 49:72)  % 氢负荷 24 小时曲线
```

削减后：

```matlab
P_data = 5 x 72
pi = 1 x 5
```

平均曲线：

```matlab
WT_avg = pi * P_data(:,1:24);
PV_avg = pi * P_data(:,25:48);
H_avg  = pi * P_data(:,49:72);
```

### 4.3 命名原则

使用含义清晰的长变量名。

功率、电量类：

```matlab
P_WT2G        % 风电卖给电网
P_WT2H        % 风电卖给电制氢
P_PV2G        % 光伏卖给电网
P_PV2H        % 光伏卖给电制氢
P_H_from_G    % 电制氢从电网购电
P_el          % 电解槽功率
P_com         % 压缩机功率
P_ba_c        % 储能充电功率
P_ba_dis      % 储能放电功率
E_ba          % 储能电量
H_tank_press  % 储氢罐气压
```

合作变量统一加 `_coop`：

```matlab
P_WT2G_coop
P_WT2H_coop
P_PV2G_coop
P_PV2H_coop

P_H_from_G_coop
P_el_coop
P_com_coop
P_ba_c_coop
P_ba_dis_coop
E_ba_coop
H_tank_press_coop
ubatt_coop
```

求解结果统一加 `sol_`：

```matlab
sol_P_WT2H_coop
sol_P_PV2H_coop
sol_P_H_from_G_coop
sol_price_WT_coop
sol_price_PV_coop
```

收益、成本、目标函数：

```matlab
revenue_...      % 收入
cost_...         % 成本
profit_...       % 利润
payment_...      % 内部交易支付额
gain_...         % 相对破裂点收益增量
obj_neg_...      % 为适配最小化而取负的目标函数
```

避免继续使用师兄原代码里的 `a1`、`a2`、`f01`、`f02`、`Wh2`、`Wwt2`、`Uwt02` 这类不透明命名，除非专门对照原代码。

---

## 5. 公共参数规范

`common_params.m` 只放常数，不放 `sdpvar`、`binvar`、优化结果。不能写 `clear`、`clc`、`close all`。

关键公共参数：

```matlab
T = 24;
hours = 1:T;
solver_name = 'gurobi';
```

工业分时电价必须是 24 x 1 列向量：

```matlab
price_G = [
    0.3376; 0.3376; 0.3376; 0.3376; 0.3376; 0.3376;
    0.3376; 0.3376; 0.5980; 0.5980; 0.5980; 0.5980;
    0.8654; 0.8654; 0.8654; 0.5980; 0.5980; 0.5980;
    0.5980; 0.8654; 0.8654; 0.8654; 0.8654; 0.3376
];
price_G = price_G(:);
```

风电和光伏上网电价必须是标量，不能是 1 x 24 向量：

```matlab
price_WT2G = 0.34;
price_PV2G = 0.40;
```

如果画横线，必须另起变量名：

```matlab
price_WT2G_line = price_WT2G * ones(1,24);
price_PV2G_line = price_PV2G * ones(1,24);
```

风电成本参数：

```matlab
cost_WT_om_coeff = 0.008;
cost_WT2H_quad_coeff = 0.00003;
cost_WT2H_linear_coeff = 0.01;
```

光伏成本参数：

```matlab
cost_PV_om_coeff = 0.0085;
cost_PV2H_quad_coeff = 0.00003;
cost_PV2H_linear_coeff = 0.01;
```

电制氢系统参数：

```matlab
H_yield_coeff = 0.019224;

P_el_max = 5000;
P_el_rp_max = 1000;

H_spec2Heat = 14.304;
T_in = 40;
n_com = 0.7;
K = 1.4;
k1 = (K - 1) / K;

volume_tank_H = 500;
Temp_tank_H = 60;
H_mol = 0.002;
Flow_com_H = 0.004;

H_tank_press_min = 20;
H_tank_press_max = 40;
H_tank_t0 = 28;

E_ba_min = 200;
E_ba_max = 1800;
E_ba_t0 = 1000;

E_ba_c = 0.95;
E_ba_dis = 0.96;

P_ba_c_max = 500;
P_ba_dis_max = 600;

el_om_coeff = 0.022;
ba_om_coeff = 0.00018;
```

---

## 6. 场景生成逻辑，必须和师兄一致

为了让 `rng(20)` 下图形和师兄前面场景图一致，`generate_scene.m` 中每小时随机数调用顺序必须和师兄 `julei.m` 一致：

```text
每个 t：
1. 光伏 betarnd
2. 氢负荷 betarnd
3. 风速 wblrnd
```

光伏逻辑：

```matlab
if a_pv > 0
    S_pv = 10;
    prey_pv = 0.14;
    rmax = 700;
    pv_samp = betarnd(a_pv, b_pv, 1, times);
    Ppv_samp = pv_samp * rmax * S_pv * prey_pv;
else
    Ppv_samp = zeros(1,times);
end
```

重要坑点：

```matlab
a_pv > 0
```

不能写成：

```matlab
a_pv > 1
```

否则白天 `a_pv=0.54`、`0.86` 时会被错误置 0。

风电参数必须和师兄一致：

```matlab
PN_wt = 1000;
vci = 3;
vN = 13;
vco = 25;
```

重要坑点：

```matlab
vN = 13
```

不能写成：

```matlab
vN = 12
```

否则风电曲线、场景削减概率都会不同。

场景削减必须对齐师兄：

```matlab
P_data = [WT_data' PV_data' H_data'];
pi = 1/times * ones(1,times);
number = 5;
```

距离计算为了复现师兄，当前只用前 24 列风电数据：

```matlab
for k = 1:24
    l(i,j) = l(i,j) + (P_data(i,k) - P_data(j,k))^2;
end
```

从建模角度，用 1:72 更合理；从复现角度，必须先用 1:24。

---

## 7. 非合作模型核心逻辑

### 7.1 风电非合作模型

决策变量：

```matlab
P_WT2G = sdpvar(1,T);
P_WT2H = sdpvar(1,T);
```

约束：

```matlab
P_WT2G(i) >= 0
P_WT2H(i) >= 0
P_WT2G(i) + P_WT2H(i) == WT_avg(i)
```

目标：

```matlab
revenue_WT2G = sum(P_WT2G) * price_WT2G;
revenue_WT2H = P_WT2H * price_G;

cost_WT_om = sum(WT_avg) * cost_WT_om_coeff;

cost_WT2H = cost_WT2H_quad_coeff * sum(P_WT2H)^2 ...
          + cost_WT2H_linear_coeff * sum(P_WT2H);

obj_WT_profit = -(revenue_WT2G + revenue_WT2H - cost_WT_om - cost_WT2H);
```

重要输出：

```matlab
ideal_profit_WT_noncoop = -value(obj_WT_profit);
ideal_revenue_WT_G_only = sum(WT_avg) * price_WT2G;
ideal_profit_WT_G_only = ideal_revenue_WT_G_only - value(cost_WT_om);
```

物理含义：

```text
合作前理想收益：风电自由选择卖电网或卖电制氢时的最大利润。
合作前实际收益：传统非合作实际中电制氢不交易，风电全部卖电网的利润。
```

### 7.2 光伏非合作模型

同风电模型。

关键输出：

```matlab
ideal_profit_PV_noncoop
ideal_revenue_PV_G_only
ideal_profit_PV_G_only
```

注意师兄原代码里 `sg = shijig - a13` 可疑，物理上应为扣光伏运维成本 `a23`。先忠实复现时可保持师兄写法；重构版本建议用光伏自身运维成本。

### 7.3 电制氢非合作模型

决策变量：

```matlab
P_el = sdpvar(1,T);
P_com = sdpvar(1,T);
H_tank_press = sdpvar(1,T);

P_H_from_G = sdpvar(1,T);
P_ba_c = sdpvar(1,T);
P_ba_dis = sdpvar(1,T);
E_ba = sdpvar(1,T);
ubatt = binvar(1,T,'full');
```

所有动态关系必须写成约束，不能直接给 `sdpvar` 赋值：

正确：

```matlab
C3 = [C3, H_tank_press(1) == H_tank_t0];
C3 = [C3, E_ba(1) == E_ba_t0];

C3 = [C3, H_tank_press(i) == H_tank_press(i-1) + ...];
C3 = [C3, E_ba(i) == E_ba(i-1) + ...];
C3 = [C3, P_el(i) == H_tank_press(i) / H_yield_coeff];
```

错误：

```matlab
H_tank_press(1) = H_tank_t0;
E_ba(1) = E_ba_t0;
P_el(i) = H_tank_press(i) / H_yield_coeff;
```

非合作功率平衡：

```matlab
P_H_from_G(i) + P_ba_dis(i) == P_el(i) + P_ba_c(i) + P_com(i)
```

成本：

```matlab
cost_H_from_G = P_H_from_G * price_G;
```

电制氢运维成本存在两个口径：

师兄原代码口径：

```matlab
cost_H_om = el_om_coeff * sum(P_el) ...
          + ba_om_coeff * (sum(P_ba_c) + sum(P_ba_dis)^2);
```

我曾经写过的另一口径：

```matlab
cost_H_om = el_om_coeff * sum(P_el) ...
          + ba_om_coeff * (sum(P_ba_c) + sum(P_ba_dis))^2;
```

当前若要严格复现师兄，应使用第一种。

输出：

```matlab
ideal_cost_H_noncoop_Total = value(cost_H_from_G + cost_H_om);
```

---

## 8. 合作问题 1 核心逻辑

文件：`coop_question1.m`

功能：求合作模式下交易量，不求风氢、光氢交易价格。

合作变量：

```matlab
P_WT2G_coop = sdpvar(1,T);
P_WT2H_coop = sdpvar(1,T);

P_PV2G_coop = sdpvar(1,T);
P_PV2H_coop = sdpvar(1,T);

P_H_from_G_coop = sdpvar(1,T);
P_el_coop = sdpvar(1,T);
P_com_coop = sdpvar(1,T);
H_tank_press_coop = sdpvar(1,T);

P_ba_c_coop = sdpvar(1,T);
P_ba_dis_coop = sdpvar(1,T);
E_ba_coop = sdpvar(1,T);
ubatt_coop = binvar(1,T,'full');
```

风光出力分配：

```matlab
P_WT2G_coop(i) + P_WT2H_coop(i) == WT_avg(i)
P_PV2G_coop(i) + P_PV2H_coop(i) == PV_avg(i)
```

合作电制氢功率平衡：

```matlab
P_H_from_G_coop(i) + P_ba_dis_coop(i) + P_WT2H_coop(i) + P_PV2H_coop(i) ...
== P_el_coop(i) + P_ba_c_coop(i) + P_com_coop(i)
```

合作问题 1 风电基础利润，只包含电网售电、运维、过网费，不包含风氢内部交易支付：

```matlab
revenue_WT_coop = sum(P_WT2G_coop) * price_WT2G;
cost_WT_om_coop = sum(WT_avg) * cost_WT_om_coeff;
cost_WT2H_coop = cost_WT2H_quad_coeff * sum(P_WT2H_coop)^2 ...
               + cost_WT2H_linear_coeff * sum(P_WT2H_coop);

ideal_profit_WT_coop_Total = revenue_WT_coop - cost_WT_om_coop - cost_WT2H_coop;
```

合作问题 1 光伏基础利润：

```matlab
revenue_PV_coop = sum(P_PV2G_coop) * price_PV2G;
cost_PV_om_coop = sum(PV_avg) * cost_PV_om_coeff;
cost_PV2H_coop = cost_PV2H_quad_coeff * sum(P_PV2H_coop)^2 ...
               + cost_PV2H_linear_coeff * sum(P_PV2H_coop);

ideal_profit_PV_coop_Total = revenue_PV_coop - cost_PV_om_coop - cost_PV2H_coop;
```

合作问题 1 电制氢基础成本，不包含支付给风电和光伏的钱：

```matlab
cost_H_from_G_coop = P_H_from_G_coop * price_G;

cost_H_om_coop = el_om_coeff * sum(P_el_coop) ...
               + ba_om_coeff * (sum(P_ba_c_coop) + sum(P_ba_dis_coop)^2);

ideal_cost_H_coop_Total = cost_H_from_G_coop + cost_H_om_coop;
```

目标函数：

```matlab
obj_neg_revenue_coop = - (ideal_profit_WT_coop_Total ...
                        + ideal_profit_PV_coop_Total ...
                        - ideal_cost_H_coop_Total);
```

求解后必须保存：

```matlab
sol_P_WT2H_coop = value(P_WT2H_coop);
sol_P_PV2H_coop = value(P_PV2H_coop);
sol_P_H_from_G_coop = value(P_H_from_G_coop);

sol_P_el_coop = value(P_el_coop);
sol_P_ba_c_coop = value(P_ba_c_coop);
sol_P_ba_dis_coop = value(P_ba_dis_coop);
sol_P_com_coop = value(P_com_coop);
```

重要原则：question1 不应包含内部交易支付。风氢、光氢交易收入与支出只在 question2 出现。

---

## 9. 合作问题 2 核心逻辑

文件：`coop_question2.m`

功能：在 question1 已求出交易量后，求风氢、光氢交易价格。

价格变量：

```matlab
price_WT_coop = sdpvar(24,1);
price_PV_coop = sdpvar(24,1);
```

交易支付额必须写成逐小时点积，不能用 `.*`：

正确：

```matlab
payment_WT2H_coop = sol_P_WT2H_coop(:)' * price_WT_coop;
payment_PV2H_coop = sol_P_PV2H_coop(:)' * price_PV_coop;
```

错误：

```matlab
payment_WT2H_coop = sol_P_WT2H_coop .* price_WT_coop;
```

最终利润与成本：

```matlab
profit_WT_coop_final = ideal_profit_WT_coop_Total + payment_WT2H_coop;
profit_PV_coop_final = ideal_profit_PV_coop_Total + payment_PV2H_coop;

cost_H_coop_final = ideal_cost_H_coop_Total ...
                  + payment_WT2H_coop ...
                  + payment_PV2H_coop;
```

破裂点两种口径：

口径 A，师兄原代码理想收益破裂点：

```matlab
gain_WT = profit_WT_coop_final - ideal_profit_WT_noncoop;
gain_PV = profit_PV_coop_final - ideal_profit_PV_noncoop;
gain_H = ideal_cost_H_noncoop_Total - cost_H_coop_final;
```

口径 B，合作前实际收益破裂点：

```matlab
gain_WT = profit_WT_coop_final - ideal_profit_WT_G_only;
gain_PV = profit_PV_coop_final - ideal_profit_PV_G_only;
gain_H = ideal_cost_H_noncoop_Total - cost_H_coop_final;
```

当前现象：

1. 口径 A 更接近师兄原代码，但我的重构版本会出现贴边解。
2. 口径 B 经济解释更稳定，三方均获得明显收益增量。

价格约束：

```matlab
for i = 1:24
    C5 = [C5, price_WT_coop(i) >= 0];
    C5 = [C5, price_WT_coop(i) <= 0.9];

    C5 = [C5, price_PV_coop(i) >= 0];
    C5 = [C5, price_PV_coop(i) <= 0.9];

    if sol_P_WT2H_coop(i) > 1e-6
        C5 = [C5, price_WT_coop(i) >= price_WT2G];
    else
        C5 = [C5, price_WT_coop(i) == 0];
    end

    if sol_P_PV2H_coop(i) > 1e-6
        C5 = [C5, price_PV_coop(i) >= price_PV2G];
    else
        C5 = [C5, price_PV_coop(i) == 0];
    end
end
```

个体理性约束：

```matlab
eps_gain = 0;       % 忠实复现师兄边界解时使用
% eps_gain = 1e-6;  % 规范模型更合理，但理想收益口径下可能不可行

C5 = [C5, gain_WT >= eps_gain];
C5 = [C5, gain_PV >= eps_gain];
C5 = [C5, gain_H >= eps_gain];
```

目标函数：

```matlab
obj_neg_nash_log = - (log(gain_WT) + log(gain_PV) + log(gain_H));
```

目标函数命名必须用：

```matlab
obj_neg_nash_log
```

不要叫 `obj_profit` 或 `obj_revenue`。

求解后保存：

```matlab
sol_price_WT_coop = value(price_WT_coop);
sol_price_PV_coop = value(price_PV_coop);

sol_payment_WT2H_coop = value(payment_WT2H_coop);
sol_payment_PV2H_coop = value(payment_PV2H_coop);

sol_profit_WT_coop_final = value(profit_WT_coop_final);
sol_profit_PV_coop_final = value(profit_PV_coop_final);
sol_cost_H_coop_final = value(cost_H_coop_final);

sol_gain_WT = value(gain_WT);
sol_gain_PV = value(gain_PV);
sol_gain_H = value(gain_H);
```

---

## 10. 理想收益、实际收益、合作后实际收益的物理意义

针对风电、光伏。

合作前理想收益：

```text
非合作优化模型中，风电或光伏从自身利润最大化角度自由选择卖给电网或电制氢，得到的最优利润。
```

代码对应：

```matlab
ideal_profit_WT_noncoop = -value(obj_WT_profit);
ideal_profit_PV_noncoop = -value(obj_PV_profit);
```

合作前实际收益：

```text
传统非合作现实下，电制氢系统不与风光交易，风电和光伏只能全部卖给电网。
```

代码对应：

```matlab
ideal_profit_WT_G_only = sum(WT_avg) * price_WT2G - cost_WT_om;
ideal_profit_PV_G_only = sum(PV_avg) * price_PV2G - cost_PV_om;
```

合作后实际收益：

```text
question1 确定风光卖给电制氢的交易量，question2 确定交易价格后，风电和光伏的最终收益。
```

代码对应：

```matlab
profit_WT_coop_final = ideal_profit_WT_coop_Total + payment_WT2H_coop;
profit_PV_coop_final = ideal_profit_PV_coop_Total + payment_PV2H_coop;
```

电制氢没有“理想收益”和“实际收益”的区分，主要比较合作前成本和合作后成本。

---

## 11. 重大 Bug 与修复记录

### 11.1 `sdpvar` 不能直接赋值

错误：

```matlab
H_tank_press(1) = H_tank_t0;
E_ba(1) = E_ba_t0;
P_el(i) = H_tank_press(i)/H_yield_coeff;
```

修复：

```matlab
C3 = [C3, H_tank_press(1) == H_tank_t0];
C3 = [C3, E_ba(1) == E_ba_t0];
C3 = [C3, P_el(i) == H_tank_press(i)/H_yield_coeff];
```

否则会出现：

```text
One of the constraints evaluates to a DOUBLE variable
```

### 11.2 目标函数变成向量导致 `Nonlinear multi-objective`

原因：`price_WT2G` 在画图时被覆盖成 `1 x 24` 向量。

错误：

```matlab
price_WT2G = 0.34 * ones(size(time));
revenue_WT_coop = sum(P_WT2G_coop) * price_WT2G;
```

修复：

```matlab
price_WT2G = 0.34;  % 标量
price_WT2G_line = price_WT2G * ones(1,24);  % 画图专用
```

检查方式：

```matlab
disp(size(obj_neg_revenue_coop));  % 必须是 1 1
```

### 11.3 交易支付额不能用逐元素乘法

错误：

```matlab
payment_WT2H_coop = sol_P_WT2H_coop .* price_WT_coop;
```

原因：`1 x 24` 与 `24 x 1` 会扩展成 `24 x 24`。

修复：

```matlab
payment_WT2H_coop = sol_P_WT2H_coop(:)' * price_WT_coop;
```

### 11.4 价格约束不能把电量和价格比较

错误：

```matlab
C5 = [C5, sol_P_WT2H_coop(i) >= price_WT2G];
```

修复：

```matlab
C5 = [C5, price_WT_coop(i) >= price_WT2G];
```

### 11.5 场景生成对不齐

原因：

1. 随机调用顺序不一致。
2. 光伏判断条件写成 `a_pv > 1`。
3. 光伏面积写成 `S_pv = 8`。
4. 风机额定风速写成 `vN = 12`。

修复：

```text
调用顺序：光伏、氢负荷、风电。
光伏条件：a_pv > 0。
光伏面积：S_pv = 10。
风机额定风速：vN = 13。
```

### 11.6 场景削减距离维度

从复现师兄角度，距离只用 1:24：

```matlab
for k = 1:24
```

不能擅自改为 1:72，否则和师兄图不一致。

### 11.7 question1 画图变量误导

原先可能画成：

```matlab
风电卖给电网 + 光伏卖给电网 + 电制氢从电网购电
```

这是无明确物理意义的组合。

正确画电制氢购电结构：

```matlab
purchase_matrix = [
    sol_P_H_from_G_coop(:), ...
    sol_P_WT2H_coop(:), ...
    sol_P_PV2H_coop(:)
];

bar(hours, purchase_matrix, 'stacked');
legend('电网购电量','风电购电量','光伏购电量');
```

---

## 12. 当前未解决问题与下一步待办

### 12.1 最大未解决问题：破裂点口径

当前现象：

1. 师兄原代码中：

   ```matlab
   surplus_actual = 2173.5
   surplus_ideal = 181.0651
   ```
2. 我的重构代码中：

   ```matlab
   surplus_actual = 1752.5
   surplus_ideal ≈ 0
   ```

下一步：

1. 在师兄源代码和我的代码里同时输出 `surplus_ideal` 的三部分构成。
2. 对比：

   ```matlab
   风电部分 = cooperation_WT_base - WT_ideal_noncoop
   光伏部分 = cooperation_PV_base - PV_ideal_noncoop
   电制氢部分 = H_noncoop_cost - H_coop_base_cost
   ```
3. 找出差异是否来自风电、光伏、电制氢中的某一个模块。
4. 组会问师兄：论文 question2 破裂点到底用理想收益还是实际收益。

师兄变量版检查代码：

```matlab
surplus_actual = ...
    (Wwt2 - sf) ...
  + (Wpv2 - sg) ...
  + (Wh2 - Uh02);

surplus_ideal = ...
    (Wwt2 - Uwt02) ...
  + (Wpv2 - Upv02) ...
  + (Wh2 - Uh02);
```

我的变量版检查代码：

```matlab
surplus_actual = ...
    (ideal_profit_WT_coop_Total - ideal_profit_WT_G_only) ...
  + (ideal_profit_PV_coop_Total - ideal_profit_PV_G_only) ...
  + (ideal_cost_H_noncoop_Total - ideal_cost_H_coop_Total);

surplus_ideal = ...
    (ideal_profit_WT_coop_Total - ideal_profit_WT_noncoop) ...
  + (ideal_profit_PV_coop_Total - ideal_profit_PV_noncoop) ...
  + (ideal_cost_H_noncoop_Total - ideal_cost_H_coop_Total);
```

### 12.2 价格曲线和论文不完全一致

原因可能包括：

1. 随机场景不同。
2. `question2` 多解，小时价格不唯一。
3. 没有交易的时段价格无经济意义。
4. 论文图可能做过后处理。
5. 师兄源代码跑出的价格图也和论文图不完全一样。

后处理建议：

```matlab
plot_price_WT = sol_price_WT_coop;
plot_price_PV = sol_price_PV_coop;

plot_price_WT(sol_P_WT2H_coop(:) <= 1e-6) = 0;
plot_price_PV(sol_P_PV2H_coop(:) <= 1e-6) = 0;
```

### 12.3 是否严格复现师兄源代码，还是使用更合理版本

两个版本都要保留：

版本 A：师兄源代码口径。

```text
破裂点：理想非合作收益。
优点：接近论文理论表述。
问题：我的重构代码目前出现边界解。
```

版本 B：实际收益口径。

```text
破裂点：合作前实际收益。
优点：三方均有明确正收益改善，系统收益闭合。
问题：合作后实际收益可能低于合作前理想收益。
```

---

## 13. result_summary.m 当前输出内容

`result_summary.m` 应输出：

1. 求解状态。
2. 表 4.1 风电合作前后收益比较。
3. 表 4.2 光伏合作前后收益比较。
4. 表 4.3 电制氢合作前后成本比较。
5. 表 4.4 系统整体收益比较。
6. question1 与 question2 的系统净收益一致性检查。
7. 纳什谈判收益增量检查。
8. 合作后电制氢购电结构汇总。
9. 保存 `summary_results.mat`。

关键一致性检查：

```matlab
system_net_after_from_q1 = ideal_profit_WT_coop_Total ...
                         + ideal_profit_PV_coop_Total ...
                         - ideal_cost_H_coop_Total;

system_net_after_from_q2 = sol_profit_WT_coop_final ...
                         + sol_profit_PV_coop_final ...
                         - sol_cost_H_coop_final;
```

差值应接近 0：

```matlab
abs(system_net_after_from_q2 - system_net_after_from_q1) < 1e-6
```

---

## 14. 和师兄组会沟通的问题

建议直接问：

1. `question2` 的纳什谈判破裂点到底采用哪一组？

   ```matlab
   Uwt02 = -f01;
   Upv02 = -f02;
   ```

   还是：

   ```matlab
   sf
   sg
   ```

2. 表 4.1、表 4.2 中“合作前理想收益”和“合作前实际收益”在最终纳什谈判约束里分别扮演什么角色？

3. 论文里“合作后实际收益大于合作前理想收益”的结果，是直接由源代码生成，还是经过结果筛选或图表整理？

4. 价格图中没有交易的时段是否做了置零或后处理？

5. 师兄源代码中光伏实际收益 `sg = shijig - a13` 是否是笔误？是否应为 `sg = shijig - a23`？

6. 电制氢储能运维成本公式到底采用：

   ```matlab
   sum(P_ba_c) + sum(P_ba_dis)^2
   ```

   还是：

   ```matlab
   (sum(P_ba_c) + sum(P_ba_dis))^2
   ```

---

## 15. 继续推进时的优先级

优先级 1：保持当前能跑通版本，保存代码和输出。

优先级 2：把师兄源代码和重构代码的 `surplus_ideal` 分项差异找出来。

优先级 3：组会确认破裂点口径。

优先级 4：根据师兄反馈决定最终保留版本：

1. 忠实复现版。
2. 逻辑修正版。
3. 对照分析版。

优先级 5：整理复现报告，重点写清：

1. 场景生成和削减。
2. 三主体非合作模型。
3. 合作问题 1。
4. 合作问题 2。
5. 理想收益、实际收益、合作后实际收益的区别。
6. 破裂点口径对纳什谈判结果的影响。

(END OF CONTEXT)
