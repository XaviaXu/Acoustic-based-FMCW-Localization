clear
sf = 48000;
gap = 0.10;
L = 0.20;
halfT = 0.5;%s
standardFreq = 100; %f
B = 2000;
offsetPart = 0.005;
standardPeriod = sf/(B*offsetPart*2);
offsetPoints = sf*halfT*offsetPart*2;

%% read data from file
% file = "0311-L10/30-10-2.pcm";
file = "30-1820-0-0.pcm";
fileId = fopen(file,'r');
audioDataRaw = fread(fileId,inf,'int16')';
audioDataRawTotalTime = length(audioDataRaw)/sf;
fclose(fileId);
figure(1)
plot(audioDataRaw)

%% remove offset
% [b,a] = butter(5,18000/(sf/2),'high');
% audioDataRaw = filter(b,a,audioDataRaw);

timeOffset = 0; %s
totalTime = ceil(audioDataRawTotalTime - timeOffset);
totalPoint = length(audioDataRaw)
timeOffsetPoint = timeOffset*sf;

audioData = audioDataRaw;
figure(2)
plot(audioData)
xlabel('sampling points')
ylabel('sound pressure')


%% calc sound strength
windowSizePoint = 6;
audioVolume = zeros(1,totalPoint);
for n = 6: totalPoint
    audioVolume(1,n) = 10*log(sum(audioData(1,n-5:n).^2)/windowSizePoint)/log(10);
end



%% filter
% audioVolume = lowpass(audioVolume,150,sf);
[pksRaw,locsRaw] = findpeaks(-audioVolume,'minpeakdistance',standardPeriod*0.7);
pksRaw = -pksRaw;

figure(4)
plot(audioVolume)
hold on
plot(locsRaw,pksRaw,'.')
hold off
audioV = audioVolume;



%% extract
audioStrPro = [];
avgPeak = mean(pksRaw);

i = 1;
cnt = 0;
while i < length(locsRaw)
    win = audioV(1,locsRaw(i):locsRaw(i+1));
    [pks,locs] = findpeaks(-win,'minpeakdistance',standardPeriod*0.15);
    if(length(pks)>2)
    elseif(length(win)>standardPeriod*0.86 && length(win)<standardPeriod*1.15 && max(win)>10+min(win)&&min(win)>47)
        audioStrPro = [audioStrPro win];
        cnt = cnt + 1;
    end
    i = i+1;
end

[pksRaw,locsRaw] = findpeaks(-audioStrPro,'minpeakdistance',standardPeriod*0.7);
pksRaw = -pksRaw;

figure(8)
subplot(2,1,1);
title('sound strength')
plot(audioVolume)
xlabel('sampling points')

subplot(2,1,2);
title('sound strength after processing')
plot(audioStrPro)
xlabel('sampling points')

temp = diff(locsRaw);
figure(11)
plot(temp)

%% solve equation
size = sum(temp,'all')/length(temp);

delta = sf*sf*halfT/(B*size)-offsetPoints;
disDiff = delta/sf*340.29;
syms x
eqn = sqrt((x+gap/2)^2+L^2)-sqrt((x-gap/2)^2+L^2)-disDiff;
func = matlabFunction(eqn,'Vars',x);

% options = optimset('Display','iter');
x=fzero(func,0);

size 
x

