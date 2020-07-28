function img = combineWaveAndor(prefix,ordering,nonWaveNums,imgnums)
% img = combineWaveAndor(prefix,ordering,nonWaveNums,imgnums)
% ----------------------------------------------------------------
% Combine andor files of mulitple wavelengths into a single image
% prefix, ordering the same as for makeAndorFileName
% nonwavenums are the numbers of other dimensions besides wavelength in the
% order they appear in the filename. imgnums are the wavelength numbers to
% combine
% see also makeAndorFileName
% AW 2020

ordForCombine = find(ordering == 'w');

for ii = 1:length(imgnums)
    fileToRead = makeAndorFileName(prefix,ordering,[nonWaveNums(1:(ordForCombine-1)),...
        imgnums(ii) nonWaveNums((ordForCombine+1):end)]);
    newimg = imread(fileToRead);
    if ii == 1
        si = size(newimg);
        img = uint16(zeros(si(1),si(2),length(imgnums)));
    end
    img(:,:,ii) = newimg;
end
    
    
       

