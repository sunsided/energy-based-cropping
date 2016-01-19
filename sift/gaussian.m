sigma = 1;
mean  = 0;

x = -5*sigma:0.1:5*sigma;
y = gaussmf(x, [sigma mean]);
y2 = gaussmf(x, [2*sigma mean]);
%y3 = gaussmf(x, [1/sqrt(2) * sigma mean]);

close all; figure; 
ax = axes; 

plot(x, y, 'k'); hold on;
plot(x, y2, 'b');
%plot(x, y3, 'm');

grid on;
xlabel(sprintf('gaussian, \\mu = %.4f, \\sigma = %.4f', mean, sigma));

threeSigma = 1*sigma;
line([threeSigma threeSigma], get(ax,'YLim'), 'LineStyle', ':', 'Color', [1 0 0], 'LineWidth', 2)
line([-threeSigma -threeSigma], get(ax,'YLim'), 'LineStyle', ':', 'Color', [1 0 0], 'LineWidth', 2)
