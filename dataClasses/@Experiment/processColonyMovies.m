function processColonyMovies(this)
%process a live cell imaging micropatterning experiment. assumes one colony
%per movie

meta = this.metaData;
DAPIChannel =meta.nuclearChannel;
findColoniesParameters = this.processingParameters.clparameters;

adjustmentFactor = this.processingParameters.adjustmentFactor;

nImages = length(this.imageNameStruct.well);

if isempty(this.processedImageDirectory)
    this.processedImageDirectory = fullfile(this.rawImageDirectory,'colonies');
end

imgDir = this.rawImageDirectory;

colDir = this.processedImageDirectory;
if ~exist(colDir,'dir')
    mkdir(colDir);
end

for mm = 1:nImages %main processing loop

    imgfile = this.getFileNameFromStruct(mm);

    rr = bfGetReader(fullfile(imgDir, imgfile));

    %img = zeros([meta.ySize, meta.xSize, meta.nChannels],'uint16');
    %
    img = zeros(rr.getSizeY,rr.getSizeX,meta.nChannels);

    for ci = 1:meta.nChannels
        img(:,:,ci) = bfGetPlaneAtZCT(rr,1,ci,1);
    end


    disp('determine threshold');
    forIlim = img(:,:,DAPIChannel);
    t = thresholdMP(forIlim, adjustmentFactor);

    if isfield(this.processingParameters,'minThresh') && t < this.processingParameters.minThresh
        t = this.processingParameters.minThresh;
    end

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

    if numel(newColonies) > 1
        disp('Error: only one colony per image permitted in processColonyMovies')
    end




    % store the ID so the colony object knows its position in the
    % array (used to then load the image etc)
    newColonies.setID(mm);
    newColonies.well = this.imageNameStruct.well(mm);
    newColonies.plate=this.imageNameStruct.plate(mm);
    b = newColonies.boundingBox;
    colnucmask = mask(b(3):b(4),b(1):b(2));

    for tt = 1:meta.nTime
        %     b(1:2) = b(1:2) - double(xmin - 1);
        %     b(3:4) = b(3:4) - double(ymin - 1);

        if tt  > 1 %get the image of next time point
            for ci = 1:meta.nChannels
                if rr.getSizeZ > 1&& rr.getSizeT == 1
                    img(:,:,ci) = bfGetPlaneAtZCT(rr,tt,ci,1);
                elseif rr.getSizeT > 1 && rr.getSizeZ == 1
                    img(:,:,ci) = bfGetPlaneAtZCT(rr,1,ci,tt);
                else
                    disp('Error in processColonyMovies: getSizeZ and getSizeT cannot both be > 1')
                end
            end
        end
        colonyNow = copyObject(newColonies); %deep copy so we don't overwrite

        colimg = img(b(3):b(4),b(1):b(2), :);

        % write colony image
        %newColonies(coli).saveImage(colimg, colDir);

        % write DAPI separately for Ilastik
        %colonies(coli).saveImage(colimg, colDir, DAPIChannel);


        % make radial average
        colonyNow.makeRadialAvgNoSeg(colimg, colnucmask,[], meta.colMargin)

        %display the preview
        if tt == 1
            makePreview(img,mask,cleanmask,meta,newColonies);
        else

            colonies(mm,tt) = colonyNow;
            % calculate moments
            %colonies(coli).calculateMoments(colimg);

        end

    end
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