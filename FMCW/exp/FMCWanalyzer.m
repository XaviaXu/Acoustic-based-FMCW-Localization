clear
sf = 48000;
gap = 0.20;
halfT = 0.5;%s
standardFreq = 100; %f
B = 5000;
offsetPart = 0.005;
standardPeriod = sf/(B*offsetPart*2);

%% read data from file
% file = "R10T1-2.pcm";
% file = "30-R10-1.pcm";
file = "10-0.005-30-20-2.pcm";
fileId = fopen(file,'r');
audioDataRaw = fread(fileId,inf,'int16')';
audioDataRawTotalTime = length(audioDataRaw)/sf;
fclose(fileId);
figure(1)
plot(audioDataRaw)

%% remove offset
% [b,a] = butter(5,18000/(sf/2),'high');
% audioDataRaw = filter(b,a,audioDataRaw);

timeOffset = 1; %s
totalTime = ceil(audioDataRawTotalTime - timeOffset - 1);
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
% audioVolume = smooth(audioVolume,50)';
% locate = find(audioVolume<10);
% audioVolume(locate) = [];


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


i = 1;
cnt = 0;
while i < length(locsRaw)
    win = audioV(1,locsRaw(i):locsRaw(i+1));
    [pks,locs] = findpeaks(win,'minpeakdistance',standardPeriod*0.2);
    if(length(pks)<2 && pks>3+min(win))
        audioStrPro = [audioStrPro win];
        cnt = cnt + 1;
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

figure(8)
subplot(2,1,1);
plot(audioVolume)
subplot(2,1,2);
plot(audioStrPro)


%% fft
size = length(audioStrPro)/cnt;
freq = sf/size;

[size freq]
%  % FFT on audioVolume
% FFTWindowSize = length(audioStrPro);
% audioDataFFT = abs(fft(audioStrPro)/FFTWindowSize);
% audioDataFFTHalf = audioDataFFT(1:FFTWindowSize/2+1);
% audioDataFFTHalf(2:end-1) = 2*audioDataFFTHalf(2:end-1);
% FFTxlabel = sf*(0:(FFTWindowSize/2))/FFTWindowSize;
% figure(7)
% plot(FFTxlabel,audioDataFFTHalf)
% xlim([0 400])
