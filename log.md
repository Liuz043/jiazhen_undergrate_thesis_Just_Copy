# 日志
用于记录遇到的问题，以及解决方案，方便自己后续进行回顾或者以后别人再遇到问题可以看看

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