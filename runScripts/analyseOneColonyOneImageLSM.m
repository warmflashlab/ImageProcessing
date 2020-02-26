%% Script for analyzing LSM colony - based on SC script

% template file - quantify nuclear signal in all channels in one .oif file
% (one file corresponds to one colony in one image)
%%
masterFolder = '/Volumes/SAPNA/190522_sox2ReporterCells';
rawFile = [masterFolder filesep 'imaging1/rawData/Track0001/Image0001_01.oif']; % raw file
channelNames = {'DAPI', 'BRA', 'SOX2', 'CDX2'};

processedDataFolder = [masterFolder filesep 'processedData1']; % path to processed data folder
mkdir(processedDataFolder);
%%
% 1) specify and save metadata
meta = MetadataMicropattern(rawFile);
meta.channelNames = channelNames;
meta.colRadiiMicron = 350; % radius of the colony in microns
save([masterFolder filesep 'metadata1.mat'], 'meta');
%%
% 2) read file
filereader = bfGetReader(rawFile);
channelIdx = 1:numel(channelNames);

% 3) make maxZ image
rawFile_maxZ = MakeMaxZImage(filereader, channelIdx, 1);
%%
% 4) smooth and background subtract
for ii = channelIdx
    %for jj = channels
    rawFile_maxZ(:,:,ii) = smoothAndBackgroundSubtractOneImage(rawFile_maxZ(:,:,ii));
end
%%
for ii = 1:4
    figure; imshow(rawFile_maxZ(:,:,ii),[]);
end
%%
% 5) make colony mask
dapiChannel = find(cell2mat(cellfun(@(c)strcmp(c,'DAPI'),upper(channelNames),'UniformOutput',false)));
dapiImage = rawFile_maxZ(:,:,dapiChannel);

colonyMask = makeColonyMaskUsingDapiImage(dapiImage, meta);
%%
figure; imshowpair(colonyMask, dapiImage);
%%
% 6) save colony images and mask
imwrite(colonyMask, [processedDataFolder filesep 'colony1_colonyMask.tif']);
imwrite(dapiImage, [processedDataFolder filesep 'colony1_ch' int2str(dapiChannel) '.tif']);

for ii = channelIdx
    if ii == 1
        imwrite(rawFile_maxZ(:,:,ii), [processedDataFolder filesep 'colony1.tif']);
    else
        imwrite(rawFile_maxZ(:,:,ii), [processedDataFolder filesep 'colony1.tif'], 'WriteMode', 'append');
    end
end
%% ------- perform nuclear segmentation in ilastik -----------
%%
% 7) use nuclear mask to compute average intensity across colony
% a) read mask
nuclearMask = readIlastikFile([processedDataFolder filesep 'colony1_ch' int2str(dapiChannel) '_Simple Segmentation.h5']);
sizeThreshold = floor(0.1*pi*(10^2)/meta.xres);
nuclearMask = bwareaopen(nuclearMask, sizeThreshold);
%%
nuclearMask = nuclearMask&colonyMask;
figure; imshow(nuclearMask);
%%
% b) apply mask to all images, get neighbourhood average nuclear intensity
tooHighIntensity = 3800; % intensity threshold for positive signal in all channels
for ii = channelIdx
    intensityProfile(:,:,ii) = getColonyNuclearIntensityProfile(rawFile_maxZ(:,:,ii), nuclearMask, meta, tooHighIntensity);
end
%%
intensityProfile_dapiNormalized = intensityProfile./intensityProfile(:,:,dapiChannel);
intensityProfile_dapiNormalized(isnan(intensityProfile_dapiNormalized)) = 0;
%%
for ii = 1:4
    figure; imshow(intensityProfile_dapiNormalized(:,:,ii),[]);
end
%%
% c) compute mean intesnity in each bin
% radialProfile - contains mean radial profile as a function of distance
% from the colony edge. 

outerBin = 10; % in microns
bins = getBinEdgesConstantArea(meta.colRadiiMicron(1), outerBin); % bin area is constant.
% bins represent distance from colony edge in microns


dists = bwdist(~colonyMask);
dists = dists*meta.xres; % convert to microns

for ii = 1:length(bins)-1
    bin1 = [bins(ii) bins(ii+1)];
    idx1 = find(dists>bin1(1) & dists<=bin1(2));
    radialProfile.pixels(1,ii) = numel(idx1);
    
    if~isempty(idx1)
        for jj = 1:meta.nChannels
            image1 = intensityProfile(:,:,jj);
            image1(isinf(image1)) = 0;
            radialProfile.notNormalized.mean(jj,ii) = mean(image1([idx1]));
            radialProfile.notNormalized.std(jj,ii) = std(image1([idx1]));
            
            image1 = intensityProfile_dapiNormalized(:,:,jj);
            image1(isinf(image1)) = 0;
            radialProfile.dapiNormalized.mean(jj,ii) = mean(image1([idx1]));
            radialProfile.dapiNormalized.std(jj,ii) = std(image1([idx1]));
        end
    end
end
%%



