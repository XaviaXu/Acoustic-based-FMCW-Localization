clear
%% THREE
L = 0.1;
y = 0.3:0.01:0.4;
F = 100;
Fmax = 23000;
T = 0.02;
B = Fmax-F;
sf = 48000*10;
% [X,Y] = meshgrid(geChirp,y);
% L = sqrt((X+L/2).^2 + Y.^2)/340;
% R = sqrt((X-L/2).^2 + Y.^2)/340;
% U = L+R;
% V = L-R;
% Z = cos(F*V+B/T*U.*V);
% mesh(X,Y,Z)
% figure
% surf(X,Y,Z)

% %% TWO
% y = 0.3;
% 
% L = sqrt((x+L/2).^2 + y^2)/340;
% R = sqrt((x-L/2).^2 + y^2)/340;
% U = L+R;
% V = Lplot(x,Z)

%% formula

N = T * sf;
n = 0:N-1;
% t = n/ sf;
t = 1/sf:1/sf:T;
K = B/T;
geChirp = cos(2*pi.*(F.*t+K/2.*t.^2));
figure(1)
plot(t,geChirp)

y = 0.5;
x = -0.7;
l = sqrt((x+L/2)^2 + y^2)+0.3;
r = sqrt((x-L/2)^2 + y^2);

deltaT = abs(l-r)/340;

cross = cos(2*pi.*(F.*t+K/2.*t.^2))+cos(2*pi.*(F.*(t+deltaT)+K/2.*(t+deltaT).^2));
expect = 2*cos(pi*(F*deltaT+K/2.*(2*deltaT.*t+deltaT^2)));
low = 2*cos(pi.*(F*(deltaT+2.*t)+K/2.*(2*t.^2+2*deltaT.*t+deltaT^2)));

i = 1;
while true
    if t(i)+deltaT>T
        break; 
    end
    i = i+1;
end

cross = cross(1:i);
expect = expect(1:i);
low = low(1:i);
t = t(1:i);
figure(2)
subplot(3,1,1)
plot(t,cross)

subplot(3,1,2)
plot(t,expect)
xlabel('low frequency')
subplot(3,1,3)
plot(t,low)
xlabel('high frequency')

figure(3)
plot(t,abs(expect))
xlabel('t/seconds')
ylabel('sound pressure')