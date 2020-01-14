title('费茨定律线性拟合');
xlabel('ID');
ylabel('平均耗时');
box on
hold on
scatter(ans,time,'b')
hold on
line([3.5,6.5],[651.13,1159.63],'color','r');
legend('平均耗时','线性拟合');