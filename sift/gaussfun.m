deltaT  = 0.25;
t       = -10:deltaT:10;
sigma_1 = 2;
mu_1    = 0;

sigma_2 = 3;
mu_2    = 0;

g1 = normpdf(t, mu_1, sigma_1);
g2 = normpdf(t, mu_2, sigma_2);

g3 = conv(g1, g2, 'same') * deltaT;

close all; figure;
plot(t, g1, 'bo-'); hold on;
plot(t, g2, 'r*-');
plot(t, g3, 'g+-');

xlabel('t');
legend('g(\sigma_1)', 'g(\sigma_2)', 'g(\sigma_1) \ast g(\sigma_2)', 'Location', 'NorthEast');
title('Convolution of two gaussians');

% http://www.oxfordmathcenter.com/drupal7/node/296

std1 = sqrt( sum( t.^2.*g1 ) ) * deltaT^2 % explain where deltaT comes from
std2 = sqrt( sum( t.^2.*g2 ) ) * deltaT^2
std3 = sqrt( sum( t.^2.*g3 ) ) * deltaT^2

sqrt( std1^2 + std2^2 )
sqrt( sigma_1^2 + sigma_2^2 )