function filteredImage = smoothAndBackgroundSubtractOneImage(rawImage, smoothFilterRadius)
% removes noise by applying a gaussian filter. 
% subtracts background. 
% ----- works for one image -----

%NOTE: pixel size for bg is hard-coded. should be variable. 

%%
%image1 = imgaussfilt(rawImage,[0.5 0.5]); % [mean std] gaussian filter;
%10X image [0.5 0.5], 20X image [2 1] work fine;\
if ~exist('smoothFilterRadius', 'var')
    sf = 0.5;
else
    sf = smoothFilterRadius;
end
image1 = imgaussfilt(rawImage,[sf, sf]);
%removes noise

pixelSize = 100;
image2 = imopen(image1, strel('disk', pixelSize));
% erosion  removes objects - assuming they are all < pixel size. 
% dilation enhances background.
%figure; imshow(image2,[]); max(max(image2));
filteredImage = imsubtract(image1, image2);
end
