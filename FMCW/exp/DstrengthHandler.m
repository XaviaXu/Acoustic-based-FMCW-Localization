clear
sf = 48000;
%!!!
B = 5000;
F = 15000;
T = 0.1*B/1000*2*sf;
Period = 15*T;
offset = 25/B*T;

periodPoints = 960;
gap = 0.1;
L = 0.3;

%% read data
fileName = "70-0-0.wav";

fileId = fopen(fileName,'r');
audioDataRaw = fread(fileId,inf,'int16')';
audioDataRawTotalTime = length(audioDataRaw)/sf;
fclose(fileId);
figure(1)
plot(audioDataRaw)

timeOffset = 0;
totalTime = floor(audioDataRawTotalTime - timeOffset - 1);
totalPoints = totalTime*sf;
timeOffsetPoint = timeOffset*sf;

audioData = audioDataRaw;


%% audio volume
windowSizePoint = 6;
audioVolume = zeros(1,totalPoints);
for m = 6: totalPoints
    audioVolume(1,m) = 10*log(sum(audioData(1,m-5:m).^2)/windowSizePoint)/log(10);
end
figure(2)
plot(audioVolume)


%%

s = find(audioData>2000);
startX = s(1);
leftAD = audioData(1,startX:startX+Period);
rightAD = audioData(1,startX+Period+T:startX+Period*2+T);
totalAD = audioData(1,startX+Period*2+T*2:length(audioData));
expAD = leftAD+rightAD;
%% single channel strength
leftV = zeros(1,length(leftAD));
for m = 6: length(leftAD)
    leftV(1,m) = 10*log(sum(leftAD(1,m-5:m).^2)/windowSizePoint)/log(10);
end
rightV = zeros(1,length(rightAD));
for m = 6: length(rightAD)
    rightV(1,m) = 10*log(sum(rightAD(1,m-5:m).^2)/windowSizePoint)/log(10);
end
figure(6)
subplot(2,1,1)
plot(leftV)
% axis([1,T*7,10,80])
title('left')
subplot(2,1,2)
plot(rightV)
% axis([1,T*7,10,80])
title('right')

figure(7)
subplot(1,2,1)
plot(leftV(1,T*5+1:T*6))
% axis([1,T,10,80])
title('left')
subplot(1,2,2)
plot(rightV(1,T*5+1:T*6))
% axis([1,T,10,80])
title('right')

%% sound strength
expV = zeros(1,length(expAD));
for m = 6: length(expAD)
    expV(1,m) = 10*log(sum(expAD(1,m-5:m).^2)/windowSizePoint)/log(10);
end

realV = zeros(1,length(totalAD));
for m = 6: length(totalAD)
    realV(1,m) = 10*log(sum(totalAD(1,m-5:m).^2)/windowSizePoint)/log(10);
end
figure(3)
plot(realV)
figure(4)
subplot(2,1,1)
plot(expV)
% axis([1,T*7,10,80])
title('generated')
subplot(2,1,2)
plot(realV)
% axis([1,T*7,10,80])
title('real')
%% single t
expVS = expV(1,T*5+1:T*6);
realVS = realV(1,T*5+1:T*6);
f = F:2*B/T:(F+B);
figure(5)
% subplot(1,2,1)
% 
% plot(f,expVS(1,1:T/2+1))
% hold on
% plot(f,fliplr(expVS(1,T/2:T)))
% hold off
% axis([F,F+B,30,80])
% title('generated')
% 
% subplot(1,2,2)
plot(f,realVS(1,1:T/2+1))
hold on
plot(f,fliplr(realVS(1,T/2:T)))
hold off
% axis([F,F+B,30,80])
title('real')