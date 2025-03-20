function markers = MorphoMarkers(dem,dist,th)
% function markers = MorphoMarkers(dem,dist,th)
% EMF function for extraction of morphological markers.
% - dem  : source DEM (negative, max(DEM) must be 0)
% - dist : distance of desired markers from edges (default 3px)
% - th   : if specified, DEM is thresholded at this value.
%
if nargin == 1,
    dist = 3;
    th = inf;
elseif nargin == 2
    th = inf;
end

% DEM thresholding
dem(dem < -th) = -th;

% Seed generation
seed = imregionalmin(double(dem)).*(-double(dem));
seed = floor(seed);

% Seed dilation
markers = DilateSeeds( seed, dist );
