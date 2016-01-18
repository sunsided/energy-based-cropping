close all; clear all; clc;

%filename = '../../resources/images/source/7A5F52750ADD07483305B0C2226A484ED74B42FD4D87B4BBBC352DCF4E8D8BB8.jpg';
%filename = '../../resources/images/test-images/lena.png';
%filename = '../../resources/images/test-images/troete-sw.jpg';
filename = '../../resources/images/test-images/circle.png';

I0 = double( imread(filename) )./255;   % load image and normalize to 0..1
I0 = sum( I0.^(1/2.2), 3)/3;            % grayscale conversion by gleam
I0 = imresize(I0, 0.5, 'bilinear');     % downsample image for speed
[H,W] = size(I0);

minI = min(min(I0)); maxI = max(max(I0));
I0 = (I0-minI)/(maxI-minI);            % stretch the histogram

% Scale-space extrema detection
s       = 2;                            % the number of wanted scales
O       = 3;                            % the number of octaves
S       = s+3;                          % then umber of required scales
sigma_0 = 1.6;                          % first-scale sigma
sigma_n = 0.5;                          % intrinsic sigma
k       = 2^(1/s);

% pre-process according to the paper
I = I0;
I = imresize(I, 2, 'nearest');         % preprocessing: upsample
O = O+1;

% repeat image edges to aid the convolution kernel at the image edges
I = padarray(I, 0.5*size(I), 'replicate');

sigma = 0.5;
kernel_width = 1 + 2*floor(3*sigma);
h = fspecial('gaussian', [1 kernel_width], sigma);
I = conv2(h, h, I, 'same');

% prepare the scales
Ls = cell(O, S);

k_offset = 0;
for o=0:(O-1)
    if o>0
        %k_offset = o*(S-2);                 % selects the sigma to double
        I = Ls{o,S-2};                  % select image with half sigma
        I = imresize(I, 0.5, 'nearest');  % downsample by 2
    end
    
    for s=0:(S-1)
        I_previous = I;
        if s>0
            I_previous = Ls{o+1,s};
        end

        % obtain iterative sigma
        sigma        = k^((o*(S-3))+s) * sigma_0 * sqrt( k^2-1 );
        %sigma        = k^(o*S+s-k_offset) * sigma_0 * sqrt( k^2-1 );
        sigma_opt    = sqrt( sigma^2 - sigma_n^2 );

        % create a separable kernel
        kernel_width = 1 + 2*floor(3*sigma_opt);
        h = fspecial('gaussian', [1 kernel_width], sigma_opt);

        % build the scale
        Ls{o+1,s+1} = conv2(h, h, I_previous, 'same');
    end
end

% unpad
for i=1:numel(Ls)
    I = Ls{i};  
    [M, N] = size(I);
    Ls{i} = I(0.25*M:0.75*M-1, 0.25*N:0.75*N-1);
end

% build Difference-of-Gaussian
DoG = cell(O, S - 1);
keypoints = {};
for o=1:O
    
    %imwrite(Ls{o,1}, sprintf('sift-scales/l-octave-%d-scale-%d.png', o, 1));
    for s=2:S
        DoG{o,s-1} = Ls{o,s} - Ls{o,s-1};
        
        %imwrite(Ls{o,s}, sprintf('sift-scales/l-octave-%d-scale-%d.png', o, s));
        %dog = (DoG{o,s-1}-min(min(DoG{o,s-1}))) / (max(max(DoG{o,s-1})) - min(min(DoG{o,s-1})));
        %imwrite(dog, sprintf('sift-scales/dog-octave-%d-scale-%d,%d.png', o, s,s-1));
    end
    
    for s=2:S-2
        d = DoG{o,s};
        [Y,X] = size(d);
        for y=2:Y-1
            for x=2:X-1
                p = d(y,x);
                n = [d(y-1,x-1), d(y-1,x), d(y-1,x+1), ...
                     d(y,x-1),             d(y,x+1), ...
                     d(y+1,x-1), d(y+1,x), d(y+1,x+1)];
                minimum = p < min(n);
                maximum = p > max(n);
                if ~minimum && ~maximum
                    continue;
                end
                
                d = DoG{o,s-1};
                n = [d(y-1,x-1), d(y-1,x), d(y-1,x+1), ...
                     d(y,x-1),             d(y,x+1), ...
                     d(y+1,x-1), d(y+1,x), d(y+1,x+1)];
                if (minimum && p >= min(n)) || (minimum && p > d(y,x)) || ...
                   (maximum && p <= max(n)) || (maximum && p < d(y,x))
                    fprintf('x: %4d, y:%4d, octave %d, scale %d: discarded at lower scale\n', ...
                            floor(x/X*W), floor(y/Y*H), o, s-1);
                    continue;
                end
                
                d = DoG{o,s+1};
                n = [d(y-1,x-1), d(y-1,x), d(y-1,x+1), ...
                     d(y,x-1),             d(y,x+1), ...
                     d(y+1,x-1), d(y+1,x), d(y+1,x+1)];
                if (minimum && p >= min(n)) || (minimum && p > d(y,x)) || ...
                   (maximum && p <= max(n)) || (maximum && p < d(y,x))
                    fprintf('x: %4d, y:%4d, octave %d, scale %d: discarded at higher scale\n', ...
                            floor(x/X*W), floor(y/Y*H), o, s-1);
                    continue;
                end
                
                fprintf('x: %4d, y:%4d, octave %d, scale %d: match!\n', ...
                            floor(x/X*W), floor(y/Y*H), o, s-1);
                keypoints{numel(keypoints)+1} = [x, y, o-1, s];
            end
        end
    end
    
end

%for i=1:numel(Ls)
%    figure, imshow(Ls{i})
%end

%for i=1:numel(DoG)
%    dog = (DoG{i}-min(min(DoG{i}))) / (max(max(DoG{i})) - min(min(DoG{i})));
%    figure, imshow(dog)
%end

figure, imshow(I0), axis image, hold on;
[Y, X] = size(I0);
for k=1:numel(keypoints)
    kp  = keypoints{k};
    pos = kp(1:2) * 2^(kp(3)-1);
    plot(pos(1), pos(2), 'r+', 'MarkerSize', 3)
end