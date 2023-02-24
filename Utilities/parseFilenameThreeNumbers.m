function [nums, strs,prefix] = parseFilenameThreeNumbers(str)
% This breaks up a file name with 3 numbers and returns the three numbers
% as an array, a cell array of the strings that follow each number, and an
% optional prefix. 
inds = isstrprop(str,"digit");
dd = diff(inds);
start_inds = find(dd==1)+1;
end_inds = find(dd==-1);
nums = zeros(3,1);
for ii = 1:length(start_inds)
    nums(ii) = str2double(str(start_inds(ii):end_inds(ii)));
end
us = [strfind(str,'_') strfind(str,'.')]; %find all underscores and period

if us(1) < start_inds(1) %there is an underscore before 1st number
    prefix = str(1:(us(1)-1));
    for ii = 1:3
        strs{ii} = str( (us(ii)+1):(start_inds(ii)-1));
    end

else
    prefix = '';
    strs{1} = str(1:(start_inds(1)-1));
    for ii = 2:3
        strs{ii} = str((us(ii-1)+1):(start_inds(ii)-1));
    end
end

end