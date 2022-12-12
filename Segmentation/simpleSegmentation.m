function mask = simpleSegmentation(img,cellSize,minIntensity,filterSize)
% Very simple segmentation routine based on a local thresholding.
% Normalizes image to the dilation and thresholds using 0.9 of max
% Need to specify an object (cell) size 
% Can specifiy a minimum threshold for pixels to be included (optional)
% Returns a binary mask 

img_max = imdilate(img,strel('disk',cellSize));

img_local_max = imdivide(img,img_max);

if ~exist('minIntensity','var')
    minIntensity = 0;
end
mask = img_local_max > 0.9 & img > minIntensity;

if ~exist('filterSize','var')
    filterSize = true;
end

if filterSize
sizefilt = floor(pi*[(cellSize/2)^2, (10*cellSize)^2]);
mask = bwareafilt(mask,sizefilt);
end


