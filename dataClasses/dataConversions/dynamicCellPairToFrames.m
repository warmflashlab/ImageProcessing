function [frames, frameNames] = dynamicCellPairToFrames(dynCellP)
% Function to convert array of dynamic cell pairs (tracking data of
% sisters) to frame data.

frameNames = {dynCellP.frameId};
frameNames = unique(frameNames);
nPos = length(frameNames);

tempFunc = @(x) x.lastFrame;
lf_all = arrayfun(tempFunc,dynCellP);
lf = max(lf_all);

for ii = 1:nPos
frames{ii}(lf) = frame;
end

for ii = 1:length(dynCellP)  
    fn = find(~cellfun(@isempty,strfind(frameNames,dynCellP(ii).frameId)));
    [fD, fr] = dynCellP(ii).exportFluorData;
    nc = size(fD,2)/2; %columns of data/cell
    for jj = fr
        ind = jj - fr(1) + 1;
        frames{fn}(jj).fluorData = [frames{fn}(jj).fluorData; fD(ind,1:nc); fD(ind,nc+1:end)];
    end
    
end
