close all; clear all; clc;

%filename = '../resources/images/source/7A5F52750ADD07483305B0C2226A484ED74B42FD4D87B4BBBC352DCF4E8D8BB8.jpg';
%filename = '../resources/images/test-images/lena.png';
%filename = '../resources/images/test-images/troete-sw.jpg';
filename = '../resources/images/test-images/circle.png';

I_input = double( imread(filename) )./255;      % load image and normalize to 0..1
I_input = sum( I_input.^(1/2.2), 3)/3;          % grayscale conversion by gleam
I_input = imresize(I_input, 0.5, 'bilinear');   % downsample image for speed
[H,W] = size(I_input); minI = min(I_input(:)); maxI = max(I_input(:));
I_input = (I_input-minI)/(maxI-minI);           % stretch the histogram

% Scale-space extrema detection
n_spo     = 3;                                  % the number of DoG scales per octave
n_oct     = 5;                                  % the number of octaves
sigma_min = 0.8;                                % 
delta_min = 0.5;                                % initial inter-pixel distance
sigma_in  = 0.5;                                % input image intrinsic sigma
C_dog     = (2^(1/n_spo)-1)/(2^(1/3)-1)*0.015;  % DoG contrast threshold with C_dog=0.015 for n_spo=3
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
disp('Building scales in octave 0 ...');
sigma_0 = sqrt(sigma_min^2 - sigma_in^2) / delta_min;
h = fspecial('gaussian', [1 1+2*floor(3*sigma_0)], sigma_0);
L{oct(0), sca(0)} = conv2(h, h, I_seed, 'same');

for s=1:n_spo+2
    sigma_s = sigma(s);
    h = fspecial('gaussian', [1 1+2*floor(3*sigma_s)], sigma_s);
    L{oct(0), sca(s)} = conv2(h, h, L{oct(0), sca(s-1)} , 'same');
end

% octave 1..n
for o=1:n_oct-1
    disp(['Building scales in octave ' num2str(o) ' ...']);
    
    % downsample the previous octave's image with 2*sigma of L{oct(o-1), sca(0)}
    L{oct(o), sca(0)} = imresize(L{oct(o-1), sca(n_spo)}, 0.5, 'nearest');
    for s=1:n_spo+2
        sigma_s = sigma(s);
        h = fspecial('gaussian', [1 1+2*floor(3*sigma_s)], sigma_s);
        L{oct(o), sca(s)} = conv2(h, h, L{oct(o), sca(s-1)} , 'same');
    end
end

% unpad
for e=1:numel(L)
    I_seed = L{e};  [M, N] = size(I_seed);
    L{e} = I_seed(floor(0.25*M):floor(0.75*M-1), floor(0.25*N):floor(0.75*N-1));
end

% build Difference-of-Gaussian
DoG = cell(n_oct, n_spo+2);
extrema = {};
for o=0:n_oct-1
    disp(['Detection in octave ' num2str(o) ' ...']);
    delta = delta_min * 2^o;
    
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
                
                dl = DoG{oct(o),sca(s-1)};
                n = [dl(y-1,x-1), dl(y-1,x), dl(y-1,x+1), ...
                     dl(y,x-1),              dl(y,x+1), ...
                     dl(y+1,x-1), dl(y+1,x), dl(y+1,x+1)];
                if (minimum && p >= min(n)) || (minimum && p > dl(y,x)) || ...
                   (maximum && p <= max(n)) || (maximum && p < dl(y,x))
                    %fprintf('x: %4d, y:%4d, octave %d, scale %d: discarded at lower scale\n', ...
                    %        floor(x/X*W), floor(y/Y*H), o, s-1);
                    continue;
                end
                
                dh = DoG{oct(o),sca(s+1)};
                n = [dh(y-1,x-1), dh(y-1,x), dh(y-1,x+1), ...
                     dh(y,x-1),              dh(y,x+1), ...
                     dh(y+1,x-1), dh(y+1,x), dh(y+1,x+1)];
                if (minimum && p >= min(n)) || (minimum && p > dh(y,x)) || ...
                   (maximum && p <= max(n)) || (maximum && p < dh(y,x))
                    %fprintf('x: %4d, y:%4d, octave %d, scale %d: discarded at higher scale\n', ...
                    %        floor(x/X*W), floor(y/Y*H), o, s-1);
                    continue;
                end
                
                %fprintf('x: %4d, y:%4d, octave %d, scale %d: match!\n', 
                %            floor(x/X*W), floor(y/Y*H), o, s-1);
                        
                % low contrast suppression
                if abs(p) < (0.8*C_dog)
                    %fprintf(' -> discarded keypoint due to low contrast.\n');
                    continue;
                end
                  
                extrema{numel(extrema)+1} = [x, y, o, s];
            end
        end
    end
    
