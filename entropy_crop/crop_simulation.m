close all;

N = 256;                    % border length
I = ones(N, N);             % white background
I = cumsum(ones(N)/N, 2);
I = toeplitz(1:N)/N;
I(32:224, 32:224) = 0.9375; % light gray box
I(64:192, 32:224) = 0.875;  % light gray box
I(64:192, 32:224) = 0.875;  % light gray box
I(64:192, 64:192) = 0.75;   % light gray box
I(96:160, 64:192) = 0.5;    % light gray box
I(96:160, 96:160) = 0;      % black box

tI = 0.15;                   % threshold value
tJ = 0.22;                   % threshold value

N_meas = 1000;
distances = nan(N_meas, 2);
P = [32, 32, 224, 224];

for i=1:N_meas

    E = 0.05*randn(N);          % zero-mean noise with s=0.05
    Ie = abs(I + E);            % apply the noise to the image
    Ie(Ie>1) = 1;
    Ie(Ie<0) = 0;

    Gx = conv2(Ie, 0.125*[-1 0 1; -2 0 2; -1 0 1]);
    Gy = conv2(Ie, 0.125*[-1 -2 -1; 0 0 0; 1 2 1]);
    J = abs(Gx) + abs(Gy);
    J = J(1+2:N, 1+2:N);

    %vI = Ie(1,1);               % candidate value
    %boxI = findBoundingBox(Ie, tI, vI, 0);
    
    [t,vI,tI] = energyThreshold(Ie, 6);
    boxI = findBoundingBox(Ie, sqrt(tI), vI, 0);

    J = (J-min(J(:)))/(max(J(:))-min(J(:)));
%    vJ = 0;                     % candidate value

    tJ = energyThreshold(J);    % threshold value
    vJ = 0;                     % candidate value
    boxJ = findBoundingBox(J, tJ, vJ, 0);

    distances(i, 1) = sum((boxI - P).^2); % norm(boxI-P)^2
    distances(i, 2) = sum((boxJ - P).^2); % norm(boxI-P)^2
    
end

distance_mean = mean(distances)
distance_std  = std(distances)