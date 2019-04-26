function [x, y] = maskToXY(mask);

%gets xy coordinates from centroids of objects in binary mask
% AW. Apr 23 2019

stats = regionprops(mask,'Centroid');
xy = [stats.Centroid];

x = xy(1:2:end);
y = xy(2:2:end);