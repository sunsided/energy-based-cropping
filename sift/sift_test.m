%filename = '../../resources/images/source/7A5F52750ADD07483305B0C2226A484ED74B42FD4D87B4BBBC352DCF4E8D8BB8.jpg';
filename = '../../resources/images/source/0A681D9ADB6193D1217E62A3A0E998EBE8E5C446B5D44CB5DBAC998B5B32B6DA.jpg';

I = double( imread(filename) )./255;    % load image and normalize to 0..1
I = sum( I.^(1/2.2), 3)/3;              % grayscale conversion by gleam
I = imresize(I, 0.5, 'bilinear');       % downsample image for speed

minI = min(min(I)); maxI = max(max(I));
I = (I-minI)/(maxI-minI);               % stretch the histogram

imshow(I)

% Scale-space extrema detection
N_octaves = 4;
N_scales  = 5;
sigma_0   = 1.6;
k         = sqrt(2);

% "Pixels more distant from the center of the operator have 
% smaller influence, and pixels farther than 3 sigma from the center
% have negligible influence." 
% Image Processing, Analysis and Machine Vision, 3rd. edition, p. 176

% pre-process according to the paper
%{
I = imresize(I, 2, 'nearest');          % preprocessing: upsample
scale = 0.5;
sigma = 1.5;
kernel_width = 1 + 2*floor(0.5* (3*sigma) );
h = fspecial('gaussian', kernel_width, sigma);
I = conv2(I, h, 'same');
%}

figure, imshow(I)

sigma = sigma_0;
for s=1:N_scales
    sigma = (k^(s-1))*sigma;
    kernel_width = 1 + 2*floor(0.5* (3*sigma) );
    h = fspecial('gaussian', kernel_width, sigma);
    
    Is = conv2(I, h, 'same');
    imshow(Is)
end

figure, imshow(Is)

