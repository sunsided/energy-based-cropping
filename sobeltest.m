img = imread('D:\dev\EigeneSources\ma\resources\images\gleam\1.png');
Gx = img;

sobelX = [1 0 -1]/2;
Gx = conv2(Gx, sobelX) + 127.5;
Gx_max = max(max(Gx))
Gx_min = min(min(Gx))

sobelX = [1; 2; 1]/4;
Gx = conv2(Gx, sobelX);
Gx_max = max(max(Gx))
Gx_min = min(min(Gx))

%{
sobelX = [1 0 -1; 
          2 0 -2; 
          1 0 -1]/8;
sobelY = [1 2 1; 
          0 0 0; 
         -1 -2 -1]/8;

Gx = conv2(img, sobelX) + 0.5;
Gy = conv2(img, sobelY) + 0.5;

Gx_max = max(max(Gx))
Gx_min = min(min(Gx))
Gy_max = max(max(Gy))
Gy_min = min(min(Gy))
%}

imshow(uint8(Gx))