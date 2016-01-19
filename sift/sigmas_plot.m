clear all;

n_spo     = 3;                                  % the number of DoG scales per octave
n_oct     = 4;                                  % the number of octaves
sigma_min = 0.8;                                % 
delta_min = 0.5;                                % initial inter-pixel distance
sigma_in  = 0.5;                                % input image intrinsic sigma
%S        = 1+n_spo+2;                          % then umber of required scales

% compare  k = 2^(1/n_spo);
sigma = @(s) sigma_min/delta_min * sqrt( 2^(2*s/n_spo) - 2^(2*(s-1)/n_spo) );

% compare Anatomy of SIFT
derp = @(d,s)d/delta_min*sigma_min*sqrt( ...
              (d/delta_min*sigma_min*2^(s/n_spo))^2 + ...
              (d/delta_min*sigma_min*2^((s-1)/n_spo))^2 );
derp(0,0),          derp(0,1)
derp(1,0-1*n_spo),  derp(1,1-1*n_spo)
derp(2,0-2*n_spo),  derp(2,1-2*n_spo)

apply_to_seed   = @(s) delta_min * sqrt( s^2 + (sigma_in/delta_min)^2 );
apply_sigma_1   = @(o, s, s0) (delta_min*2^o)/delta_min*sigma_min * sqrt( s^2 +  s0^2 );
apply_sigma_2   = @(o, s, s0)                                       sqrt( s^2 +  s0^2 );

oct   = @(i) i+1;
scale = @(i) i+1;

deltas = nan( n_oct, 1+n_spo+2 );
sigmas = nan( n_oct, 1+n_spo+2 );

% octave 0
sigmas(oct(0), scale(0)) = apply_to_seed( sqrt(sigma_min^2 - sigma_in^2) / delta_min );
for s=1:n_spo+2
    sigmas(oct(0), scale(s)) = apply_sigma_1(0, sigma(s-1), sigmas(oct(0), scale(s-1)) );
end

% octave 1...n_oct
for o=1:n_oct
    sigmas(oct(o), scale(0))     = sigmas(oct(o-1), scale(n_spo));
    for s=1:n_spo+2
        sigmas(oct(o), scale(s)) = apply_sigma_2(o, sigma(s), sigmas(oct(o), scale(s-1)) );
    end
end

sigmas