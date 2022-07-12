function alignedImg = shiftsToAlignedImage(imgsToAlign,ashifts)
% Function to take a cell array of images, and a cell array of shifts and
% assemble the image. 

% imgsToAlign - cell array of images to align
% ashifts - cell array containing the shift of each image in absolute
% terms. 
% this is produced by first running alignImagesOnGrid and then absoluteShiftsAndSize
% both routines from CK repo StemCellTracker

% output is aligned image

imgsizes = cellfunc(@size, imgsToAlign);

d1 = @(x) x(1); d2 = @(x) x(2);
maxShift1 = max(max(cellfun(d1,ashifts)));
maxShift2 = max(max(cellfun(d2,ashifts)));
oneImSize = imgsizes{1,1};
img_size = oneImSize+ [maxShift2, maxShift1];

alignedImg = uint16(zeros(img_size));

for ii = 1:size(ashifts,1)
    for jj = 1:size(ashifts,2)
        alignedImg((ashifts{ii,jj}(1) + 1):(ashifts{ii,jj}(1) + oneImSize(1)),(ashifts{ii,jj}(2) + 1):(ashifts{ii,jj}(2) + oneImSize(2)))= imgsToAlign{ii,jj};
    end
end