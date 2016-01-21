close all; clear all; clc;

%filename = '../../resources/images/source/7A5F52750ADD07483305B0C2226A484ED74B42FD4D87B4BBBC352DCF4E8D8BB8.jpg';
%filename = '../../resources/images/test-images/lena.png';
%filename = '../../resources/images/test-images/troete-sw.jpg';
filename = '../../resources/images/test-images/circle.png';

I_input = double( imread(filename) )./255;      % load image and normalize to 0..1
I_input = sum( I_input.^(1/2.2), 3)/3;          % grayscale conversion by gleam
I_input = imresize(I_input, 0.5, 'bilinear');   % downsample image for speed
[H,W] = size(I_input); minI = min(I_input(:)); maxI = max(I_input(:));
I_input = (I_input-minI)/(maxI-minI);           % stretch the histogram

% Scale-space extrema detection
n_spo     = 3;                                  % the number of DoG scales per octave
n_oct     = 4;                                  % the number of octaves
sigma_min = 0.8;                                % 
delta_min = 0.5;                                % initial inter-pixel distance
sigma_in  = 0.5;                                % input image intrinsic sigma
L         = cell(n_oct, 1+n_spo+2);             % the array containing the scales

sigma = @(s) sigma_min/delta_min * sqrt( 2^(2*s/n_spo) - 2^(2*(s-1)/n_spo) );

oct = @(idx) idx+1;
sca = @(idx) idx+1;

% pre-process according to the paper
I_seed = I_input;
I_seed = imresize(I_seed, 2, 'nearest');         % preprocessing: upsample

% border padding to aid the convolution kernel at the image edges
I_seed = padarray(I_seed, 0.5*size(I_seed), 'replicate');

% octave 0
sigma_0 = sqrt(sigma_min^2 - sigma_in^2) / delta_min;
h = fspecial('gaussian', [1 1+2*floor(3*sigma_0)], sigma_0);
L{oct(0), sca(0)} = conv2(h, h, I_seed, 'same');

for s=1:n_spo+2
    sigma_s = sigma(s);
    h = fspecial('gaussian', [1 1+2*floor(3*sigma_s)], sigma_s);
    L{oct(0), sca(s)} = conv2(h, h, L{oct(0), sca(s-1)} , 'same');
end

% octave 1..n
for o=1:n_oct
    % downsample the previous octave's image with 2*sigma of L{oct(o-1), sca(0)}
    L{oct(o), sca(0)} = imresize(L{oct(o-1), sca(n_spo)}, 0.5, 'nearest');
    for s=1:n_spo+2
        sigma_s = sigma(s);
        h = fspecial('gaussian', [1 1+2*floor(3*sigma_s)], sigma_s);
        L{oct(o), sca(s)} = conv2(h, h, L{oct(o), sca(s-1)} , 'same');
    end
end

% unpad
for i=1:numel(L)
    I_seed = L{i};  
    [M, N] = size(I_seed);
    L{i} = I_seed(0.25*M:0.75*M-1, 0.25*N:0.75*N-1);
end

% build Difference-of-Gaussian
DoG = cell(n_oct, n_spo+2);
keypoints = {};
for o=0:n_oct
    
    %imwrite(Ls{o,1}, sprintf('sift-scales/l-octave-%d-scale-%d.png', o, 1));
    for s=1:n_spo+2
        DoG{oct(o),sca(s-1)} = L{oct(o),sca(s)} - L{oct(o),sca(s-1)};
        
        %imwrite(L{oct(o),sca(s)}, sprintf('sift-scales/l-octave-%d-scale-%d.png', o, s));
        %dog = (DoG{oct(o),sca(s-1)}-min(min(DoG{oct(o),sca(s-1)}))) / (max(max(DoG{oct(o),sca(s-1)})) - min(min(DoG{oct(o),sca(s-1)})));
        %imwrite(dog, sprintf('sift-scales/dog-octave-%d-scale-%d,%d.png', o, s,s-1));
    end
    
    for s=1:n_spo
        d = DoG{oct(o),sca(s)};
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
                
                d = DoG{oct(o),sca(s-1)};
                n = reshape( d(y-1:y+1,x-1:x+1), 1, []);
                if (minimum && (p > min(n))) || (maximum && (p < max(n)))
                    fprintf('x: %4d, y:%4d, octave %d, scale %d: discarded at lower scale\n', ...
                            floor(x/X*W), floor(y/Y*H), o, n_spo-1);
                    continue;
                end
                
                d = DoG{oct(o),sca(n_spo+1)};
                n = reshape( d(y-1:y+1,x-1:x+1), 1, []);
                if (minimum && (p > min(n))) || (maximum && (p < max(n)))
                    fprintf('x: %4d, y:%4d, octave %d, scale %d: discarded at higher scale\n', ...
                            floor(x/X*W), floor(y/Y*H), o, n_spo-1);
                    continue;
                end
                
                fprintf('x: %4d, y:%4d, octave %d, scale %d: match!\n', ...
                            floor(x/X*W), floor(y/Y*H), o, n_spo-1);
                keypoints{numel(keypoints)+1} = [x, y, o-1, n_spo];
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

figure, imshow(I_input), axis image, hold on;
[Y, X] = size(I_input);
for k=1:numel(keypoints)
    kp  = keypoints{k};
    o   = kp(3);
    pos = kp(1:2) * 2^o;
    plot(pos(1), pos(2), 'r+', 'MarkerSize', 3)
end