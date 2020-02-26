function maxIntensityImage = MakeMaxZImage(fileReader, channels, timepoint,  z_Range, nSeries)
%% returns the maximum z projection for specified channels(>=1) and timepoints(1) for
%a given image.


% channels : channelID for which you want to make max z projection
% timepoint: time point for which you want to do the same.
% z_Range specifies z slices to be considered for max z projection
% nSeries: position for which you want to do the same.

if ~exist('nSeries', 'var')
    nSeries = 0;
end
fileReader.setSeries(nSeries);

% preallocating cell array that stores max_intensity images for each channel.
% Within each channel max_intensity images for each time point are stored.
% max_intensity_image(:,:,channel)
maxIntensityImage = uint16(zeros(1024,1024,numel(channels)));

if ~exist('z_Range', 'var')
    z_Range = 1:fileReader.getSizeZ; % z slices to be considered for the max z projection
end

counter = 1;
for ii = channels
    maxIntensityImage1 = [];
    for jj = z_Range
        iplane = fileReader.getIndex(jj-1, ii-1, timepoint-1)+1; %[zPlane channel timePoint]
        image1 = bfGetPlane(fileReader, iplane);
        
        if ii == channels(1)
            maxIntensityImage = uint16(zeros(size(image1,1), size(image1, 2), numel(channels)));
        end
        
        if jj == z_Range(1)
            maxIntensityImage1 = image1;
        else
            maxIntensityImage1 = max(image1, maxIntensityImage1);
        end
    end
    maxIntensityImage(:,:,counter) = maxIntensityImage1;
    counter = counter+1;
end
end
