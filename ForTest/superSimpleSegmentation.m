function [mask, img_bgsub] = superSimpleSegmentation(img,cellSize,minIntensityAboveBackground)

img = imfilter(img,fspecial('gaussian',floor(cellSize/4),floor(cellSize/8)));
bg = imopen(img,strel('disk',cellSize/2));
img_bgsub = imsubtract(img,bg);
mask = img_bgsub > minIntensityAboveBackground;
cellArea = pi*(cellSize/2)^2;
mask = bwareafilt(mask,[cellArea/3 cellArea*3]);

