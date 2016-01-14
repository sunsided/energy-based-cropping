sigma = 1;
mean  = 0;

x = -5*sigma:0.1:5*sigma;
y = gaussmf(x, [sigma mean]);

close all; figure; 
ax = axes; 

plot(x, y); hold on;
xlabel(sprintf('gaussian, \\mu = %.4f, \\sigma = %.4f', mean, sigma));

threeSigma = 3*sigma;
line([threeSigma threeSigma], get(ax,'YLim'), 'LineStyle', ':', 'Color', [1 0 0])
line([-threeSigma -threeSigma], get(ax,'YLim'), 'LineStyle', ':', 'Color', [1 0 0])