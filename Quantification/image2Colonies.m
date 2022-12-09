function colonies = image2Colonies(imgfile,meta,varargin)
% Function that takes an imagfile as input and returns an array of colonies
% will optionally create a directory colonies containing images of
% individual colonies.
% varargin allows for overwrite of default metadata options. Must have keyword:value pairs.
%   -channelLabel (default {'DAPI','Cdx2','Sox2','Bra'})
%   -colRadiiMicron (default [200 500 800 1000]/2 )
%   -colMargin (default 10)
%   -DAPIChannel - nuclear marker channel. By default looks for DAPI in
%   channel labels
%   -metaDataFile: can read meta structure from file and skip extracting
%   from vsi. (Default reads from vsi).

%NOTE: removing metadata from processVsi, this will be a separate function

maxMemoryGB = 4;

if isfield(in_struct,'DAPIChannel')
    DAPIChannel = in_struct.DAPIChannel;
else
    DAPIChannel = find(strcmp(meta.channelNames,'DAPI'));
end
% 
% [~,vsinr] = fileparts(imgfile);
% vsinr = vsinr(end-3:end);
% colDir = fullfile(dataDir,['colonies_' vsinr]);

%% processing loop

% masks for radial averages
[radialMaskStack, edges] = makeRadialBinningMasks(...
            meta.colRadiiPixel, meta.colRadiiMicron, meta.colMargin);
% split the image up in big chunks for efficiency
maxBytes = (maxMemoryGB*1024^3);
bytesPerPixel = 2;
dataSize = meta.ySize*meta.xSize*meta.nChannels*bytesPerPixel;
nChunks = ceil(dataSize/maxBytes);

if nChunks > 1
    nRows = 2;
else
    nRows = 1;
end
nCols = ceil(nChunks/nRows);

xedge = (0:nCols)*(meta.xSize/nCols);
yedge = (0:nRows)*(meta.ySize/nRows);

% define the data structures to be filled in
preview = zeros(floor([2048 2048*meta.xSize/meta.ySize 4]));
mask = false([meta.ySize meta.xSize]);
colonies = [];
chunkColonies = {};
% L = 2048;
% bg = (2^16-1)*ones([L L meta.nChannels],'uint16');

