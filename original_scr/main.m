clear;
clc;
close all;

rng(20); % 设置随机数种子，确保结果可复现

run('julei.m');

run('windmodel.m');
run('ray.m');
run('h20model.m');

run('question1.m');
run('question2.m');

run('result.m');