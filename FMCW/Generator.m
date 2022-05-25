clear
sf = 48000;
F = 15000;
B = 5000;
T = 0.1*B/1000;
offsetPart = 50/(2*B);
%% generate zig
N = T * sf;
t = 1/sf:1/sf:T;
K = B/T;
% turnFlag = 0;
% audio = zeros(1,length(t));
%%
% chirpData = cos(2*pi.*(F.*t+K/2.*t.^2));
chirpData = chirp(t,F,T,F+B);
zig = [chirpData flip(chirpData)];
figure(1)
plot(zig)
offsetPoint = length(zig)*offsetPart;
figure(2)
spectrogram(zig,256,250,256,48000)
%% generate 60 sec
audio = [];
for i = 1:30/T
    audio = [audio zig];
end
% 
figure(2)
spectrogram(audio,256,250,256,48000)
%% generate single track
audioData = audio;
% sound(audioData,sf);
fileName = [num2str(F/1000) num2str((F+B)/1000) 'k' num2str(T*2) 'TSingle.wav'];
% 
audiowrite(fileName,audioData,sf);
%% generate left/right
% % offsetPoint = N * offsetPart;
% totalPoint = length(audio) - offsetPoint;
% audioData1 = audio(1,1:totalPoint);
% audioData2 = audio(1,1+offsetPoint:totalPoint+offsetPoint);
% 
% %%
% audioData = [audioData1',audioData2'];
% fileName = [num2str(F/1000) num2str((F+B)/1000) 'k' num2str(T*2) 'T' num2str(offsetPart) 'Offzig.wav'];
% 
% audiowrite(fileName,audioData,sf);



