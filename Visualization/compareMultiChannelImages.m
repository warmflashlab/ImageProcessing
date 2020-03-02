function compareMultiChannelImages(imgs,condToUseForChan,limToUseForChan,cropwindow,toplabels,sidelabels)
%Function to make composite image comparing multi-channel images each
%channel on a consistent look up table. 
% imgs = cell array of multichannel images (mxnxq array where mxn is image
% size and q is number of channels). 
% condToUseForChan - vector of integers, lenght of number of channels. Each
% entry is the condition to use to set the limits for that channel (optional; 
% default is 1st condition for all). 
% limToUseForChan - lim to use for imadjust. Default [0 1].
% cropwindow - coordinates of window for cropping (same for all images).
% see imcrop for definition
% toplabels - labels on top, correspond to conditions, cell array of
% strings
% sidelabels - labels on side, correspond to channels, cell array of
% strings
%
% requires tight_subplot from matlabcentral 
% to fix - limToUseForChan syntax unclear. 



nchan = min(cellfun(@(x) size(x,3), imgs)); %minimum of chan numbers
if ~exist('condToUseForChan','var')  || isempty(condToUseForChan)
    condToUseForChan = ones(nchan,1);
end
nimgs = length(imgs);
q = 1;

ax = axes('Units','normalized', ...
    'Position',[0 0 1 1], ...
    'XTickLabel','', ...
    'YTickLabel','');
set(gca,'Xtick',[]);
set(gca,'Ytick',[]);

[ha, pos] = tight_subplot(nchan,nimgs,0.003,[0.001, 0.03],[0.03, 0.001]);
axes(ax);
if exist('toplabels','var')
    for ii = 1:nimgs
        xpos = pos{ii}(1)+pos{ii}(3)/2-0.01*length(toplabels{ii})/2;
        ypos = pos{ii}(2)+pos{ii}(4)+0.013;
        text(xpos,ypos,toplabels{ii},'Color','k','FontSize',24);
    end
end

if exist('sidelabels','var')
    for ii = 1:nchan
        xpos = pos{(ii-1)*nimgs+1}(1)-0.013;
        ypos = pos{(ii-1)*nimgs+1}(2)+pos{(ii-1)*nimgs+1}(4)/2-0.02;
        text(xpos,ypos,sidelabels{ii},'Color','k','Rotation',90,'FontSize',24);
    end
end

if ~exist('limToUseForChan','var') || isempty(limToUseForChan)
    limToUseForChan = [zeros(nchan,1) ones(nchan,1)];
end

for chan = 1:nchan
    if limToUseForChan(chan,2) <= 1
        lims = stretchlim(imgs{condToUseForChan(chan)}(:,:,chan),limToUseForChan(chan,:));
    else
        lims = stretchlim(imgs{condToUseForChan(chan)}(:,:,chan),[limToUseForChan(chan,1) 1]);
        lims(2) = lims(2) *limToUseForChan(chan,2);
    end
    for ii = 1:nimgs
        axes(ha(q));
        imgToUse = imgs{ii}(:,:,chan);
        if exist('cropwindow','var') && ~isempty(cropwindow)
            imgToUse = imcrop(imgToUse,cropwindow);
        end
        imshow(imadjust(imgToUse,lims));
        q = q + 1;
    end
end
