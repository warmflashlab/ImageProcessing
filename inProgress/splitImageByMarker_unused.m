function mask = splitImageByMarker(img,thresh)

img_sm = imfilter(img,fspecial('gaussian',10,3));

if ~exist('thresh','var')
    thresh = prctile(img_sm(:),20); % use for background
end

si = size(img_sm);

mask = false(si);

lastind = zeros(si(1),1);
for ii = 1:si(1)
    vals = img_sm(ii,:);
    othresh = vals > thresh;
    cs = cumsum(othresh,'reverse')./(si(2):-1:1);
    lastind(ii) = find(cs < 0.03,1);
    mask(ii,1:lastind(ii)) = true;
end


