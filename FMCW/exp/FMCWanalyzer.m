clear
sf = 48000;
gap = 0.10;
halfT = 0.5;%s
standardFreq = 100; %f
standardPeriod = 480;
waveLength = 340.29/19999.751;

%% read data from file
file = "mibT1-3.pcm";
% file = "1108/-20-1.pcm";
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
[pksRaw,locsRaw] = findpeaks(-audioVolume,'minpeakdistance',200);
pksRaw = -pksRaw;

figure(3)
plot(audioVolume)
hold on
plot(locsRaw,pksRaw,'.')
hold off

%% rm futile parts
audioFlag = find(audioVolume>=74);
audioV = [];
 for i = 1:length(audioFlag)-1
     if audioFlag(i+1)-audioFlag(i)>halfT*sf/2
         %中部大空隔 去除过小值
         audioV = [audioV audioVolume(1,audioFlag(i)+1:audioFlag(i+1)-1)];
     else
         %小间隔 去除
     end
 end 
 
[pksRaw,locsRaw] = findpeaks(-audioV,'minpeakdistance',200);
pksRaw = -pksRaw;
figure(5)
plot(audioV)
hold on
plot(locsRaw,pksRaw,'.')
hold off

%% rm low volume part
windowSize = 480*5;
audioStrPro = [];
stack = [];
locsRaw = [1 locsRaw];
i = 1;
while i <= length(locsRaw)
    if(locsRaw(i)+windowSize>length(audioV))
        break;
    end
    window = audioV(1,locsRaw(i):locsRaw(i)+windowSize);
    TF = isoutlier(window,'mean',2);
    index = find(TF==1);
    
    flag = 0;
    for j = 1:length(index)
        if window(index(j))>65
            % remove
            temp = find(locsRaw>(locsRaw(i)+index(j)+windowSize*2));
            if isempty(temp)
                i = length(locsRaw);
            else
                i = temp(1);
            end
            flag = 1;
            break
        end
    end
    
    if flag==0 && audioV(locsRaw(i+1))>35
        %no remove
        audioStrPro = [audioStrPro audioV(1,locsRaw(i):locsRaw(i+1))];
        stack = [stack i];
        i = i+1;
    elseif flag ==0
        while audioV(locsRaw(i+1))<=35 || audioV(locsRaw(i+2))<=35
            i = i+1;
        end
        i = i+1;
    end
   
end

[pksRaw,locsRaw] = findpeaks(-audioStrPro,'minpeakdistance',200);
pksRaw = -pksRaw;
figure(3)
plot(audioStrPro)
hold on
plot(locsRaw,pksRaw,'.')
hold off

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
