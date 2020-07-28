function fname = makeAndorFileName(prefix,ordering,numbers,suf)
% fname = makeAndorFileName(prefix,ordering,numbers,suf)
% ----------------------------------------------------------------
% Make a file name in the andor format. Specify prefix, ordering gives the
% order of dimenions e.g. 'fzw', numbers give the number for each dimension
% example: 
% makeAndorFileName('NodalLefty','pfw',[0 0 0]) yields 'NodalLefty_p0000_f0000_w0000.tif'
% AW 2020

fname = prefix;

if ~exist('suf','var')
    suf = '.tif';
end

for ii = 1:length(ordering)
    fname = [fname '_' ordering(ii) sprintf('%.4d',numbers(ii))];
end

fname = [fname suf];