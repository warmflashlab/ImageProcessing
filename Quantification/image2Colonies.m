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

in_struct = varargin2parameter(varargin);

DAPIChannel = meta.nuclearChannel;
findColoniesParameters = in_struct.clparameters;
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


img = zeros([meta.ySize, meta.xSize, meta.nChannels],'uint16');
[~, ext] = strtok(imgfile,'.'); %get file extension

%read file. 
if strcmp(ext,'.vsi')
    img = bfopen_mod(imgfile,xmin,ymin,xmax-xmin+1,ymax-ymin+1,1); %read only the 1st series from the vsi
else
    for ci = 1:meta.nChannels
        img(:,:,ci) = imread(imgfile,ci);
    end
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

%preview = uint16(preview);
% if ~exist(fullfile(dataDir,'preview'),'dir')
%     mkdir(fullfile(dataDir,'preview'));
% end

% exclude some bad colonies based on moments
% goodcolidx = false([1 numel(colonies)]);
% for coli = 1:numel(colonies)
%     CM = colonies(coli).CM{in_struct.momentChannel};
%     if norm(CM) < in_struct.CMcutoff
%         goodcolidx(coli) = true;
%     end
% end
% colonies = colonies(goodcolidx);


