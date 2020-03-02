function [imgs, names] = readImageDir(dirname,suffix,subString)
%Function read images from a directory and store in a cell array. 
% dirname - name of directory
% suffix - image suffix
% subString - include only those with subString (or use '~foo' to exclude
% string 'foo'
% outputs:
% imgs - cell array with images
% names - cell array containing corresponding file names
%
% NOTE: images currently must be openable by imread. In future, use
% bioformats

ff = dir(fullfile(dirname,['*.' suffix]));
nimg = length(ff);


if exist('subString','var') && ~isempty(subString)
    includeAll = false;
    if subString(1) == '~'
        excludeStr = true;
        strToTest = subString(2:end);
    else
        excludeStr = false;
        strToTest = subString;
    end
else
    includeAll = true;
end

q = 1;
for ii = 1:nimg
    if ~includeAll
    ind = strfind(lower(ff(ii).name),lower(strToTest));
    end
    if includeAll || (excludeStr == false && ~isempty(ind)) ||...
            (excludeStr == true && isempty(ind))
        %rr = bfGetReader(fullfile(dirname,ff(ii).name));
        %imgs{q} = bfopen(rr);
        imgs{q} = imread(fullfile(dirname,ff(ii).name));
        names{q} = ff(ii).name;
        q = q + 1;
    end
end
