function [ box ] = findBoundingBox( I, threshold, level, offset )
%FINDBOUNDINGBOX Finds the bounding box of the image content

    [M, N] = size(I);
    top  = 1 + offset;    
    left = 1 + offset;
    right = N - offset;
    bottom = M - offset;
    
    % find top-most row
    y_top = NaN;
    for y=top:bottom
        for x=left:right
            if abs(I(y,x)-level) < threshold; 
                continue;
            end
            y_top = y;
            break;
        end
        if ~isnan(y_top)
            break;
        end
    end
    
    if isnan(y_top)
        % in this case, the whole image was croppped
        box = [ 1, 1, M, N ];
        return;
    end
    
    % find bottom-most row
    y_bottom = NaN;
    for y=bottom:-1:y_top
        for x=left:right
            if abs(I(y,x)-level) < threshold
                continue;
            end
            y_bottom = y;
            break;
        end
        if ~isnan(y_bottom)
            break;
        end
    end
    
    % find left-most column
    x_left = right;
    for y=y_top:y_bottom
        x = left;
        while x <= x_left
            if abs(I(y,x)-level) >= threshold
                x_left = x;
            end
            
            x = x+1;
            if x_left == left
                break;
            end
        end
        if x_left == left
            break;
        end
    end
    
    % find left-most column
    x_right = left;
    for y=y_top:y_bottom
        x = right;
        while x >= x_right
            if abs(I(y,x)-level) >= threshold
                x_right = x;
            end
            
            x = x-1;
            if x_right == right
                break;
            end
        end
        if x_right == right
            break;
        end
    end
    
    box = [x_left, y_top, x_right, y_bottom];
end

