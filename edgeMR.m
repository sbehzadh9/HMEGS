function [edges, edges_pan, edges_ms, edges_fused] = edgeMR(pan, ms, se, enh_fact)
% function edges = edgeMR(pan, ms, se, enh_fact)
% Performs pansharpening-free the edge fusion on multi-resolution RS images 
% (IKONOS, WorldView, etc.). Canny is used with default parameters.
% - pan      : panchromatic band
% - ms       : multispectral bands
% - se       : structuring element for morphological edge fusion
%            : ( default ONES(resolution_ratio) )
% - enh_fact : if specified, performs MS edge refinement using finer
%              contours extracted from the panchromatic (Canny thresholds
%              are divided by this value) *** BETA ***.
%
% For earlier Matlab versions than R2013a, replace 'canny_old' by 'canny'
%
dims = size(ms);
rows = dims(1); cols = dims(2); bands = dims(3);

% Default structuring element equal to the NxN square 
% equal to resolution ratio (e.g. for IKONOS, ones(4)).
if nargin == 2,
    pdims = size(pan);
    se = ones(pdims(1) / rows, pdims(2) / cols);
end

% Performing band-per-band edge detection on multispectral
edges_ms_band = zeros(dims);
edges_ms = zeros(rows, cols);
for b=1:bands
    edges_ms_band(:,:,b) = edge(ms(:,:,b), 'canny_old');
    edges_ms = or(edges_ms, edges_ms_band(:,:,b));
end

% upsampling of MS edge map
edges_ms = bwmorph(kron(edges_ms, ones(4)),'thin',inf);

% Edge detection on panchromatic band
[edges_pan, th] = edge(pan,'canny_old');

edges = edges_pan;

% Panchromatic-based MS edge refinement (optional)
if nargin == 4,
    edge_pan_dil = imdilate(edges, se);
    edges_ms_mask = edges_ms.*not(edge_pan_dil);
    edgeFine = edge(pan,'canny_old',th/enh_fact);
    edges_ms_mask = imdilate(edges_ms_mask,se) .* edgeFine;
    edges = (edges_ms_mask+2*edges) > 0;
end

% Merging of contours and thinning
edge_pan_dil = imdilate(edges, se);
edges_ms_mask = edges_ms.*not(edge_pan_dil);
edges_ms_mask = imdilate(edges_ms_mask,se) .* edges_ms;
edges = edges_ms_mask+2*edges;
edges = edges>0;

% Optional Output
edges_fused = edges .* ~edges_ms_mask + 2.*edges.*edges_ms_mask;
