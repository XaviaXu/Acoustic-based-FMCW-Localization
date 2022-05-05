clear
sf = 48000;
timeOffset = 3.5; %s
timeOffsetPoint = timeOffset*sf;
%%
% file = "1227/10-0.005-30-20-1.pcm";
fileL = "0304/L.pcm";
fileIdL = fopen(fileL,'r');
audioDataRawL = fread(fileIdL,inf,'int16')';
audioDataRawTotalTimeL = length(audioDataRawL)/sf;
fclose(fileIdL);
figure(1)
plot(audioDataRawL)


totalTime = ceil(audioDataRawTotalTimeL - timeOffset - 1);
totalPoint = totalTime*sf;
audioDataL = audioDataRawL(1,timeOffsetPoint + (1:totalPoint));
figure(1)
plot(audioDataL)
windowSizePoint = 6;
audioVolume = zeros(1,totalPoint);
for n = 6: totalPoint
    audioVolume(1,n) = 10*log(sum(audioDataL(1,n-5:n).^2)/windowSizePoint)/log(10);
end



figure(3)
plot(audioVolume)

%%
% file = "1227/10-0.005-30-20-1.pcm";
fileR = "0304/R.pcm";
fileIdR = fopen(fileR,'r');
audioDataRawR = fread(fileIdR,inf,'int16')';
audioDataRawTotalTimeR = length(audioDataRawR)/sf;
fclose(fileIdR);
figure(2)
plot(audioDataRawR)

totalTimeR = ceil(audioDataRawTotalTimeR - timeOffset - 5);
totalPoint = totalTimeR*sf;
audioDataR = audioDataRawR(1,timeOffsetPoint+12153-sf + (1:totalPoint));
figure(2)
plot(audioDataR)
windowSizePoint = 6;
audioVolume = zeros(1,totalPoint);
for n = 6: totalPoint
    audioVolume(1,n) = 10*log(sum(audioDataR(1,n-5:n).^2)/windowSizePoint)/log(10);
end


figure(4)
plot(audioVolume)


%%
X = audioDataL- audioDataR;
figure(5)
plot(X)
figure(6)
spectrogram(X,256,250,256,48000)
%%
len = totalPoint-0.005*sf;
audioL1 = audioDataL(1,1:len);
audioL2 = audioDataL(1,0.005*sf+(1:len));
audioR1 = audioDataR(1,1:len);
audioR2 = audioDataR(1,0.005*sf+(1:len));
figure(7)
subplot(3,1,1);
plot((audioL1+audioL2))
subplot(3,1,2);
plot(audioR1+audioR2)
subplot(3,1,3);
plot(audioL1+audioR2)