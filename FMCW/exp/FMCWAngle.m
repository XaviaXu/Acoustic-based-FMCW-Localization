clear

sf = 48000;
T = 1;
TPoints = T*sf;
freqDiff = 50;
B = 5000;
periodMiddle = sf/freqDiff;
periodPoints = 960;
gap = 0.1;
L = 0.3;

offsetPart = 0.005;
offsetPoints = sf*T*offsetPart;

%% read data
% fileName = "0408/2-7+20-1.pcm";
fileName = "+20-510-0.pcm";
fileId = fopen(fileName,'r');
audioDataRaw = fread(fileId,inf,'int16')';
audioDataRawTotalTime = length(audioDataRaw)/sf;
fclose(fileId);
figure(1)
plot(audioDataRaw)

timeOffset = 1;
totalTime = floor(audioDataRawTotalTime - timeOffset - 1);
totalPoints = totalTime*sf;
timeOffsetPoint = timeOffset*sf;

audioData = audioDataRaw(1,timeOffsetPoint + (1:totalPoints));
figure(2)
plot(audioData)

%% audio volume
windowSizePoint = 6;
audioVolume = zeros(1,totalPoints);
for m = 6: totalPoints
    audioVolume(1,m) = 10*log(sum(audioData(1,m-5:m).^2)/windowSizePoint)/log(10);
end
figure(3)
plot(audioVolume)

[startY,startX] = max(audioVolume(1:TPoints));
hold on
plot(startX,startY,'*')
hold off
for m=startX:TPoints:totalPoints
    xline(m)
end

[b,a] = butter(5,200/(sf/2),'low');
audioVolume = filter(b,a,audioVolume);
figure(4)
plot(audioVolume)
% xlim([2e4 4e4])
for m=startX:TPoints:totalPoints
    xline(m)
end
[pksRaw,locsRaw] = findpeaks(-audioVolume);
pksRaw = -pksRaw;
locsFiltered = [];
pksFiltered = [];
for m=1:length(locsRaw)
    checkRange = [locsRaw(m)-periodPoints*0.2 locsRaw(m)+periodPoints*0.2];
    if checkRange(1)>0 && checkRange(2)<totalPoints
        if pksRaw(m)<mean(audioVolume(checkRange(1):checkRange(2)))
            locsFiltered = [locsFiltered locsRaw(m)];
            pksFiltered = [pksFiltered pksRaw(m)];
        end
    end
end
peakPoints = [locsFiltered;pksFiltered];
hold on
plot(peakPoints(1,:),peakPoints(2,:),'*')
hold off

pieceNum = length(startX:TPoints:totalPoints-TPoints);
gaps = zeros(2,pieceNum);
border = 0.05;
borderPoints = TPoints*border;

for m=1:pieceNum
% for m=18
    xRange = [startX+(m-1)*TPoints+1 startX+m*TPoints];
    audioVolumeTemp = audioVolume(xRange(1):xRange(2));
    peaksTemp1 = peakPoints(:,peakPoints(1,:)>xRange(1)+borderPoints & peakPoints(1,:)<xRange(1)+TPoints/2-borderPoints*4);
    peaksTemp2 = peakPoints(:,peakPoints(1,:)>xRange(1)+TPoints/2+borderPoints*4 & peakPoints(1,:)<xRange(1)+TPoints-borderPoints);
    figure(5)
    plot(audioVolumeTemp)
    hold on
    plot(peaksTemp1(1,:)-xRange(1),peaksTemp1(2,:),'*')
    plot(peaksTemp2(1,:)-xRange(1),peaksTemp2(2,:),'*')
    hold off
    title(num2str(m))
    gapsTemp1 = diff(peaksTemp1(1,:));
    gapsTemp2 = diff(peaksTemp2(1,:));
    preMean1 = periodPoints;
    preMean2 = periodPoints;
    gapsfiltered1 = gapsTemp1(gapsTemp1>preMean1*0.9 & gapsTemp1<preMean1*1.1)
    gapsfiltered2 = gapsTemp2(gapsTemp2>preMean2*0.9 & gapsTemp2<preMean2*1.1)
    
    gaps(:,m) = [mean(gapsfiltered1) mean(gapsfiltered2)]
    pause(0.1)
end


%%

figure(6)
plot(gaps(1,:))
hold on
plot(gaps(2,:))
hold off
size = mean(mean(gaps));
diff = abs(mean(gaps(1,:))-mean(gaps(2,:)))

delta = sf*sf*T/(B*size*2)-offsetPoints;
disDiff = delta/sf*340.29;
syms x
eqn = sqrt((x+gap/2)^2+L^2)-sqrt((x-gap/2)^2+L^2)-disDiff;
func = matlabFunction(eqn,'Vars',x);

% options = optimset('Display','iter');
x=fzero(func,0);

size 
x




