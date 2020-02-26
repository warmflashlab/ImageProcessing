function bins = getBinEdgesConstantArea(radius, outerBin)

%% given the width of the outermost bin (outerBin) and radius of the colony, 
% ----- outerBin & radius are both in um

% this function returns the binEdges for calculating radial average. 
% Bin edges are calculated such that bin area is constant across all bins. 

bins = zeros(1,10);
bins(1:2) = [radius radius-outerBin];
%%
a = bins(1);
b = bins(2);
counter = 3;

diff = a^2 - b^2;

c = b;
while c>1
    c = sqrt(b^2 - diff);
    bins(counter) = c;
    counter = counter+1;
    
    b = c;
end
%%
bins = real(bins); %last value has an imaginary component.
%%
% remove trailing zeros sometimes there are <10 elements in the bins vector. 
last = find(bins, 1, 'last');
if last<length(bins)-1
    bins(last+2:end) = [];
end

bins = radius-bins; %returns distance from edge

if bins(end)<radius-outerBin 
    bins = [bins radius];
end
end