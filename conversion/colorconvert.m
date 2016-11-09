close all;

filename = '../resources/images/random/20130821-122721-_DSC4684.jpg';

gamma = 2.2;
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);

img = double(imread(filename))/255.0;
figure, imshow(img);
title('RGB');
imwrite(img, 'rgb.jpg');

intensity = 1/3 * (R + G + B);
figure, imshow(intensity);
title('Intensity');
imwrite(intensity, 'intensity.jpg');
J_intensity = entropy(intensity)

gleam = 1/3 * (R.^(1/gamma) + G.^(1/gamma) + B.^(1/gamma));
figure, imshow(gleam);
title('Gleam');
imwrite(gleam, 'gleam.jpg');
J_gleam = entropy(gleam)

value = max( img, [], 3 );
figure, imshow(value);
title('Value');
imwrite(value, 'value.jpg');
J_value = entropy(value)

luster = 0.5 * ( min( img, [], 3 ) + max( img, [], 3 ) );
figure, imshow(luster);
title('Luster');
imwrite(luster, 'luster.jpg');
J_luster = entropy(luster)

luminance = 0.299*R + 0.587*G + 0.114*B;
figure, imshow(luminance);
title('Luminance');
imwrite(luminance, 'luminance.jpg');
J_luminance = entropy(luminance)

luma = 0.2126*R.^(1/gamma) + 0.7152*G.^(1/gamma) + 0.0722*B.^(1/gamma);
figure, imshow(luma);
title('Luma');
imwrite(luma, 'luma.jpg');
J_luma = entropy(luma)

hybrid = 0.5 * (gleam + luster);
figure, imshow(hybrid);
title('Hybrid');
imwrite(hybrid, 'hybrid.jpg');
J_hybrid = entropy(hybrid)

Y = 0.2126*R + 0.7152*G + 0.0722*B;

Y(Y >  (6/29)^3) = Y(Y >  (6/29)^3).^(1/3);
Y(Y <= (6/29)^3) = Y(Y <= (6/29)^3) * (1/3)*(29/6)^2 + (4/29);

lightness = (1/100) * (116 * Y - 16);
figure, imshow(lightness);
title('Lightness');
imwrite(lightness, 'lightness.jpg');
J_lightness = entropy(lightness)