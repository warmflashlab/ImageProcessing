function [radialAvgNuc, r] = plotMultipleAveragesNoSegmentation(...
    meta, colSize, DAPIChannel, colonies, conditions, doubleNormalize,useChan,plotErrors)

% doubleNormalize: boolean
% first normalize by DAPI, then scale all profiles from 0 to 1 on the same
% scale

if ~exist('doubleNormalize','var')
    doubleNormalize = false;
end

if ~exist('plotErrors','var')
    plotErrors = false;
end

m = 1;
n = numel(colonies);
radialAvgNuc = {};
r = {};
minI = Inf*(1:meta.nChannels);
maxI = 0*(1:meta.nChannels);

if ~exist('useChan','var')
    useChan = 1:length(meta.channelLabel);
end

for i = 1:n
    
    radialAvg = makeAveragesNoSegmentation(...
        meta, colSize, DAPIChannel, colonies{i});
    
    %chans = 1:length(meta.channelLabel);
    chansToPlot = setdiff(useChan,DAPIChannel);
    
    if ~isempty(DAPIChannel)
        radialAvgNuc{i} = radialAvg.nucAvgDAPINormalized;
    else
        radialAvgNuc{i} = radialAvg.nucAvg;
    end
    radialAvgStd{i} = radialAvg.nucStd;
    r{i} = radialAvg.r;
    
    % for overall normalization
    % throw out 2 bins from edge when setting LUT
    % to prevent setting minimum by areas without cells
    Imargin = 6;
    minI = min(minI, min(radialAvgNuc{i}(1:end-Imargin,:)));
    maxI = max(maxI, max(radialAvgNuc{i}(1:end-Imargin,:)));
end

if doubleNormalize
    for i = 1:n
        for ci = 1:meta.nChannels
            radialAvgNuc{i}(:,ci) = (radialAvgNuc{i}(:,ci) - minI(ci))/(maxI(ci)-minI(ci));
            radialStdNuc{i}(:,ci) = radialAvgStd{i}(:,ci)/(maxI(ci)-minI(ci));
        end
    end
end

for i = 1:n
    
    subplot_tight(m,n,i,0.02)
    if plotErrors
        errorbar(r{i}(ones(length(chansToPlot),1),:)',radialAvgNuc{i}(:,chansToPlot),radialAvgNuc{i}(:,chansToPlot),'.-','LineWidth',3);
    else
        plot(r{i}, radialAvgNuc{i}(:,chansToPlot),'.-','LineWidth',3)
    end
    axis([min(r{i}) max(r{i}) 0 1]);
    legend(meta.channelLabel(chansToPlot));
    title(conditions{i})
    
    axis square
    if i > 1
        legend off;
    end
end

end