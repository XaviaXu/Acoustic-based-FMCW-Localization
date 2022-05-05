clear
sf = 48000;
F = 17000;
B = 5000;
T = 0.1*B/1000;

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
for i = 1:45/T
    if mod(i,28) <7
        audio1 = [audio1 empty];
        audio2 = [audio2 empty];
    elseif mod(i,28)<14
        audio1 = [audio1 zig];
        audio2 = [audio2 empty];
        if mod(i,28)==13
           audio1 = [audio1 empty];
           audio2 = [audio2 empty]; 
        end
    elseif mod(i,28)<21
        audio1 = [audio1 empty];
        audio2 = [audio2 zig];
        if mod(i,28)==20
           audio1 = [audio1 empty];
           audio2 = [audio2 empty]; 
        end
    else
        audio1 = [audio1 zig];
        audio2 = [audio2 zigS];
    end
end

%%
audioData =[audio1',audio2'];
fileName = ['mul' num2str(F/1000) '-' num2str((F+B)/1000) 'k.wav'];

audiowrite(fileName,audioData,sf);



