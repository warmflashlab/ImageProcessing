function [radialAvgNuc, r] = plotAveragesByChannel(this,...
                         colSize,DAPInormalize,zeroOneNorm,useChan,useCondition,plotErrors)

% doubleNormalize: boolean
% first normalize by DAPI, then scale all profiles from 0 to 1 on the same
% scale

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


nConditions = numel(useCondition);
radialAvgNuc = {};
r = {};
minI = Inf*(1:meta.nChannels);
maxI = 0*(1:meta.nChannels);

for i = 1:nConditions
    
    colonies = allColonies([allColonies.condition]==useCondition(i));
    
    radialAvg = makeAveragesNoSegmentation(...
                    meta, colSize, DAPIChannel, colonies);
    
    if DAPInormalize
        radialAvgNuc{i} = radialAvg.nucAvgDAPINormalized;
    else
        radialAvgNuc{i} = radialAvg.nucAvg;
    end
    r{i} = radialAvg.r;    
    
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
        end
    end
end

colors = distinguishable_colors(nConditions);

m = 1;
for i = 1:length(chansToPlot)
    
    subplot_tight(m,length(chansToPlot),i,0.02)
    hold on
    for j = 1:nConditions
        plot(r{j}, radialAvgNuc{j}(:,chansToPlot(i)),'.-','LineWidth',3,'Color',colors(j,:))
    end
    hold off
    axis([min(r{j}) max(r{j}) 0 1]);
    legend(conditionNames(useCondition),'Location','Best');
    title(meta.channelLabel(chansToPlot(i)))
    
    axis square
     if i > 1
         legend off;
     end
end

end