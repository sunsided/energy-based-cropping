sequence = [1 1 1 1 0 0 0 1 1 0 0 1];
kernel   = [1 0 -1];
filtered = conv(sequence, kernel);

padded   = [nan, sequence, nan];
padded2  = [0, sequence, 0];

close all;

figure;
subplot(4, 1, 1);
stem(padded);
axis image;
xlim([0.5, 14.5]);
ylim([0, 1]);
ylabel('f(x)');
title('Input sequence');

subplot(4, 1, 3);
image(255 - (padded2 * 255));
ylabel('f(x)');
title('Input sequence');

subplot(4, 1, 4);
image(255 - (filtered * 128 + 127), 'CDataMapping','scaled');
ylabel('\Delta f(x)');
title('Filtered sequence');
xlabel('x');

subplot(4, 1, 2);
stem(filtered, 'r');
xlim([0.5, 14.5]);
ylabel('\Delta f(x)');
title('Filtered sequence');

colormap bone