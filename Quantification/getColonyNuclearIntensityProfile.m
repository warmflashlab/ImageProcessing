function image1_nuclear_avg = getColonyNuclearIntensityProfile(images, nuclearMask, meta, tooHighIntensity)
% colony pixel profile

filterSize = floor(5*10/meta.xres); % 5 cell diameters
filter1 = ones(filterSize);
%channel_nuclear_avg = zeros(meta.xSize, meta.ySize, size(images,3));
nuclear_pixels = imfilter(double(nuclearMask), filter1); % number of nuclear pixels in the neighbourhood.



for ii = 1:size(images,3)
    image1 = images(:,:,ii);
    image1(image1>tooHighIntensity) = 0;
    image1 = medfilt2(image1,[5 5]); % removes small bright pixels
    image1_nuclear_cast = bsxfun(@times,image1, cast(nuclearMask,class(image1))); % nuclear cast
    image1_nuclear_nSum = imfilter(double(image1_nuclear_cast), filter1); % neighbourhood sum
    image1_nuclear_avg(:,:,ii) = double(image1_nuclear_nSum)./double(nuclear_pixels);
    image1_nuclear_avg(isnan(image1_nuclear_avg)) = 0;
end