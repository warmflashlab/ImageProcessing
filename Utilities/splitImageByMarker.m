function mask = splitImageByMarker(img,thresh,cleanUpRadius)

if ~exist('cleanUpRadius','var')
    cleanUpRadius = 10;
end

if ~exist('thresh','var')
    thresh = prctile(img(:),50); % use for background
end

img_sm = imfilter(img,fspecial('gaussian',cleanUpRadius,floor(cleanUpRadius/3)));
mask = img_sm > thresh;

mask = imclose(mask,strel('disk',cleanUpRadius));
mask = imopen(mask,strel('disk',cleanUpRadius));
