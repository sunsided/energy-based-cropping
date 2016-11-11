clc; close all;

file = 'resources/images/source/screwdriver-cropped.jpg';
longest_edge = 255;

disp(['Longest edge:             ' num2str(longest_edge)])
disp(['Maximum pixel count:      ' num2str(longest_edge*longest_edge)])

I = imread(file);
% I = imresize(I, 2); % <-- fun stuff if the original image is too small for testing
[h, w, channels] = size(I);

disp(['Original size:            ' num2str(w) 'x' num2str(h)])
disp(['Original pixel count:     ' num2str(h*w)])

% area resize
[w2, h2] = simultResize(w, h, longest_edge^2);
I3 = imresize(I, [h2, w2]);

disp(['Area resized size:        ' num2str(floor(w2)) 'x' num2str(floor(h2))])
disp(['Area resized pixel count: ' num2str(h2*w2)])

% longest edge resize
if h > w
    w = w*longest_edge/h;
    h = longest_edge;
    I2 = imresize(I, [h, w]);
else
    h = h*longest_edge/w;
    w = longest_edge;
    I2 = imresize(I, [h, w]);
end

disp(['Longest edge resize size: ' num2str(floor(w)) 'x' num2str(floor(h))])
disp(['Longest edge pixel count: ', num2str(h*w)])

figure, imshow(I), title('original image')
figure, imshow(I2), title('resized by longest edge')
figure, imshow(I3), title('area normalization')
