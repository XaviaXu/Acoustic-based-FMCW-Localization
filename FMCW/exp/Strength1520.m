clear
sf = 48000;
B = 5000;
F = 15000;
T = 0.1*B/1000;
Period = 14*T*2*sf;

K = B/T;
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

%%
timeOffset = 0;
totalTime = floor(audioDataRawTotalTime - timeOffset - 1);
totalPoints = totalTime*sf;
timeOffsetPoint = timeOffset*sf;

audioData = audioDataRaw(1,168:length(audioDataRaw));
figure(1)
plot(audioData)

%% audio volume
windowSizePoint = 6;
audioVolume = zeros(1,totalPoints);
for m = 6: totalPoints
    audioVolume(1,m) = 10*log(sum(audioData(1,m-5:m).^2)/windowSizePoint)/log(10);
end
figure(2)
plot(audioVolume)
%% strength
temp = audioData(1,1+T*2*sf:T*1.5*sf);
tempS = audioVolume(1,1+T*2*sf:T*1.5*sf);
figure(3)
% spectrogram(temp,256,250,256,48000)
plot(tempS)
tempS = smoothdata(tempS);
tempS = 100./tempS;
figure(4)
plot(tempS)
%%

t = 1/sf:1/sf:T;
K = B/T;

chirp = cos(2*pi.*(F.*t+K/2.*t.^2));

% chirp = chirp.*tempS;
zig = [chirp flip(chirp)];
figure(4)
plot(chirp)

figure(5)
spectrogram(zig,256,250,256,48000)

%% generator
offset = 25/B*length(zig);
empty = zeros(1,length(zig));
audio1 = [];
audio2 = [];
zigS = circshift(zig,offset);
for i=1:3
    for j=1:15
        if i==1
            audio1 = [audio1 zig];
            audio2 = [audio2 empty];
        elseif i==2
            audio1 = [audio1 empty];
            audio2 = [audio2 zig];
        else
            audio1 = [audio1 zig];
            audio2 = [audio2 zigS];
        end
    end
    audio1 = [audio1 empty];
    audio2 = [audio2 empty];
end

%% write
au = audio1+audio2;
figure(10)
plot(au)

% audioData =[audio1',audio2'];
% fileName = ['Off' num2str(F/1000) '-' num2str((F+B)/1000) 'k.wav'];

% audiowrite(fileName,audioData,sf);

total = au(1,1+Period*2+T*4*sf:Period*3+T*4*sf);
windowSizePoint = 6;
audioVolume = zeros(1,length(total));
for m = 6: length(total)
    audioVolume(1,m) = 10*log(sum(total(1,m-5:m).^2)/windowSizePoint)/log(10);
end
figure(2)
plot(audioVolume)
[pksRaw,locsRaw] = findpeaks(-audioVolume,'minpeakdistance',periodPoints*0.7);
pksRaw = -pksRaw;
locsFiltered = [];
pksFiltered = [];
hold on
plot(locsRaw,pksRaw,'*')
hold off

size = diff(locsRaw);

