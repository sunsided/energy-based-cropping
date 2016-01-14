close all;

N = 256;                    % border length
I = ones(N, N);             % white background
%I = cumsum(ones(N)/N, 2);
%I = toeplitz(1:N)/N;
I(32:224, 32:224) = 0.9375; % light gray box
I(64:192, 32:224) = 0.875;  % light gray box
I(64:192, 32:224) = 0.875;  % light gray box
I(64:192, 64:192) = 0.75;   % light gray box
I(96:160, 64:192) = 0.5;    % light gray box
I(96:160, 96:160) = 0;      % black box

E = 0.05*randn(N);          % zero-mean noise with s=0.05
Ie = abs(I + E);            % apply the noise to the image
Ie(Ie>1) = 1;
Ie(Ie<0) = 0;

Gx = conv2(Ie, 0.125*[-1 0 1; -2 0 2; -1 0 1]);
Gy = conv2(Ie, 0.125*[-1 -2 -1; 0 0 0; 1 2 1]);
J = abs(Gx) + abs(Gy);
J = J(1+2:N, 1+2:N);

% using the same technique as below for
% mean and threshold (e.g. standard deviation)
% could effectively mean cropping all pixels
% in the designed area, because they all meet
% these statistics ...

% Had to hack around with the image width;
% now dividing by 6 for the intensity crop,
% additionally taking the square root of 4x stdev
% (double variance).

%tI = 0.2;                   % threshold value
%vI = Ie(1,1);               % candidate value
[~,vI,tI] = energyThreshold(Ie, 6);
boxI = findBoundingBox(Ie, sqrt(tI), vI, 0)

J = (J-min(min(J)))/(max(max(J))-min(min(J)));
tJ = energyThreshold(J);    % threshold value
vJ = 0;                     % candidate value
boxJ = findBoundingBox(J, tJ, vJ, 0)

%figure, hist(reshape(I,1,[]), 64)
%figure, hist(reshape(J,1,[]), 64)

figure, subplot(2,2,1);
imshow(Ie); axis image; title('Original image with noise');

subplot(2,2,2);
imshow(J); axis image; title('Energy map');

subplot(2,2,3);
imshow(Ie); axis image; title('Intensity-based crop');
xlabel(sprintf('\\mu = %0.3f, \\tau = %0.3f', vI, tI));
line([1, N], [boxI(2), boxI(2)], 'Color', 'r');
line([1, N], [boxI(4), boxI(4)], 'Color', 'r');
line([boxI(1), boxI(1)], [1, N], 'Color', 'r');
line([boxI(3), boxI(3)], [1, N], 'Color', 'r');

subplot(2,2,4);
imshow(Ie); axis image; title('Energy-based crop');
xlabel(sprintf('\\tau = %0.3f', tJ));
line([1, N], [boxJ(2), boxJ(2)], 'Color', 'r');
line([1, N], [boxJ(4), boxJ(4)], 'Color', 'r');
line([boxJ(1), boxJ(1)], [1, N], 'Color', 'r');
line([boxJ(3), boxJ(3)], [1, N], 'Color', 'r');
