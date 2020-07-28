function write3DImage(img,outfile)
%write3DImage(img,outfile) 
%------------------------------------
%   writes a 3D image to disk. inputs are the image (img) and the name for
%   output file (outfile)

% Possible to do: write metadata to label 3rd dimension

nslice  = size(img,3);
imwrite(img(:,:,1),outfile);

for ii = 2:nslice
    imwrite(img(:,:,ii),outfile,'WriteMode','Append');
end

end

