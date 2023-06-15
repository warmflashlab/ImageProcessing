function [radialAvgNuc, r] = plotAveragesByChannel(this,...
                         colSize,DAPInormalize,zeroOneNorm,useChan,useCondition,plotErrors,fontSize)

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
        % for overall normalization
    % throw out 2 bins from edge when setting LUT
    % to prevent setting minimum by areas without cells
    Imargin = 6;
    minI = min(minI, min(radialAvgNuc{i}(1:end-Imargin,:)));
    maxI = max(maxI, max(radialAvgNuc{i}(1:end-Imargin,:)));
end

if zeroOneNorm
    for i = 1:nConditions
        for ci = 1:meta.nChannels
            radialAvgNuc{i}(:,ci) = (radialAvgNuc{i}(:,ci) - minI(ci))/(maxI(ci)-minI(ci));
            radialErrNuc{i}(:,ci) = radialErrNuc{i}(:,ci)/(maxI(ci)-minI(ci));
        end
    end
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
        xlabel('Distance from Center (\mum)');

    axis square
     if i > 1
         legend off;
     else
         ylabel('Intensity (au)');
     end

      if exist('fontSize','var')
        set(gca,'FontSize',fontSize);
    end
end

end