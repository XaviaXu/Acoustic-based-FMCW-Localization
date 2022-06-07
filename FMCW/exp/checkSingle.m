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
L = 0.7;

%% read data
fileName = "0527\70-0-1.wav";
fileId = fopen(fileName,'r');
audioDataRaw = fread(fileId,inf,'int16')';
audioDataRawTotalTime = length(audioDataRaw)/sf;
fclose(fileId);
figure(1)
plot(audioDataRaw)
audioData = audioDataRaw;

sampleName = "WithOff15-20k.wav";
sampleId = fopen(fileName,'r');
[sample,fs] = audioread(sampleName);
sampleL = sample(:,1).';
sampleR = sample(:,2).';

%% audio volume
% windowSizePoint = 6;
% audioVolume = zeros(1,length(audioData));
% for m = 6: length(audioData)
%     audioVolume(1,m) = 10*log(sum(audioData(1,m-5:m).^2)/windowSizePoint)/log(10);
% end
% figure(2)
% plot(audioVolume)


%%
startX = 169;
leftAD = normalize(audioData(1,startX:startX+Period),'medianiqr');
sampleL = sampleL(1,1:1+Period);
rightAD = normalize(audioData(1,startX+Period+T:startX+Period*2+T),'medianiqr');
sampleR = sampleR(1,1+Period+T:1+Period*2+T);
% leftAD = normalize(leftAD,'medianiqr');
figure(2)
subplot(2,1,1)
plot(leftAD)
subplot(2,1,2)
plot(rightAD)
figure(3)
subplot(2,1,1)
plot(sampleL)
subplot(2,1,2)
plot(sampleR)
xq = 0:1/16:Period;
x = 0:Period;
leftQ = interp1(leftAD,xq,'spline');
rightQ = interp1(rightAD,xq,'spline');
sampleL = interp1(sampleL,xq,'spline');
sampleR = interp1(sampleR,xq,'spline');
leftQ = leftQ(1,3:length(sampleL));
rightQ = rightQ(1,7:length(sampleR));

[pksLR,locsLR] = findpeaks(leftQ(1,1:T*16));
[pksLS,locsLS] = findpeaks(sampleL(1,1:T*16));
diffLS = diff(locsLS);
diffLR = diff(locsLR);
deltaL = diffLS-diffLR;%(2:length(locsLR))
figure(6)
plot(deltaL)


figure(4)
plot(sampleL)
hold on
plot(leftQ)
hold off
% axis([1 1000 -2 2])
legend('sample','real')

figure(5)
plot(sampleR)
hold on
plot(rightQ)
hold off
% axis([1 1000 -2 2])
legend('sample','real')

[pksRR,locsRR] = findpeaks(rightQ(1,1:T*16));
[pksRS,locsRS] = findpeaks(sampleR(1,1:T*16));
diffRS = diff(locsRS);
diffRR = diff(locsRR);
deltaR = diffRS-diffRR;%(2:length(locsLR))
figure(7)
plot(deltaR)