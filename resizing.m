w = 1009;
h = 514;

targetArea = 512^2;
aspectRatio = w/h;

w2 = sqrt(targetArea*aspectRatio)
h2 = w2/aspectRatio

[w3,h3] = simultResize(w,h, targetArea)