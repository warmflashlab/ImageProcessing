function [nucAvg, nucStdErr, r] = computeConditionAverages(this,colSize,conditionNum,DAPInormalize,zeroOneNorm)

colonies = this.data;
meta = this.metaData;

DAPIChannel = meta.nuclearChannel;

%restrict to colonies of the correct size and condition
inds = [colonies.radiusMicron] == colSize & [colonies.condition] == conditionNum;

if sum(inds) == 0
    disp('No colonies found with given size/condition');
    nucAvg = []; nucStdErr = [];
    return;
end

colonies = colonies(inds);

r = imfilter(colonies(1).radialProfile.BinEdges,[1 1]/2)*meta.xres;
r(1) = colonies(1).radialProfile.BinEdges(1)*meta.xres;
r = r(1:end-1);
colCat = cat(3,colonies(:).radialProfile);
ncol = length(colonies);

nucAll = cat(3,colCat.NucAvg);
if DAPInormalize
    nucAll = bsxfun(@rdivide,nucAll,nucAll(:,DAPIChannel,:));
end

nucAvg = mean(nucAll,3);
nucStdErr = std(nucAll,[],3)/sqrt(ncol);

if zeroOneNorm
norm = max(nucAvg) - min(nucAvg);
nucAvg = bsxfun(@minus,nucAvg,min(nucAvg));
nucAvg = bsxfun(@rdivide,nucAvg',norm')';
nucStdErr = bsxfun(@rdivide,nucStdErr',norm')';
end


