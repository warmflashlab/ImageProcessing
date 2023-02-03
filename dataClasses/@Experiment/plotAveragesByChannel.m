function [radialAvgNuc, r] = plotAveragesByChannel(this,...
                         colSize,DAPInormalize,zeroOneNorm,useChan,useCondition,plotErrors)

% doubleNormalize: boolean
% first normalize by DAPI, then scale all profiles from 0 to 1 on the same
% scale

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

conditions = unique([this.data.condition]);
conditionNames = this.metaData.conditions;

if ~exist('useCondition','var') || isempty(useCondition)
    useCondition = conditions;
end


nConditions = numel(useCondition);
radialAvgNuc = {};
r = {};
minI = Inf*(1:meta.nChannels);
maxI = 0*(1:meta.nChannels);

for i = 1:nConditions
    
    
    [radialAvgNuc{i} radialErrNuc{i} r{i}]= this.computeConditionAverages(...
        colSize,useCondition(i),DAPInormalize,zeroOneNorm);
    
end

colors = distinguishable_colors(nConditions);

m = 1;
for i = 1:length(chansToPlot)
    
    subplot_tight(m,length(chansToPlot),i,0.02)
    hold on
    for j = 1:nConditions
        if plotErrors
            errorbar(r{j},radialAvgNuc{j}(:,chansToPlot(i)),radialErrNuc{j}(:,chansToPlot(i)),'.-','LineWidth',3,'Color',colors(j,:));
        else
        plot(r{j}, radialAvgNuc{j}(:,chansToPlot(i)),'.-','LineWidth',3,'Color',colors(j,:))
        end
    end
    hold off
    if zeroOneNorm
    axis([min(r{j}) max(r{j}) 0 1]);
    end
    legend(conditionNames(useCondition),'Location','Best');
    title(meta.channelLabel(chansToPlot(i)))
    
    axis square
     if i > 1
         legend off;
     end
end

end