w = 1009;
h = 514;

targetArea = 640*480;
aspectRatio = w/h;

w2 = sqrt(targetArea*aspectRatio)
h2 = w2/aspectRatio

[w3,h3] = simultResize(w, h, targetArea)

original_area = w*h
our_area = w2*h2
algo_area = w3*h3

original_aspect = w/h
algo_aspect = w3/h3