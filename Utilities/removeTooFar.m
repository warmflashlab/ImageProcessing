function cleanmask = removeTooFar(mask,pixelradius)

cc = regionprops(mask,'Centroid','PixelIdxList');
xy = stats2xy(cc);
xy_avg = mean(xy);
diff = bsxfun(@minus,xy,xy_avg);
dist = sqrt(sum(diff.*diff,2));

cc(dist > 1.1*pixelradius) = [];

cleanmask = false(size(mask));
cleanmask(cat(1,cc.PixelIdxList))=true;