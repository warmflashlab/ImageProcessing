function makeKymograph(this,conditionNumber,params)

col = this.data;

col = col(:,[col(:,1).condition]==conditionNumber);

[ncol, ntime] = size(col);

for ii = 1:ncol
    colonies(ii) = copyObject(col(ii,1));
    for tt = 2:ntime
        colonies(ii).radialProfile(tt) = col(ii,tt).radialProfile;
    end
end

makeKymograph(colonies,params)