P_data = [WT_data' PV_data' H_data'];

pi = 1/1000 * ones(1,1000);%每个场景的概率平均分
number = 5;%目标缩减场景数
N = 1000;%蒙特卡洛数 场景数
    %% 求出距离第i个场景最近的场景
while (N ~= number)
    for i = 1:N
        l(i,i) = inf;%自己和自己的距离无限大，可以保证自己不会被选中
        for j = 1:N
            if (i ~= j)
                l(i,j) = 0;%初始化两个场景距离为0
                for k = 1:24
                    l(i,j) = l(i,j) + (P_data(i,k) - P_data(j,k))^2;
                end
                l(i,j) = sqrt(l(i,j));
            end
        end
    end


    for i = 1:N
        [m(i), n(i)] = min(l(i,:));
        d(i) = pi(i) * m(i);
    end

    %% 删除距离最小的场景
     [~,I] = min(d);
     pi(n(I)) = pi(n(I)) + pi(I);
     P_data(I,:) = [];
     pi(I) = [];
     l(I,:) = [];
     l(:,I) = [];
     m(I) = [];
     n(I) = [];
     d(I) = [];
     N = N - 1;
end