function [radialAvgNuc, r] = plotAveragesByCondition(this,...
    colSize,DAPInormalize,zeroOneNorm,useChan,useCondition,plotErrors)

allColonies = this.data;
meta = this.metaData;

if ~exist('DAPInormalize','var') || isempty(DAPInormalize)
    DAPInormalize = false;
end

if ~exist('zeroOneNorm','var') || isempty(zeroOneNorm)
    zeroOneNorm = true;
end

if ~exist('plotErrors','var') || isempty(plotErrors)
    plotErrors = false;
end

if ~exist('useChan','var') || isempty(useChan)
    useChan = 1:length(meta.channelLabel);
end

DAPIChannel = this.metaData.nuclearChannel;

if DAPInormalize
    chansToPlot = setdiff(useChan,DAPIChannel);
else
    chansToPlot = useChan;
end

conditions = unique([allColonies.condition]);
conditionNames = this.metaData.conditions;

if ~exist('useCondition','var') || isempty(useCondition)
    useCondition = conditions;
end

n = numel(useCondition);

m = 1;
radialAvgNuc = {};
r = {};
minI = Inf*(1:meta.nChannels);
maxI = 0*(1:meta.nChannels);

for i = 1:n
    [radialAvgNuc{i}, radialErrNuc{i}, r{i}] = this.computeConditionAverages(...
        colSize,useCondition(i),DAPInormalize,zeroOneNorm);
    % for overall normalization
    % throw out 2 bins from edge when setting LUT
    % to prevent setting minimum by areas without cells
    Imargin = 6;
    minI = min(minI, min(radialAvgNuc{i}(1:end-Imargin,:)));
    maxI = max(maxI, max(radialAvgNuc{i}(1:end-Imargin,:)));
end

if zeroOneNorm
    for i = 1:n
        for ci = 1:meta.nChannels
            radialAvgNuc{i}(:,ci) = (radialAvgNuc{i}(:,ci) - minI(ci))/(maxI(ci)-minI(ci));
            radialErrNuc{i}(:,ci) = radialErrNuc{i}(:,ci)/(maxI(ci)-minI(ci));
        end
    end
end

for i = 1:n
    subplot_tight(m,n,i,0.02)
    if plotErrors
        errorbar(r{i}(ones(length(chansToPlot),1),:)',radialAvgNuc{i}(:,chansToPlot),radialErrNuc{i}(:,chansToPlot),'.-','LineWidth',3);
    else
        plot(r{i}, radialAvgNuc{i}(:,chansToPlot),'.-','LineWidth',3)
    end
    if zeroOneNorm
        axis([min(r{i}) max(r{i}) 0 1]);
    end
    legend(meta.channelLabel(chansToPlot),'Location','Best');
    title(conditionNames{useCondition(i)})
    
    axis square
    if i > 1
        legend off;
    end
 
end
