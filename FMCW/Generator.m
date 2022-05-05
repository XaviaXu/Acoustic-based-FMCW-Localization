clear
sf = 48000;
F = 10000;
B = 5000;
T = 0.5;
offsetPart = 0.005;
%% generate zig
N = T * sf;
t = 1/sf:1/sf:T;
K = B/T;
% turnFlag = 0;
% audio = zeros(1,length(t));
%%
% for i = 1:length(t)
%     if turnFlag == 0
%         audio(i) = cos(2*pi*(F*t(i)+K/2*t(i)^2));
%     else
%         audio(i) = cos(2*pi*((F+K)*t(i)+K/2*t(i)^2));
%     end
%     if i/N==0
%         K = -K;
%         turnFlag = 1-turnFlag;
%     end
% end



chirp = cos(2*pi.*(F.*t+K/2.*t.^2));
zig = [chirp flip(chirp)];
figure(1)
plot(zig)
offsetPoint = length(zig)*offsetPart;
%% generate 60 sec
audio = [];
for i = 1:30/T
    audio = [audio zig];
end
% 
% figure(2)
% spectrogram(audio,256,250,256,48000)
%% generate left/right
% offsetPoint = N * offsetPart;
totalPoint = length(audio) - offsetPoint;
audioData1 = audio(1,1:totalPoint);
audioData2 = audio(1,1+offsetPoint:totalPoint+offsetPoint);

%%
audioData = [audioData1',audioData2'];
fileName = [num2str(F/1000) num2str((F+B)/1000) 'k' num2str(T*2) 'T' num2str(offsetPart) 'Offzig.wav'];

audiowrite(fileName,audioData,sf);



