clear
sf = 48000;
gap = 0.10;
halfT = 0.5;%s
standardFreq = 100; %f
standardPeriod = 480;
waveLength = 340.29/19999.751;

%% read data from file
% file = "-20-2.pcm";
file = "mid.0.pcm";
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
 audioFlag = find(audioData>4000|audioData<-4000);%original 7500
 audioWithoutTurn = [];
 
 for i = 1:length(audioFlag)-1
     if audioFlag(i+1)-audioFlag(i)>halfT*sf/2
         %中部大空隔 去除过小值？

         if(abs(audioData(1,audioFlag(i)+480*2)-audioData(1,audioFlag(i)+480*2+1))>100)
             audioWithoutTurn = [audioWithoutTurn audioData(1,audioFlag(i)+480*2:audioFlag(i)+480*2+2*halfT*sf/3)];
         else
             audioWithoutTurn = [audioWithoutTurn audioData(1,audioFlag(i)+480*2+halfT*sf/5:audioFlag(i+1)-1)];
         end
         
     else
         %小间隔 去除
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

figure(3)
plot(audioVolume)
hold on
plot(locsRaw,pksRaw,'.')
hold off

%% find lower peaks
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


%% find diff


cnt = 1;

i = 1;
audioStrPro =  audioWithoutTurn;



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
