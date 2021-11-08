clear
d = 0.5;
B = 5000;
%%
y = 0.3:0.1:0.6;
theta = -60:1:60;
x = y' * tand(theta);
[X,Y] = meshgrid(x,y);
L = sqrt((X+d/2).^2+Y.^2);
R = sqrt((X-d/2).^2+Y.^2);
Z = abs(L-R)/340*B;
mesh(X,Y,Z)
figure(1)
surf(X,Y,Z)
%%

y = 0.3;
theta = -60:1:60;
x = y.*tand(theta);
l = sqrt((x+d/2).^2+y^2);
r = sqrt((x-d/2).^2+y^2);
z = abs(l-r)/340*B;



y = 0.6;
theta = -60:1:60;
x = y.*tand(theta);
l = sqrt((x+d/2).^2+y^2);
r = sqrt((x-d/2).^2+y^2);
z2 = abs(l-r)/340*B;

figure(1)
subplot(2,1,1)
plot(theta,z)
title('y = 0.3m')
ylabel('BΔt')
subplot(2,1,2)
plot(theta,z2)
title('y = 0.6m')
xlabel('angle')
ylabel('BΔt')