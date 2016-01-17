close all;

% http://www.reedbeta.com/blog/2014/11/15/antialiasing-to-splat-or-not/
filename = 'ref-1Mspp-lanczos-2.0px.png';
I = double( imread(filename) )./255;

h = fspecial('gaussian', [1,1000], 0.5);
J = conv2(h, h, I, 'same');

%figure, imshow(I)
%figure, imshow(J)

% http://www.dsprelated.com/freebooks/sasp/FFT_versus_Direct_Convolution.html
L = 65;
M = 100;

h = fspecial('gaussian', [1, L], 0.5);
f = zeros(1, M);
f(10) = 1;
f(M-(L-1)/4) = 1;

g = conv(f,h);

figure;
plot(fftshift(abs(fft(f))));

figure;
plot(f, 'b'); hold on;
plot(g, 'r');