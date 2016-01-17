clear all;

s                     = 3;
k                     = 2^(1/s);
sigma_0               = 1.6;
P                     = s+3;

sigma_current         = sigma_0;
sigma_total(1)        = sigma_current;

for p=0:(P-1)
    sigma_direct      = k^p * sigma_0;
    
    sigma             = k^p * sigma_0 * sqrt( k^2 - 1 );
    sigma_next        = sqrt( sigma^2 + sigma_current^2 );

	direct_sigma(p+1) = sigma_direct;
    relative_sigma(p+1) = sigma;
    sigma_total(p+1)  = sigma_current;
    sigma_current = sigma_next;
end

direct_sigma, sigma_total, relative_sigma