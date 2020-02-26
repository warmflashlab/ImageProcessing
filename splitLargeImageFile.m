function splitLargeImageFile(infile,tileSize,nucChannel)
%Split a large, single time, single z-plane image into tiles. Will produce
%separate nuc channel image. set nucChannel <= 0 to skip
%AW 4/26/19


if ~exist('tileSize','var')
    tileSize = 2048;
end

if ~exist('nucChannel','var')
    nucChannel = 1;
end

nucOutput = 'DAPI';

if ~exist(nucOutput,'dir') && nucChannel > 0
    mkdir(nucOutput);
end

multiChannelOutput = 'splitImages';

if ~exist(multiChannelOutput,'dir')
    mkdir(multiChannelOutput);
end

fileprefix = strtok(infile,'.');

r = bfGetReader(infile);

sx = r.getSizeX;
sy = r.getSizeY;
sc = r.getSizeC;

nx = floor(sx/tileSize);
ny = floor(sy/tileSize);

zz = 0; tt = 0;


for xx = 1:nx
    for yy = 1:ny
        xstart = (xx-1)*tileSize+1;
        ystart = (yy-1)*tileSize+1;
        if nucChannel > 0
            ind = r.getIndex(zz,nucChannel-1,tt)+1;
            img = bfGetPlane(r,ind,xstart,ystart,tileSize,tileSize);
            imwrite(img,fullfile(nucOutput,[fileprefix '_X' int2str(xx) 'Y' int2str(yy) '_nuc.tif']));
        end
        for ii = 1:sc
            ind = r.getIndex(zz,ii-1,tt) + 1;
            img = bfGetPlane(r,ind,xstart,ystart,tileSize,tileSize);
            if ii == 1
                imwrite(img,fullfile(multiChannelOutput,[fileprefix '_X' int2str(xx) 'Y' int2str(yy) '.tif']));
            else
                imwrite(img,fullfile(multiChannelOutput,[fileprefix '_X' int2str(xx) 'Y' int2str(yy) '.tif']),'WriteMode','Append');
            end
        end
    end
end

