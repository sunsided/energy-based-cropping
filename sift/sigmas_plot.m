clear all;

n_spo     = 3;                                  % the number of DoG scales per octave
n_oct     = 4;                                  % the number of octaves
sigma_min = 0.8;                                % 
delta_min = 0.5;                                % initial inter-pixel distance
sigma_in  = 0.5;                                % input image intrinsic sigma

% compare  k = 2^(1/n_spo);
sigma = @(s) sigma_min/delta_min * sqrt( 2^(2*s/n_spo) - 2^(2*(s-1)/n_spo) );

apply_sigma     = @(s, s0) sqrt( s^2 +  s0^2 );

oct   = @(i) i+1;
scale = @(i) i+1;

sigmas = nan( n_oct, 1+n_spo+2 );

%{

    For display purposes, the simulated standard deviations are normalized
    to delta=1 which represents input image inter-pixel distance.
    Note that by reduction of the image by factor 2 in each dimension,
    i.e. subsampling by factor 2, the observed sigma doubles, since
    the distribution function now covers twice as many pixels per
    dimension.

%}

% octave 0
delta = delta_min; % because delta=delta_min*2^o for o=0
sigma_0 = sqrt(sigma_min^2 - sigma_in^2)/delta_min;
sigmas(oct(0), scale(0)) = apply_sigma( delta*sigma_0, sigma_in );
for s=1:n_spo+2
    % Note: see above about the delta coefficient
    sigmas(oct(0), scale(s)) = apply_sigma( delta*sigma(s), sigmas(oct(0), scale(s-1)) );
end

% octave 1..n
for o=1:n_oct
    delta = delta_min * 2^o;
    sigmas(oct(o), scale(0))     = sigmas(oct(o-1), scale(n_spo));
    for s=1:n_spo+2
        % Note: see above about the delta coefficient
        sigmas(oct(o), scale(s)) = apply_sigma( delta*sigma(s), sigmas(oct(o), scale(s-1)) );
    end
end

%sigmas = round(sigmas*1E2)*1E-2
sigmas