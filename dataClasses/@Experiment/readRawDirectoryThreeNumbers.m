function readRawDirectoryThreeNumbers(this,ext)
%This function will read any directory where the files have the syntax:
% [optional: prefix _] str1 num1 _ str2 num2 _ str3 num3 and will assume these numbers are for
%  plate well and position.

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
   [nums, strs, prefix] = parseFilenameThreeNumbers(allfiles(ii).name);
   if ii == 1
        ordering = strs;
   end
   plate(ii) = nums(1);
   well(ii) = nums(2);
   position(ii) = nums(3);
end


fileStruct.prefix = prefix;
fileStruct.plate = plate;
fileStruct.well = well;
fileStruct.position = position;
fileStruct.ordering = ordering;
fileStruct.extension = ext;
this.imageNameStruct = fileStruct;
end

