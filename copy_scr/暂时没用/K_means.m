clear;
%% 概率密度函数与累积分布函数求解
x=xlsread('guang');
x=sort(x);
y=xlsread('风机');
y=sort(y);
n=743;
m=743;
minx = min(x);
maxx = max(x);
dx = (maxx-minx)/743;
x1 = minx:dx:maxx-dx;
miny = min(y);
maxy = max(y);
dy = (maxy-miny)/743;
y1 = miny:dy:maxy-dy;
h=0.5;
f=zeros(1,n);%概率密度
for j = 1:n
    p(1)=0;
    for i=1:n
        f(j)=f(j)+exp(-(x1(j)-x(i))^2/2/h^2)/sqrt(2*pi);
    end
    f(j)=f(j)/n/h;
end 
[b xx]=hist(x,743);
num=numel(x);
%plot(x,b/num);
hold on
c=cumsum(b/num);        %累积分布
%plot(x,c);
h=0.5;
fw=zeros(1,m);%概率密度
for j = 1:m
    pw(1)=0;
    for i=1:m
        fw(j)=fw(j)+exp(-(y1(j)-y(i))^2/2/h^2)/sqrt(2*pi);
    end 
end 
[d yy]=hist(y,743);
num1=numel(y);
%plot(y,d/num1);
hold on
e=cumsum(d/num1);        %累积分布
%plot(y,e);
%% kendall秩相关系数
r3= corr(x, y, 'type' , 'kendall')
%% 已知概率密度函数生成蒙特卡洛抽样
N=10000; %需要随机数的个数
a=zeros(N,1); %存放随机数的数列
% Frank Copula
deta=log(1+(2/(2-r3)));
c=c';
X=[ones(length(x),1),c,c.^2,c.^3,c.^4];
b=regress(x,X);
x1=linspace(0,1,743);
y1=b(1)+b(2)*x1+b(3)*x1.^2+b(4)*x1.^3+b(5)*x1.^4;
e=e';
Y=[ones(length(y),1),e,e.^2,e.^3,e.^4];
B=regress(y,Y);
yy1=linspace(0,1,743);
Y1=B(1)+B(2)*yy1+B(3)*yy1.^2+B(4)*yy1.^3+B(5)*yy1.^4;
u=rand(10032,1);
 CC=[zeros(5,1);rand(14,1);zeros(5,1)]; 
 C=[zeros(5,1);rand(14,1);zeros(5,1)]; 
 for iii=1:417
  C=[C;CC];
 end
v=log(1+((exp(-deta.*C)-1)./((exp(-deta.*u)-1)./(exp(-deta)-1)))./-deta);
PI=b(1)+b(2)*u+b(3)*u.^2+b(4)*u.^3+b(5)*u.^4;
PI=abs(PI);
PI=PI/(1.25*max(PI));
PW=B(1)+B(2)*v+B(3)*v.^2+B(4)*v.^3+B(5)*v.^4;
PW=abs(PW);
PW=PW(1:8760,:);
PW=PW';
for i=1:8760
   if PW(i)>1000
       PW(i)=850-randperm(500,1);
   end
end
pIa=PI';
PWb=zeros(365,24);%这个相当于你申请一个空间，即m*n的数组
for i=1:365%m行
for j=1:24%n列
PWb(i,:)=PW((1:24)+(i-1)*24);%取每n个数作为一行存入b数组
end
end
PIb=zeros(365,24);%这个相当于申请一个空间，即m*n的数组
for pi=1:365%m行
for pj=1:24%n列
PIb(pi,:)=pIa((1:24)+(pi-1)*24);%取每n个数作为一行存入b数组
end
end
PI0=[zeros(365,5),PIb(:,6:19),zeros(365,5)];
PI=PI0';
PI=PI(:);
subplot(211);
plot(PI);
axis([0 8760 0 1]);
set(gcf,'unit','centimeters','position',[1,2,35,20]);
xlabel('时间/h');
ylabel('光伏出力/p.u.'); 
subplot(212);
plot((PW/max(PW)));
axis([0 8760 0 1]);
set(gcf,'unit','centimeters','position',[1,2,35,10]);
xlabel('时间/h');
ylabel('风机出力/p.u.');
set(gca,'FontSize',20);%scatter(PI/max(PI),PW/max(PW))
%% 场景聚类筛减
figure;
clustW = kmeans(PWb,4);
[siw,hiw]=silhouette(PWb,clustW);
title('基于K-means聚类方法的场景缩减');
[IDW,CW,sumdw,DW] = kmeans(PWb,4);
clustw1=find(clustW==1);
clustw1=PWb(clustw1,:);
numw1=length(clustw1(:,1));
clustw2=find(clustW==2);
clustw2=PWb(clustw2,:);
numw2=length(clustw2(:,1));
clustw3=find(clustW==3);
clustw3=PWb(clustw3,:);
numw3=length(clustw3(:,1));
clustw4=find(clustW==4);
clustw4=PWb(clustw4,:);
numw4=length(clustw4(:,1));
pw1=numw1/417;pw2=numw2/417;
pw3=numw3/417;pw4=numw4/417;
pww=[pw1,pw2,pw3,pw4];
figure;
clustI = kmeans(PI0,4);
[si,hi]=silhouette(PI0,clustI,'Euclidean');
[IDX,CI,sumd,DI] = kmeans(PI0,4);
clusti1=find(clustI==1);
clusti1=PI0(clusti1,:);
numi1=length(clusti1);
clusti2=find(clustI==2);
clusti2=PI0(clusti2,:);
numi2=length(clusti2);
clusti3=find(clustI==3);
clusti3=PI0(clusti3,:);
numi3=length(clusti3);
clusti4=find(clustI==4);
clusti4=PI0(clusti4,:);
numi4=length(clusti4);
pi1=numi1/417;pi2=numi2/417;
pi3=numi3/417;pi4=numi4/417;
pii=[pi1,pi2,pi3,pi4];
lop=1:4;
ppp=[pww',pii'];
subplot(311)
plot(CI(1,:),'-','LineWidth',2);
hold on
plot(CI(2,:),'--','LineWidth',2);plot(CI(3,:),':','LineWidth',2);plot(CI(4,:),':.','LineWidth',2);
legend(['典型场景1:',num2str(ppp(1,1))],['典型场景2:',num2str(ppp(2,1))],['典型场景3:',num2str(ppp(3,1))],['典型场景4:',num2str(ppp(4,1))]);
xlabel('时间/h');ylabel('功率/KW');
title('场景聚类筛减后光伏出力')
axis([1 24 0 1])
subplot(312)
plot(CW(1,:),'-','LineWidth',2);
hold on
plot(CW(2,:),'--','LineWidth',2);plot(CW(3,:),':','LineWidth',2);plot(CW(4,:),':.','LineWidth',2);
legend(['典型场景1:',num2str(ppp(1,2))],['典型场景2:',num2str(ppp(2,2))],['典型场景3:',num2str(ppp(3,2))],['典型场景4:',num2str(ppp(4,2))]);
xlabel('时间/h');ylabel('功率/KW');
title('场景聚类筛减后风机出力')
axis([1 24 0 1000])
subplot(313)
bar(ppp(:,1));
bar(lop,ppp);
legend('风电各场景概率');
title('聚类后各场景概率')
xlabel('场景');

