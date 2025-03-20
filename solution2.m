function tmpDem = Solution2(x, eps, perc,amrGradian,AmrSeed)
% function y = EdgeMarkFillPlus(x, eps, perc)
% x     - source image
% eps   - margin for morphological marker seed dilation (def. 3)
% perc  - percentile for selection of spectral markers to split (def. 99%)
% Default parameter value
if nargin<3 || isempty(perc)
    perc = 99;
end
if nargin<2 || isempty(eps)
    eps = 3;
end
x = double(x);
edg = edgeMS(x);
% Computing DEM
 edgamr = edgeMS(amrGradian);
 distancePaddedamr = bwdist(edgamr);
 demAmr = double(-distancePaddedamr);
% Computing Spectral Markers
% 2-step process:
% - compute pre-markers by dilating contours, isolating connected
% components and performing a first SFE for consistency
% - perform a segmentation locally to each connected components to enforce 
% spectral coherence, then perform SFE to extract final markers

% Step1
tmp = not(imdilate(edg,ones(1)));
preMarkers = ShedfitErosion(tmp, bwlabel(edgamr), 1);

% Step2
[mseimg, mse] = regionalMSE(x,preMarkers);
MSEth = percentile(mse,perc);
tmpMarkers = MarkerSegmentation(x, ...
    bwlabel(preMarkers .* (mseimg > MSEth)), 1, 0, 0);
tmpMarkers = max(max(bwlabel(preMarkers))).*(tmpMarkers>0) + ...
    tmpMarkers + bwlabel(preMarkers .* (mseimg <= MSEth));

spectralMarkers = ShedfitErosion(demAmr, tmpMarkers, 1);
tmpDem = imimposemin(demAmr,or(AmrSeed,spectralMarkers));
tmpDem(tmpDem == -inf) = min(demAmr(:)); %replace -inf for compatibility
