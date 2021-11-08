clear
sf = 48000;
F = 17000;
B = 5000;
l = 0.5;
T = 0.05;
%% generate single zig
N = T * sf;
n = 0:N-1;
t = 1/sf:1/sf:T;
K = B/T;
chirp = cos(2*pi.*(F.*t+K/2.*t.^2));
zig = [chirp flip(chirp)];
figure(1)
plot(zig)

%% generate 5 second audio
audio = [];
for i = 1:5/T
    audio = [audio zig];
end

%% calculate distance
x = 0.3;
y = 0.3;
disOffset = 0.5;
l = sqrt((x+l/2)^2+y^2);
r = sqrt((x-l/2)^2+y^2);
deltaDis = abs((l+disOffset)-r);
offsetLatency = deltaDis/340;
audioL = audio(round(offsetLatency*sf):end);
audioR = audio(1:length(audioL));
rcvAudio = audioL+audioR;
figure(2)
plot(rcvAudio)

%% audio processing
    windowSizePoint = 12;
    totalPoint = length(rcvAudio);
    volumePoint = totalPoint/windowSizePoint;
    audioVolume = zeros(1,totalPoint);

    for n=windowSizePoint:totalPoint
        audioVolume(1,n) = 10*log(sum(rcvAudio(n-windowSizePoint+1:n).^2)/windowSizePoint)/log(10);
    end
    for n=1:3
        audioVolume = smooth(audioVolume,windowSizePoint*3)';
    end
    
    [pks,locs] = findpeaks(-audioVolume);
    
    
    figure(2)
    subplot(2,1,1)
    plot(rcvAudio)
    subplot(2,1,2)
    plot(audioVolume)
    hold on
    plot(locs,-pks,'*')
    hold off




