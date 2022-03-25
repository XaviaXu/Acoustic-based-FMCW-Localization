clear
sf = 48000;
speakerDis = 0.1;
halfT = 0.5;%s
standardFreq = 100; %f
F = 17000;
B = 5000;
T = 0.5;
offsetPart = 0.005;
standardPeriod = sf/(B*offsetPart*2);
%% distance diff
yDis = 0.3;
xDis = 0.1;
leftDis = sqrt((xDis+speakerDis/2)^2+yDis^2);
rightDis = sqrt((xDis-speakerDis/2)^2+yDis^2);
dotDiff = (leftDis-rightDis)/340.29 * sf;

%% generate
N = T * sf;
t = 1/sf:1/sf:T;
K = B/T;
chirp = cos(2*pi.*(F.*t+K/2.*t.^2))*5000;
zig = [chirp flip(chirp)];
figure(1)
plot(zig)
audio = [];
for i = 1:2/T
    audio = [audio zig];
end

offsetPoint = round(N * offsetPart*2+dotDiff);
totalPoint = length(audio) - offsetPoint;
audioData1 = audio(1,1:totalPoint);
audioData2 = audio(1,1+offsetPoint:totalPoint+offsetPoint);

audioData = audioData1+0.6*audioData2;
figure(2)
plot(audioData)

%% analyze
windowSizePoint = 6;
audioVolume = zeros(1,totalPoint);
for n = 6: totalPoint
    audioVolume(1,n) = 10*log(sum(audioData(1,n-5:n).^2)/windowSizePoint)/log(10);
end
% audioVolume = smooth(audioVolume,50)';
% locate = find(audioVolume<10);
% audioVolume(locate) = [];

[pksRaw,locsRaw] = findpeaks(-audioVolume,'minpeakdistance',standardPeriod*0.7);
pksRaw = -pksRaw;

figure(3)
plot(audioVolume)
hold on
plot(locsRaw,pksRaw,'.')
hold off
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


%% rm low volume part

audioStrPro = [];
disData = [];
stack = [];

i = 1;
cnt = 0;
while i < length(locsRaw)
    win = audioV(1,locsRaw(i):locsRaw(i+1));
    [pks,locs] = findpeaks(win,'minpeakdistance',50);
    if(length(pks)>=2)
        i=i+1;
    end
    if(length(pks)<2 && pks>12+min(win)&&length(win)>standardPeriod*0.9&&length(win)<standardPeriod*1.1)
        cnt = cnt +1;
        audioStrPro = [audioStrPro win];
        disData = [disData length(win)];
    end
    i = i+1;
end

[pksRaw,locsRaw] = findpeaks(-audioStrPro,'minpeakdistance',standardPeriod*0.7);
pksRaw = -pksRaw;
figure(3)
plot(audioStrPro)
hold on
plot(locsRaw,pksRaw,'.')
hold off
temp = diff(locsRaw);
%% locsDiff
size = sum(temp,'all')/length(temp);
offsetPoints = sf*halfT*offsetPart*2;
delta = sf*sf*halfT/(B*size)-offsetPoints;
disDiff = delta/sf*340.29;
syms x
eqn = sqrt((x+speakerDis/2)^2+yDis^2)-sqrt((x-speakerDis/2)^2+yDis^2)-disDiff;
func = matlabFunction(eqn,'Vars',x);

% options = optimset('Display','iter');
x=fzero(func,0);

[size x]