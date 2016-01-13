close all;

N = 256;                    % border length
I = ones(N, N);             % white background
I(32:224, 32:224) = 0.9375; % light gray box
I(64:192, 32:224) = 0.875;  % light gray box
I(64:192, 32:224) = 0.875;  % light gray box
I(64:192, 64:192) = 0.75;   % light gray box
I(96:160, 64:192) = 0.5;    % light gray box
I(96:160, 96:160) = 0;      % black box

E = 0.05*randn(N);          % zero-mean noise with s=0.05
J = abs(I + E);             % apply the noise to the image
J(J>1) = 1;
J(J<0) = 0;

t = 0.13;                   % threshold value
v = I(1,1);                 % candidate value

box = findBoundingBox(J, t, v, 0)

%figure, hist(reshape(I,1,[]), 64)
%figure, hist(reshape(J,1,[]), 64)
figure, imshow(J); axis image;

line([1, N], [box(2), box(2)], 'Color', 'r');
line([1, N], [box(4), box(4)], 'Color', 'r');

line([box(1), box(1)], [1, N], 'Color', 'b');
line([box(3), box(3)], [1, N], 'Color', 'b');
