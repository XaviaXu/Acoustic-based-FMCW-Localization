clear
sf = 48000;
gap = 0.1;
halfT = 0.5;%s
standardFreq = 100; %f
F = 10000;
B = 5000;
T = 0.5;
offsetPart = 0.005;
standardPeriod = sf/(B*offsetPart*2);
%% distance diff
yDis = 0.3;
%0.04 -0.13
xDis = 0.1;
leftDis = sqrt((xDis+gap/2)^2+yDis^2);
rightDis = sqrt((xDis-gap/2)^2+yDis^2);
dotDiff = (leftDis-rightDis)/340.29 * sf;

%% generate
N = T * sf;
t = 1/sf:1/sf:T;
K = B/T;
chirp = cos(2*pi.*(F.*t+K/2.*t.^2))*5000.*(1-t*1.8);
expected = [];
result = [];
X = [];
for xDis=-0.3:0.1:0.3

    X=[X xDis];
    leftDis = sqrt((xDis+gap/2)^2+yDis^2);
    rightDis = sqrt((xDis-gap/2)^2+yDis^2);
    dotDiff = (leftDis-rightDis)/340.29 * sf;

zig = [chirp flip(chirp)];
figure(1)
plot(zig)
audio = [];
for i = 1:10
    audio = [audio zig];
end
for i = 1:10
    audio = [audio zig];
end
for i = 1:10
    audio = [audio zig];
end
offsetPoint = round(N * offsetPart*2+dotDiff);
real = sf*sf/(2*offsetPoint*B);
totalPoint = length(audio) - offsetPoint;
audioData1 = audio(1,1:totalPoint);

audioData2 = audio(1,1+offsetPoint:totalPoint+offsetPoint);
%2/0.6 +0.08
%1/0.6 -0.13
audioData = audioData1+0.6*audioData2;
figure(2)
plot(audioData)
xlabel('sampling points')
ylabel('sound pressure')


%% audio volume
windowSizePoint = 6;
TPoints = 2*halfT*sf;
offsetPart = 0.005;
offsetPoints = 2*sf*halfT*offsetPart;
totalPoints = length(audioData);
timeOffsetPoint = sf;
periodPoints = 960;
audioVolume = zeros(1,totalPoints);
for m = 6: totalPoints
    audioVolume(1,m) = 10*log(sum(audioData(1,m-5:m).^2)/windowSizePoint)/log(10);
end
figure(3)
plot(audioVolume)


% -10
startX = 1;
startY = audioVolume(startX);

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
diffs = diff(locsFiltered);
hold on
plot(peakPoints(1,:),peakPoints(2,:),'*')
hold off

pieceNum = length(startX:TPoints:totalPoints-TPoints);
gaps = zeros(2,pieceNum);
border = 0.05;
borderPoints = TPoints*border;
increaseCnt = 0;
decreaseCnt = 0;
for m=1:pieceNum
% for m=18
    xRange = [startX+(m-1)*TPoints+1 startX+m*TPoints];
    audioVolumeTemp = audioVolume(xRange(1):xRange(2));
    peaksTemp1 = peakPoints(:,peakPoints(1,:)>xRange(1)+borderPoints & peakPoints(1,:)<xRange(1)+TPoints/2-borderPoints*4);
    peaksTemp2 = peakPoints(:,peakPoints(1,:)>xRange(1)+TPoints/2+borderPoints*4 & peakPoints(1,:)<xRange(2)-borderPoints);
    figure(5)
    plot(audioVolumeTemp)
    hold on
    plot(peaksTemp1(1,:)-xRange(1),peaksTemp1(2,:),'*')
    plot(peaksTemp2(1,:)-xRange(1),peaksTemp2(2,:),'*')
%     plot(peakPoints(1,:)-xRange(1),peakPoints(2,:),'+')
    hold off
    title(num2str(m))
    gapsTemp1 = diff(peaksTemp1(1,:))
    gapsTemp2 = diff(peaksTemp2(1,:))
    preMean1 = periodPoints;
    preMean2 = periodPoints;
    gapsfiltered1 = gapsTemp1(gapsTemp1>preMean1*0.9 & gapsTemp1<preMean1*1.1);
    gapsfiltered2 = gapsTemp2(gapsTemp2>preMean2*0.9 & gapsTemp2<preMean2*1.1);

    
    gaps(:,m) = [mean(gapsfiltered1) mean(gapsfiltered2)]
    increaseCnt=increaseCnt+length(gapsfiltered1);
    decreaseCnt = decreaseCnt + length(gapsfiltered2);
    pause(0.1)
end
[increaseCnt,decreaseCnt]

%%

figure(6)
plot(gaps(1,:))
hold on
plot(gaps(2,:))
hold off
legend('frequency increase','frequency decrease')
size = mean(nanmean(gaps));

delta = sf*sf*2*T/(B*size*2)-offsetPoints;
disDiff = delta/sf*340.29;
syms x
eqn = sqrt((x+gap/2)^2+yDis^2)-sqrt((x-gap/2)^2+yDis^2)-disDiff;
func = matlabFunction(eqn,'Vars',x);

% options = optimset('Display','iter');
x=fzero(func,0);

delta = sf*sf*2*T/(B*real*2)-offsetPoints;
disDiff = delta/sf*340.29;
syms y
eqn = sqrt((y+gap/2)^2+yDis^2)-sqrt((y-gap/2)^2+yDis^2)-disDiff;
func = matlabFunction(eqn,'Vars',y);

% options = optimset('Display','iter');
y=fzero(func,0);
expected = [expected y];
result = [result x];
[real size] 
[y x]
end
figure(10)
plot(X,expected)
hold on
plot(X,result)
hold off
legend('expected','calculated')
