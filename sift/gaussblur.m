%close all;
%clear all;

I0 = ones(100, 400);
I0(40:60, 50:100) = 0;
I0(20:80, 150:180) = 0;
I0(20:80, 100+(150:160)) = 0;
I0(20:80, 175+(150:155)) = 0;
I0 = imresize(I0, 2, 'nearest');

[H, W] = size(I0);
pad = [100 100];
I0 = padarray(I0, pad, 'replicate');

sigma = sqrt(2)^6;
h1 = fspecial('gaussian', [1 ceil(6*sigma)], sigma);
I1 = conv2(h1, h1, I0, 'same');

I2 = imresize(I0, 0.5, 'nearest');
I2 = conv2(h1, h1, I2, 'same');
I2 = imresize(I2, 2, 'nearest');

disp('Approximating reduced-size sigma ...');
e = @(s) gaussian_blur_error(I0, I1, s);
sigma_opt = ga(e, 1, 1, sigma, [], [], 1E-5, sigma)

h3 = fspecial('gaussian', [1 ceil(6*sigma)], sigma_opt);
I3 = imresize(I0, 0.5, 'nearest');
I3 = conv2(h3, h3, I3, 'same');
I3 = imresize(I3, 2, 'bilinear');

sigma_small = sigma/2;
h4 = fspecial('gaussian', [1 ceil(6*sigma)], sigma_small);
I4 = imresize(I0, 0.5, 'nearest');
I4 = conv2(h4, h4, I4, 'same');
I4 = imresize(I4, 2, 'bilinear');

I0 = I0(pad(1):(H+pad(1)), pad(2):(W+pad(2)));
I1 = I1(pad(1):(H+pad(1)), pad(2):(W+pad(2)));
I2 = I2(pad(1):(H+pad(1)), pad(2):(W+pad(2)));
I3 = I3(pad(1):(H+pad(1)), pad(2):(W+pad(2)));
I4 = I4(pad(1):(H+pad(1)), pad(2):(W+pad(2)));

if ~exist('f', 'var')
    f = figure;
else
    figure(f);
end
subplot(3,2,1);
imshow(I0);
title('I_0');

subplot(3,2,2);
imshow(I1);
title(['I_1, \delta=1, \sigma=' num2str(sigma)]);

subplot(3,2,3);
imshow(I2);
title(['I_2 = S_2 I_0, \delta=2, \sigma=' num2str(sigma)]);

subplot(3,2,4);
imshow(I4);
title(['I_4 = S_2 I_0, \delta=2, \sigma=' num2str(sigma_small)]);

subplot(3,2,6);
E = sqrt((I3 - I1).^2);
E = (E-min(E(:)))/(max(E(:))-min(E(:)));
SSE = sum(sum((I3 - I1).^2));
imshow(E);
title(['((S_{0.5} I_3 - I_0)^2)^{0.5}, \delta=2, \sigma_{opt}\approx' num2str(sigma_opt) ', SSE=' num2str(SSE)]);

subplot(3,2,5);
E = sqrt((I4 - I1).^2);
E = (E-min(E(:)))/(max(E(:))-min(E(:)));
SSE = sum(sum((I4 - I1).^2));
imshow(E);
title(['((S_{0.5} I_4 - I_0)^2)^{0.5}, \delta=2, \sigma=' num2str(sigma_small) ', SSE=' num2str(SSE)]);
