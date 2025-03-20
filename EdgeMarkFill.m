function y = EdgeMarkFill(x, eps)
% function y = EdgeMarkFill(x, eps)
% Performs the Edge, Mark and Fill segmentation of a N-channel image.
% x     - source image
% eps   - margin for morphological marker seed dilation
%

% Default parameter value
if nargin==1,
    eps = 3;
end

% Computing Edges
edg = edgeMS(double(x));

% Computing DEM
edgPadded = padarray(edg, [1,1], 1);
distancePadded = bwdist(edgPadded);
distance =  distancePadded(2:end-1,2:end-1);
dem = double(-distance);

% Computing Morphological Markers
morphoMarkers = MorphoMarkers(dem,eps);

% Performing Marker-controlled Watershed
tmpDem = imimposemin(dem,morphoMarkers);
tmpDem(tmpDem == -inf) = min(dem(:)); %replace -inf for compatibility
y = bmWatershed(tmpDem);
