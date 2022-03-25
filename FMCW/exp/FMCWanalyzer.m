clear
sf = 48000;
gap = 0.10;
L = 0.25;
halfT = 0.5;%s
standardFreq = 100; %f
B = 5000;
offsetPart = 0.005;
standardPeriod = sf/(B*offsetPart*2);
offsetPoints = sf*halfT*offsetPart*2;

%% read data from file
% file = "0311-L10/30-10-2.pcm";
file = "25-20-1.pcm";
fileId = fopen(file,'r');
audioDataRaw = fread(fileId,inf,'int16')';
audioDataRawTotalTime = length(audioDataRaw)/sf;
fclose(fileId);
figure(1)
plot(audioDataRaw)

%% remove offset
% [b,a] = butter(5,18000/(sf/2),'high');
% audioDataRaw = filter(b,a,audioDataRaw);

timeOffset = 5; %s
totalTime = ceil(audioDataRawTotalTime - timeOffset - 5);
totalPoint = totalTime*sf;
timeOffsetPoint = timeOffset*sf;

audioData = audioDataRaw(1,timeOffsetPoint + (1:totalPoint));
figure(2)
plot(audioData)


%% calc sound strength
windowSizePoint = 6;
audioVolume = zeros(1,totalPoint);
for n = 6: totalPoint
    audioVolume(1,n) = 10*log(sum(audioData(1,n-5:n).^2)/windowSizePoint)/log(10);
end



%% filter
audioVolume = lowpass(audioVolume,150,sf);
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
    elseif(length(win)>standardPeriod*0.85 && length(win)<standardPeriod*1.15 && max(win)>10+min(win)&&min(win)>47)
        audioStrPro = [audioStrPro win];
        cnt = cnt + 1;
    end
    i = i+1;
end

[pksRaw,locsRaw] = findpeaks(-audioStrPro,'minpeakdistance',standardPeriod*0.7);
pksRaw = -pksRaw;

figure(8)
subplot(2,1,1);
plot(audioVolume)
subplot(2,1,2);
plot(audioStrPro)

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

