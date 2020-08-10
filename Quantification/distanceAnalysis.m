function distanceData = distanceAnalysis(img,chan,opts)

bins = [0 1:20:500]; %include zero bin for normalization
nbins = length(bins)-1;

if ~exist('chan','var')
    chan = 1;
end

nchan = size(img,3);

imgToUse = squeeze(img(:,:,chan));

if exist('opts','var') && isfield(opts,'threshold')
    thresh = opts.threshold;
else
    thresh = prctile(imgToUse(:),50);
end

if exist('opts','var') && isfield(opts,'cleanUpRadius')
    cUR = opts.cleanUpRadius;
else
    cUR = 10;
end

mask = splitImageByMarker(imgToUse,thresh,cUR);

dists = bwdist(mask);
distanceData = zeros(nbins,nchan);

for ii = 1:(length(bins)-1)
    pix = dists >= bins(ii) & dists < bins(ii+1);
    for jj = 1:nchan
        imgToQuantify = squeeze(img(:,:,jj));
        distanceData(ii,jj) = mean(imgToQuantify(pix));
    end
end
