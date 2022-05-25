clear
sf = 48000;
%!!!
B = 5000;
F = 15000;
T = 0.1*B/1000*2*sf;
Period = 7*T;
offset = 25/B*T;

periodPoints = 960;
gap = 0.1;
L = 0.3;

%% read data
fileName = "L1520-H10_0.wav";

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
% figure(3)
% spectrogram(audioData,256,250,256,48000)
%%
X = 1;
while X+T<length(audioVolume)

S = audioVolume(1,X:X+T);
f = F:2*B/T:(F+B);
figure(4)

plot(f,S(1,1:T/2+1))
hold on
plot(f,fliplr(S(1,T/2:T)))
hold off
axis([15000,20000,0,85])
xlabel('Frequency')
ylabel('Sound Strength')
legend('frequency increase','frequency decrease','Location','southwest')
pause(0.1)
X = X+T;
end