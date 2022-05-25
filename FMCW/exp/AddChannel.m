clear
sf = 48000;
%!!!
B = 5000;
F = 15000;
T = 0.1*B/1000*2*sf;
Period = 14*T;
offset = 25/B*T;

periodPoints = 960;
gap = 0.2;
L = 0.7;

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
startX = 1;
leftAD = audioData(1,startX:startX+Period);
rightAD = audioData(1,startX+Period+T:startX+Period*2+T);
totalAD = audioData(1,startX+Period*2+T*3:startX+Period*3+T*3);

expAD = leftAD+circshift(rightAD,offset);
figure(3)
subplot(2,1,1)
plot(leftAD)
title('left')
subplot(2,1,2)
plot(rightAD)
title('right')
figure(4)
subplot(2,1,1)
plot(totalAD)
title('real')
subplot(2,1,2)
plot(expAD)
title('added')
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

figure(5)
subplot(2,1,1)
plot(expV)
title('generated')
subplot(2,1,2)
plot(realV)
title('real')
%% single t

