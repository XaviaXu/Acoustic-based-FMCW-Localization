clear
sf = 48000;
gap = 0.10;
standardFreq = 100; %f
standardPeriod = 480;
waveLength = 340.29/19999.751;

%% read data from file
% file = "17-22-0.5T0.01Oleft.pcm";
% file = "0.01off.pcm";
% file = "0.5T-0.01Off-mid.pcm";
file = "-20-1.pcm";
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

%% rm turning part
 prev = 1;
 audioWithoutTurn = [];
 for i = 1:totalPoint
     if audioData(i)>7000 || audioData(i)<-7000
         if i - prev >= 300 %remove
             audioWithoutTurn = [audioWithoutTurn audioData(1,prev+1:i-1)];             
         end
         prev = i;
     end     
 end 

 figure(5)
 plot(audioWithoutTurn)
totalPoint = length(audioWithoutTurn);


%% calc sound strength
windowSizePoint = 6;
audioVolume = zeros(1,totalPoint);
for n = 6: totalPoint
    audioVolume(1,n) = 10*log(sum(audioWithoutTurn(1,n-5:n).^2)/windowSizePoint)/log(10);
end
% audioVolume = smooth(audioVolume,50)';
% locate = find(audioVolume<10);
% audioVolume(locate) = [];
[pksRaw,locsRaw] = findpeaks(-audioVolume,'minpeakdistance',200);
pksRaw = -pksRaw;


%% find lower peaks
m = movmean(pksRaw,[10 10]);
pks = zeros(1,length(pksRaw));
locs = zeros(1,length(locsRaw));
cnt = 1;
for i = 1:length(pksRaw)
    if pksRaw(i)<m(i)
        pks(cnt) = pksRaw(i);
        locs(cnt) = locsRaw(i);
        cnt = cnt+1;
    end
end
pks = pks(1,1:cnt-1);
locs = locs(1,1:cnt-1);

figure(3)
plot(audioVolume)
hold on
plot(locs,pks,'.')
hold off

%% find diff

len = length(pks);
cnt = 1;
locsDiff = zeros(1,len);
i = 1;
audioStrPro = []
while i <=len-1 
    if locs(i+1)-locs(i)< 2*480
        locsDiff(cnt) = locs(i+1)-locs(i);
        audioStrPro = [audioStrPro audioVolume(1,locs(i):locs(i+1)-1)];
        cnt = cnt+1;
    end
    i = i+1;
end
locsDiff = locsDiff(1:cnt-1);%cnt-1
locsDiff = rmoutliers(locsDiff);
locsDiff = rmoutliers(locsDiff,'movmean',5);
figure(4)
plot(locsDiff)
figure(6)
plot(audioStrPro)

% % redundant
% [pksRaw,locsRaw] = findpeaks(-audioStrPro,'minpeakdistance',200);
% pksRaw = -pksRaw;
% 
% m = movmean(pksRaw,[10 10]);
% pks = zeros(1,length(pksRaw));
% locs = zeros(1,length(locsRaw));
% cnt = 1;
% for i = 1:length(pksRaw)
%     if pksRaw(i)<m(i)
%         pks(cnt) = pksRaw(i);
%         locs(cnt) = locsRaw(i);
%         cnt = cnt+1;
%     end
% end
% pks = pks(1,1:cnt-1);
% locs = locs(1,1:cnt-1);
% 
% figure(6)
% plot(audioStrPro)
% hold on
% plot(locs,pks,'.')
% hold off

%% fft
 % FFT on audioVolume
FFTWindowSize = length(audioStrPro);
audioDataFFT = abs(fft(audioStrPro)/FFTWindowSize);
audioDataFFTHalf = audioDataFFT(1:FFTWindowSize/2+1);
audioDataFFTHalf(2:end-1) = 2*audioDataFFTHalf(2:end-1);
FFTxlabel = sf*(0:(FFTWindowSize/2))/FFTWindowSize;
figure(7)
plot(FFTxlabel,audioDataFFTHalf)
xlim([0 400])
