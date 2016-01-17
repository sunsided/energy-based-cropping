close all; clear all; clc;

%filename = '../../resources/images/source/7A5F52750ADD07483305B0C2226A484ED74B42FD4D87B4BBBC352DCF4E8D8BB8.jpg';
filename = '../../resources/images/test-images/lena.png';

I = double( imread(filename) )./255;    % load image and normalize to 0..1
I = sum( I.^(1/2.2), 3)/3;              % grayscale conversion by gleam
I = imresize(I, 0.5, 'bilinear');       % downsample image for speed

minI = min(min(I)); maxI = max(max(I));
I = (I-minI)/(maxI-minI);               % stretch the histogram

% Scale-space extrema detection
s       = 2;                            % the number of wanted scales
O       = 3;                            % the number of octaves
S       = s+3;                          % then umber of required scales
sigma_0 = sqrt(2)/2;%1.6;                          % first-scale gamma
sigma_n = 0;%0.5;                          % intrinsic gamma
k       = 2^(1/s); % for N_scales=5 --> s=2 --> sqrt(2);

% pre-process according to the paper
I = imresize(I, 2, 'nearest');          % preprocessing: upsample
O = O+1;

% repeat image edges to aid the convolution kernel at the image edges
I = padarray(I, 0.5*size(I), 'replicate');

sigma = 1.0;
kernel_width = 1 + 2*floor(3*sigma);
h = fspecial('gaussian', [1 kernel_width], sigma);
I = conv2(h, h, I, 'same');

% prepare the scales
Ls = cell(O * S, 1);

k_offset = 0;
for o=0:O
    if o>0
        k_offset = o*(S-2);          % selects the sigma to double
        I = Ls{o*S-2};               % select image with half sigma
        I = imresize(I, 0.5, 'nearest');  % downsample by 2
    end
    
    for s=(o*S):(o*S)+(S-1)
        I_previous = I;
        if s>(o*S)
            I_previous = Ls{s};
        end

        % obtain iterative sigma
        sigma        = k^(s-k_offset) * sigma_0 * sqrt( k^2-1 );
        sigma_opt    = sqrt( sigma^2 - sigma_n^2 )

        % create a separable kernel
        kernel_width = 1 + 2*floor(3*sigma_opt);
        h = fspecial('gaussian', [1 kernel_width], sigma_opt);

        % build the scale
        Ls{s+1} = conv2(h, h, I_previous, 'same');
    end
end

% unpad
for i=1:numel(Ls)
    I = Ls{i};  
    [M, N] = size(I);
    Ls{i} = I(0.25*M:0.75*M-1, 0.25*N:0.75*N-1);
end

% build Difference-of-Gaussian
DoG = cell(O * (S-1) - 2, 1);
for o=0:O-1
    
    imwrite(Ls{o*S+1}, sprintf('sift-scales/l-octave-%d-scale-%d.png', o, 1));
    for s=2:S
        DoG{o*(S-1)+s-1} = Ls{o*S+s} - Ls{o*S+s-1};
        
        imwrite(Ls{o*S+s}, sprintf('sift-scales/l-octave-%d-scale-%d.png', o, s));
        dog = (DoG{o*(S-1)+s-1}-min(min(DoG{o*(S-1)+s-1}))) / (max(max(DoG{o*(S-1)+s-1})) - min(min(DoG{o*(S-1)+s-1})));
        imwrite(dog, sprintf('sift-scales/dog-octave-%d-scale-%d,%d.png', o, s,s-1));
    end
end

for i=1:numel(Ls)
    figure, imshow(Ls{i})
end

for i=1:numel(DoG)
    dog = (DoG{i}-min(min(DoG{i}))) / (max(max(DoG{i})) - min(min(DoG{i})));
    figure, imshow(dog)
end
