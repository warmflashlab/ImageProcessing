function splitLargeImageFile(infile,tileSize,nucChannel)

if ~exist('tileSize','var')
    tileSize = 2048;
end

if ~exist('nucChannel','var')
    nucChannel = 1;
end

nucOutput = 'DAPI';

if ~exist(nucOutput,'dir')
    mkdir(nucOutput);
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
        ind = r.getIndex(zz,nucChannel,tt)+1;
        img = bfGetPlane(r,ind,xstart,ystart,tileSize,tileSize);
        imwrite(img,fullfile(nucOutput,[fileprefix '_X' int2str(xx) 'Y' int2str(yy) '_nuc.tif']));
    end
end

