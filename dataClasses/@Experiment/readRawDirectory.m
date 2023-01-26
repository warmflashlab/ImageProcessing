function readRawDirectory(this,ext)
%reads the raw directory and files in the imageNameStruct, modifies the 
%Experiment object in place. 

if ~exist('ext','var')
    ext = '.tif';
end
direc = this.rawImageDirectory();
allfiles = dir([direc filesep '*' ext]);
nImages = length(allfiles);
plate = [];
well = [];
position = [];
for ii=1:nImages
    nm = allfiles(ii).name;
    us = [strfind(nm,'_') strfind(nm,'.')]; %find all underscores and period
    if ii == 1
        prefix = strtok(nm,'_');
    end

    ind = strfind(nm,'_plate');

    if ~isempty(ind)
        inds(1) = ind;
        next_us = us(find(us > ind,1,"first"));
        plate = [plate str2num(nm((ind+6):(next_us-1)))];
    else
        inds(1) = 0;
    end

    ind = strfind(nm,'_well');
    if ~isempty(ind)
        inds(2) = ind;
        next_us = us(find(us > ind,1,"first"));
        well = [well str2num(nm((ind+5):(next_us-1)))];
    else
        inds(2) = 0;
    end

    ind = strfind(nm,'_pos');
    if ~isempty(ind)
        inds(3) = ind;
        next_us = us(find(us > ind,1,"first"));
        position = [position str2num(nm((ind+4):(next_us-1)))];
    else
        inds(3) = 0;
    end



end
ordering = {'plate','well','pos'};
drop = inds == 0;
ordering(drop) =[];
inds(drop) =[];
[~, reord]=sort(inds);
ordering=ordering(reord);

fileStruct.prefix = prefix;
fileStruct.plate = plate;
fileStruct.well = well;
fileStruct.position = position;
fileStruct.ordering = ordering;
fileStruct.extension = ext;
this.imageNameStruct = fileStruct;
end