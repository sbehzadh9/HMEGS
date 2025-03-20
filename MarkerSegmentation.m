function seg = MREMF_MarkerSegmentation( image, regions, depth, MSE, area )
% function seg = MREMF_MarkerSegmentation( image, regions, depth, MSE, area )
% MR-EMF auxiliary function for marker segmentation using TSMRF.
% image   : source data
% regions : marker map (labeled)
% depth   : number of TSMRF split levels
% MSE     : MSE threshold
% area    : area threshold
%
set = TSMRF_SET;
set = set.setBlindDisconnecting(depth, MSE, area);

%input File
in = TSMRF_IMAGE;
in.data = image;
in.roi = regions>0;
in.initSeg = regions;

%segmentation
seg = tsmrf(in, set);
