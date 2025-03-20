function y = MR_EdgeMarkFill(pan, ms, pan_th, eps, perc)
% function y = MR_EdgeMarkFill(pan, ms, pan_th, eps, perc)
% Performs the Edge, Mark and Fill Plus segmentation of a PAN+MultiSpectral
% multi-resolution image.
% pan    - source panchromatic band (hi-res)
% ms     - source multispectral data (low-res)
% pan_th - threshold for PAN/MS domain split (def. 5)
% eps    - margin for morphological marker seed dilation (def. 3)
% perc   - percentile for selection of spectral markers to split (def. 99%)
%

% Default parameter value
if nargin<5 || isempty(perc),
    perc = 99;
end

if nargin<4 || isempty(eps),
    eps = 3;
end

if nargin<3 || isempty(pan_th),
    pan_th = 5;
end

% Computing Edges
pan = double(pan);
ms = double(ms);
edg = edgeMR(pan,ms);

% Computing DEM
edgPadded = padarray(edg, [1,1], 1);
distancePadded = bwdist(edgPadded);
distance =  distancePadded(2:end-1,2:end-1);
dem = double(-distance);

% Computing Morphological Markers
morphoMarkers = MorphoMarkers(dem,eps);

% Generation of PAN/MS domains
dist = pan_th;
tmp = not(imdilate(edg,ones(3)));
maskPAN = (-dem < dist) .* tmp;
preMarkers_PAN = ShedfitErosion(dem, bwlabel(maskPAN), 1);
maskMS = not(preMarkers_PAN) .* tmp;
%   Opening to disconnect markers connected by thin (less than 4x4) links
maskMS = imdilate(imerode(maskMS,ones(4)),ones(4));
%   WARNING! The following only removes spurious markers lying on borders
preMarkers_MS_up = ShedfitErosion(dem, bwlabel(maskMS), 1);

% Spectral Markers for PAN Domain
[mseimg, mse] = regionalMSE(pan,preMarkers_PAN);
MSEth_PAN = percentile(mse,perc);
tmpMarkers_PAN = MarkerSegmentation(double(pan), ...
    bwlabel(preMarkers_PAN .* (mseimg > MSEth_PAN)), 1, 0, 0); 
tmpMarkers_PAN = max(max(bwlabel(preMarkers_PAN))).*(tmpMarkers_PAN>0) + ...
    tmpMarkers_PAN + bwlabel(preMarkers_PAN .* (mseimg <= MSEth_PAN));
spectralMarkers_PAN = ShedfitErosion(dem, tmpMarkers_PAN, 1);

% Spectral Markers for MS Domain
%   Downsample MS mask to perform segmentation on low-res data
dsRowFactor = size(pan,1) / size(ms,1);
dsColFactor = size(pan,2) / size(ms,2);
% BUG!
% preMarkers_MS = preMarkers_MS_up(1:dsRowFactor:end,1:dsColFactor:end);
% Correction:
preMarkers_MS_tmp = bwlabel(preMarkers_MS_up);
preMarkers_MS = preMarkers_MS_tmp(1:dsRowFactor:end,1:dsColFactor:end);
% End BUG!
[mseimg, mse] = regionalMSE(ms,preMarkers_MS);
MSEth_MS = percentile(mse,perc);
tmpMarkers_MS_dn = MarkerSegmentation(double(ms), ...
    bwlabel(preMarkers_MS .* (mseimg > MSEth_MS)), 1, 0, 0);
tmpMarkers_MS_dn = max(max(bwlabel(preMarkers_MS))).*(tmpMarkers_MS_dn>0) + ...
    tmpMarkers_MS_dn + bwlabel(preMarkers_MS .* (mseimg <= MSEth_MS));
%   Upsample segmentation result and match with hi-res mask
tmpMarkers_MS = kron(tmpMarkers_MS_dn, ones(dsRowFactor,dsColFactor)) ...
    .* preMarkers_MS_up;
tmpMarkers_MS = imdilate(tmpMarkers_MS,ones(4)) .* preMarkers_MS_up;
spectralMarkers_MS = ShedfitErosion(dem, tmpMarkers_MS, 1);

% Performing Marker-controlled Watershed
markers = or( morphoMarkers, ...
    or(spectralMarkers_PAN, spectralMarkers_MS) );
tmpDem = imimposemin(dem,markers);
tmpDem(tmpDem == -inf) = min(dem(:)); %replace -inf for compatibility
y = bmWatershed(tmpDem);
