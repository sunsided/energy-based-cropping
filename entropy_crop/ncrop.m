%filename = '../resources/images/source/7A5F52750ADD07483305B0C2226A484ED74B42FD4D87B4BBBC352DCF4E8D8BB8.jpg';
filename = '../resources/images/source/0A681D9ADB6193D1217E62A3A0E998EBE8E5C446B5D44CB5DBAC998B5B32B6DA.jpg';
img = imread(filename);

% conversion to grayscale
gray = rgb2gray(img);
imshow(gray);

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
imshow(G)

% Crop the image
height = size(G, 1);
width = size(G, 2);

topY   = (1+edgeOffset);
for y=topY:(height-edgeOffset)
    done = false;
    for x=(1+edgeOffset):(width-edgeOffset)
        value = G(y, x);
        if value ~= noEdgeGrayValue
            topY = y;
            done = true;
            break;
        end
    end
    if done
        break;
    end
end


bottomY   = (height-edgeOffset);
for y=bottomY:-1:(1+edgeOffset)
    done = false;
    for x=(1+edgeOffset):(width-edgeOffset)
        value = G(y, x);
        if value ~= noEdgeGrayValue
            bottomY = y;
            done = true;
            break;
        end
    end
    if done
        break;
    end
end

leftX = (1+edgeOffset);
for x=leftX:(width-edgeOffset)
    done = false;
    for y=topY:bottomY
        value = G(y, x);
        if value ~= noEdgeGrayValue
            leftX = x;
            done = true;
            break;
        end
    end
    if done
        break;
    end
end

rightX = (width-edgeOffset);
for x=rightX:-1:leftX
    done = false;
    for y=topY:bottomY
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
rectangle('Position', [leftX, topY, rightX-leftX, bottomY-topY], 'EdgeColor','red');