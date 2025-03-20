% Script segmentazione MR-EMF e sottoprodotti (Watershed 8-connessa)
% Parametri 'de facto' dell'algoritmo:
% - margine per marker morfologici
% - soglia MSE segmentazione PAN/MS

%% load input images
inpath = 'In';
addpath(inpath); % input data path

pan = imread('po_120665_pan_0000000.tif');
red = imread('po_120665_red_0000000.tif');
grn = imread('po_120665_grn_0000000.tif');
blu = imread('po_120665_blu_0000000.tif');
nir = imread('po_120665_nir_0000000.tif');
mlt = cat(3, blu, grn, red, nir);

pansh = enviread('po_120665_mltSharpned_0000000');

clear red grn blu nir inpath

%% computing edges for multi-resolution
% Dilate to cover a 4x4-pixel window (searching - and adding - MS contours
% which does not appear in the panchromatic edge map)
tic;
addpath EdgeDetection;
edg = edgeMR(pan, mlt);
t_edg = toc;

%% computing distance and basic dem
%(si effettua un padding e si inizializza il bordo,
% per fare in modo che il bordo dell'immagine venga considerato un edge)
tic;
edgPadded = padarray(edg, [1,1], 1);
distancePadded = bwdist(edgPadded);
distance =  distancePadded(2:end-1,2:end-1);
dem = double(-distance);
t_dem = toc;
clear edgPadded distancePadded distance

%% --> WATERSHED (WS) RESULTS
tic;
WS = bmWatershed(dem);
t_ws = toc;

%% markerMorfologici (EMF)
tic;
addpath EMF;
morphoMarkers = EMF_MorphoMarkers(dem,3);
t_mm = toc;

%% --> EMF RESULT
tic;
tmpDem = imimposemin(double(dem),morphoMarkers);
tmpDem(tmpDem == -inf) = min(dem(:));
EMF = bmWatershed(tmpDem);
t_emf = toc;
clear tmpDem;

%% computing spectral markers on pansharpened
% 2-step process:
% - compute pre-markers by dilating contours, isolating connected
% components and performing a first LSE for consistency
% - perform a segmentation locally to each connected components to enforce 
% spectral coherence, then perform LSE to extract final markers
%
% Step1
tic;
tmp = not(imdilate(edg,ones(3)));
preMarkers = MREMF_MarkerErosion(dem, bwlabel(tmp), 1);
% Step2
[mseimg, mse] = regionalMSE(pansh,preMarkers);
MSEth_Pansh = percentile(mse,99);
% +++++ Alternative computation, working +++++
tmpMarkers = MREMF_MarkerSegmentation(double(pansh), ...
    bwlabel(preMarkers .* (mseimg > MSEth_Pansh)), 1, 0, 0); 
tmpMarkers = max(max(bwlabel(preMarkers))).*(tmpMarkers>0) + ...
    tmpMarkers + bwlabel(preMarkers .* (mseimg <= MSEth_Pansh));
% ++++++++++++++++++++++++++++++++++++++++++++++++
% tmpMarkers = MREMF_MarkerSegmentation(pansh, ...
%     bwlabel(preMarkers),1,MSEth_Pansh,0);
spectralMarkers = MREMF_MarkerErosion(dem, tmpMarkers, 1);
t_sm = toc;
clear preMarkers tmpMarkers mseimg mse;

%% --> EMF+ RESULT
tic;
tmpDem = imimposemin(dem,or(morphoMarkers,spectralMarkers));
tmpDem(tmpDem == -inf) = min(dem(:));
EMFplus = bmWatershed(tmpDem);
t_emfplus = toc;
clear tmpDem;

%% computing spectral markers on multi-resolution
% 2-step procedure:
% - perform the PAN/MS domain split by thresholding the DEM, suppressing
% dilated contours and perfoming LSE on PAN mask (PAN pre-markers),
% complementing, opening and performing LSE on MS mask (MS pre-markers.
% - on each domain, perform segmentation locally to each connected
% components and perform final LSE (for low-res, remap fragments to hi-res
% marker mask).

% Step1
tic;
% Generation of PAN/MS domains
dist = 5;
tmp = not(imdilate(edg,ones(3)));
maskPAN = (-dem < dist) .* tmp;
preMarkers_PAN = MREMF_MarkerErosion(dem, bwlabel(maskPAN), 1);
maskMS = not(preMarkers_PAN) .* tmp;
% Opening to disconnect markers connected by thin (less than 4x4) links
maskMS = imdilate(imerode(maskMS,ones(4)),ones(4));
preMarkers_MS_up = MREMF_MarkerErosion(dem, bwlabel(maskMS), 1); 
% WARNING! only removes spurious markers lying on borders

% Step2

% 2a. markers for PAN domain
[mseimg, mse] = regionalMSE(pan,preMarkers_PAN);
MSEth_PAN = percentile(mse,99);
% +++++ Alternative computation, working +++++
tmpMarkers_PAN = MREMF_MarkerSegmentation(double(pan), ...
    bwlabel(preMarkers_PAN .* (mseimg > MSEth_PAN)), 1, 0, 0); 
tmpMarkers_PAN = max(max(bwlabel(preMarkers_PAN))).*(tmpMarkers_PAN>0) + ...
    tmpMarkers_PAN + bwlabel(preMarkers_PAN .* (mseimg <= MSEth_PAN));
% ++++++++++++++++++++++++++++++++++++++++++++++++
% tmpMarkers_PAN = MREMF_MarkerSegmentation(double(pan), ...
%     bwlabel(preMarkers_PAN), 1, MSEth_PAN, 0); 
spectralMarkers_PAN = MREMF_MarkerErosion(dem, tmpMarkers_PAN, 1);

% 2b. markers for MS domain
% Downsample MS mask to perform segmentation on low-res data
dsRowFactor = size(pan,1) / size(mlt,1);
dsColFactor = size(pan,2) / size(mlt,2);
preMarkers_MS = preMarkers_MS_up(1:dsRowFactor:end,1:dsColFactor:end);
[mseimg, mse] = regionalMSE(mlt,preMarkers_MS);
MSEth_MS = percentile(mse,99);
% +++++ Alternative computation, working +++++
tmpMarkers_MS_dn = MREMF_MarkerSegmentation(double(mlt), ...
    bwlabel(preMarkers_MS .* (mseimg > MSEth_MS)), 1, 0, 0);
tmpMarkers_MS_dn = max(max(bwlabel(preMarkers_MS))).*(tmpMarkers_MS_dn>0) + ...
    tmpMarkers_MS_dn + bwlabel(preMarkers_MS .* (mseimg <= MSEth_MS));
% ++++++++++++++++++++++++++++++++++++++++++++
% tmpMarkers_MS_dn = MREMF_MarkerSegmentation(double(mlt), ...
%     bwlabel(preMarkers_MS), 1, MSEth_MS, 0);
% Upsample segmentation result and match with hi-res mask
tmpMarkers_MS = kron(tmpMarkers_MS_dn, ones(dsRowFactor,dsColFactor));
tmpMarkers_MS = imdilate(tmpMarkers_MS,ones(4)) .* preMarkers_MS_up;
spectralMarkers_MS = MREMF_MarkerErosion(dem, tmpMarkers_MS, 1);

t_mrsm = toc;
% clear tmp maskPan maskMS preMarkers_PAN preMarkers_MS_up tmpMarkers_PAN;
% clear dsRowFactor dsColFactor preMarkers_MS tmpMarkers_MS_dn tmpMarkers_MS;
% clear dist maskPAN maskMS mseimg mse;

%% --> MR-EMF result
tic;
markers = or( morphoMarkers, ...
    or(spectralMarkers_PAN, spectralMarkers_MS) );
tmpDem = imimposemin(dem,markers);
tmpDem(tmpDem == -inf) = min(dem(:));
MR_EMF = bmWatershed(tmpDem);
t_mremf = toc;
clear tmpDem;

%% EVALUATION (segmentation and classification)
load gts;

% evaluate segmentations
eval.WS.segm = evalSegPrague(WS,gt);
eval.EMF.segm = evalSegPrague(EMF,gt);
eval.EMFplus.segm = evalSegPrague(EMFplus,gt);
eval.MR_EMF.segm = evalSegPrague(MR_EMF,gt);

% evaluate classifications
% Maximum Likelihood
ml = objMLclass(pansh,gt_train);
eval.ML.class = confMatrix(ml,gt_test);
eval.ML.class.map = ml;
% Watershed
cl = majorityClass(WS,ml);
eval.WS.class = confMatrix(cl,gt_test);
eval.WS.class.map = cl;
% EMF
cl = majorityClass(EMF,ml);
eval.EMF.class = confMatrix(cl,gt_test);
eval.EMF.class.map = cl;
% EMF+
cl = majorityClass(EMFplus,ml);
eval.EMFplus.class = confMatrix(cl,gt_test);
eval.EMFplus.class.map = cl;
% MR-EMF
cl = majorityClass(MR_EMF,ml);
eval.MR_EMF.class = confMatrix(cl,gt_test);
eval.MR_EMF.class.map = cl;

clear ml cl;

%% Saving...
save res_multires_20131123.mat
