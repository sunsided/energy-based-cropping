function [ w, h ] = simultResize( w, h, targetArea )
    aspectRatio = w/h;
    w = sqrt(targetArea*aspectRatio);
    h = w/aspectRatio;
end

