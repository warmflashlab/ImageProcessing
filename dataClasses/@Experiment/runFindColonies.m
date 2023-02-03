function runFindColonies(this,filenrs,prefix,ext)

if ~exist('prefix','var')
    prefix = 'Colony';
end

if ~exist('ext','var')
    ext = '.tif';
end

allFilenrs = [filenrs{:}];
nImages = numel(allFilenrs);

meta = this.metaData;
DAPIChannel =meta.nuclearChannel;
findColoniesParameters = this.processingParameters.clparameters;


adjustmentFactor = [];

colDir = this.processedImageDirectory;

colNow = 1; %counter for the number of colonies
colonies = []; % to store all colonies
for mm = 1:nImages %main processing loop
    
    %find the condition
    f = @(x) sum(ismember(x,allFilenrs(mm)));
    cond = find(cellfun(f,filenrs));
    
    imgfile = fullfile(colDir,[prefix num2str(allFilenrs(mm)) ext]);

    %img = zeros([meta.ySize, meta.xSize, meta.nChannels],'uint16');
    clear img;
    for ci = 1:meta.nChannels
        img(:,:,ci) = imread(imgfile,ci);
    end


    disp('determine threshold');
    forIlim = img(:,:,DAPIChannel);
    t = thresholdMP(forIlim, adjustmentFactor);

    mask = forIlim > t;

    disp('find colonies');
    %actually finds the colonies
    tic
    [newColonies, cleanmask] = findColonies(mask, [], meta, findColoniesParameters);
    toc

    % channels to save to individual images
    % if ~exist(colDir,'dir')
    %     mkdir(colDir);
    % end

    nColonies = numel(newColonies);

    for coli = 1:nColonies



        % store the ID so the colony object knows its position in the
        % array (used to then load the image etc)
        newColonies(coli).setID(colNow);
        newColonies(coli).condition = cond;
        
        
        %newColonies(coli).well = this.imageNameStruct.well(mm);
        %newColonies(coli).plate=this.imageNameStruct.plate(mm);
        b = newColonies(coli).boundingBox;
        colnucmask = mask(b(3):b(4),b(1):b(2));

        %     b(1:2) = b(1:2) - double(xmin - 1);
        %     b(3:4) = b(3:4) - double(ymin - 1);
        colimg = img(b(3):b(4),b(1):b(2), :);

        % write colony image
        %newColonies(coli).saveImage(colimg, colDir);

        % write DAPI separately for Ilastik
        %colonies(coli).saveImage(colimg, colDir, DAPIChannel);

        % make radial average
        newColonies(coli).makeRadialAvgNoSeg(colimg, colnucmask,[], meta.colMargin)
        
        %display the preview
        makePreview(img,mask,cleanmask,meta,newColonies);

        % calculate moments
        %colonies(coli).calculateMoments(colimg);
        colNow = colNow + 1;
    end
    colonies = [colonies, newColonies];
end
this.data = colonies;
end

function preview= makePreview(img,mask,cleanmask,meta,colonies)

previewSize = 512;
% for preview (thumbnail)
preview = zeros(floor([previewSize previewSize*meta.xSize/meta.ySize 4]));
ymin = 1; xmin = 1;
ymax = meta.ySize; xmax = meta.xSize;

ymaxprev = ceil(size(preview,1)*double(ymax)/meta.ySize);
yminprev = ceil(size(preview,1)*double(ymin)/meta.ySize);
xmaxprev = ceil(size(preview,2)*double(xmax)/meta.xSize);
xminprev = ceil(size(preview,2)*double(xmin)/meta.xSize);



for ci = 1:meta.nChannels
    preview(yminprev:ymaxprev,xminprev:xmaxprev, ci) = ...
        imresize(img(:,:,ci),[ymaxprev-yminprev+1, xmaxprev-xminprev+1]);
    % rescale lookup for easy preview
    preview(:,:,ci) = imadjust(mat2gray(preview(:,:,ci)));
end

% make overview image of results of this function
maskPreview = imresize(mask, [size(preview,1) size(preview,2)]);
cleanmaskPreview = imresize(cleanmask, [size(preview,1) size(preview,2)]);
maskPreviewRGB = cat(3,maskPreview,cleanmaskPreview,0*maskPreview);
scale = mean(size(mask)./[size(preview,1) size(preview,2)]);

figure(1),
imshow(maskPreviewRGB)
%imwrite(maskPreviewRGB, fullfile(dataDir,'preview',['previewMask_' vsinr '.tif']));
hold on
for ii=1:length(colonies)
bbox = colonies(ii).boundingBox/scale;
rec = [bbox(1), bbox(3), bbox(2)-bbox(1), bbox(4)-bbox(3)];
rectangle('Position',rec,'LineWidth',2,'EdgeColor','g')
text(bbox(1),bbox(3)-25, ['col ' num2str(colonies(ii).ID)],'Color','g','FontSize',15);
end
hold off
% saveas(gcf, fullfile(dataDir,'preview',['previewSeg_' vsinr '.tif']));
%close;
% 
% imwrite(squeeze(preview(:,:,1)),fullfile(dataDir,'preview',['previewDAPI_' vsinr '.tif']));
% imwrite(preview(:,:,2:4),fullfile(dataDir,'preview',['previewRGB_' vsinr '.tif']));
end