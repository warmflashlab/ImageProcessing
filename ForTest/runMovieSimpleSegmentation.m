function p = runMovieSimpleSegmentation(imgfile,cellSize,minIntensityAboveBackground,chans)

doCells = false;
p = Position(); %initialize data class
p.filename = imgfile;
rr = bfGetReader(imgfile);
nt = rr.getSizeT;
p.nTime = nt;
nchans = length(chans);
p.nChannels = nchans;

for ii = 1:nt
    iplane = rr.getIndex(0,chans(1)-1,ii-1)+1;
    nuc_img = bfGetPlane(rr,iplane);
    [nuc, nuc_img_bgsub] = superSimpleSegmentation(nuc_img,cellSize,minIntensityAboveBackground);
    nucPlusCyt = imdilate(nuc,strel('disk',floor(cellSize/3)));
    cytOnly = nucPlusCyt & ~nuc;
    si = size(nuc_img);
    fimgs = uint16(zeros(si(1),si(2),nchans-1));
    for jj = 2:nchans
        iplane = rr.getIndex(0,chans(jj)-1,ii-1)+1;
        fimgs(:,:,jj-1) = backGroundSubImOpen(bfGetPlane(rr,iplane),cellSize/2);
    end
    
    if doCells
        stats = regionsprops(nuc,nuc_img,'Centroid','MeanIntensity','Area');
        for jj = 2:nchans
            stats_f(jj-1) = regionprops(mask,fimgs(:,:,jj-1),'MeanIntensity');
        end
    end
    
    nucPixAvg = mean(nuc_img(nuc));
    nucCytPixAvg = mean(nuc_img(nucPlusCyt));
    cytPixAvg = mean(nuc_img(cytOnly));
    
    for jj = 2:nchans
        img = squeeze(fimgs(:,:,jj-1));
        nucPixAvg = [nucPixAvg; mean(img(nuc))];
        nucCytPixAvg = [nucCytPixAvg; mean(img(nucPlusCyt))];
        cytPixAvg = [cytPixAvg; mean(img(cytOnly))];
    end
    
    pixAvgData.nucAvg = nucPixAvg;
    pixAvgData.cytAvg = cytPixAvg;
    pixAvgData.nucCytAvg = nucCytPixAvg;
    
    if ii == 1
        p.pixAvgData = pixAvgData;
    else
        p.pixAvgData(ii) = pixAvgData;
    end
    
    
end
