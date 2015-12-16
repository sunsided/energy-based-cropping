close all;

%filename = '../../resources/images/source/7A5F52750ADD07483305B0C2226A484ED74B42FD4D87B4BBBC352DCF4E8D8BB8.jpg';
%filename = '../../resources/images/source/6A6E132456CE9AA651058B1608B77052B4B5E10F58EDD38ABE14B0CD46891A1D.png';
%filename = '../../resources/images/source/6513053600A14B930EDD7E5CDBED92EBB724676DA3F0EFDF3FD3F564743E14B4.png';
%filename = '../../resources/images/source/0A681D9ADB6193D1217E62A3A0E998EBE8E5C446B5D44CB5DBAC998B5B32B6DA.jpg';
filename = '../../resources/images/random/dino20riders.jpg';

img = imread(filename);

figA = figure;
imshow(img);

% conversion to grayscale
gray = rgb2gray(img);

% edge filtering
noEdgeGrayValue = 0;
edgeOffset = 3;
sobelX = [1 0 -1; 
          2 0 -2; 
          1 0 -1];
sobelY = sobelX';
      
Gx = conv2(sobelX, double(gray));
Gy = conv2(sobelY, double(gray));
G = sqrt(Gx.^2 + Gy.^2);

%{
noEdgeGrayValue = 0.569;
edgeOffset = 3;
G = 0.25 * conv2([1 2 1; 2 -12 2; 1 2 1], double(gray));
%}

minG = min(min(G));
maxG = max(max(G));
G = (G - minG) ./ (maxG - minG);

max(max(G))
min(min(G))

figure;
figB = imshow(G)

% Crop the image
height = size(G, 1);
width = size(G, 2);

topY   = (1+edgeOffset);
bottomY   = (height-edgeOffset);
leftX = (1+edgeOffset);
rightX = (width-edgeOffset);

bottommostTopY = (height-edgeOffset)
rightmostLeftX = (width-edgeOffset);

for y=topY:bottommostTopY
    done = false;
    for x=leftX:rightmostLeftX
        value = G(y, x);
        if value ~= noEdgeGrayValue
            topY = y;
            
            % since this is already a wall, leftX doesn't
            % need to scan further
            rightmostLeftX = x;
            done = true;
            break;
        end
    end
    if done
        break;
    end
end

topmostBottomY = topY + 1;
leftmostRightX = leftX+1;

for y=bottomY:-1:topmostBottomY
    done = false;
    for x=rightX:-1:leftmostRightX
        value = G(y, x);
        if value ~= noEdgeGrayValue
            bottomY = y;
            
            % since this is already a wall, leftX doesn't
            % need to scan further
            leftmostRightX = x;
            done = true;
            break;
        end
    end
    if done
        break;
    end
end

for x=leftX:rightmostLeftX
    done = false;
    for y=topY:bottommostTopY    
        value = G(y, x);
        if value ~= noEdgeGrayValue
            leftX = x;
            
            % there's no chance the leftmost bound
            % for rightX might have moved to the right
            % so no fix here.
            done = true;
            break;
        end
    end
    if done
        break;
    end
end

for x=rightX:-1:leftmostRightX
    done = false;
    for y=topY:bottommostTopY    
        value = G(y, x);
        if value ~= noEdgeGrayValue
            rightX = x;
            done = true;
            break;
        end
    end
    if done
        break;
    end
end

hold on;
rectangle('Position', [leftX, topY, rightX-leftX, bottomY-topY], 'EdgeColor','red', 'LineStyle', ':');

figure(figA);
hold on;
rectangle('Position', [leftX, topY, rightX-leftX, bottomY-topY], 'EdgeColor','red', 'LineStyle', ':', 'LineWidth', 2);

figure;
imshow(img(topY:bottomY, leftX:rightX, :));