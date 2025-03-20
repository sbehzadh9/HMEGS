function tmpDem = EdgeMarkFillPlusv1(x, eps, perc,amr,AmrSeed)
% function y = EdgeMarkFillPlus(x, eps, perc)
% Performs the Edge, Mark and Fill Plus segmentation of a N-channel image.
% x     - source image
% eps   - margin for morphological marker seed dilation (def. 3)
% perc  - percentile for selection of spectral markers to split (def. 99%)

% Default parameter value
if nargin<3 || isempty(perc),
    perc = 99;
end

if nargin<2 || isempty(eps),
    eps = 3;
end

img=x;
x = double(x);
edg = edgeMS(x);

% Computing Final Marker
 edgPadded = padarray(edg, [1,1], 1);
 distancePadded = bwdist(edgPadded);
 distance =  distancePadded(2:end-1,2:end-1);
 dem = double(-distance);
 morphoMarkersEmf = MorphoMarkers(dem,eps);

 edgamr = edgeMS(amr);
 distancePaddedamr = bwdist(edgamr);
 demamr = double(-distancePaddedamr);
 morphoMarkersAmr = MorphoMarkers(demamr,eps);

SE = strel('disk',1);
AmrSeed0=AmrSeed;
AmrSeed = imdilate(AmrSeed, SE);
EmforAmr=or(morphoMarkersEmf,morphoMarkersAmr);
EmforAmrOpen=imopen(EmforAmr,SE);
MarkerFinal=or(AmrSeed,EmforAmrOpen);

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

spectralMarkers = ShedfitErosion(demamr, tmpMarkers, 1);


tmpDem = imimposemin(demamr,or(MarkerFinal,spectralMarkers));
tmpDem(tmpDem == -inf) = min(demamr(:)); %replace -inf for compatibility
