clear,clc
    times=1000;%场景数
    parameter=load('parameters.txt');
    WT_c=parameter(:,1);%风电参数 24个不同时刻下的参数1
    WT_k=parameter(:,2);%风电参数 24个不同时刻下的参数2
    PV_a=parameter(:,3);%光伏功率24个不同时刻下的参数1
    PV_b=parameter(:,4);%光伏功率24个不同时刻下的参数2
    PH_a=parameter(:,5);%光伏功率24个不同时刻下的参数1
    PH_b=parameter(:,6);%光伏功率24个不同时刻下的参数2
    
    % P_car=P_car;
    % baseMVA = 100000;%SB 基准功率
    % Vmax=1.07;
    % Vmin=0.93
    
    for t=1:24
    % 光伏有功服从Beta分布
    Ppv_samp=zeros(1,times);  %time 是蒙特卡洛仿真的次数，也是场景数
    % Beta分布的两个形状参数
    % a_pv=0.6869; #式子2-6中的a
    % b_pv=2.1320;  #式子2-6中的B
    a_pv=PV_a(t); 
    b_pv=PV_b(t);  
     if a_pv>0
    % 光伏发电相关参数：组件总面积S_pv、光电转换率prey_pv、最大光强rmax(kW/m2)
    S_pv=10;%随意给出，自己调节
    prey_pv=0.14;%随意给出，自己调节
    rmax=700;%随意给出，自己调节
    % 光伏有功出力样本
    pv_samp(1,:)=betarnd(a_pv,b_pv,1,times);%生成形状为(1,times,)，参数为a_pv,b_pv的Beta分布
     Ppv_samp(1,:)=pv_samp(1,:)*rmax*S_pv*prey_pv;% 光伏功率=Beta分布*最大光强*组件总面积*光电转换率
     else
    Ppv_samp=zeros(1,times) ;
     end %对应的是if a_pv>0
     
    % 氢负荷需求服从Beta分布
    Ppv_samp2=zeros(1,times);  %time 是蒙特卡洛仿真的次数，也是场景数
    % Beta分布的两个形状参数
    % a_pv=0.6869; #式子2-6中的a
    % b_pv=2.1320;  #式子2-6中的B
    a_pv2=PH_a(t); 
    b_pv2=PH_b(t);  
     if a_pv2>1
    % 氢负荷需求相关参数
    S_pv2=8;%随意给出，自己调节
    prey_pv2=0.2;%随意给出，自己调节
    rmax2=60;%随意给出，自己调节
    % 氢负荷需求样本
    pv_samp2(1,:)=betarnd(a_pv2,b_pv2,1,1000);%生成形状为(1,times,)，参数为a_pv,b_pv的Beta分布
     Ppv_samp2(1,:)=pv_samp2(1,:)*rmax2*S_pv2*prey_pv2;% 氢负荷需求参照光伏出功公式
     else
    Ppv_samp2=betarnd(a_pv2,b_pv2,1,1000)*30 + a_pv2 * 150 ;
     end %对应的是if a_pv>0
     
       
     %%==风电%%%%%
     % weibull分布的两个形状参数
    % k_wt=1.637;
    % c_wt=5.218;
    % 风机发电相关参数：切入风速vci、切出风速vco、额定风速vN、额定功率PN_wt
    k_wt=WT_k(t);%风光参数 24个不同时刻下的参数1
    c_wt=WT_c(t);%风光参数 24个不同时刻下的参数2
    wt_samp =wblrnd(c_wt,k_wt,1,times);  % 风速 产生服从weibull分布的样本 ，形状为（(1,times,)
    PN_wt=1000;%随意给出，自己调节 ：额定功率
    vci=3 ;%随意给出，自己调节; 切入风速
    vN=13;%随意给出，自己调节  ： 额定风速
    vco=25 ;%随意给出，自己调节 切出风速
    for i=1:times  %得到风电出力样本
        if wt_samp(i)<vci %如果风速小于切入风速
            Pwt_samp(i)=0; %风机功率为0
        end %对应if wt_samp(i)<vci
         if wt_samp(i)>vci&&wt_samp(i)<vN %如果风速大于切入风速，同时小于额定风速
            Pwt_samp(i)=(wt_samp(i)-vci)/(vN-vci)*PN_wt;%式子2-4中的2 
            if   Pwt_samp(i)>PN_wt %如果风电功率大于额定功率
                 Pwt_samp(i)=PN_wt; %则风电功率等于额定功率
            end %对应 if   Pwt_samp(i)>PN_wt
         end%对应if wt_samp(i)>vci&&wt_samp(i)<vN 
         if wt_samp(i)>vN&&wt_samp(i)< vco %如果风速大于额定风速 同时小于切出风速
            Pwt_samp(i)=PN_wt;%风电功率等于额定功率
         end %对应 if wt_samp(i)>vN&&wt_samp(i)< vco
         if wt_samp(i)> vco %如果风速大于切出风速
            Pwt_samp(i)=0;%风电功率等于0
         end%对应 if wt_samp(i)> vco
    end%对应for i=1:times%得到风电出力样本
    for i=1:times
     Pwt_samp(i)= Pwt_samp(i) ; %存储每个场景下 ，t时刻 风电发功率
    end%对应 前二行的 for i=1:times
    
     PV_data(t,:)=  Ppv_samp;%存储t时刻 所有场景的光伏功率
     WT_data(t,:)=  Pwt_samp;%存储t时刻 所有场景的风电功率   
     H2_data(t,:)=  Ppv_samp2;%存储t时刻 所有场景的氢负荷需求
     
    end%对应的是for t=1:24
    
    %======================场景削减===========================%
    P_wind_pre=[WT_data' PV_data' H2_data']; %存储风电、光伏、氢负荷 数据
    %场景削减
    pi=1/1000*ones(1,1000);%概率
    number=5;%缩减至场景数
    N=1000;%蒙特卡洛数 场景数
    while (N~=number)% 如果数不等于场景数
    %计算每个样本的欧氏距离
    for i=1:N %遍历每一个场景
        l(i,i)=inf; %第i个场景 和第i个场景的距离为无穷大
        for j=1:N %遍历每一个场景
            if(i~=j)%如果两个场景编号不一样
                l(i,j)=0;%初始化两个场景距离为0
                for k=1:24
                    l(i,j)=l(i,j)+(P_wind_pre(i,k)-P_wind_pre(j,k))^2;%计算场景i与场景j的距离
                end %对应for k=1:24
                l(i,j)=sqrt(l(i,j));%距离开平方
            end%对应if(i~=j)%如果两个场景编号不一样
        end%对应 for j=1:N %遍历每一个场景
    end%对应 for i=1:N %遍历每一个场景
     
    %计算样本的相应值
    for i=1:N%遍历每一个场景
        [m(i),n(i)]=min(l(i,:));%m(i)为最小值的值，n(i)为最小值存在的索引号
        d(i)=pi(i)*m(i);
    end %对应  %计算样本的相应值 for i=1:N
     
    %找出样本最小的
    [s,I]=min(d);
    %更新
    pi(n(I))=pi(n(I))+pi(I);%场景概率
    P_wind_pre(I,:)=[];
    pi(I)=[];
    l(I,:)=[];
    l(:,I)=[];
    m(I)=[];
    n(I)=[];
    d(I)=[];
    N=N-1;
    end%对应while (N~=number)% 如果数不等于场景数
     
    %P_wind_pre %样本区间
    pi; %概率
    %plot(P_wind_pre(3,25:48)); 
    %% 作图--概率
    figure(1);
    plot(pi);
    xlabel('场景数');
    ylabel('概率');
    title('各场景下概率');
    
    %% 作图--风(原始数据)
    figure(2);
    for i=1:1000
    x=1:24;
    y=i*ones(1,24);
    z=WT_data(:,i);
    plot3(x,y,z);hold on;
    grid on
    xlabel('时间/h');
    xlim([1 24])
    ylabel('场景');
    zlabel('风机出力/kW');
    title('1000个场景下风电出力');
    end
    
    %% 作图--光(原始数据)
    figure(3);
    for i=1:1000
    x=1:24;
    y=i*ones(1,24);
    z=PV_data(:,i);
    plot3(x,y,z);hold on;
    grid on
    xlabel('时间/h');
    xlim([1 24])
    ylabel('场景');
    zlabel('光伏出力/kW');
    title('1000个场景下光伏出力');
    end
    
     %% 作图--氢(原始数据)
    figure(4);
    for i=1:1000
    x=1:24;
    y=i*ones(1,24);
    z=H2_data(:,i);
    plot3(x,y,z);hold on;
    grid on
    xlabel('时间/h');
    xlim([1 24])
    ylabel('场景');
    zlabel('氢气负荷需求量/kg');
    title('1000个场景下氢气负荷需求量');
    end
    
    %% 作图--风(缩减后)
    figure(5);
    x=1:24;
    y1=ones(1,24);
    y2=2*ones(1,24);
    y3=3*ones(1,24);
    y4=4*ones(1,24);
    y5=5*ones(1,24);
    z1=P_wind_pre(1,1:24);
    z2=P_wind_pre(2,1:24);
    z3=P_wind_pre(3,1:24);
    z4=P_wind_pre(4,1:24);
    z5=P_wind_pre(5,1:24);
    plot3(x,y1,z1);hold on;
    plot3(x,y2,z2);hold on;
    plot3(x,y3,z3);hold on;
    plot3(x,y4,z4);hold on;
    plot3(x,y5,z5);hold on;
    grid on
    xlabel('时间/h');
    xlim([1 24])
    ylabel('场景');
    set(gca,'ytick',[1,2,3,4,5]);
    zlabel('风机出力/kW');
    legend('场景一','场景二','场景三','场景四','场景五');
    title('缩减后5个场景下风电出力');
    %% 作图--光(缩减后)
    figure(6);
    x=1:24;
    y1=ones(1,24);
    y2=2*ones(1,24);
    y3=3*ones(1,24);
    y4=4*ones(1,24);
    y5=5*ones(1,24);
    z1=P_wind_pre(1,25:48);
    z2=P_wind_pre(2,25:48);
    z3=P_wind_pre(3,25:48);
    z4=P_wind_pre(4,25:48);
    z5=P_wind_pre(5,25:48);
    plot3(x,y1,z1);hold on;
    plot3(x,y2,z2);hold on;
    plot3(x,y3,z3);hold on;
    plot3(x,y4,z4);hold on;
    plot3(x,y5,z5);hold on;
    grid on
    xlabel('时间/h');
    xlim([1 24])
    ylabel('场景');
    set(gca,'ytick',[1,2,3,4,5]);
    zlabel('光伏出力/kW');
    legend('场景一','场景二','场景三','场景四','场景五')
    title('缩减后5个场景下光伏出力');
       %% 作图--氢(缩减后)
    figure(7);
    x=1:24;
    y1=ones(1,24);
    y2=2*ones(1,24);
    y3=3*ones(1,24);
    y4=4*ones(1,24);
    y5=5*ones(1,24);
    z1=P_wind_pre(1,49:72);
    z2=P_wind_pre(2,49:72);
    z3=P_wind_pre(3,49:72);
    z4=P_wind_pre(4,49:72);
    z5=P_wind_pre(5,49:72);
    plot3(x,y1,z1);hold on;
    plot3(x,y2,z2);hold on;
    plot3(x,y3,z3);hold on;
    plot3(x,y4,z4);hold on;
    plot3(x,y5,z5);hold on;
    grid on
    xlabel('时间/h');
    xlim([1 24])
    ylabel('场景');
    set(gca,'ytick',[1,2,3,4,5]);
    zlabel('氢负荷需求/kg');
    legend('场景一','场景二','场景三','场景四','场景五')
    title('缩减后5个场景下氢负荷需求');