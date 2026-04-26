clear;
clc;
close all;

run('intialization.m');
run('scene_reduction.m');

%% 概率
figure(1);
plot(pi);
xlabel('场景数');
ylabel('概率');
title('各场景下概率');

%% 风电（原始数据）
figure(2);
for i = 1:times
    x = 1:24;
    y = i * ones(1,24);
    z = WT_data(:,i);
    plot3(x, y, z);
    hold on;
end
grid on;
xlabel('时间/h');
xlim([1 24]);
ylabel('场景');
zlabel('风机出力/kW');
title('1000个场景下风电出力');

%% 光伏（原始数据）
figure(3);
for i = 1:times
    x = 1:24;
    y = i * ones(1,24);
    z = PV_data(:,i);
    plot3(x, y, z);
    hold on;
end
grid on;
xlabel('时间/h');
xlim([1 24]);
ylabel('场景');
zlabel('光伏出力/kW');
title('1000个场景下光伏出力');

%% 氢负荷需求量（原始数据）
figure(4);
for i = 1:times
    x = 1:24;
    y = i * ones(1,24);
    z = H_data(:,i);
    plot3(x, y, z);
    hold on;
end
grid on;
xlabel('时间/h');
xlim([1 24]);
ylabel('场景');
zlabel('氢气负荷需求量/kg');
title('1000个场景下氢气负荷需求量');

%% 风电（缩减后）
figure(5);
x = 1:24;

for s = 1:5
    y = s * ones(1,24);
    z = P_wind_pre(s, 1:24);
    plot3(x, y, z, 'LineWidth', 1.5);
    hold on;
end

grid on;
xlabel('时间/h');
xlim([1 24]);
ylabel('场景');
set(gca, 'ytick', 1:5);
zlabel('风机出力/kW');
legend('场景一','场景二','场景三','场景四','场景五');
title('缩减后5个场景下风电出力');

%% 光伏（缩减后）
figure(6);
x = 1:24;

for s = 1:5
    y = s * ones(1,24);
    z = P_wind_pre(s, 25:48);
    plot3(x, y, z, 'LineWidth', 1.5);
    hold on;
end

grid on;
xlabel('时间/h');
xlim([1 24]);
ylabel('场景');
set(gca, 'ytick', 1:5);
zlabel('光伏出力/kW');
legend('场景一','场景二','场景三','场景四','场景五');
title('缩减后5个场景下光伏出力');

%% 氢负荷需求量（缩减后）
figure(7);
x = 1:24;

for s = 1:5
    y = s * ones(1,24);
    z = P_wind_pre(s, 49:72);
    plot3(x, y, z, 'LineWidth', 1.5);
    hold on;
end

grid on;
xlabel('时间/h');
xlim([1 24]);
ylabel('场景');
set(gca, 'ytick', 1:5);
zlabel('氢负荷需求/kg');
legend('场景一','场景二','场景三','场景四','场景五');
title('缩减后5个场景下氢负荷需求');