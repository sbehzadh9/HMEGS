function tmpDem = EdgeMarkFillPlus(x, eps, perc,r_g)
% function y = EdgeMarkFillPlus(x, eps, perc)
% Performs the Edge, Mark and Fill Plus segmentation of a N-channel image.
% x     - source image
% eps   - margin for morphological marker seed dilation (def. 3)
% perc  - percentile for selection of spectral markers to split (def. 99%)
%

% Default parameter value
if nargin<3 || isempty(perc),
    perc = 99;
end

if nargin<2 || isempty(eps),
    eps = 3;
end

% Computing Edges
x = double(x);
edg = edgeMS(x);

% Computing DEM
edgPadded = padarray(edg, [1,1], 1);
distancePadded = bwdist(edgPadded);
distance =  distancePadded(2:end-1,2:end-1);
dem = double(-distance);

% Computing Morphological Markers
morphoMarkers = MorphoMarkers(dem,eps);

% Computing Spectral Markers
% 2-step process:
% - compute pre-markers by dilating contours, isolating connected
% components and performing a first SFE for consistency
% - perform a segmentation locally to each connected components to enforce 
% spectral coherence, then perform SFE to extract final markers
%
% Step1
tmp = not(imdilate(edg,ones(3)));

preMarkers = ShedfitErosion(dem, bwlabel(tmp), 1);

%preMarkers=tmp;
% Step2
[mseimg, mse] = regionalMSE(x,preMarkers);
MSEth = percentile(mse,perc);
tmpMarkers = MarkerSegmentation(x, ...
    bwlabel(preMarkers .* (mseimg > MSEth)), 500, 0, 0);
tmpMarkers = max(max(bwlabel(preMarkers))).*(tmpMarkers>0) + ...
    tmpMarkers + bwlabel(preMarkers .* (mseimg <= MSEth));



spectralMarkers = ShedfitErosion(dem, tmpMarkers, 1);
tmpDem = imimposemin(dem,or(morphoMarkers,spectralMarkers));
tmpDem(tmpDem == -inf) = min(dem(:)); %replace -inf for compatibility
