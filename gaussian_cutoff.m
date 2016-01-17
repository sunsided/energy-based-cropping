clear all;
g = @(x,s) 1/(s*sqrt(2*pi)) .* exp(-(x.^2)/(2*s^2));

s_range = 1e-5:0.01:10;
s_results = nan(numel(s_range),4);
i = 0;

for s=s_range
    i = i+1;
    s_results(i,1) = g(1*s,s);
    s_results(i,2) = g(3*s,s);
    s_results(i,3) = g(6*s,s);
    s_results(i,4) = g(9*s,s);
end

close all;
figure;
loglog(s_range, s_results(:,1), 'k'); hold on;
loglog(s_range, s_results(:,2), 'r');
loglog(s_range, s_results(:,3), 'b');
loglog(s_range, s_results(:,4), 'm');