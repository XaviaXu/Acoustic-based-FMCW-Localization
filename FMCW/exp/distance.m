%%

sf = 48000;
fs = sf;
T = 1;
f1 = 15000; f2 = 19000; f3 = 20000;
t = linspace(0, T, sf * T);
y = chirp(t, f2, T, f3);

file = "0527\30+10-1.wav";
fileId = fopen(file,'r');
audioDataRaw = fread(fileId,inf,'int16')';
audioDataRaw = audioDataRaw(1,68:sf*2+67);
audioDataRawTotalTime = length(audioDataRaw)/sf;
t1=0:1/fs:(length(audioDataRaw)-1)/fs;
fclose(fileId);
figure(1)
plot(audioDataRaw)
figure(2)
spectrogram(audioDataRaw, 256, 250, 256, fs,'yaxis');


%%
sampleName = "WithOff15-20k.wav";

[sample,fs] = audioread(sampleName);
sampleL = sample(1:sf*2,1).';
% sampleR = sample(:,2).';
sigMix = sampleL.*audioDataRaw;

figure(3)
plot(sigMix)

ratio = 256;
[b, a] = butter(5, 1000/(sf/2),'low');
sigMix = filter(b,a,sigMix);
sigX = 1:length(sigMix);
sigXInter = 1:1/ratio:length(sigMix);
sigMixInter = interp1(sigX,sigMix,sigXInter);

figure(4)
plot(sigMixInter)

FFTWindowSize = length(sigMixInter);
audioDataFFT = abs(fft(sigMix,FFTWindowSize)/FFTWindowSize);
audioDataFFTHalf = audioDataFFT(1:FFTWindowSize/2+1);
audioDataFFTHalf(2:end-1) = 2*audioDataFFTHalf(2:end-1);
FFTxlabel = sf*(0:(FFTWindowSize/2))/FFTWindowSize;
figure(5)
plot(FFTxlabel,audioDataFFTHalf) 
[maxValue,index] = max(audioDataFFTHalf);
xlabel('Frequency(Hz)')
ylabel('Power/Frequency(dB/Hz)')
xlim([0 50])

dis = FFTxlabel(index)/10000*340