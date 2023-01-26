function processColonies(this)

meta = this.metaData;
DAPIChannel =meta.nuclearChannel;
findColoniesParameters = this.processingParameters.clparameters;
adjustmentFactor = [];

nImages = length(this.imageNameStruct.well);

if isempty(this.processedImageDirectory)
    this.processedImageDirectory = fullfile(this.rawImageDirectory,'colonies');
end

colDir = this.processedImageDirectory;
if ~exist(colDir)
    mkdir(colDir);
end

colNow = 1; %counter for the number of colonies
colonies = []; % to store all colonies
for mm = 1:nImages %main processing loop
    
    imgfile = this.getFileNameFromStruct(mm);
    
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
    newColonies = findColonies(mask, [], meta, findColoniesParameters);
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
        newColonies(coli).well = this.imageNameStruct.well(mm);
        newColonies(coli).plate=this.imageNameStruct.plate(mm);
        b = newColonies(coli).boundingBox;
        colnucmask = mask(b(3):b(4),b(1):b(2));
        
        %     b(1:2) = b(1:2) - double(xmin - 1);
        %     b(3:4) = b(3:4) - double(ymin - 1);
        colimg = img(b(3):b(4),b(1):b(2), :);
        
        % write colony image
        newColonies(coli).saveImage(colimg, colDir);
        
        % write DAPI separately for Ilastik
        %colonies(coli).saveImage(colimg, colDir, DAPIChannel);
        
        % make radial average
        newColonies(coli).makeRadialAvgNoSeg(colimg, colnucmask,[], meta.colMargin)
        
        % calculate moments
        %colonies(coli).calculateMoments(colimg);
        colNow = colNow + 1;
    end
    colonies = [colonies, newColonies];
end
this.data = colonies;