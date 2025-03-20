function out = ShedfitErosion(dem, mask, join)
% function out = ShedfitErosion(dem, mask, clean)
% Shed-fit Erosion. Processes the connected regions of the map
% to match them with one or more (merged) watershed regions.
% - dem   : source DEM
% - mask  : source marker mask
% - join : if 1, links regions sharing a miminum plateau
%

if nargin == 2,
    join = 1;
end

% Initial watershed
wtr = bmWatershed(double(dem));

% DEM local minima
minimi = imregionalmin(dem);

% watershed-colored map of mimima
minimiWtr = minimi.*wtr;

% OLD
% % marker-colored map of mimima
% minimiMask = minimi.*mask;
% 
% % compute label matching
% [labels, indexes] = unique(minimiWtr);
% labelsCorr = minimiMask(indexes);
% 
% % generate marker map
% wtr = wtr+1;
% out_1 = labelsCorr(wtr);
% 
% % optional clean
% if clean == 1
%     out_2 = out_1.*(out_1==mask);
% else
%     out_2 = out_1;
% end
% 
% % remove occasional junctions among markers obtained by landslide erosion
% % of adjacent pre-marker segments.
% c = doubledcontours(out_2);
% out_3 = out_2 .* not(c);
% 
% % generate output
% out = out_3>0;

% NEW
if (max(minimiWtr(:)) > max(mask(:))),
    L = 10^ceil(log10(max(minimiWtr(:))+1));
    ass1 = (mask + L.*minimiWtr).*minimi;
    ass2 = (mask + L.*wtr);
else
    L = 10^ceil(log10(max(mask(:))+1));
    ass1 = (L.*mask + minimiWtr).*minimi;
    ass2 = (L.*mask + wtr);
end

lbl = sparse(max(ass2(:)),1);
lbl(setdiff(unique(ass1),0)) = 1;
sfeMask = full(lbl(ass2)).*mask;

% Remove occasional junctions among markers obtained by landslide erosion
% of adjacent pre-marker segments.
c = doubledcontours(sfeMask);
if join == 0,
    % Output with priority to segmentation:
    % regions sharing a dem minimum (plateau) output separate markers
    out = ((sfeMask .* not(c)) > 0); 
else
    % Output with priority to watershed:
    % regions sharing a dem minimum (plateau) output separate markers
    out = ((sfeMask .* not(c)) > 0) | (minimi .* mask>0);
end
