function h = barPlotWithErrors(data,errs)

h = bar(data);
hold on;
for ii = 1:length(h)
    errorbar(h(ii).XData+h(ii).XOffset,h(ii).YData,errs(:,ii),'k.','LineWidth',3);
end