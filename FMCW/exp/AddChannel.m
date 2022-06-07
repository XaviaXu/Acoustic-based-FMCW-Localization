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
L = 0.5;

%% read data
fileName = "0527\70-10-0.wav";

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
xq = 0:1/8:Period;
x = 0:Period;
leftQ = interp1(leftAD,xq,'spline');
rightQ = interp1(rightAD,xq,'spline');
figure(1)
plot(leftAD,'.')
hold on
plot(xq,leftQ,'color','r')
hold off

expAD = (leftQ+circshift(rightQ,offset*8));
expAD = expAD(1,2:8:length(expAD));
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

[b,a] = butter(5,200/(sf/2),'low');
expV = filter(b,a,expV);
realV = filter(b,a,realV);

figure(5)
subplot(2,1,1)
plot(expV)
for m=startX:T:Period
    xline(m)
end
title('generated')
subplot(2,1,2)
plot(realV)
for m=startX:T:Period
    xline(m)
end
title('real')
%% slice
figure(6)
subplot(2,1,1)
plot(realV)
for m=startX:T:Period
    xline(m)
end
[pksRaw,locsRaw] = findpeaks(-realV,'minpeakdistance',periodPoints*0.7);
pksRaw = -pksRaw;
locsFiltered = [];
pksFiltered = [];
for m=1:length(locsRaw)
   
    checkRange = [locsRaw(m)-periodPoints*0.2 locsRaw(m)+periodPoints*0.2];

    if checkRange(1)>0 && checkRange(2)<Period
        if pksRaw(m)<mean(realV(checkRange(1):checkRange(2)))
            locsFiltered = [locsFiltered locsRaw(m)];
            pksFiltered = [pksFiltered pksRaw(m)];
        end
    end
end
peakPointsR = [locsFiltered;pksFiltered];
hold on
plot(peakPointsR(1,:),peakPointsR(2,:),'*')
hold off
title('real')
subplot(2,1,2)
plot(expV)
for m=startX:T:Period
    xline(m)
end
[pksRaw,locsRaw] = findpeaks(-expV,'minpeakdistance',periodPoints*0.7);
pksRaw = -pksRaw;
locsFiltered = [];
pksFiltered = [];
for m=1:length(locsRaw)
    checkRange = [locsRaw(m)-periodPoints*0.2 locsRaw(m)+periodPoints*0.2];
    if checkRange(1)>0 && checkRange(2)<Period
        if pksRaw(m)<mean(realV(checkRange(1):checkRange(2)))
            locsFiltered = [locsFiltered locsRaw(m)];
            pksFiltered = [pksFiltered pksRaw(m)];
        end
    end
end
peakPointsE = [locsFiltered;pksFiltered];
hold on
plot(peakPointsE(1,:),peakPointsE(2,:),'*')
hold off
title('added')

%% check by T
pieceNum = length(startX:T:Period);
realG = [];
gaps = [];
border = 0.05;
borderPoints = T*border;
audioV = [realV(1,1:length(expV));expV];
peakPoints= peakPointsR;
for j = 1:2
    audioVolume = audioV(j,:);
    if j==2
        peakPoints = peakPointsE;
        realG = [realG gaps];
        gaps = [];
    end
    for m=1:pieceNum
    % for m=18
        xRange = [startX+(m-1)*T+1 startX+m*T];
        audioVolumeTemp = audioVolume(xRange(1):xRange(2));
        peaksTemp1 = peakPoints(:,peakPoints(1,:)>xRange(1)+borderPoints & peakPoints(1,:)<xRange(1)+T/2-borderPoints*4);
        peaksTemp2 = peakPoints(:,peakPoints(1,:)>xRange(1)+T/2+borderPoints*4 & peakPoints(1,:)<xRange(1)+T-borderPoints);
        figure(10)
        plot(audioVolumeTemp)
        hold on
        plot(peaksTemp1(1,:)-xRange(1),peaksTemp1(2,:),'*')
        plot(peaksTemp2(1,:)-xRange(1),peaksTemp2(2,:),'*')
        hold off
%         title(num2str(m))
        xlabel('sampling point')
        ylabel('sound strength(dB)')
        gapsTemp1 = diff(peaksTemp1(1,:));
        gapsTemp2 = diff(peaksTemp2(1,:));
        preMean1 = periodPoints;
        preMean2 = periodPoints;
        gapsfiltered1 = gapsTemp1(gapsTemp1>preMean1*0.9 & gapsTemp1<preMean1*1.1)
        gapsfiltered2 = gapsTemp2(gapsTemp2>preMean2*0.9 & gapsTemp2<preMean2*1.1)

%         gaps(:,m) = [mean(gapsfiltered1) mean(gapsfiltered2)]
        gaps = [gaps gapsfiltered1 gapsfiltered2];
        pause(0.1) 
    end

end
%%
figure(8)
plot(realG)
hold on 
plot(gaps)
hold off
legend('real','added')

size = [mean(realG) mean(gaps)];
res = zeros(1,2);
for i = 1:2

    delta = sf*T/(B*size(1,i)*2)-offset;
    disDiff = delta/sf*340.29;
    syms x
    eqn = sqrt((x+gap/2)^2+L^2)-sqrt((x-gap/2)^2+L^2)-disDiff;
    func = matlabFunction(eqn,'Vars',x);

    % options = optimset('Display','iter');
    x=fzero(func,0);
    res(1,i) = x;

end
size
res