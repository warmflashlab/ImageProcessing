function mask = simpleSegmentation(img,cellSize,minIntensity)

%img_sm = smoothImage(img,floor(cellSize/3),floor(cellSize/6));

img_max = imdilate(img,strel('disk',cellSize));

img_local_max = imdivide(img,img_max);

if ~exist('minIntensity','var')
    minIntensity = 0;
end
mask = img_local_max > 0.9 & img > minIntensity;

sizefilt = floor(pi*[(cellSize/2)^2, (10*cellSize)^2]);

mask = bwareafilt(mask,sizefilt);


