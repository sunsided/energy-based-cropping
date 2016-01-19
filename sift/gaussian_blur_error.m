function [ SSE ] = gaussian_blur_error( Iinput, Iref, sigma )

    sigma = abs(sigma);

    % subsample
    I = imresize(Iinput, 0.5, 'nearest');

    % apply the kernel
    h = fspecial('gaussian', [1 ceil(6*sigma)], sigma);
    I = conv2(h, h, I, 'same');

    % calculate the error
    Iref = imresize(Iref, 0.5, 'nearest');
    SSE = sum(sum((Iref - I).^2));

end

