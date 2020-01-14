filename = 'points.txt';
[x,y,i] = textread(filename,'%n%n%n','delimiter',',');
%% 计算固定采集数据的二维平均空间偏移距离
A = 1;
B = -1;
C = 0;
for loop = 1:length(x)
    d(loop) = abs(A*x(loop)+B*y(loop)+C)/sqrt(A^2+B^2);
end
dis = mean(d);
pres = dis/sqrt(2);

% % 画出加入小扰动后的点图
u = normrnd(0,0.005,320,1);
axis([0 1 0 1 -0.025 0.025]);
xlabel('x');
ylabel('y');
zlabel('z');
box on
hold on
scatter3(x,y,u,'.','r');
hold on
u = normrnd(0,0.01,320,1);
scatter3(x,y,u,'.','b');
hold on
plot3([0 1],[0 1],[0 0],'g');
legend('\sigma=0.005','\sigma=0.01');

%% 计算不同sigma的小扰动加入后，与二维情况下的对比
% Q1 = [0 0 0];Q2 = [1 1 0];
% for count = 1:2
%     j = 1;
%     for i = 0.01:-0.0001:0
%         u = normrnd(0,i,320,1);
%         for loop = 1:length(x)
%             P = [x(loop) y(loop) u(loop)];
%             d3(loop) = norm(cross(Q2-Q1,P-Q1))/norm(Q2-Q1);
%         end
%         dis3(count,j) = mean(d3);
%         j = j+1;
%     end
% end
% axis([0 100 0.012 0.019]);
% line([0 100],[dis dis],'color','r');
% hold on
% plot(dis3(1,:),'color','b');
% hold on
% plot(dis3(2,:),'color','g');
% hold on
%  legend('二维','三维1','三维2');
% xlabel('\sigma');
% ylabel('空间偏移距离');