chunkIdx = 0;
prevNWells = 0;
for n = 1:numel(yedge)-1
    for m = 1:numel(xedge)-1
        
        chunkIdx = chunkIdx + 1;
        
        disp(['reading chunk ' num2str(chunkIdx) ' of ' num2str(nChunks)])
        
        xmin = uint32(xedge(m) + 1); xmax = uint32(xedge(m+1));
        ymin = uint32(yedge(n) + 1); ymax = uint32(yedge(n+1));
        
        % add one sided overlap to make sure all colonies are completely
        % within at least one chunk
        % theoretically one radius should be enough but we need a little
        % margin
        if n < nRows
            ymax = ymax + 1.25*max(meta.colRadiiPixel);
        end
        if m < nCols
            xmax = xmax + 1.25*max(meta.colRadiiPixel);
        end
        chunkheight = ymax - ymin + 1;
        chunkwidth = xmax - xmin + 1;
        
        % for preview (thumbnail)
        ymaxprev = ceil(size(preview,1)*double(ymax)/meta.ySize);
        yminprev = ceil(size(preview,1)*double(ymin)/meta.ySize);
        xmaxprev = ceil(size(preview,2)*double(xmax)/meta.xSize);
        xminprev = ceil(size(preview,2)*double(xmin)/meta.xSize);
        
        img = zeros([chunkheight, chunkwidth, meta.nChannels],'uint16');
        [~, ext] = strtok(imgfile,'.');
        if strcmp(ext,'.vsi')
            img_bf = bfopen_mod(imgfile,xmin,ymin,xmax-xmin+1,ymax-ymin+1,1); %read only the 1st series from the vsi
            
            for ci = 1:meta.nChannels
                %             tic
                %             disp(['reading channel ' num2str(ci)])
                %             img(:,:,ci) = imread(btfname,'Index',ci,'PixelRegion',{[ymin,ymax],[xmin, xmax]});
                img(:,:,ci) = img_bf{1}{ci,1};
                preview(yminprev:ymaxprev,xminprev:xmaxprev, ci) = ...
                    imresize(img(:,:,ci),[ymaxprev-yminprev+1, xmaxprev-xminprev+1]);
                % rescale lookup for easy preview
                preview(:,:,ci) = imadjust(mat2gray(preview(:,:,ci)));
                %            toc
            end
        else
            for ci = 1:meta.nChannels
                img(:,:,ci) = imread(imgfile,ci);
                preview(yminprev:ymaxprev,xminprev:xmaxprev, ci) = ...
                    imresize(img(:,:,ci),[ymaxprev-yminprev+1, xmaxprev-xminprev+1]);
                % rescale lookup for easy preview
                preview(:,:,ci) = imadjust(mat2gray(preview(:,:,ci)));
            end
        end

        % determine background
        % bg = getBackground(bg, img, L);
        
        disp('determine threshold');
        if m == 1 && n == 1
            
            for ci = DAPIChannel

                imsize = 2048;
                si = size(img);
                xx = min(si(1),4*imsize); yy = min(si(2),4*imsize);
                if xx < 2*imsize
                    x0 = 1;
                else
                    x0 = imsize + 1;
                end
                if yy < 2*imsize
                    y0 = 1;
                else
                    y0 = imsize + 1;
                end
                
                forIlim = img(x0:xx,y0:yy,ci);
                t = thresholdMP(forIlim, adjustmentFactor);
            end
        end
        mask(ymin:ymax,xmin:xmax) = img(:,:,DAPIChannel) > t;
        
        disp('find colonies');
        tic
        range = [xmin, xmax, ymin, ymax];
        
        [chunkColonies{chunkIdx}, cleanmask, welllabel] = findColonies(mask, range, meta, s);

        toc
        
        disp('merge colonies')
        prevNColonies = numel(colonies);
        if prevNColonies > 0
            D = distmat(cat(1,colonies.center), chunkColonies{chunkIdx}.center);
            [i,j] = find(D < max(meta.colRadiiPixel)*meta.xres);
            chunkColonies{chunkIdx}(j) = [];
        end
        % add fields to enable concatenating
        colonies = cat(2,colonies,chunkColonies{chunkIdx});
        
        disp('process individual colonies')
        tic
        
        % channels to save to individual images
        if ~exist(colDir,'dir')
            mkdir(colDir);
        end
        
        nColonies = numel(colonies);
        
        for coli = prevNColonies+1:nColonies
            
            % store the ID so the colony object knows its position in the
            % array (used to then load the image etc)
            colonies(coli).setID(coli);

            %increment well to account for previous
            colonies(coli).well = colonies(coli).well + prevNWells;
            
            fprintf('.');
            if mod(coli,60)==0
                fprintf('\n');
            end

            b = colonies(coli).boundingBox;
            colnucmask = mask(b(3):b(4),b(1):b(2));
            
            b(1:2) = b(1:2) - double(xmin - 1);
            b(3:4) = b(3:4) - double(ymin - 1);
            colimg = img(b(3):b(4),b(1):b(2), :);
            
            % write colony image
            colonies(coli).saveImage(colimg, colDir);
            
            % write DAPI separately for Ilastik
            colonies(coli).saveImage(colimg, colDir, DAPIChannel);
            
            % subtract background
            bg = imopen(colimg, strel('disk',15));
            colimg = colimg - bg;
            
            % make radial average
            colonies(coli).makeRadialAvgNoSeg(colimg, colnucmask, meta.colMargin)
            
            % calculate moments
            colonies(coli).calculateMoments(colimg);
        end
        prevNWells = prevNWells+max(max(welllabel));

        fprintf('\n');
        toc
        
    end
end
%preview = uint16(preview);
if ~exist(fullfile(dataDir,'preview'),'dir')
	mkdir(fullfile(dataDir,'preview'));
end

% exclude some bad colonies based on moments
goodcolidx = false([1 numel(colonies)]);
for coli = 1:numel(colonies)
	CM = colonies(coli).CM{in_struct.momentChannel};
    if norm(CM) < in_struct.CMcutoff
        goodcolidx(coli) = true;
    end
end
colonies = colonies(goodcolidx);

% make overview image of results of this function
maskPreview = imresize(mask, [size(preview,1) size(preview,2)]);
cleanmaskPreview = imresize(cleanmask, [size(preview,1) size(preview,2)]);
maskPreviewRGB = cat(3,maskPreview,cleanmaskPreview,0*maskPreview);
scale = mean(size(mask)./[size(preview,1) size(preview,2)]);

figure,
imshow(maskPreviewRGB)
imwrite(maskPreviewRGB, fullfile(dataDir,'preview',['previewMask_' vsinr '.tif']));
hold on
for i = 1:numel(colonies)
    bbox = colonies(i).boundingBox/scale;
    rec = [bbox(1), bbox(3), bbox(2)-bbox(1), bbox(4)-bbox(3)];
    rectangle('Position',rec,'LineWidth',2,'EdgeColor','g')
    text(bbox(1),bbox(3)-25, ['col ' num2str(colonies(i).ID)],'Color','g','FontSize',15);
end
hold off
saveas(gcf, fullfile(dataDir,'preview',['previewSeg_' vsinr '.tif']));
close;

imwrite(squeeze(preview(:,:,1)),fullfile(dataDir,'preview',['previewDAPI_' vsinr '.tif']));
imwrite(preview(:,:,2:4),fullfile(dataDir,'preview',['previewRGB_' vsinr '.tif']));

save(fullfile(dataDir,['colonies_' vsinr]), 'colonies');
