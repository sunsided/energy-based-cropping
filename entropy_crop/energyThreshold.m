function [ t, m, s ] = energyThreshold( J, subdivision )
%ENERGYTHRESHOLD Obtains the threshold for energy-based cropping

    if ~exist('subdivision', 'var')
        subdivision = 5;
    end

    [M, N]   = size(J);
    height   = floor(M/subdivision);
    width    = floor(N/subdivision);
    
    J_top    = J(1:height,:);
    J_bottom = J(N-height:N,:);
    J_left   = J(height:N-height-1, 1:width);
    J_right  = J(height:N-height-1, M-width-1:M);

    border_energies = [ reshape(J_top,1,[]), ...
                        reshape(J_bottom,1,[]), ...
                        reshape(J_left,1,[]), ...
                        reshape(J_right,1,[]) ];
    figure, hist(border_energies, 64)

    m = median(border_energies);
    s = std(border_energies);
    t = m + 4*s;

end

