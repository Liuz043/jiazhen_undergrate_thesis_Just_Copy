# 日志
用于记录遇到的问题，以及解决方案，方便自己后续进行回顾或者以后别人再遇到问题可以看看

## 文件夹当前架构
### 4.26
在copy_scr文件夹里面新建了initialization.m和scene_reduction.m和init_plot.m三个文件，作用分别是生成随机风光氢场景、缩减场景以及调用函数并且画图

## 4.26遇到问题以及解决方案
1. 首先就是尝试同步到git和github，结果发现代理配置不对，先使用了以下命令得到当前端口，发现还是之前使用的，于是准备进行修改。
    ~~~
    git config --global --get http.proxy                
    git config --global --get https.proxy
    ~~~
    使用以下命令进行修改配置端口
    ~~~
    git config --global http.proxy http://127.0.0.1:7897
    git config --global https.proxy https://127.0.0.1:7897
    ~~~
    但是还是存在报错，后来查看了配置的详细页
    ~~~
    git config --show-origin --get-regexp proxy
    ~~~
    发现之前单独对于GitHub建立了一个配置，删去即可
2. 师兄的命名有点乱，特别是到氢负荷那一块，感觉是后来再添加的部分，进行了一下修改
    ~~~
    P_data --- P_wind_pre
    H_data --- H2_data
    a_h = a_pv2
    %% 类似这种，主要出现在氢负荷部分
    ~~~