end

disp(['Refining ' num2str(numel(extrema)) ' found extrema ...']);
keypoints = {};
for e=1:numel(extrema)
    
    extremum = extrema{e};
    x = extremum(1); y = extremum(2);
    o = extremum(3); s = extremum(4);
    
    for i=1:5
        % ensure scale is in range
        s = min(max(s, 1), n_spo-1);
        
        % select the DoG scales
        dh = DoG{oct(o), sca(s+1)};
        d  = DoG{oct(o), sca(s)};
        dl = DoG{oct(o), sca(s-1)};
        
        % ensure coordinates are in range
        [Y, X] = size(d);
        x = min(max(x, 2), X-1);
        y = min(max(y, 2), Y-1);
        
        % determination of the Hessian
        h11 = dh(y,x)  + dl(y,x)  - 2*d(y,x);
        h22 = d(y,x+1) + d(y,x-1) - 2*d(y,x);
        h33 = d(y+1,x) + d(y-1,x) - 2*d(y,x);
        h12 = 0.25*(dh(y,x+1)  - dh(y,x-1)  - dl(y,x+1)  + dl(y,x-1));
        h13 = 0.25*(dh(y+1,x)  - dh(y-1,x)  - dl(y+1,x)  + dl(y-1,x));
        h23 = 0.25*(d(y+1,x+1) - d(y-1,x+1) - d(y+1,x-1) + d(y-1,x-1));

        H = [ h11, h12, h13;
              h12, h22, h23;
              h13, h23, h33 ];

        % 3D gradient
        g = [ 0.5*( dh(y,x)  - dl(y,x)  );
              0.5*( d(y,x+1) - d(y,x-1) );
              0.5*( d(y+1,x) - d(y-1,x) ) ];

        % calculate maximum of fitted 3D quadratic surface
        alpha = -H\g; % = -inv(H)*g;
        if max(isnan(alpha)) == 1
            break;
        end
        
        % refine candidate position
        candidate = [ ...
            delta*(alpha(2)+x), ...
            delta*(alpha(3)+y), ...
            o, ...
            delta/delta_min*sigma_min * 2^((alpha(1)+s)/n_spo) ];

        if isnan(max(alpha)) || max(abs(alpha)) >= 0.6
            % refine the working point, then try again
            s = round(s + alpha(1));
            x = round(x + alpha(2));
            y = round(y + alpha(3));
            continue;
        end
        break;
    end

    % calculate maximum of fitted 3D quadratic surface
    if max(isnan(alpha)) == 1 || max(abs(alpha)) >= 0.6
        %fprintf(' -> discarded candidate because refinement failed.\n');
        continue;
    end
    
    % TODO: Refine with 2D hessian to detect edges
    
    keypoints{numel(keypoints)+1} = candidate;
end

disp(['Found ' num2str(numel(keypoints)) ' keypoints ...']);

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
    pos = kp(1:2) * 2^(o-n_oct+1);
    
    if pos(1) > X || pos(1) < 0 || pos(2) > Y || pos(2) < 0
        disp(['Keypoint out of bounds: ' mat2str(pos) ' of ' mat2str([X Y])]);
    end
    
    plot(pos(1), pos(2), 'r+', 'MarkerSize', 3)
end