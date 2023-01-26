function processColonies(this)

DAPIChannel = this.meta.nuclearChannel;
findColoniesParameters = this.processingParameters.clparameters;
adjustmentFactor = [];
% if isfield(in_struct,'DAPIChannel')
%     DAPIChannel = in_struct.DAPIChannel;
% else
%     DAPIChannel = find(strcmp(meta.channelNames,'DAPI'));
% end
%
% [~,vsinr] = fileparts(imgfile);
% vsinr = vsinr(end-3:end);
% colDir = fullfile(dataDir,['colonies_' vsinr]);
nImages = length(this.imageNameStruct.well)

for mm = 1:nImages

img = zeros([meta.ySize, meta.xSize, meta.nChannels],'uint16');

for ci = 1:meta.nChannels
    img(:,:,ci) = imread(imgfile,ci);
end


disp('determine threshold');
forIlim = img(:,:,ci);
t = thresholdMP(forIlim, adjustmentFactor);

mask = img(:,:,DAPIChannel) > t;

disp('find colonies');
%actually finds the colonies
tic
[colonies, cleanmask, welllabel] = findColonies(mask, [], meta, findColoniesParameters);
toc

% channels to save to individual images
% if ~exist(colDir,'dir')
%     mkdir(colDir);
% end

nColonies = numel(colonies);

for coli = 1:nColonies

    % store the ID so the colony object knows its position in the
    % array (used to then load the image etc)
    colonies(coli).setID(coli);
    b = colonies(coli).boundingBox;
    colnucmask = mask(b(3):b(4),b(1):b(2));

    %     b(1:2) = b(1:2) - double(xmin - 1);
    %     b(3:4) = b(3:4) - double(ymin - 1);
    colimg = img(b(3):b(4),b(1):b(2), :);

    % write colony image
    %colonies(coli).saveImage(colimg, colDir);

    % write DAPI separately for Ilastik
    %colonies(coli).saveImage(colimg, colDir, DAPIChannel);

    % make radial average
    colonies(coli).makeRadialAvgNoSeg(colimg, colnucmask,[], meta.colMargin)

    % calculate moments
    %colonies(coli).calculateMoments(colimg);
end
end