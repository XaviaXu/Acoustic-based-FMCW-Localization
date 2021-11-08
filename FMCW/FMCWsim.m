% generate FMCW
sf = 480000;
signalTime = 20;


t = 1/sf:1/sf:signalTime/1000;
startFrequency = 1000;
endFrequency = 20000;
chirpSignal = chirp(t,startFrequency,signalTime/1000,endFrequency);
zigSignal = [chirpSignal flip(chirpSignal)];
chirpPiece = [chirpSignal zeros(1,length(chirpSignal))];

data = [];
for m=1:10
    data = [data zigSignal]; 
%     data = [data chirpPiece];
end
totalPoint = length(zigSignal)*8;
offsetPoint = 120;
%% cal dotDiff
speakerDis = 0.1;
yDis = 0.3;

for theta = -45:45
    xDis = yDis * tand(theta);
    leftDis = sqrt((xDis+speakerDis/2)^2+yDis^2);
    rightDis = sqrt((xDis-speakerDis/2)^2+yDis^2);
    
    dotDiff = round((leftDis-rightDis)/340 * sf);
    
    %%    start
    
    
    sig1 = data(1,1:totalPoint);
    sig2 = data(1,1+dotDiff+offsetPoint:totalPoint+dotDiff+offsetPoint);
    sigMix = sig1 + sig2;
    
%     resample
    [P,Q] = rat(48e3/sf);
    sigMix = resample(sigMix,P,Q);    




    %%    
    windowSizePoint = 12;
%     audioDataTemp = sigMix;
%     volumePoint = totalPoint/windowSizePoint;
%     audioVolume = zeros(1,totalPoint);
% 
%     for n=windowSizePoint:totalPoint
%         audioVolume(1,n) = 10*log(sum(audioDataTemp(n-windowSizePoint+1:n).^2)/windowSizePoint)/log(10);
%     end
%     for n=1:3
%         audioVolume = smooth(audioVolume,windowSizePoint*3)';
%     end
    
    [audioVolume,lo1] = envelope(sigMix,40,'peak');
    for n=1:3
        audioVolume = smooth(audioVolume,windowSizePoint*3)';
    end
    
    [pks,locs] = findpeaks(audioVolume);

    figure(3)
    subplot(2,1,1)
    plot(sigMix)
    subplot(2,1,2)
    plot(audioVolume)
    hold on
    plot(locs,pks,'*')
    hold off
    
    [theta dotDiff]


%     segData = [];
%     T = length(zigSignal);
%     i = 1;    
%     segData = [segData audioVolume(1,1895:9241)];
%     segData = [segData audioVolume(1,9861:17207)];
% 
%     for m= 1:3
%         segData = [segData segData];
%     end
    segData = audioVolume;
    
    % FFT on audioVolume
    FFTWindowSize = length(segData);
    audioDataFFT = abs(fft(segData)/FFTWindowSize);
    audioDataFFTHalf = audioDataFFT(1:FFTWindowSize/2+1);
    audioDataFFTHalf(2:end-1) = 2*audioDataFFTHalf(2:end-1);
    FFTxlabel = sf*(0:(FFTWindowSize/2))/FFTWindowSize;
    %
    
    
    figure(4)
    subplot(3,1,1)
    plot(sigMix)
    subplot(3,1,2)
    plot(audioVolume)
    hold on
    plot(locs,pks,'*')
    hold off
    subplot(3,1,3)
    plot(FFTxlabel,audioDataFFTHalf)
    xlim([0 6000])
%% end
    pause(1)
end




