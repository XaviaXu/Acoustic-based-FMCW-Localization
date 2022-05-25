clear
sf = 48000;
F = 15000;
B = 5000;
T = 0.1*B/1000;
offsetP = 0.005;

%% generate zig
N = T * sf;
t = 1/sf:1/sf:T;
K = B/T;

chirp = cos(2*pi.*(F.*t+K/2.*t.^2));
zig = [chirp flip(chirp)];
figure(1)
plot(zig)

%% generate 60 sec
empty = zeros(1,length(zig));
audio1 = [];
audio2 = [];
offset = 25/B*length(zig);
zigS = circshift(zig,offset);
for i = 1:60
    if mod(i,60) <15
        audio1 = [audio1 zig];
        audio2 = [audio2 empty];
        if mod(i,60)==14
           audio1 = [audio1 empty];
           audio2 = [audio2 empty]; 
        end
    elseif mod(i,60)<30
        audio1 = [audio1 empty];
        audio2 = [audio2 zig];
        if mod(i,45)==29
           audio1 = [audio1 empty];
           audio2 = [audio2 empty]; 
        end
    elseif mod(i,60)<45
        audio1 = [audio1 zig];
        audio2 = [audio2 zigS];
    else
        audio1 = [audio1 empty];
        audio2 = [audio2 empty];
    end
end

%%
audioData =[audio1',audio2'];
fileName = ['WithOff' num2str(F/1000) '-' num2str((F+B)/1000) 'k.wav'];

audiowrite(fileName,audioData,sf);



