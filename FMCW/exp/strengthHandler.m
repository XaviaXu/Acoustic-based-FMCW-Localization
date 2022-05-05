clear
sf = 48000;
%!!!
B = 5000;
F = 17000;
T = 0.1*B/1000*2*sf;
Period = 7*T;
offset = 25/B*T;

periodPoints = 960;
gap = 0.1;
L = 0.3;


%% read data
fileName = "M18-20-20-1.pcm";

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

audioData = audioDataRaw(1,timeOffsetPoint + (1:totalPoints));


%% audio volume
windowSizePoint = 6;
audioVolume = zeros(1,totalPoints);
for m = 6: totalPoints
    audioVolume(1,m) = 10*log(sum(audioData(1,m-5:m).^2)/windowSizePoint)/log(10);
end
figure(2)
plot(audioVolume)

%%
% 17-22 +20 232953 -20 227165
% 18-20 -20 80682
maxS = max(audioData)
startX = find(max());
leftAD = audioData(1,startX:startX+Period);
rightAD = audioData(1,startX+Period+T:startX+Period*2+T);
totalAD = audioData(1,startX+Period*2+T*2:length(audioData));
expAD = leftAD+circshift(rightAD,offset);
figure(3)
subplot(2,1,1)
title('generated')
plot(expAD)
subplot(2,1,2)
title('real')
plot(totalAD)

%% sound strength
expV = zeros(1,length(expAD));
for m = 6: length(expAD)
    expV(1,m) = 10*log(sum(expAD(1,m-5:m).^2)/windowSizePoint)/log(10);
end

realV = zeros(1,length(totalAD));
for m = 6: length(totalAD)
    realV(1,m) = 10*log(sum(totalAD(1,m-5:m).^2)/windowSizePoint)/log(10);
end
figure(4)
subplot(2,1,1)
title('generated')
plot(expV)
subplot(2,1,2)
title('real')
plot(realV)